// Member detail screen — info đầy đủ + sacrament timeline + family + actions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../data/member/repository.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../domain/member/entity.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/crud/collection_crud.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';
import '../modules/configs.dart' as cfg;
import 'member_form.dart';

class _SacramentEntry {
  _SacramentEntry({required this.label, required this.icon, required this.color, required this.date, this.subtitle, this.bookNumber});
  final String label;
  final IconData icon;
  final Color color;
  final DateTime date;
  final String? subtitle;
  final String? bookNumber;
}

class _DetailData {
  _DetailData({required this.member, required this.sacraments, required this.donations, this.familyName, this.districtName});
  final Member member;
  final List<_SacramentEntry> sacraments;
  final List<RecordModel> donations;
  final String? familyName;
  final String? districtName;
}

final _detailProvider = FutureProvider.autoDispose.family<_DetailData, String>((ref, id) async {
  final pb = RealCmPocketBase.instance();
  final member = await ref.read(memberRepoProvider).getById(id);

  // Fetch family name
  String? familyName;
  if (member.familyId != null) {
    try {
      final f = await pb.collection('families').getOne(member.familyId!);
      familyName = f.data['family_name']?.toString();
    } catch (_) {}
  }
  String? districtName;
  if (member.districtId != null) {
    try {
      final d = await pb.collection('districts').getOne(member.districtId!);
      districtName = d.data['name']?.toString();
    } catch (_) {}
  }

  // Fetch all sacraments where member_id (or groom_id/bride_id for marriage) matches
  final sacraments = <_SacramentEntry>[];

  Future<void> addSacrament(String collection, String dateField, String label, IconData icon, Color color, {String filterField = 'member_id'}) async {
    try {
      final res = await pb.collection(collection).getList(
        page: 1, perPage: 10,
        filter: '$filterField = "$id"',
        sort: '-$dateField',
      );
      for (final r in res.items) {
        final d = DateTime.tryParse(r.data[dateField]?.toString() ?? '');
        if (d == null) continue;
        sacraments.add(_SacramentEntry(
          label: label,
          icon: icon,
          color: color,
          date: d,
          bookNumber: r.data['book_number']?.toString(),
          subtitle: r.data['priest_name']?.toString(),
        ));
      }
    } catch (_) {}
  }

  await addSacrament('sacrament_baptism', 'baptism_date', 'Rửa Tội', RealCmIcons.baptism, RealCmColors.info);
  await addSacrament('sacrament_confirmation', 'confirmation_date', 'Thêm Sức', RealCmIcons.confirmation, RealCmColors.danger);
  await addSacrament('sacrament_marriage', 'marriage_date', 'Hôn Phối (chú rể)', RealCmIcons.marriage, RealCmColors.accent, filterField: 'groom_id');
  await addSacrament('sacrament_marriage', 'marriage_date', 'Hôn Phối (cô dâu)', RealCmIcons.marriage, RealCmColors.accent, filterField: 'bride_id');
  await addSacrament('sacrament_anointing', 'anointing_date', 'Xức Dầu', RealCmIcons.anointing, RealCmColors.warning);
  await addSacrament('sacrament_funeral', 'funeral_date', 'An Táng', RealCmIcons.funeral, RealCmColors.textMuted);

  sacraments.sort((a, b) => b.date.compareTo(a.date));

  // Donations match theo full_name (đơn giản — backwards compat).
  final donations = <RecordModel>[];
  try {
    final qName = member.fullName.replaceAll('"', '');
    final res = await pb.collection('donations').getList(
      page: 1, perPage: 50,
      filter: 'donor_name ~ "$qName"',
      sort: '-date',
    );
    donations.addAll(res.items);
  } catch (_) {}

  return _DetailData(
    member: member,
    sacraments: sacraments,
    donations: donations,
    familyName: familyName,
    districtName: districtName,
  );
});

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({super.key, required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(realCmAuthProvider);
    final canEdit = auth.canEditMembers;
    final asyncData = ref.watch(_detailProvider(memberId));
    return RealCmAppShell(
      title: 'Chi tiết giáo dân',
      actions: [
        IconButton(
          icon: const Icon(RealCmIcons.refresh),
          tooltip: 'Làm mới',
          onPressed: () => ref.invalidate(_detailProvider(memberId)),
        ),
        if (canEdit)
          IconButton(
            icon: const Icon(RealCmIcons.edit),
            tooltip: 'Sửa',
            onPressed: () async {
              final m = asyncData.value?.member;
              if (m == null) return;
              final r = await showMemberFormModal(context, ref, existing: m);
              if (r != null) ref.invalidate(_detailProvider(memberId));
            },
          ),
      ],
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s4),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48, color: RealCmColors.danger),
              const SizedBox(height: RealCmSpacing.s2),
              Text('Lỗi tải: $e', textAlign: TextAlign.center),
              const SizedBox(height: RealCmSpacing.s3),
              OutlinedButton.icon(
                icon: const Icon(RealCmIcons.refresh),
                label: const Text('Thử lại'),
                onPressed: () => ref.invalidate(_detailProvider(memberId)),
              ),
            ]),
          ),
        ),
        data: (data) => _DetailBody(data: data),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.data});
  final _DetailData data;

  @override
  Widget build(BuildContext context) {
    final m = data.member;
    final df = DateFormat('dd/MM/yyyy', 'vi');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card với avatar lớn + tên
            Container(
              padding: const EdgeInsets.all(RealCmSpacing.s4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(RealCmRadius.lg),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  _BigAvatar(member: m),
                  const SizedBox(width: RealCmSpacing.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Wrap(spacing: 8, runSpacing: 4, children: [
                          if (m.gender != null)
                            _badge(m.gender == RealCmGender.male ? 'Nam' : m.gender == RealCmGender.female ? 'Nữ' : 'Khác',
                                m.gender == RealCmGender.male ? RealCmColors.info : RealCmColors.primary),
                          if (m.status != RealCmMemberStatus.active)
                            _statusBadge(m.status),
                          if (m.birthDate != null)
                            _badge('Sinh ${df.format(m.birthDate!)}', RealCmColors.textMuted),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RealCmSpacing.s4),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _InfoCard(member: m, familyName: data.familyName, districtName: data.districtName, df: df)),
              const SizedBox(width: RealCmSpacing.s4),
              Expanded(child: _SacramentTimeline(entries: data.sacraments)),
            ]),
            const SizedBox(height: RealCmSpacing.s4),
            if (data.donations.isNotEmpty)
              _DonationsCard(donations: data.donations),
            if (data.donations.isNotEmpty) const SizedBox(height: RealCmSpacing.s4),
            if (m.notes != null && m.notes!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(RealCmSpacing.s4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(RealCmRadius.lg),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: RealCmColors.textMuted)),
                  const SizedBox(height: 8),
                  Text(m.notes!),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      );

  Widget _statusBadge(RealCmMemberStatus s) {
    final cfg = {
      RealCmMemberStatus.movedOut: ('Đã chuyển', RealCmColors.warning),
      RealCmMemberStatus.deceased: ('Đã qua đời', RealCmColors.textMuted),
      RealCmMemberStatus.excommunicated: ('Vạ tuyệt thông', RealCmColors.danger),
      RealCmMemberStatus.active: ('Đang sinh hoạt', RealCmColors.success),
    }[s]!;
    return _badge(cfg.$1, cfg.$2);
  }
}

class _BigAvatar extends StatelessWidget {
  const _BigAvatar({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    final url = RealCmPocketBase.fileUrl(
      collection: 'members', recordId: member.id, filename: member.photo, thumb: '300x300',
    );
    final color = member.gender == RealCmGender.male ? RealCmColors.info
        : member.gender == RealCmGender.female ? RealCmColors.primary
        : RealCmColors.textMuted;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? Center(child: Icon(RealCmIcons.member, size: 40, color: color))
          : Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(RealCmIcons.member, size: 40, color: color)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.member, required this.familyName, required this.districtName, required this.df});
  final Member member;
  final String? familyName;
  final String? districtName;
  final DateFormat df;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String?)>[
      ('Tên Thánh', member.saintName),
      ('Họ tên đời', member.fullName),
      ('Ngày sinh', member.birthDate != null ? df.format(member.birthDate!) : null),
      ('Nơi sinh', member.birthPlace),
      ('Số CCCD', member.idNumber),
      ('Điện thoại', member.phone),
      ('Email', member.email),
      ('Địa chỉ', member.address),
      ('Cha', member.fatherNameText),
      ('Mẹ', member.motherNameText),
      ('Gia đình', familyName),
      ('Giáo họ', districtName),
    ].where((r) => r.$2 != null && r.$2!.isNotEmpty).toList();
    return Container(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: RealCmSpacing.s3),
        for (final r in rows) Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 100, child: Text(r.$1, style: const TextStyle(color: RealCmColors.textMuted, fontSize: 13))),
            const SizedBox(width: 8),
            Expanded(child: Text(r.$2!, style: const TextStyle(fontWeight: FontWeight.w500))),
          ]),
        ),
        if (rows.isEmpty) const Text('(Chưa nhập thông tin)', style: TextStyle(color: RealCmColors.textMuted)),
      ]),
    );
  }
}

class _SacramentTimeline extends StatelessWidget {
  const _SacramentTimeline({required this.entries});
  final List<_SacramentEntry> entries;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy', 'vi');
    return Container(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Hành trình Bí Tích', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: RealCmSpacing.s3),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Chưa có Bí Tích nào ghi nhận', style: TextStyle(color: RealCmColors.textMuted)),
          )
        else
          for (final e in entries) Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: e.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(e.icon, size: 18, color: e.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(e.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Text(df.format(e.date), style: const TextStyle(color: RealCmColors.textMuted, fontSize: 13)),
                  ]),
                  if (e.bookNumber != null) Text('Số sổ ${e.bookNumber}', style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
                  if (e.subtitle != null && e.subtitle!.isNotEmpty) Text(e.subtitle!, style: const TextStyle(fontSize: 12)),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _DonationsCard extends StatelessWidget {
  const _DonationsCard({required this.donations});
  final List<RecordModel> donations;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy', 'vi');
    final fmt = NumberFormat.decimalPattern('vi');
    num totalIn = 0;
    num totalOut = 0;
    for (final d in donations) {
      final amt = (d.data['amount'] as num?) ?? 0;
      if (d.data['type']?.toString() == 'expense') {
        totalOut += amt;
      } else {
        totalIn += amt;
      }
    }
    return Container(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 18),
          const SizedBox(width: 8),
          const Expanded(child: Text('Đóng góp tài chính', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
          Text('${donations.length} phiếu',
              style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
        ]),
        const SizedBox(height: RealCmSpacing.s2),
        Row(children: [
          if (totalIn > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RealCmColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(RealCmRadius.full),
              ),
              child: Text('Đã dâng: ${fmt.format(totalIn)} đ',
                  style: const TextStyle(fontSize: 12, color: RealCmColors.success, fontWeight: FontWeight.w600)),
            ),
          if (totalOut > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RealCmColors.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(RealCmRadius.full),
              ),
              child: Text('Đã chi: ${fmt.format(totalOut)} đ',
                  style: const TextStyle(fontSize: 12, color: RealCmColors.danger, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
        const SizedBox(height: RealCmSpacing.s3),
        for (final d in donations.take(10))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Icon(
                d.data['type']?.toString() == 'expense' ? Icons.arrow_circle_down : Icons.arrow_circle_up,
                size: 16,
                color: d.data['type']?.toString() == 'expense' ? RealCmColors.danger : RealCmColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(d.data['description']?.toString().isNotEmpty == true
                    ? d.data['description'].toString()
                    : (d.data['type']?.toString() ?? '')),
              ),
              Text(_typeLabel(d.data['type']?.toString() ?? ''),
                  style: const TextStyle(fontSize: 11, color: RealCmColors.textMuted)),
              const SizedBox(width: 8),
              Text(
                d.data['date'] != null ? df.format(DateTime.parse(d.data['date'].toString())) : '',
                style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted),
              ),
              const SizedBox(width: 12),
              Text(
                '${fmt.format((d.data['amount'] as num?) ?? 0)} đ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: d.data['type']?.toString() == 'expense' ? RealCmColors.danger : RealCmColors.success,
                ),
              ),
            ]),
          ),
        if (donations.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('... và ${donations.length - 10} phiếu khác',
                style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
          ),
      ]),
    );
  }

  String _typeLabel(String t) => {
        'sunday_offering': 'Dâng CN',
        'feast_offering': 'Lễ trọng',
        'building_fund': 'Quỹ XD',
        'mass_intention': 'Xin lễ',
        'other_in': 'Thu khác',
        'expense': 'Chi',
      }[t] ?? t;
}
