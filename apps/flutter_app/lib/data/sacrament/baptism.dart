// Baptism repository — pattern canonical cho 5 sổ Bí Tích.
// Confirmation/Marriage/Anointing/Funeral repository follow cùng pattern này.
import 'package:pocketbase/pocketbase.dart';
import '../../core/logging/logger.dart';
import '../../domain/sacrament/baptism.dart';
import '../../platform/pocketbase/client.dart';

class BaptismRepository {
  BaptismRepository();
  final _log = RealCmLogger.of('baptism.repo');
  static const _collection = 'sacrament_baptism';

  Future<List<Baptism>> list({String? memberId, String? search, int year = 0}) async {
    final pb = RealCmPocketBase.instance();
    final filters = <String>[];
    if (memberId != null) filters.add('member_id = "$memberId"');
    if (year > 0) {
      filters.add('baptism_date >= "$year-01-01" && baptism_date <= "$year-12-31"');
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.replaceAll('"', '');
      filters.add('(book_number ~ "$q" || priest_name ~ "$q")');
    }
    final res = await pb.collection(_collection).getList(
      page: 1, perPage: 100,
      filter: filters.isEmpty ? null : filters.join(' && '),
      sort: '-baptism_date',
      expand: 'member_id',
    );
    return res.items.map((r) => Baptism.fromJson(r.toJson())).toList();
  }

  Future<Baptism> getById(String id) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).getOne(id, expand: 'member_id,godfather_id,godmother_id');
    return Baptism.fromJson(rec.toJson());
  }

  Future<Baptism> create(Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).create(body: data);
    _log.info('Tạo Rửa Tội ${rec.id}');
    return Baptism.fromJson(rec.toJson());
  }

  Future<Baptism> update(String id, Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    final rec = await pb.collection(_collection).update(id, body: data);
    return Baptism.fromJson(rec.toJson());
  }

  Future<void> delete(String id) async {
    final pb = RealCmPocketBase.instance();
    await pb.collection(_collection).delete(id);
    _log.info('Xoá Rửa Tội $id');
  }
}
