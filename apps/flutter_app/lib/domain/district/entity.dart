// District (giáo họ / giáo khu) entity.
import 'package:equatable/equatable.dart';

class District extends Equatable {
  const District({
    required this.id,
    required this.name,
    this.code,
    this.headMemberId,
    this.addressZone,
    this.notes,
    this.deletedAt,
    this.created,
    this.updated,
  });

  final String id;
  final String name;
  final String? code;
  final String? headMemberId;
  final String? addressZone;
  final String? notes;
  final DateTime? deletedAt;
  final DateTime? created;
  final DateTime? updated;

  factory District.fromJson(Map<String, dynamic> j) => District(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        code: j['code'] as String?,
        headMemberId: _e(j['head_member_id']),
        addressZone: j['address_zone'] as String?,
        notes: j['notes'] as String?,
        deletedAt: _d(j['deleted_at']),
        created: _d(j['created']),
        updated: _d(j['updated']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'head_member_id': headMemberId,
        'address_zone': addressZone,
        'notes': notes,
      }..removeWhere((k, v) => v == null);

  @override
  List<Object?> get props => [id, name, code, updated];

  static String? _e(dynamic v) => (v == null || v == '') ? null : v as String;
  static DateTime? _d(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
