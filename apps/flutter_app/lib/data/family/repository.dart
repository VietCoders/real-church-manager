// Family repository.
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/logging/logger.dart';
import '../../domain/family/entity.dart';
import '../../platform/pocketbase/client.dart';
import '../../platform/storage/adapter.dart';

class FamilyRepository {
  FamilyRepository();
  final _log = RealCmLogger.of('family.repo');
  static const _collection = 'families';
  Box<dynamic> get _cache => Hive.box<dynamic>(RealCmStorageAdapter.boxCacheFamilies);

  Future<List<Family>> list({String? districtId, String? search}) async {
    final pb = RealCmPocketBase.instance();
    final filters = <String>['deleted_at = null'];
    if (districtId != null && districtId.isNotEmpty) filters.add('district_id = "$districtId"');
    if (search != null && search.trim().isNotEmpty) {
      final q = search.replaceAll('"', '');
      filters.add('(family_name ~ "$q" || phone ~ "$q")');
    }
    final res = await pb.collection(_collection).getList(
      page: 1, perPage: 100, filter: filters.join(' && '), sort: '-updated',
    );
    final items = res.items.map((r) => Family.fromJson(r.toJson())).toList();
    for (final f in items) await _cache.put(f.id, f.toJson());
    return items;
  }

  Future<Family> getById(String id) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).getOne(id);
    return Family.fromJson(rec.toJson());
  }

  Future<Family> create(Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).create(body: data);
    _log.info('Tạo gia đình ${rec.id}');
    return Family.fromJson(rec.toJson());
  }

  Future<Family> update(String id, Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).update(id, body: data);
    return Family.fromJson(rec.toJson());
  }

  Future<void> softDelete(String id) async {
    final pb = RealCmPocketBase.instance();
    await pb.collection(_collection).update(id, body: {'deleted_at': DateTime.now().toIso8601String()});
  }

  Future<void Function()> subscribe(void Function(RecordSubscriptionEvent) cb) async {
    final pb = RealCmPocketBase.instance();
    return pb.collection(_collection).subscribe('*', cb);
  }
}
