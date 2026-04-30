// Member entity — không phụ thuộc PocketBase, chỉ data thuần.
import 'package:equatable/equatable.dart';

enum RealCmGender { male, female, other }

enum RealCmMemberStatus { active, movedOut, deceased, excommunicated }

class Member extends Equatable {
  const Member({
    required this.id,
    required this.fullName,
    this.saintName,
    this.gender,
    this.birthDate,
    this.birthPlace,
    this.deathDate,
    this.districtId,
    this.familyId,
    this.fatherId,
    this.motherId,
    this.fatherNameText,
    this.motherNameText,
    this.spouseId,
    this.phone,
    this.email,
    this.address,
    this.photo,
    this.idNumber,
    this.baptismDate,
    this.baptismId,
    this.confirmationDate,
    this.confirmationId,
    this.marriageDate,
    this.marriageId,
    this.funeralId,
    this.notes,
    this.tags,
    this.status = RealCmMemberStatus.active,
    this.deletedAt,
    this.created,
    this.updated,
  });

  final String id;
  final String? saintName;
  final String fullName;
  final RealCmGender? gender;
  final DateTime? birthDate;
  final String? birthPlace;
  final DateTime? deathDate;
  final String? districtId;
  final String? familyId;
  final String? fatherId;
  final String? motherId;
  final String? fatherNameText;
  final String? motherNameText;
  final String? spouseId;
  final String? phone;
  final String? email;
  final String? address;
  final String? photo;
  final String? idNumber;
  final DateTime? baptismDate;
  final String? baptismId;
  final DateTime? confirmationDate;
  final String? confirmationId;
  final DateTime? marriageDate;
  final String? marriageId;
  final String? funeralId;
  final String? notes;
  final List<String>? tags;
  final RealCmMemberStatus status;
  final DateTime? deletedAt;
  final DateTime? created;
  final DateTime? updated;

  /// Tên hiển thị: "Tên Thánh + Họ Tên" theo cách Công giáo VN.
  String get displayName {
    if (saintName != null && saintName!.isNotEmpty) {
      return '$saintName $fullName';
    }
    return fullName;
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      saintName: json['saint_name'] as String?,
      fullName: (json['full_name'] as String?) ?? '',
      gender: _parseGender(json['gender'] as String?),
      birthDate: _parseDate(json['birth_date']),
      birthPlace: json['birth_place'] as String?,
      deathDate: _parseDate(json['death_date']),
      districtId: _emptyToNull(json['district_id'] as String?),
      familyId: _emptyToNull(json['family_id'] as String?),
      fatherId: _emptyToNull(json['father_id'] as String?),
      motherId: _emptyToNull(json['mother_id'] as String?),
      fatherNameText: json['father_name_text'] as String?,
      motherNameText: json['mother_name_text'] as String?,
      spouseId: _emptyToNull(json['spouse_id'] as String?),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      photo: json['photo'] as String?,
      idNumber: json['id_number'] as String?,
      baptismDate: _parseDate(json['baptism_date']),
      baptismId: _emptyToNull(json['baptism_id'] as String?),
      confirmationDate: _parseDate(json['confirmation_date']),
      confirmationId: _emptyToNull(json['confirmation_id'] as String?),
      marriageDate: _parseDate(json['marriage_date']),
      marriageId: _emptyToNull(json['marriage_id'] as String?),
      funeralId: _emptyToNull(json['funeral_id'] as String?),
      notes: json['notes'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
      status: _parseStatus(json['status'] as String?),
      deletedAt: _parseDate(json['deleted_at']),
      created: _parseDate(json['created']),
      updated: _parseDate(json['updated']),
    );
  }

  Map<String, dynamic> toJson() => {
        'saint_name': saintName,
        'full_name': fullName,
        'gender': gender?.name,
        'birth_date': birthDate?.toIso8601String(),
        'birth_place': birthPlace,
        'death_date': deathDate?.toIso8601String(),
        'district_id': districtId,
        'family_id': familyId,
        'father_id': fatherId,
        'mother_id': motherId,
        'father_name_text': fatherNameText,
        'mother_name_text': motherNameText,
        'spouse_id': spouseId,
        'phone': phone,
        'email': email,
        'address': address,
        'id_number': idNumber,
        'notes': notes,
        'tags': tags,
        'status': status.name == 'movedOut' ? 'moved_out' : status.name,
      }..removeWhere((key, value) => value == null);

  @override
  List<Object?> get props => [id, saintName, fullName, gender, status, updated];

  static RealCmGender? _parseGender(String? s) {
    if (s == null || s.isEmpty) return null;
    return RealCmGender.values.firstWhere(
      (e) => e.name == s,
      orElse: () => RealCmGender.other,
    );
  }

  static RealCmMemberStatus _parseStatus(String? s) {
    if (s == null || s.isEmpty) return RealCmMemberStatus.active;
    if (s == 'moved_out') return RealCmMemberStatus.movedOut;
    return RealCmMemberStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => RealCmMemberStatus.active,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  static String? _emptyToNull(String? s) => (s == null || s.isEmpty) ? null : s;
}
