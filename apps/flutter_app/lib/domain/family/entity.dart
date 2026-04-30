// Family entity.
import 'package:equatable/equatable.dart';

class Family extends Equatable {
  const Family({
    required this.id,
    required this.headId,
    this.familyName,
    this.districtId,
    this.address,
    this.phone,
    this.notes,
    this.deletedAt,
    this.created,
    this.updated,
  });

  final String id;
  final String? familyName;
  final String headId;
  final String? districtId;
  final String? address;
  final String? phone;
  final String? notes;
  final DateTime? deletedAt;
  final DateTime? created;
  final DateTime? updated;

  factory Family.fromJson(Map<String, dynamic> j) => Family(
        id: j['id'] as String,
        familyName: j['family_name'] as String?,
        headId: (j['head_id'] as String?) ?? '',
        districtId: _e(j['district_id']),
        address: j['address'] as String?,
        phone: j['phone'] as String?,
        notes: j['notes'] as String?,
        deletedAt: _d(j['deleted_at']),
        created: _d(j['created']),
        updated: _d(j['updated']),
      );

  Map<String, dynamic> toJson() => {
        'family_name': familyName,
        'head_id': headId,
        'district_id': districtId,
        'address': address,
        'phone': phone,
        'notes': notes,
      }..removeWhere((k, v) => v == null);

  @override
  List<Object?> get props => [id, headId, familyName, updated];

  static String? _e(dynamic v) => (v == null || v == '') ? null : v as String;
  static DateTime? _d(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
