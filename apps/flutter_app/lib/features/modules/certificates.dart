// Certificate printers — fetch member + parish, build PDF, mở preview screen.
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../platform/pdf/builder.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/pdf/preview_screen.dart';
import '../../ui/toast/service.dart';

Future<void> _logPrint({
  required String sacramentType,
  required String sacramentRecordId,
  String? memberId,
}) async {
  try {
    final pb = RealCmPocketBase.instance();
    await pb.collection('cert_print_logs').create(body: {
      'sacrament_type': sacramentType,
      'sacrament_record_id': sacramentRecordId,
      if (memberId != null) 'member_id': memberId,
      if (pb.authStore.record != null) 'user_id': pb.authStore.record!.id,
    });
  } catch (_) {
    // Fire-and-forget — không ảnh hưởng UX nếu fail
  }
}

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

bool _validate(BuildContext ctx, Map<String, dynamic> data, List<String> requiredFields) {
  final missing = <String>[];
  for (final f in requiredFields) {
    final v = data[f];
    if (v == null || v.toString().trim().isEmpty) missing.add(f);
  }
  if (missing.isEmpty) return true;
  realCmToast(ctx, 'Thiếu dữ liệu bắt buộc: ${missing.join(", ")}', type: RealCmToastType.error);
  return false;
}

// ─── Public printers ──────────────────────────────────────

Future<void> printBaptismCertificate(BuildContext ctx, RecordModel rec) async {
  if (!_validate(ctx, rec.data, ['member_id', 'baptism_date', 'priest_name'])) return;
  final parish = await _fetchParish();
  final member = await _fetchMember(rec.data['member_id']?.toString());
  if (member == null) {
    if (ctx.mounted) realCmToast(ctx, 'Không tìm thấy giáo dân tương ứng', type: RealCmToastType.error);
    return;
  }
  final doc = await RealCmCertificateBuilder.baptism(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    memberFullName: (member.data['full_name'] ?? '').toString(),
    memberSaintName: (member.data['saint_name'] ?? '').toString(),
    memberBirthDate: _parseDate(member.data['birth_date']),
  );
  if (ctx.mounted) await realCmShowPdfPreview(ctx, title: 'Chứng chỉ Rửa Tội', document: doc);
  await _logPrint(sacramentType: 'baptism', sacramentRecordId: rec.id, memberId: rec.data['member_id']?.toString());
}

Future<void> printConfirmationCertificate(BuildContext ctx, RecordModel rec) async {
  if (!_validate(ctx, rec.data, ['member_id', 'confirmation_date', 'bishop_name'])) return;
  final parish = await _fetchParish();
  final member = await _fetchMember(rec.data['member_id']?.toString());
  if (member == null) {
    if (ctx.mounted) realCmToast(ctx, 'Không tìm thấy giáo dân tương ứng', type: RealCmToastType.error);
    return;
  }
  final doc = await RealCmCertificateBuilder.confirmation(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    memberFullName: _memberName(member),
  );
  if (ctx.mounted) await realCmShowPdfPreview(ctx, title: 'Chứng chỉ Thêm Sức', document: doc);
  await _logPrint(sacramentType: 'confirmation', sacramentRecordId: rec.id, memberId: rec.data['member_id']?.toString());
}

Future<void> printMarriageCertificate(BuildContext ctx, RecordModel rec) async {
  if (!_validate(ctx, rec.data, ['groom_id', 'bride_id', 'marriage_date', 'priest_name'])) return;
  final parish = await _fetchParish();
  final groom = await _fetchMember(rec.data['groom_id']?.toString());
  final bride = await _fetchMember(rec.data['bride_id']?.toString());
  if (groom == null || bride == null) {
    if (ctx.mounted) realCmToast(ctx, 'Không tìm thấy chú rể hoặc cô dâu', type: RealCmToastType.error);
    return;
  }
  final doc = await RealCmCertificateBuilder.marriage(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    groomFullName: _memberName(groom),
    brideFullName: _memberName(bride),
  );
  if (ctx.mounted) await realCmShowPdfPreview(ctx, title: 'Chứng chỉ Hôn Phối', document: doc);
  await _logPrint(sacramentType: 'marriage', sacramentRecordId: rec.id, memberId: rec.data['groom_id']?.toString());
}

Future<void> printAnointingCertificate(BuildContext ctx, RecordModel rec) async {
  if (!_validate(ctx, rec.data, ['member_id', 'anointing_date', 'priest_name'])) return;
  final parish = await _fetchParish();
  final member = await _fetchMember(rec.data['member_id']?.toString());
  if (member == null) {
    if (ctx.mounted) realCmToast(ctx, 'Không tìm thấy giáo dân tương ứng', type: RealCmToastType.error);
    return;
  }
  final doc = await RealCmCertificateBuilder.anointing(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    memberFullName: _memberName(member),
  );
  if (ctx.mounted) await realCmShowPdfPreview(ctx, title: 'Chứng chỉ Xức Dầu', document: doc);
  await _logPrint(sacramentType: 'anointing', sacramentRecordId: rec.id, memberId: rec.data['member_id']?.toString());
}

Future<void> printFuneralCertificate(BuildContext ctx, RecordModel rec) async {
  if (!_validate(ctx, rec.data, ['member_id', 'death_date', 'funeral_date', 'priest_name'])) return;
  final parish = await _fetchParish();
  final member = await _fetchMember(rec.data['member_id']?.toString());
  if (member == null) {
    if (ctx.mounted) realCmToast(ctx, 'Không tìm thấy giáo dân tương ứng', type: RealCmToastType.error);
    return;
  }
  final doc = await RealCmCertificateBuilder.funeral(
    parishName: parish.name,
    parishAddress: parish.address,
    data: rec.data,
    memberFullName: _memberName(member),
  );
  if (ctx.mounted) await realCmShowPdfPreview(ctx, title: 'Chứng chỉ An Táng', document: doc);
  await _logPrint(sacramentType: 'funeral', sacramentRecordId: rec.id, memberId: rec.data['member_id']?.toString());
}
