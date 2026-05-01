// Offline queue + sync service.
// Khi PB request lỗi network: enqueue (collection, op, data) vào Hive box.
// Khi connectivity_plus báo online: drain queue + retry.
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/logger.dart';
import '../pocketbase/client.dart';
import '../storage/adapter.dart';

enum SyncOp { create, update, delete }

class _PendingItem {
  _PendingItem({
    required this.id,
    required this.collection,
    required this.op,
    this.recordId,
    this.body,
  });

  final String id; // queue key
  final String collection;
  final SyncOp op;
  final String? recordId;
  final Map<String, dynamic>? body;

  Map<String, dynamic> toJson() => {
        'id': id,
        'collection': collection,
        'op': op.name,
        'record_id': recordId,
        'body': body,
      };

  factory _PendingItem.fromJson(Map raw) {
    final m = Map<String, dynamic>.from(raw);
    return _PendingItem(
      id: m['id'] as String,
      collection: m['collection'] as String,
      op: SyncOp.values.firstWhere((e) => e.name == m['op'], orElse: () => SyncOp.update),
      recordId: m['record_id'] as String?,
      body: (m['body'] as Map?)?.cast<String, dynamic>(),
    );
  }
}

class RealCmSyncQueue {
  RealCmSyncQueue._();
  static final _log = RealCmLogger.of('sync.queue');
  static final RealCmSyncQueue instance = RealCmSyncQueue._();

  StreamSubscription? _connSub;
  bool _draining = false;

  /// Bắt đầu listen connectivity. Gọi 1 lần khi app start sau khi auth ready.
  void start() {
    _connSub?.cancel();
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final hasNet = results.any((r) => r != ConnectivityResult.none);
      if (hasNet) {
        _log.info('Online detected, drain queue (pending=${pendingCount()})');
        unawaited(drain());
      }
    });
  }

  void stop() {
    _connSub?.cancel();
    _connSub = null;
  }

  int pendingCount() => RealCmStorageAdapter.offlineQueue().length;

  Future<void> enqueueCreate(String collection, Map<String, dynamic> body) async {
    final box = RealCmStorageAdapter.offlineQueue();
    final id = 'q_${DateTime.now().microsecondsSinceEpoch}';
    final item = _PendingItem(id: id, collection: collection, op: SyncOp.create, body: body);
    await box.put(id, item.toJson());
    _log.info('Enqueue CREATE $collection (id=$id)');
  }

  Future<void> enqueueUpdate(String collection, String recordId, Map<String, dynamic> body) async {
    final box = RealCmStorageAdapter.offlineQueue();
    final id = 'q_${DateTime.now().microsecondsSinceEpoch}';
    final item = _PendingItem(id: id, collection: collection, op: SyncOp.update, recordId: recordId, body: body);
    await box.put(id, item.toJson());
    _log.info('Enqueue UPDATE $collection/$recordId (id=$id)');
  }

  Future<void> enqueueDelete(String collection, String recordId) async {
    final box = RealCmStorageAdapter.offlineQueue();
    final id = 'q_${DateTime.now().microsecondsSinceEpoch}';
    final item = _PendingItem(id: id, collection: collection, op: SyncOp.delete, recordId: recordId);
    await box.put(id, item.toJson());
    _log.info('Enqueue DELETE $collection/$recordId (id=$id)');
  }

  /// Thử đẩy hết queue. Gọi khi online hoặc khi user click "Đồng bộ".
  Future<int> drain() async {
    if (_draining) return 0;
    _draining = true;
    final box = RealCmStorageAdapter.offlineQueue();
    int success = 0;
    try {
      final keys = box.keys.toList();
      for (final key in keys) {
        final raw = box.get(key);
        if (raw is! Map) {
          await box.delete(key);
          continue;
        }
        final item = _PendingItem.fromJson(raw);
        try {
          final pb = RealCmPocketBase.instance();
          final col = pb.collection(item.collection);
          switch (item.op) {
            case SyncOp.create:
              await col.create(body: item.body ?? {});
              break;
            case SyncOp.update:
              if (item.recordId != null) {
                await col.update(item.recordId!, body: item.body ?? {});
              }
              break;
            case SyncOp.delete:
              if (item.recordId != null) {
                await col.delete(item.recordId!);
              }
              break;
          }
          await box.delete(key);
          success++;
        } catch (e) {
          _log.warning('Drain ${item.id} thất bại: $e — giữ trong queue, retry sau');
          // Stop drain to avoid hammering offline server
          break;
        }
      }
    } finally {
      _draining = false;
    }
    if (success > 0) _log.info('Drained $success item');
    return success;
  }
}

/// Riverpod provider để UI watch số pending.
final pendingSyncCountProvider = StateProvider<int>((_) => RealCmSyncQueue.instance.pendingCount());

class PendingItemView {
  PendingItemView({required this.id, required this.collection, required this.op, this.recordId, this.body});
  final String id;
  final String collection;
  final SyncOp op;
  final String? recordId;
  final Map<String, dynamic>? body;
}

extension RealCmSyncQueueQuery on RealCmSyncQueue {
  List<PendingItemView> listPending() {
    final box = RealCmStorageAdapter.offlineQueue();
    final items = <PendingItemView>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      try {
        final m = Map<String, dynamic>.from(raw);
        items.add(PendingItemView(
          id: m['id'].toString(),
          collection: m['collection'].toString(),
          op: SyncOp.values.firstWhere((e) => e.name == m['op'], orElse: () => SyncOp.update),
          recordId: m['record_id'] as String?,
          body: (m['body'] as Map?)?.cast<String, dynamic>(),
        ));
      } catch (_) {}
    }
    return items;
  }

  Future<void> removeItem(String id) async {
    await RealCmStorageAdapter.offlineQueue().delete(id);
  }
}
