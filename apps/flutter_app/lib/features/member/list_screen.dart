// Member list — full CRUD: search + add (modal) + edit (modal) + soft delete (confirm).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/member/repository.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../domain/member/entity.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/modal/service.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';
import 'bulk_export.dart';
import 'member_form.dart';

class _MemberListQuery {
  const _MemberListQuery({this.search, this.status});
  final String? search;
  final String? status;

  @override
  bool operator ==(Object other) => other is _MemberListQuery && other.search == search && other.status == status;
  @override
  int get hashCode => Object.hash(search, status);
}

final _memberListProvider = FutureProvider.autoDispose.family<List<Member>, _MemberListQuery>(
  (ref, q) => ref.read(memberRepoProvider).list(search: q.search, status: q.status),
);

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  String _search = '';
  String? _statusFilter = 'active'; // mặc định chỉ hiện active
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addNew() async {
    final result = await showMemberFormModal(context, ref);
    if (result != null) {
      ref.invalidate(_memberListProvider);
    }
  }

  Future<void> _edit(Member m) async {
    final result = await showMemberFormModal(context, ref, existing: m);
    if (result != null) {
      ref.invalidate(_memberListProvider);
    }
  }

  Future<void> _delete(Member m) async {
    final ok = await realCmConfirm(
      context,
      title: 'Xoá giáo dân',
      body: 'Bạn có chắc muốn xoá giáo dân "${m.displayName}"?\n\nLưu ý: dữ liệu sẽ ẩn khỏi danh sách nhưng vẫn giữ trong sổ Bí Tích để bảo toàn lịch sử.',
      confirmLabel: 'Xoá',
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(memberRepoProvider).softDelete(m.id);
      if (mounted) {
        realCmToast(context, 'Đã xoá ${m.displayName}', type: RealCmToastType.success);
        ref.invalidate(_memberListProvider);
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Xoá thất bại: $e', type: RealCmToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(realCmAuthProvider);
    final canEdit = auth.canEditMembers;
    final asyncList = ref.watch(_memberListProvider(_search.isEmpty ? null : _search));
    final df = DateFormat('dd/MM/yyyy', 'vi');

    return RealCmAppShell(
      title: 'Danh sách giáo dân',
      actions: [
        IconButton(
          icon: const Icon(Icons.table_view),
          tooltip: 'Xuất toàn bộ ra Excel',
          onPressed: () => exportMembersToExcel(context),
        ),
        IconButton(
          icon: const Icon(RealCmIcons.refresh),
          tooltip: 'Làm mới',
          onPressed: () => ref.invalidate(_memberListProvider),
        ),
      ],
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: _addNew,
              icon: const Icon(RealCmIcons.add),
              label: const Text('Thêm giáo dân'),
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(RealCmSpacing.s4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(RealCmIcons.search),
                      hintText: 'Tìm theo tên Thánh, họ tên, điện thoại...',
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(RealCmIcons.close),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: RealCmSpacing.s3),
                asyncList.maybeWhen(
                  data: (list) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s3, vertical: RealCmSpacing.s2),
                    decoration: BoxDecoration(
                      color: RealCmColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(RealCmRadius.full),
                    ),
                    child: Text('${list.length} giáo dân',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorState(error: e.toString(), onRetry: () => ref.invalidate(_memberListProvider)),
              data: (members) {
                if (members.isEmpty) return _EmptyState(canAdd: canEdit, onAdd: _addNew, hasSearch: _search.isNotEmpty);
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: RealCmSpacing.s2),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                  itemBuilder: (_, i) {
                    final m = members[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: RealCmSpacing.s2),
                      leading: _Avatar(member: m),
                      title: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Wrap(
                          spacing: RealCmSpacing.s2,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (m.birthDate != null)
                              _chip(RealCmIcons.calendar, df.format(m.birthDate!)),
                            if (m.phone != null && m.phone!.isNotEmpty)
                              _chip(Icons.phone_outlined, m.phone!),
                            if (m.address != null && m.address!.isNotEmpty)
                              _chip(Icons.location_on_outlined, m.address!),
                            if (m.status != RealCmMemberStatus.active)
                              _statusChip(m.status),
                          ],
                        ),
                      ),
                      trailing: canEdit
                          ? PopupMenuButton<String>(
                              icon: const Icon(RealCmIcons.more),
                              onSelected: (v) {
                                if (v == 'edit') _edit(m);
                                if (v == 'delete') _delete(m);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Row(children: [Icon(RealCmIcons.edit, size: 18), SizedBox(width: 8), Text('Sửa')])),
                                PopupMenuItem(value: 'delete', child: Row(children: [Icon(RealCmIcons.delete, size: 18, color: RealCmColors.danger), SizedBox(width: 8), Text('Xoá', style: TextStyle(color: RealCmColors.danger))])),
                              ],
                            )
                          : null,
                      onTap: () => context.push('/members/${m.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _genderColor(RealCmGender? g) {
    switch (g) {
      case RealCmGender.male: return RealCmColors.info;
      case RealCmGender.female: return RealCmColors.primary;
      default: return RealCmColors.textMuted;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Widget _chip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: RealCmColors.textMuted),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
      ],
    );
  }

  Widget _statusChip(RealCmMemberStatus s) {
    String label;
    Color color;
    switch (s) {
      case RealCmMemberStatus.movedOut:
        label = 'Đã chuyển xứ';
        color = RealCmColors.warning;
        break;
      case RealCmMemberStatus.deceased:
        label = 'Đã qua đời';
        color = RealCmColors.textMuted;
        break;
      case RealCmMemberStatus.excommunicated:
        label = 'Vạ tuyệt thông';
        color = RealCmColors.danger;
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RealCmRadius.full),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.canAdd, required this.onAdd, required this.hasSearch});
  final bool canAdd;
  final VoidCallback onAdd;
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RealCmSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hasSearch ? RealCmIcons.search : RealCmIcons.member, size: 56, color: RealCmColors.textDisabled),
            const SizedBox(height: RealCmSpacing.s3),
            Text(hasSearch ? 'Không tìm thấy giáo dân nào' : 'Chưa có giáo dân nào',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: RealCmSpacing.s2),
            Text(
              hasSearch ? 'Thử từ khoá khác hoặc xoá bộ lọc.' : 'Thêm giáo dân đầu tiên cho giáo xứ.',
              style: const TextStyle(color: RealCmColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch && canAdd) ...[
              const SizedBox(height: RealCmSpacing.s4),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(RealCmIcons.add),
                label: const Text('Thêm giáo dân'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RealCmSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(RealCmIcons.error, size: 56, color: RealCmColors.danger),
            const SizedBox(height: RealCmSpacing.s3),
            const Text('Lỗi tải dữ liệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: RealCmSpacing.s2),
            Text(error, style: const TextStyle(color: RealCmColors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: RealCmSpacing.s4),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(RealCmIcons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member});
  final Member member;

  Color _genderColor() {
    switch (member.gender) {
      case RealCmGender.male: return RealCmColors.info;
      case RealCmGender.female: return RealCmColors.primary;
      default: return RealCmColors.textMuted;
    }
  }

  String _initials() {
    final parts = member.displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _genderColor();
    final url = RealCmPocketBase.fileUrl(
      collection: 'members',
      recordId: member.id,
      filename: member.photo,
      thumb: '100x100',
    );
    if (url == null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(_initials(), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withValues(alpha: 0.15),
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }
}
