// Dashboard customize — bật/tắt từng widget + chọn kích thước + reorder.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../domain/dashboard/widget_spec.dart';
import '../../ui/toast/service.dart';
import 'dashboard_screen.dart';
import 'widget_registry.dart';

class DashboardCustomizeScreen extends ConsumerStatefulWidget {
  const DashboardCustomizeScreen({super.key});

  @override
  ConsumerState<DashboardCustomizeScreen> createState() => _DashboardCustomizeScreenState();
}

class _DashboardCustomizeScreenState extends ConsumerState<DashboardCustomizeScreen> {
  List<DashboardWidgetSpec>? _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final async = ref.read(dashboardLayoutProvider);
    async.whenData((list) => _draft = [...list]);
  }

  Future<void> _save() async {
    if (_draft == null) return;
    setState(() => _saving = true);
    try {
      // Reindex order theo thứ tự hiện tại trong list (visible trước, hidden sau).
      final visible = _draft!.where((s) => s.enabled).toList();
      final hidden = _draft!.where((s) => !s.enabled).toList();
      final reindexed = <DashboardWidgetSpec>[];
      for (var i = 0; i < visible.length; i++) {
        reindexed.add(visible[i].copyWith(order: i));
      }
      for (var i = 0; i < hidden.length; i++) {
        reindexed.add(hidden[i].copyWith(order: visible.length + i));
      }
      await ref.read(dashboardRepoProvider).save(DashboardLayout(widgets: reindexed));
      ref.invalidate(dashboardLayoutProvider);
      if (mounted) {
        realCmToast(context, 'Đã lưu cấu hình dashboard', type: RealCmToastType.success);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Lưu thất bại: $e', type: RealCmToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetDefault() async {
    setState(() => _draft = DashboardWidgetRegistry.defaultLayout());
    realCmToast(context, 'Đã đặt lại layout mặc định (chưa lưu)', type: RealCmToastType.info);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dashboardLayoutProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuỳ chỉnh dashboard'),
        actions: [
          TextButton.icon(
            icon: const Icon(RealCmIcons.refresh, size: 18),
            label: const Text('Mặc định'),
            onPressed: _resetDefault,
          ),
          const SizedBox(width: RealCmSpacing.s2),
          ElevatedButton.icon(
            icon: _saving
                ? const SizedBox(
                    height: 16, width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(RealCmIcons.save, size: 18),
            label: const Text('Lưu'),
            onPressed: _saving ? null : _save,
          ),
          const SizedBox(width: RealCmSpacing.s4),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (initial) {
          _draft ??= [...initial];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(RealCmSpacing.s4),
                color: RealCmColors.surfaceVariant,
                child: const Row(
                  children: [
                    Icon(RealCmIcons.info, color: RealCmColors.info, size: 18),
                    SizedBox(width: RealCmSpacing.s2),
                    Expanded(
                      child: Text(
                        'Kéo-thả để sắp xếp · Bật/tắt visibility · Chọn kích thước (Nhỏ/Vừa/Lớn/Toàn ngang).',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: RealCmSpacing.s3),
                  itemCount: _draft!.length,
                  onReorder: (oldIdx, newIdx) {
                    setState(() {
                      if (newIdx > oldIdx) newIdx -= 1;
                      final item = _draft!.removeAt(oldIdx);
                      _draft!.insert(newIdx, item);
                    });
                  },
                  itemBuilder: (_, i) {
                    final spec = _draft![i];
                    final meta = DashboardWidgetRegistry.meta(spec.type);
                    return _CustomizeRow(
                      key: ValueKey(spec.type),
                      index: i,
                      spec: spec,
                      meta: meta,
                      onToggle: (v) {
                        setState(() {
                          _draft![i] = spec.copyWith(enabled: v);
                        });
                      },
                      onSizeChanged: (size) {
                        setState(() {
                          _draft![i] = spec.copyWith(size: size);
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CustomizeRow extends StatelessWidget {
  const _CustomizeRow({
    super.key,
    required this.index,
    required this.spec,
    required this.meta,
    required this.onToggle,
    required this.onSizeChanged,
  });

  final int index;
  final DashboardWidgetSpec spec;
  final DashboardWidgetMeta? meta;
  final ValueChanged<bool> onToggle;
  final ValueChanged<DashboardWidgetSize> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final m = meta;
    return Container(
      margin: const EdgeInsets.only(bottom: RealCmSpacing.s2),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(RealCmRadius.md),
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s3, vertical: RealCmSpacing.s2),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle, color: RealCmColors.textMuted),
          ),
          const SizedBox(width: RealCmSpacing.s3),
          Container(
            padding: const EdgeInsets.all(RealCmSpacing.s2),
            decoration: BoxDecoration(
              color: RealCmColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(RealCmRadius.sm),
            ),
            child: Icon(m?.icon ?? RealCmIcons.info, size: 16, color: RealCmColors.primary),
          ),
          const SizedBox(width: RealCmSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m?.title ?? spec.type,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (m?.description != null)
                  Text(m!.description, style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: RealCmSpacing.s3),
          DropdownButton<DashboardWidgetSize>(
            value: spec.size,
            underline: const SizedBox.shrink(),
            items: DashboardWidgetSize.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) {
              if (v != null) onSizeChanged(v);
            },
          ),
          const SizedBox(width: RealCmSpacing.s2),
          Switch(value: spec.enabled, onChanged: onToggle),
        ],
      ),
    );
  }
}
