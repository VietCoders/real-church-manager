// Safe PB write wrapper — catch network error → enqueue + trả lỗi cho UI biết là offline.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import 'queue.dart';

class OfflineQueuedException implements Exception {
  OfflineQueuedException(this.message);
  final String message;
  @override
  String toString() => message;
}

bool _isNetworkError(Object e) {
  if (e is SocketException) return true;
  if (e is HttpException) return true;
  if (e is ClientException) {
    final inner = e.originalError;
    if (inner is SocketException) return true;
    final msg = e.toString().toLowerCase();
    return msg.contains('failed host lookup') ||
        msg.contains('connection refused') ||
        msg.contains('connection closed') ||
        msg.contains('network is unreachable') ||
        msg.contains('connection timed out') ||
        msg.contains('software caused connection abort');
  }
  return false;
}

/// Tạo record. Nếu mất mạng → enqueue + throw OfflineQueuedException để UI hiển thị "Đã lưu offline".
Future<RecordModel?> safePbCreate(
  PocketBase pb,
  String collection,
  Map<String, dynamic> body,
) async {
  try {
    return await pb.collection(collection).create(body: body);
  } catch (e) {
    if (_isNetworkError(e)) {
      await RealCmSyncQueue.instance.enqueueCreate(collection, body);
      throw OfflineQueuedException('Đã lưu nháp — sẽ tự đồng bộ khi có mạng.');
    }
    rethrow;
  }
}

Future<RecordModel?> safePbUpdate(
  PocketBase pb,
  String collection,
  String recordId,
  Map<String, dynamic> body,
) async {
  try {
    return await pb.collection(collection).update(recordId, body: body);
  } catch (e) {
    if (_isNetworkError(e)) {
      await RealCmSyncQueue.instance.enqueueUpdate(collection, recordId, body);
      throw OfflineQueuedException('Đã lưu nháp — sẽ tự đồng bộ khi có mạng.');
    }
    rethrow;
  }
}

Future<void> safePbDelete(
  PocketBase pb,
  String collection,
  String recordId,
) async {
  try {
    await pb.collection(collection).delete(recordId);
  } catch (e) {
    if (_isNetworkError(e)) {
      await RealCmSyncQueue.instance.enqueueDelete(collection, recordId);
      throw OfflineQueuedException('Đã lưu yêu cầu xoá — sẽ tự đồng bộ khi có mạng.');
    }
    rethrow;
  }
}

/// Bump pending count provider sau enqueue/drain.
void bumpPendingDebug(String tag) {
  if (kDebugMode) {
    debugPrint('[sync] $tag, pending=${RealCmSyncQueue.instance.pendingCount()}');
  }
}
