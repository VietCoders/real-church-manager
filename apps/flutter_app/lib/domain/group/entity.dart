// Group (đoàn thể / hội đoàn) entity.
import 'package:equatable/equatable.dart';

enum RealCmGroupType { confraternity, youth, choir, pastoral, other }

class Group extends Equatable {
  const Group({
    required this.id,
    required this.name,
    required this.type,
    this.code,
    this.headMemberId,
    this.viceHeadMemberId,
    this.foundingDate,
    this.meetingSchedule,
    this.notes,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? code;
  final RealCmGroupType type;
  final String? headMemberId;
  final String? viceHeadMemberId;
  final DateTime? foundingDate;
  final String? meetingSchedule;
  final String? notes;
  final DateTime? deletedAt;

  factory Group.fromJson(Map<String, dynamic> j) => Group(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        code: j['code'] as String?,
        type: _parseType(j['type'] as String?),
        headMemberId: _e(j['head_member_id']),
        viceHeadMemberId: _e(j['vice_head_member_id']),
        foundingDate: _d(j['founding_date']),
        meetingSchedule: j['meeting_schedule'] as String?,
        notes: j['notes'] as String?,
        deletedAt: _d(j['deleted_at']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'type': type.name,
        'head_member_id': headMemberId,
        'vice_head_member_id': viceHeadMemberId,
        'founding_date': foundingDate?.toIso8601String(),
        'meeting_schedule': meetingSchedule,
        'notes': notes,
      }..removeWhere((k, v) => v == null);

  @override
  List<Object?> get props => [id, name, type];

  static RealCmGroupType _parseType(String? s) {
    if (s == null) return RealCmGroupType.other;
    return RealCmGroupType.values.firstWhere((e) => e.name == s, orElse: () => RealCmGroupType.other);
  }

  static String? _e(dynamic v) => (v == null || v == '') ? null : v as String;
  static DateTime? _d(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
