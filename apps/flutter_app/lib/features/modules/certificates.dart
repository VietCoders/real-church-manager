// Certificate printers — fetch member + parish, build PDF, print preview.
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../platform/pdf/builder.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/toast/service.dart';

class _ParishInfo {
  const _ParishInfo({required this.name, required this.address});
  final String name;
  final String address;
}

Future<_ParishInfo> _fetchParish() async {
  final pb = RealCmPocketBase.instance();
  try {
    final res = await pb.collection('parish_settings').getList(page: 1, perPage: 1);
    if (res.items.isEmpty) {
      return const _ParishInfo(name: 'Giáo xứ', address: '');
    }
    final d = res.items.first.data;
    return _ParishInfo(
      name: (d['name'] ?? d['parish_name'] ?? 'Giáo xứ').toString(),
      address: (d['address'] ?? d['parish_address'] ?? '').toString(),
    );
  } catch (_) {
    return const _ParishInfo(name: 'Giáo xứ', address: '');
  }
}

Future<RecordModel?> _fetchMember(String? id) async {
  if (id == null || id.isEmpty) return null;
  try {
    final pb = RealCmPocketBase.instance();
    return await pb.collection('members').getOne(id);
  } catch (_) {
    return null;
  }
}

String _memberName(RecordModel? m) {
  if (m == null) return '';
  final saint = (m.data['saint_name'] ?? '').toString();
  final full = (m.data['full_name'] ?? '').toString();
  return saint.isEmpty ? full : '$saint $full';
}

DateTime? _parseDate(dynamic v) {
  if (v == null || v.toString().isEmpty) return null;
  return DateTime.tryParse(v.toString());
}

// ─── Public printers ──────────────────────────────────────

Future<void> printBaptismCertificate(BuildContext ctx, RecordModel rec) async {
  final parish = await _fetchParish();
  final member = await _fetchMember(rec.data['member_id']?.toString());
  final doc = await RealCmCertificateBuilder.baptism(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    memberFullName: (member?.data['full_name'] ?? '').toString(),
    memberSaintName: (member?.data['saint_name'] ?? '').toString(),
    memberBirthDate: _parseDate(member?.data['birth_date']),
  );
  await RealCmCertificateBuilder.printDocument(doc, jobName: 'Chứng chỉ Rửa Tội');
}

Future<void> printConfirmationCertificate(BuildContext ctx, RecordModel rec) async {
  final parish = await _fetchParish();
  final member = await _fetchMember(rec.data['member_id']?.toString());
  final doc = await RealCmCertificateBuilder.confirmation(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    memberFullName: _memberName(member),
  );
  await RealCmCertificateBuilder.printDocument(doc, jobName: 'Chứng chỉ Thêm Sức');
}

Future<void> printMarriageCertificate(BuildContext ctx, RecordModel rec) async {
  final parish = await _fetchParish();
  final groom = await _fetchMember(rec.data['groom_id']?.toString());
  final bride = await _fetchMember(rec.data['bride_id']?.toString());
  final doc = await RealCmCertificateBuilder.marriage(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    groomFullName: _memberName(groom),
    brideFullName: _memberName(bride),
  );
  await RealCmCertificateBuilder.printDocument(doc, jobName: 'Chứng chỉ Hôn Phối');
}

Future<void> printAnointingCertificate(BuildContext ctx, RecordModel rec) async {
  final parish = await _fetchParish();
  final member = await _fetchMember(rec.data['member_id']?.toString());
  final doc = await RealCmCertificateBuilder.anointing(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    memberFullName: _memberName(member),
  );
  await RealCmCertificateBuilder.printDocument(doc, jobName: 'Chứng chỉ Xức Dầu');
}

Future<void> printFuneralCertificate(BuildContext ctx, RecordModel rec) async {
  final parish = await _fetchParish();
  final member = await _fetchMember(rec.data['member_id']?.toString());
  final doc = await RealCmCertificateBuilder.funeral(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    memberFullName: _memberName(member),
  );
  await RealCmCertificateBuilder.printDocument(doc, jobName: 'Chứng chỉ An Táng');
}
