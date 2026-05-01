// Member repository — wrap PocketBase + Hive cache + realtime subscription.
import 'dart:async';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../../core/logging/logger.dart';
import '../../domain/member/entity.dart';
import '../../platform/pocketbase/client.dart';
import '../../platform/storage/adapter.dart';

class MemberRepository {
  MemberRepository();

  final _log = RealCmLogger.of('member.repo');
  static const String _collection = 'members';

  Box<dynamic> get _cache => Hive.box<dynamic>(RealCmStorageAdapter.boxCacheMembers);

  Future<List<Member>> list({
    int page = 1,
    int perPage = 50,
    String? search,
    String? districtId,
    String? status,
    String? sort = '-updated',
  }) async {
    final pb = RealCmPocketBase.instance();
    final filters = <String>['deleted_at = null'];
    if (districtId != null && districtId.isNotEmpty) {
      filters.add('district_id = "$districtId"');
    }
    if (status != null && status.isNotEmpty) {
      filters.add('status = "$status"');
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.replaceAll('"', '');
      filters.add('(full_name ~ "$q" || saint_name ~ "$q" || phone ~ "$q")');
    }
    final res = await pb.collection(_collection).getList(
          page: page,
          perPage: perPage,
          filter: filters.join(' && '),
          sort: sort ?? '-updated',
        );
    final members = res.items.map((r) => Member.fromJson(r.toJson())).toList();
    // Cache list keys cho offline preview.
    for (final m in members) {
      await _cache.put(m.id, m.toJson());
    }
    return members;
  }

  Future<Member> getById(String id) async {
    try {
      final pb = RealCmPocketBase.instance();
      final rec = await pb.collection(_collection).getOne(id);
      final m = Member.fromJson(rec.toJson());
      await _cache.put(m.id, m.toJson());
      return m;
    } catch (e) {
      // Fallback offline cache
      final cached = _cache.get(id);
      if (cached is Map) {
        return Member.fromJson(Map<String, dynamic>.from(cached));
      }
      rethrow;
    }
  }

  Future<Member> create(Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).create(body: data);
    final m = Member.fromJson(rec.toJson());
    await _cache.put(m.id, m.toJson());
    _log.info('Tạo giáo dân ${m.id}: ${m.displayName}');
    return m;
  }

  Future<Member> update(String id, Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).update(id, body: data);
    final m = Member.fromJson(rec.toJson());
    await _cache.put(m.id, m.toJson());
    _log.info('Cập nhật giáo dân $id');
    return m;
  }

  /// Soft delete: đặt deleted_at thay vì DELETE physical (giữ history sổ Bí Tích).
  Future<void> softDelete(String id) async {
    final pb = RealCmPocketBase.instance();
    await pb.collection(_collection).update(id, body: {
      'deleted_at': DateTime.now().toIso8601String(),
    });
    await _cache.delete(id);
    _log.info('Soft-delete giáo dân $id');
  }

  /// Phát hiện trùng lặp giáo dân theo full_name + (birth_date hoặc saint_name).
  /// Dùng khi tạo mới để cảnh báo user trước.
  Future<List<Member>> findDuplicates({
    required String fullName,
    DateTime? birthDate,
    String? saintName,
    String? excludeId,
  }) async {
    if (fullName.trim().isEmpty) return [];
    final pb = RealCmPocketBase.instance();
    final q = fullName.replaceAll('"', '').trim();
    final filters = <String>['deleted_at = null', 'full_name ~ "$q"'];
    if (excludeId != null) filters.add('id != "$excludeId"');
    final res = await pb.collection(_collection).getList(
      page: 1,
      perPage: 20,
      filter: filters.join(' && '),
      sort: 'full_name',
    );
    final candidates = res.items.map((r) => Member.fromJson(r.toJson())).toList();
    // Lọc thêm theo birthDate hoặc saintName để giảm false positive
    return candidates.where((m) {
      final sameName = m.fullName.toLowerCase().trim() == fullName.toLowerCase().trim();
      if (!sameName) return false;
      if (birthDate != null && m.birthDate != null) {
        return m.birthDate!.year == birthDate.year &&
            m.birthDate!.month == birthDate.month &&
            m.birthDate!.day == birthDate.day;
      }
      if (saintName != null && saintName.isNotEmpty && m.saintName != null) {
        return m.saintName!.toLowerCase() == saintName.toLowerCase();
      }
      return true; // chỉ trùng tên đầy đủ → vẫn cảnh báo
    }).toList();
  }

  /// Subscribe realtime — return unsubscribe function.
  Future<void Function()> subscribe(void Function(RecordSubscriptionEvent) onEvent) async {
    final pb = RealCmPocketBase.instance();
    return pb.collection(_collection).subscribe('*', onEvent);
  }

  /// Upload photo cho member. Trả về Member updated.
  Future<Member> uploadPhoto(String memberId, File file) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).update(
      memberId,
      files: [http.MultipartFile.fromBytes('photo', await file.readAsBytes(), filename: file.path.split(Platform.pathSeparator).last)],
    );
    final m = Member.fromJson(rec.toJson());
    await _cache.put(m.id, m.toJson());
    _log.info('Upload photo cho member $memberId');
    return m;
  }

  /// Xoá photo (set photo='').
  Future<Member> removePhoto(String memberId) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).update(memberId, body: {'photo': null});
    final m = Member.fromJson(rec.toJson());
    await _cache.put(m.id, m.toJson());
    return m;
  }
}
