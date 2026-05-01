// Shared CRUD scaffold helpers — Form modal + section header + empty/error states.
import 'package:flutter/material.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';

class CrudFormScaffold extends StatelessWidget {
  const CrudFormScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.body,
    required this.onCancel,
    required this.onSave,
    required this.saving,
    this.isEdit = false,
    this.maxWidth = 720,
  });
  final String title;
  final IconData icon;
  final Widget body;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool saving;
  final bool isEdit;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.lg)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(RealCmSpacing.s4),
              decoration: BoxDecoration(
                color: RealCmColors.primary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(RealCmRadius.lg)),
              ),
              child: Row(children: [
                Icon(icon, color: RealCmColors.primary),
                const SizedBox(width: RealCmSpacing.s3),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(icon: const Icon(RealCmIcons.close), onPressed: saving ? null : onCancel),
              ]),
            ),
            Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(RealCmSpacing.s4), child: body)),
            Container(
              padding: const EdgeInsets.all(RealCmSpacing.s3),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant))),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: saving ? null : onCancel, child: const Text('Huỷ')),
                const SizedBox(width: RealCmSpacing.s2),
                ElevatedButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(RealCmIcons.save, size: 18),
                  label: Text(isEdit ? 'Lưu thay đổi' : 'Thêm mới'),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class CrudFormSection extends StatelessWidget {
  const CrudFormSection({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RealCmSpacing.s2, top: RealCmSpacing.s2),
      child: Row(children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: RealCmColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: RealCmSpacing.s2),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RealCmColors.textMuted)),
      ]),
    );
  }
}

class CrudEmptyState extends StatelessWidget {
  const CrudEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
    required this.canAdd,
    required this.addLabel,
    required this.onAdd,
    this.isSearching = false,
  });
  final IconData icon;
  final String title;
  final String hint;
  final bool canAdd;
  final String addLabel;
  final VoidCallback onAdd;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RealCmSpacing.s5),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isSearching ? RealCmIcons.search : icon, size: 56, color: RealCmColors.textDisabled),
          const SizedBox(height: RealCmSpacing.s3),
          Text(isSearching ? 'Không tìm thấy' : title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: RealCmSpacing.s2),
          Text(isSearching ? 'Thử từ khoá khác.' : hint, style: const TextStyle(color: RealCmColors.textMuted), textAlign: TextAlign.center),
          if (!isSearching && canAdd) ...[
            const SizedBox(height: RealCmSpacing.s4),
            ElevatedButton.icon(onPressed: onAdd, icon: const Icon(RealCmIcons.add), label: Text(addLabel)),
          ],
        ]),
      ),
    );
  }
}

class CrudErrorState extends StatelessWidget {
  const CrudErrorState({super.key, required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RealCmSpacing.s5),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(RealCmIcons.error, size: 56, color: RealCmColors.danger),
          const SizedBox(height: RealCmSpacing.s3),
          const Text('Lỗi tải dữ liệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: RealCmSpacing.s2),
          Text('$error', style: const TextStyle(color: RealCmColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: RealCmSpacing.s4),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(RealCmIcons.refresh), label: const Text('Thử lại')),
        ]),
      ),
    );
  }
}
