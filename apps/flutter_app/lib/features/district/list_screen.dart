// District (Giáo họ) list — CRUD đầy đủ qua modal đơn giản hơn member.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/district/repository.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../domain/district/entity.dart';
import '../../platform/pocketbase/auth.dart';
import '../../ui/modal/service.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';

final districtRepoProvider = Provider((_) => DistrictRepository());
final _districtListProvider =
    FutureProvider.autoDispose<List<District>>((ref) => ref.read(districtRepoProvider).list());

class DistrictListScreen extends ConsumerWidget {
  const DistrictListScreen({super.key});

  Future<void> _showForm(BuildContext context, WidgetRef ref, {District? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final zoneCtrl = TextEditingController(text: existing?.addressZone ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.lg)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(RealCmSpacing.s4),
                  decoration: BoxDecoration(
                    color: RealCmColors.primary.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(RealCmRadius.lg)),
                  ),
                  child: Row(
                    children: [
                      const Icon(RealCmIcons.district, color: RealCmColors.primary),
                      const SizedBox(width: RealCmSpacing.s3),
                      Expanded(
                        child: Text(existing == null ? 'Thêm giáo họ' : 'Sửa giáo họ',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        icon: const Icon(RealCmIcons.close),
                        onPressed: saving ? null : () => Navigator.of(ctx).pop(false),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(RealCmSpacing.s4),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Tên giáo họ *', hintText: 'Giáo họ Thánh Giuse'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                        ),
                        const SizedBox(height: RealCmSpacing.s3),
                        TextFormField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(labelText: 'Mã (vd GH-01)', hintText: 'Chữ hoa + số + dấu gạch'),
                        ),
                        const SizedBox(height: RealCmSpacing.s3),
                        TextFormField(
                          controller: zoneCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Khu vực địa lý'),
                        ),
                        const SizedBox(height: RealCmSpacing.s3),
                        TextFormField(
                          controller: notesCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Ghi chú'),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(RealCmSpacing.s3),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Theme.of(ctx).colorScheme.outlineVariant)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: saving ? null : () => Navigator.of(ctx).pop(false), child: const Text('Huỷ')),
                      const SizedBox(width: RealCmSpacing.s2),
                      ElevatedButton.icon(
                        onPressed: saving ? null : () async {
                          if (!formKey.currentState!.validate()) return;
                          setSt(() => saving = true);
                          try {
                            final data = {
                              'name': nameCtrl.text.trim(),
                              'code': codeCtrl.text.trim().toUpperCase(),
                              'address_zone': zoneCtrl.text.trim(),
                              'notes': notesCtrl.text.trim(),
                            }..removeWhere((_, v) => (v as String).isEmpty);
                            if (existing == null) {
                              await ref.read(districtRepoProvider).create(data);
                            } else {
                              await ref.read(districtRepoProvider).update(existing.id, data);
                            }
                            if (ctx.mounted) Navigator.of(ctx).pop(true);
                          } catch (e) {
                            if (ctx.mounted) realCmToast(ctx, 'Lỗi: $e', type: RealCmToastType.error);
                            setSt(() => saving = false);
                          }
                        },
                        icon: saving
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(RealCmIcons.save, size: 18),
                        label: Text(existing == null ? 'Thêm' : 'Lưu'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved == true && context.mounted) {
      realCmToast(context, existing == null ? 'Đã thêm giáo họ' : 'Đã cập nhật', type: RealCmToastType.success);
      ref.invalidate(_districtListProvider);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, District d) async {
    final ok = await realCmConfirm(context,
        title: 'Xoá giáo họ',
        body: 'Xoá giáo họ "${d.name}"? Giáo dân thuộc giáo họ này sẽ không bị xoá nhưng cần chuyển sang giáo họ khác.',
        confirmLabel: 'Xoá',
        danger: true);
    if (!ok) return;
    try {
      await ref.read(districtRepoProvider).softDelete(d.id);
      if (context.mounted) {
        realCmToast(context, 'Đã xoá ${d.name}', type: RealCmToastType.success);
        ref.invalidate(_districtListProvider);
      }
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Xoá thất bại: $e', type: RealCmToastType.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(realCmAuthProvider);
    final canEdit = auth.canEditMembers;
    final async = ref.watch(_districtListProvider);

    return RealCmAppShell(
      title: 'Giáo họ',
      actions: [
        IconButton(icon: const Icon(RealCmIcons.refresh), onPressed: () => ref.invalidate(_districtListProvider)),
      ],
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(context, ref),
              icon: const Icon(RealCmIcons.add),
              label: const Text('Thêm giáo họ'),
            )
          : null,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(RealCmSpacing.s5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RealCmIcons.district, size: 56, color: RealCmColors.textDisabled),
                    const SizedBox(height: RealCmSpacing.s3),
                    const Text('Chưa có giáo họ nào', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: RealCmSpacing.s2),
                    const Text('Tạo giáo họ đầu tiên để phân nhóm giáo dân.',
                        style: TextStyle(color: RealCmColors.textMuted)),
                    if (canEdit) ...[
                      const SizedBox(height: RealCmSpacing.s4),
                      ElevatedButton.icon(
                        onPressed: () => _showForm(context, ref),
                        icon: const Icon(RealCmIcons.add),
                        label: const Text('Thêm giáo họ'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(RealCmSpacing.s3),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: RealCmSpacing.s2),
            itemBuilder: (_, i) {
              final d = list[i];
              return Material(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RealCmRadius.md),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: RealCmSpacing.s2),
                  leading: CircleAvatar(
                    backgroundColor: RealCmColors.primary.withValues(alpha: 0.12),
                    child: const Icon(RealCmIcons.district, color: RealCmColors.primary, size: 20),
                  ),
                  title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    [
                      if (d.code != null && d.code!.isNotEmpty) 'Mã: ${d.code}',
                      if (d.addressZone != null && d.addressZone!.isNotEmpty) d.addressZone!,
                    ].join(' · '),
                    style: const TextStyle(fontSize: 13, color: RealCmColors.textMuted),
                  ),
                  trailing: canEdit
                      ? PopupMenuButton<String>(
                          icon: const Icon(RealCmIcons.more),
                          onSelected: (v) {
                            if (v == 'edit') _showForm(context, ref, existing: d);
                            if (v == 'delete') _delete(context, ref, d);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Sửa')),
                            PopupMenuItem(value: 'delete', child: Text('Xoá', style: TextStyle(color: RealCmColors.danger))),
                          ],
                        )
                      : null,
                  onTap: canEdit ? () => _showForm(context, ref, existing: d) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
