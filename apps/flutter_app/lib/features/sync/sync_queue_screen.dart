// Sync queue screen — manage pending offline writes (priest_pastor only).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/sync/queue.dart';
import '../../ui/modal/service.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';

class SyncQueueScreen extends ConsumerStatefulWidget {
  const SyncQueueScreen({super.key});
  @override
  ConsumerState<SyncQueueScreen> createState() => _SyncQueueScreenState();
}

class _SyncQueueScreenState extends ConsumerState<SyncQueueScreen> {
  bool _draining = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(realCmAuthProvider);
    if (!auth.isPriest) {
      return RealCmAppShell(
        title: 'Đồng bộ chờ',
        body: const Center(child: Text('Chỉ Cha xứ/Cha phó xem được')),
      );
    }
    final items = RealCmSyncQueue.instance.listPending();

    return RealCmAppShell(
      title: 'Đồng bộ chờ (${items.length})',
      actions: [
        IconButton(
          icon: const Icon(RealCmIcons.refresh),
          onPressed: () => setState(() {}),
        ),
        TextButton.icon(
          icon: _draining
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.sync, size: 18),
          label: const Text('Đồng bộ ngay'),
          onPressed: items.isEmpty || _draining
              ? null
              : () async {
                  setState(() => _draining = true);
                  final n = await RealCmSyncQueue.instance.drain();
                  if (!mounted) return;
                  setState(() => _draining = false);
                  ref.read(pendingSyncCountProvider.notifier).state = RealCmSyncQueue.instance.pendingCount();
                  realCmToast(context,
                      n > 0 ? 'Đã đồng bộ $n thay đổi' : 'Vẫn chưa kết nối server',
                      type: n > 0 ? RealCmToastType.success : RealCmToastType.warning);
                },
        ),
      ],
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.cloud_done_outlined, size: 64, color: RealCmColors.success),
                  SizedBox(height: RealCmSpacing.s3),
                  Text('Đã đồng bộ tất cả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Không có thay đổi nào đang chờ đồng bộ.',
                      style: TextStyle(color: RealCmColors.textMuted)),
                ]),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
              itemBuilder: (_, i) {
                final it = items[i];
                return ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _opColor(it.op).withValues(alpha: 0.15),
                    child: Icon(_opIcon(it.op), color: _opColor(it.op), size: 18),
                  ),
                  title: Text('${_opLabel(it.op)} · ${_collectionLabel(it.collection)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(it.recordId != null ? 'Record ${it.recordId}' : 'Ghi mới',
                      style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
                  childrenPadding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
                  children: [
                    if (it.body != null)
                      Container(
                        padding: const EdgeInsets.all(RealCmSpacing.s2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(RealCmRadius.md),
                        ),
                        child: SelectableText(
                          const JsonEncoder.withIndent('  ').convert(it.body),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                      ),
                    const SizedBox(height: RealCmSpacing.s2),
                    Row(children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 16, color: RealCmColors.danger),
                        label: const Text('Xoá khỏi queue', style: TextStyle(color: RealCmColors.danger)),
                        onPressed: () async {
                          final ok = await realCmConfirm(context,
                              title: 'Xoá khỏi hàng chờ',
                              body: 'Bỏ thay đổi này khỏi queue? Hành động không thể khôi phục.',
                              danger: true,
                              confirmLabel: 'Xoá');
                          if (!ok) return;
                          await RealCmSyncQueue.instance.removeItem(it.id);
                          if (!mounted) return;
                          ref.read(pendingSyncCountProvider.notifier).state = RealCmSyncQueue.instance.pendingCount();
                          setState(() {});
                          realCmToast(context, 'Đã xoá', type: RealCmToastType.warning);
                        },
                      ),
                    ]),
                  ],
                );
              },
            ),
    );
  }

  Color _opColor(SyncOp op) {
    switch (op) {
      case SyncOp.create: return RealCmColors.success;
      case SyncOp.update: return RealCmColors.info;
      case SyncOp.delete: return RealCmColors.danger;
    }
  }

  IconData _opIcon(SyncOp op) {
    switch (op) {
      case SyncOp.create: return Icons.add_circle_outline;
      case SyncOp.update: return Icons.edit_outlined;
      case SyncOp.delete: return Icons.delete_outline;
    }
  }

  String _opLabel(SyncOp op) => {
        SyncOp.create: 'Tạo mới',
        SyncOp.update: 'Cập nhật',
        SyncOp.delete: 'Xoá',
      }[op]!;

  String _collectionLabel(String c) => {
        'members': 'Giáo dân',
        'families': 'Gia đình',
        'districts': 'Giáo họ',
        'sacrament_baptism': 'Sổ Rửa Tội',
        'sacrament_confirmation': 'Sổ Thêm Sức',
        'sacrament_marriage': 'Sổ Hôn Phối',
        'sacrament_anointing': 'Sổ Xức Dầu',
        'sacrament_funeral': 'Sổ An Táng',
        'donations': 'Sổ thu/chi',
        'mass_intentions': 'Lễ ý',
        'groups': 'Đoàn thể',
        'liturgical_events': 'Lịch phụng vụ',
      }[c] ?? c;
}
