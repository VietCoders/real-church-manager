// Baptism record (Sổ Rửa Tội).
import 'package:equatable/equatable.dart';

class Baptism extends Equatable {
  const Baptism({
    required this.id,
    required this.memberId,
    required this.baptismDate,
    required this.priestName,
    this.bookNumber,
    this.baptismPlace,
    this.godfatherName,
    this.godmotherName,
    this.godfatherId,
    this.godmotherId,
    this.fatherName,
    this.motherName,
    this.notes,
    this.created,
    this.updated,
  });

  final String id;
  final String? bookNumber;
  final String memberId;
  final DateTime baptismDate;
  final String? baptismPlace;
  final String priestName;
  final String? godfatherName;
  final String? godmotherName;
  final String? godfatherId;
  final String? godmotherId;
  final String? fatherName;
  final String? motherName;
  final String? notes;
  final DateTime? created;
  final DateTime? updated;

  factory Baptism.fromJson(Map<String, dynamic> j) => Baptism(
        id: j['id'] as String,
        bookNumber: j['book_number'] as String?,
        memberId: (j['member_id'] as String?) ?? '',
        baptismDate: DateTime.parse(j['baptism_date'] as String),
        baptismPlace: j['baptism_place'] as String?,
        priestName: (j['priest_name'] as String?) ?? '',
        godfatherName: j['godfather_name'] as String?,
        godmotherName: j['godmother_name'] as String?,
        godfatherId: _e(j['godfather_id']),
        godmotherId: _e(j['godmother_id']),
        fatherName: j['father_name'] as String?,
        motherName: j['mother_name'] as String?,
        notes: j['notes'] as String?,
        created: _d(j['created']),
        updated: _d(j['updated']),
      );

  Map<String, dynamic> toJson() => {
        'book_number': bookNumber,
        'member_id': memberId,
        'baptism_date': baptismDate.toIso8601String(),
        'baptism_place': baptismPlace,
        'priest_name': priestName,
        'godfather_name': godfatherName,
        'godmother_name': godmotherName,
        'godfather_id': godfatherId,
        'godmother_id': godmotherId,
        'father_name': fatherName,
        'mother_name': motherName,
        'notes': notes,
      }..removeWhere((k, v) => v == null);

  @override
  List<Object?> get props => [id, memberId, baptismDate, bookNumber];

  static String? _e(dynamic v) => (v == null || v == '') ? null : v as String;
  static DateTime? _d(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
