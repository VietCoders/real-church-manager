// District repository.
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/logging/logger.dart';
import '../../domain/district/entity.dart';
import '../../platform/pocketbase/client.dart';
import '../../platform/storage/adapter.dart';

class DistrictRepository {
  DistrictRepository();
  final _log = RealCmLogger.of('district.repo');
  static const _collection = 'districts';
  Box<dynamic> get _cache => Hive.box<dynamic>(RealCmStorageAdapter.boxCacheDistricts);

  Future<List<District>> list({String? search}) async {
    final pb = RealCmPocketBase.instance();
    final filters = <String>['deleted_at = null'];
    if (search != null && search.trim().isNotEmpty) {
      final q = search.replaceAll('"', '');
      filters.add('(name ~ "$q" || code ~ "$q")');
    }
    final res = await pb.collection(_collection).getList(
      page: 1, perPage: 200, filter: filters.join(' && '), sort: 'name',
    );
    final items = res.items.map((r) => District.fromJson(r.toJson())).toList();
    for (final d in items) await _cache.put(d.id, d.toJson());
    return items;
  }

  Future<District> getById(String id) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).getOne(id);
    return District.fromJson(rec.toJson());
  }

  Future<District> create(Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).create(body: data);
    _log.info('Tạo giáo họ ${rec.id}');
    return District.fromJson(rec.toJson());
  }

  Future<District> update(String id, Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).update(id, body: data);
    return District.fromJson(rec.toJson());
  }

  Future<void> softDelete(String id) async {
    final pb = RealCmPocketBase.instance();
    await pb.collection(_collection).update(id, body: {'deleted_at': DateTime.now().toIso8601String()});
  }
}
