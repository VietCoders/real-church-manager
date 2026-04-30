// Stats repository — aggregation queries cho dashboard widgets.
// PocketBase REST API filter/perPage để đếm + group by client-side khi cần.
import 'package:pocketbase/pocketbase.dart';

import '../../core/logging/logger.dart';
import '../../platform/pocketbase/client.dart';

class StatsRepository {
  StatsRepository();
  final _log = RealCmLogger.of('stats.repo');

  /// Tổng giáo dân (đang hoạt động, chưa qua đời, chưa xoá).
  Future<int> totalActiveMembers() async {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection('members').getList(
          page: 1,
          perPage: 1,
          filter: 'deleted_at = null && status = "active"',
        );
    return res.totalItems;
  }

  /// Tổng gia đình.
  Future<int> totalFamilies() async {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection('families').getList(
          page: 1,
          perPage: 1,
          filter: 'deleted_at = null',
        );
    return res.totalItems;
  }

  /// Tổng giáo họ.
  Future<int> totalDistricts() async {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection('districts').getList(
          page: 1,
          perPage: 1,
          filter: 'deleted_at = null',
        );
    return res.totalItems;
  }

  /// Số rửa tội trong năm hiện tại.
  Future<int> baptismsThisYear() async {
    final pb = RealCmPocketBase.instance();
    final yr = DateTime.now().year;
    final res = await pb.collection('sacrament_baptism').getList(
          page: 1,
          perPage: 1,
          filter: 'baptism_date >= "$yr-01-01" && baptism_date <= "$yr-12-31"',
        );
    return res.totalItems;
  }

  /// Số hôn phối trong năm hiện tại.
  Future<int> marriagesThisYear() async {
    final pb = RealCmPocketBase.instance();
    final yr = DateTime.now().year;
    final res = await pb.collection('sacrament_marriage').getList(
          page: 1,
          perPage: 1,
          filter: 'marriage_date >= "$yr-01-01" && marriage_date <= "$yr-12-31"',
        );
    return res.totalItems;
  }

  /// Số an táng trong năm.
  Future<int> funeralsThisYear() async {
    final pb = RealCmPocketBase.instance();
    final yr = DateTime.now().year;
    final res = await pb.collection('sacrament_funeral').getList(
          page: 1,
          perPage: 1,
          filter: 'funeral_date >= "$yr-01-01" && funeral_date <= "$yr-12-31"',
        );
    return res.totalItems;
  }

  /// Phân bổ giáo dân theo nhóm tuổi.
  /// Trả về: {0-12: n, 13-18: n, 19-30: n, 31-60: n, 60+: n}
  Future<Map<String, int>> membersByAgeGroup() async {
    final pb = RealCmPocketBase.instance();
    // Lấy max 1000 record để đếm; production lớn nên có endpoint stats riêng.
    final res = await pb.collection('members').getList(
          page: 1,
          perPage: 1000,
          filter: 'deleted_at = null && status = "active"',
          fields: 'id,birth_date',
        );
    final now = DateTime.now();
    final buckets = <String, int>{
      '0-12': 0,
      '13-18': 0,
      '19-30': 0,
      '31-60': 0,
      '60+': 0,
      'Không rõ': 0,
    };
    for (final r in res.items) {
      final birthRaw = r.data['birth_date'];
      if (birthRaw == null || birthRaw.toString().isEmpty) {
        buckets['Không rõ'] = buckets['Không rõ']! + 1;
        continue;
      }
      final birth = DateTime.tryParse(birthRaw.toString());
      if (birth == null) {
        buckets['Không rõ'] = buckets['Không rõ']! + 1;
        continue;
      }
      final age = now.year - birth.year - ((now.month < birth.month || (now.month == birth.month && now.day < birth.day)) ? 1 : 0);
      if (age < 0) {
        buckets['Không rõ'] = buckets['Không rõ']! + 1;
      } else if (age <= 12) {
        buckets['0-12'] = buckets['0-12']! + 1;
      } else if (age <= 18) {
        buckets['13-18'] = buckets['13-18']! + 1;
      } else if (age <= 30) {
        buckets['19-30'] = buckets['19-30']! + 1;
      } else if (age <= 60) {
        buckets['31-60'] = buckets['31-60']! + 1;
      } else {
        buckets['60+'] = buckets['60+']! + 1;
      }
    }
    return buckets;
  }

  /// Phân bổ theo giới tính.
  Future<Map<String, int>> membersByGender() async {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection('members').getList(
          page: 1,
          perPage: 1,
          filter: 'deleted_at = null && status = "active"',
        );
    final total = res.totalItems;
    if (total == 0) return {'male': 0, 'female': 0, 'other': 0};

    Future<int> countOf(String gender) async {
      final r = await pb.collection('members').getList(
            page: 1,
            perPage: 1,
            filter: 'deleted_at = null && status = "active" && gender = "$gender"',
          );
      return r.totalItems;
    }

    final male = await countOf('male');
    final female = await countOf('female');
    final other = total - male - female;
    return {'male': male, 'female': female, 'other': other};
  }

  /// Sinh nhật sắp tới trong N ngày tới.
  Future<List<RecordModel>> upcomingBirthdays({int withinDays = 30}) async {
    final pb = RealCmPocketBase.instance();
    final now = DateTime.now();
    final end = now.add(Duration(days: withinDays));
    final mmddNow = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final mmddEnd = '${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    // Filter qua substring birth_date (yyyy-mm-dd format) — heuristic, lấy 100 record gần nhất.
    // Production: cần PB hook custom hoặc index riêng; hiện tại dùng client-side filter.
    final res = await pb.collection('members').getList(
          page: 1,
          perPage: 200,
          filter: 'deleted_at = null && status = "active" && birth_date != ""',
          sort: 'full_name',
        );
    final result = <RecordModel>[];
    for (final r in res.items) {
      final raw = r.data['birth_date']?.toString() ?? '';
      if (raw.length < 10) continue;
      final mmdd = raw.substring(5, 10); // MM-DD
      final inRange = mmddNow.compareTo(mmddEnd) <= 0
          ? (mmdd.compareTo(mmddNow) >= 0 && mmdd.compareTo(mmddEnd) <= 0)
          : (mmdd.compareTo(mmddNow) >= 0 || mmdd.compareTo(mmddEnd) <= 0);
      if (inRange) result.add(r);
    }
    result.sort((a, b) {
      final ma = (a.data['birth_date']?.toString() ?? '').substring(5);
      final mb = (b.data['birth_date']?.toString() ?? '').substring(5);
      return ma.compareTo(mb);
    });
    return result;
  }

  /// Bí Tích gần nhất (mới tạo).
  Future<List<RecordModel>> recentBaptisms({int limit = 5}) async {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection('sacrament_baptism').getList(
          page: 1,
          perPage: limit,
          sort: '-baptism_date',
          expand: 'member_id',
        );
    return res.items;
  }
}
