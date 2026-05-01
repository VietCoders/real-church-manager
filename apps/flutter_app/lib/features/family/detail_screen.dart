// Family detail screen — info gia đình + danh sách thành viên qua family_members junction.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/modal/service.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';

class _FamilyMemberRow {
  _FamilyMemberRow({
    required this.junctionId,
    required this.memberId,
    required this.fullName,
    required this.saintName,
    required this.role,
    this.birthDate,
    this.gender,
    this.photo,
  });
  final String junctionId;
  final String memberId;
  final String fullName;
  final String saintName;
  final String role;
  final DateTime? birthDate;
  final String? gender;
  final String? photo;

  String get displayName => saintName.isEmpty ? fullName : '$saintName $fullName';
}

class _FamilyDetailData {
  _FamilyDetailData({required this.family, required this.members, this.districtName, this.headName});
  final RecordModel family;
  final List<_FamilyMemberRow> members;
  final String? districtName;
  final String? headName;
}

final _familyDetailProvider = FutureProvider.autoDispose.family<_FamilyDetailData, String>((ref, id) async {
  final pb = RealCmPocketBase.instance();
  final family = await pb.collection('families').getOne(id);

  String? districtName;
  if (family.data['district_id'] != null) {
    try {
      final d = await pb.collection('districts').getOne(family.data['district_id'].toString());
      districtName = d.data['name']?.toString();
    } catch (_) {}
  }

  String? headName;
  if (family.data['head_id'] != null) {
    try {
      final h = await pb.collection('members').getOne(family.data['head_id'].toString());
      headName = '${h.data['saint_name'] ?? ''} ${h.data['full_name'] ?? ''}'.trim();
    } catch (_) {}
  }

  // Load family_members junction with expand=member_id
  final res = await pb.collection('family_members').getList(
    page: 1, perPage: 50,
    filter: 'family_id = "$id" && left_date = null',
    expand: 'member_id',
    sort: 'role',
  );

  final rows = <_FamilyMemberRow>[];
  for (final r in res.items) {
    final exp = r.expand['member_id'];
    if (exp == null || exp.isEmpty) continue;
    final mRec = exp.first;
    final birth = DateTime.tryParse(mRec.data['birth_date']?.toString() ?? '');
    rows.add(_FamilyMemberRow(
      junctionId: r.id,
      memberId: mRec.id,
      fullName: mRec.data['full_name']?.toString() ?? '',
      saintName: mRec.data['saint_name']?.toString() ?? '',
      role: r.data['role']?.toString() ?? 'other',
      birthDate: birth,
      gender: mRec.data['gender']?.toString(),
      photo: mRec.data['photo']?.toString(),
    ));
  }

  return _FamilyDetailData(family: family, members: rows, districtName: districtName, headName: headName);
});

class FamilyDetailScreen extends ConsumerWidget {
  const FamilyDetailScreen({super.key, required this.familyId});
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(realCmAuthProvider);
    final canEdit = auth.canEditMembers;
    final async = ref.watch(_familyDetailProvider(familyId));
    return RealCmAppShell(
      title: 'Chi tiết gia đình',
      actions: [
        IconButton(
          icon: const Icon(RealCmIcons.refresh),
          onPressed: () => ref.invalidate(_familyDetailProvider(familyId)),
        ),
      ],
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _addMember(context, ref),
              icon: const Icon(RealCmIcons.add),
              label: const Text('Thêm thành viên'),
            )
          : null,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Padding(
          padding: const EdgeInsets.all(RealCmSpacing.s4),
          child: Text('Lỗi tải: $e', style: const TextStyle(color: RealCmColors.danger)),
        )),
        data: (data) => _Body(data: data, canEdit: canEdit, onMembersChanged: () => ref.invalidate(_familyDetailProvider(familyId))),
      ),
    );
  }

  Future<void> _addMember(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _AddMemberDialog(familyId: familyId),
    );
    if (ok == true) ref.invalidate(_familyDetailProvider(familyId));
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.data, required this.canEdit, required this.onMembersChanged});
  final _FamilyDetailData data;
  final bool canEdit;
  final VoidCallback onMembersChanged;

  Future<void> _removeMember(BuildContext context, WidgetRef ref, _FamilyMemberRow row) async {
    final ok = await realCmConfirm(
      context,
      title: 'Xoá khỏi gia đình',
      body: 'Bỏ ${row.displayName} khỏi gia đình này? Giáo dân vẫn còn trong hệ thống.',
      confirmLabel: 'Xoá',
      danger: true,
    );
    if (!ok) return;
    try {
      await RealCmPocketBase.instance().collection('family_members').delete(row.junctionId);
      if (context.mounted) realCmToast(context, 'Đã xoá', type: RealCmToastType.success);
      onMembersChanged();
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Lỗi: $e', type: RealCmToastType.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = data.family;
    final df = DateFormat('dd/MM/yyyy', 'vi');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(RealCmSpacing.s4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(RealCmRadius.lg),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: RealCmColors.info.withValues(alpha: 0.15),
                  child: const Icon(RealCmIcons.family, color: RealCmColors.info, size: 32),
                ),
                const SizedBox(width: RealCmSpacing.s4),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.data['family_name']?.toString() ?? 'Gia đình', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  if (data.headName != null) Text('Gia trưởng: ${data.headName}', style: const TextStyle(color: RealCmColors.textMuted)),
                  if (data.districtName != null) Text('Giáo họ: ${data.districtName}', style: const TextStyle(color: RealCmColors.textMuted)),
                  if (f.data['address']?.toString().isNotEmpty == true)
                    Text(f.data['address'], style: const TextStyle(color: RealCmColors.textMuted)),
                  if (f.data['phone']?.toString().isNotEmpty == true)
                    Text('SĐT: ${f.data['phone']}', style: const TextStyle(color: RealCmColors.textMuted)),
                ])),
              ]),
            ),
            const SizedBox(height: RealCmSpacing.s4),
            Text('Thành viên gia đình (${data.members.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: RealCmSpacing.s2),
            if (data.members.isEmpty)
              Container(
                padding: const EdgeInsets.all(RealCmSpacing.s4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(RealCmRadius.lg),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: const Center(child: Text('Chưa có thành viên', style: TextStyle(color: RealCmColors.textMuted))),
              )
            else
              for (final r in data.members)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(RealCmRadius.md),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: _MemberAvatar(memberId: r.memberId, photo: r.photo, gender: r.gender),
                    title: Text(r.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Wrap(spacing: 6, children: [
                      _roleBadge(r.role),
                      if (r.birthDate != null) Text(df.format(r.birthDate!), style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
                    ]),
                    trailing: canEdit
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline, color: RealCmColors.danger),
                            tooltip: 'Xoá khỏi gia đình',
                            onPressed: () => _removeMember(context, ref, r),
                          )
                        : null,
                    onTap: () => context.push('/members/${r.memberId}'),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    final cfg = {
      'head': ('Gia trưởng', RealCmColors.danger),
      'spouse': ('Vợ/chồng', RealCmColors.primary),
      'child': ('Con', RealCmColors.info),
      'parent': ('Cha/mẹ', RealCmColors.warning),
      'sibling': ('Anh/chị/em', RealCmColors.success),
      'other': ('Khác', RealCmColors.textMuted),
    }[role] ?? (role, RealCmColors.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cfg.$2.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RealCmRadius.full),
      ),
      child: Text(cfg.$1, style: TextStyle(fontSize: 11, color: cfg.$2, fontWeight: FontWeight.w600)),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.memberId, required this.photo, required this.gender});
  final String memberId;
  final String? photo;
  final String? gender;

  @override
  Widget build(BuildContext context) {
    final color = gender == 'male' ? RealCmColors.info : gender == 'female' ? RealCmColors.primary : RealCmColors.textMuted;
    final url = RealCmPocketBase.fileUrl(collection: 'members', recordId: memberId, filename: photo, thumb: '100x100');
    if (url == null) {
      return CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(RealCmIcons.member, color: color, size: 18),
      );
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }
}

class _AddMemberDialog extends ConsumerStatefulWidget {
  const _AddMemberDialog({required this.familyId});
  final String familyId;

  @override
  ConsumerState<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<_AddMemberDialog> {
  String? _selectedMemberId;
  String _role = 'child';
  bool _saving = false;
  List<RecordModel> _members = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final pb = RealCmPocketBase.instance();
      final res = await pb.collection('members').getList(
        page: 1, perPage: 100,
        filter: 'deleted_at = null',
        sort: 'full_name',
      );
      if (mounted) setState(() => _members = res.items);
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_selectedMemberId == null) return;
    setState(() => _saving = true);
    try {
      await RealCmPocketBase.instance().collection('family_members').create(body: {
        'family_id': widget.familyId,
        'member_id': _selectedMemberId,
        'role': _role,
        'joined_date': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        realCmToast(context, 'Đã thêm thành viên', type: RealCmToastType.success);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Lỗi: $e', type: RealCmToastType.error);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _members
        .where((m) {
          if (_search.isEmpty) return true;
          final q = _search.toLowerCase();
          final name = '${m.data['saint_name'] ?? ''} ${m.data['full_name'] ?? ''}'.toLowerCase();
          return name.contains(q);
        })
        .toList();
    return AlertDialog(
      title: const Text('Thêm thành viên vào gia đình'),
      content: SizedBox(
        width: 480,
        height: 520,
        child: Column(children: [
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Quan hệ trong gia đình'),
            items: const [
              DropdownMenuItem(value: 'head', child: Text('Gia trưởng')),
              DropdownMenuItem(value: 'spouse', child: Text('Vợ/chồng')),
              DropdownMenuItem(value: 'child', child: Text('Con')),
              DropdownMenuItem(value: 'parent', child: Text('Cha/mẹ')),
              DropdownMenuItem(value: 'sibling', child: Text('Anh/chị/em')),
              DropdownMenuItem(value: 'other', child: Text('Khác')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _role = v);
            },
          ),
          const SizedBox(height: RealCmSpacing.s3),
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(RealCmIcons.search), hintText: 'Tìm giáo dân'),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: RealCmSpacing.s2),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final m = filtered[i];
                final selected = _selectedMemberId == m.id;
                return RadioListTile<String>(
                  title: Text('${m.data['saint_name'] ?? ''} ${m.data['full_name'] ?? ''}'),
                  subtitle: Text(m.data['gender']?.toString() ?? ''),
                  value: m.id,
                  groupValue: _selectedMemberId,
                  onChanged: (v) => setState(() => _selectedMemberId = v),
                  selected: selected,
                  dense: true,
                );
              },
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
        ElevatedButton(
          onPressed: (_saving || _selectedMemberId == null) ? null : _save,
          child: Text(_saving ? 'Đang lưu...' : 'Thêm'),
        ),
      ],
    );
  }
}
