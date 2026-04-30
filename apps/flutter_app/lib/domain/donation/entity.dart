// Donation (sổ thu chi) entity.
import 'package:equatable/equatable.dart';

enum RealCmDonationType {
  sundayOffering,    // sunday_offering
  feastOffering,     // feast_offering
  buildingFund,      // building_fund
  massIntention,     // mass_intention
  otherIn,           // other_in
  expense,           // expense
}

class Donation extends Equatable {
  const Donation({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    this.currency = 'VND',
    this.donorName,
    this.donorMemberId,
    this.familyId,
    this.description,
    this.receiptNo,
    this.notes,
  });

  final String id;
  final DateTime date;
  final RealCmDonationType type;
  final double amount;
  final String currency;
  final String? donorName;
  final String? donorMemberId;
  final String? familyId;
  final String? description;
  final String? receiptNo;
  final String? notes;

  bool get isExpense => type == RealCmDonationType.expense;

  factory Donation.fromJson(Map<String, dynamic> j) => Donation(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        type: _parseType(j['type'] as String?),
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        currency: (j['currency'] as String?) ?? 'VND',
        donorName: j['donor_name'] as String?,
        donorMemberId: _e(j['donor_member_id']),
        familyId: _e(j['family_id']),
        description: j['description'] as String?,
        receiptNo: j['receipt_no'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'type': _typeToWire(type),
        'amount': amount,
        'currency': currency,
        'donor_name': donorName,
        'donor_member_id': donorMemberId,
        'family_id': familyId,
        'description': description,
        'receipt_no': receiptNo,
        'notes': notes,
      }..removeWhere((k, v) => v == null);

  @override
  List<Object?> get props => [id, date, type, amount];

  static RealCmDonationType _parseType(String? s) {
    switch (s) {
      case 'sunday_offering': return RealCmDonationType.sundayOffering;
      case 'feast_offering': return RealCmDonationType.feastOffering;
      case 'building_fund': return RealCmDonationType.buildingFund;
      case 'mass_intention': return RealCmDonationType.massIntention;
      case 'other_in': return RealCmDonationType.otherIn;
      case 'expense': return RealCmDonationType.expense;
      default: return RealCmDonationType.otherIn;
    }
  }

  static String _typeToWire(RealCmDonationType t) {
    switch (t) {
      case RealCmDonationType.sundayOffering: return 'sunday_offering';
      case RealCmDonationType.feastOffering: return 'feast_offering';
      case RealCmDonationType.buildingFund: return 'building_fund';
      case RealCmDonationType.massIntention: return 'mass_intention';
      case RealCmDonationType.otherIn: return 'other_in';
      case RealCmDonationType.expense: return 'expense';
    }
  }

  static String? _e(dynamic v) => (v == null || v == '') ? null : v as String;
}
