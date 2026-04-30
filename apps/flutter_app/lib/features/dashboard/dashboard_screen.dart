// Dashboard screen — grid 12-col responsive với widget tự sắp xếp + bật/tắt.
// Sau login, đây là màn hình mặc định. Drag-drop reorder qua reorderable_grid_view.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../data/dashboard/repository.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../domain/dashboard/widget_spec.dart';
import '../../platform/pocketbase/auth.dart';
import '../../ui/toast/service.dart';
import '../auth/connection_logout_actions.dart';
import 'customize_screen.dart';
import 'widget_registry.dart';

final dashboardRepoProvider = Provider((_) => DashboardLayoutRepository());

final dashboardLayoutProvider =
    FutureProvider.autoDispose<List<DashboardWidgetSpec>>((ref) async {
  final layout = await ref.read(dashboardRepoProvider).load();
  return DashboardWidgetRegistry.mergeWithDefaults(layout.widgets);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const double _gridGap = RealCmSpacing.s3;

  /// Số cột thực tế tuỳ kích thước màn hình (responsive).
  int _gridCols(double width) {
    if (width >= 1400) return 12;
    if (width >= 1000) return 8;
    if (width >= 700) return 6;
    if (width >= 480) return 4;
    return 2;
  }

  /// Kích thước widget chiếm bao nhiêu cell trên grid hiện tại.
  int _widgetCols(DashboardWidgetSize size, int totalCols) {
    final ratio = size.cols / 12;
    final c = (totalCols * ratio).round();
    return c.clamp(1, totalCols);
  }

  double _widgetHeight(DashboardWidgetSize size) {
    switch (size) {
      case DashboardWidgetSize.sm:
        return 160;
      case DashboardWidgetSize.md:
        return 280;
      case DashboardWidgetSize.lg:
        return 320;
      case DashboardWidgetSize.xl:
        return 360;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(realCmAuthProvider);
    final layoutAsync = ref.watch(dashboardLayoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển'),
        actions: [
          IconButton(
            icon: const Icon(RealCmIcons.refresh),
            tooltip: 'Làm mới',
            onPressed: () => ref.invalidate(dashboardLayoutProvider),
          ),
          IconButton(
            icon: const Icon(RealCmIcons.settings),
            tooltip: 'Tuỳ chỉnh dashboard',
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const DashboardCustomizeScreen(),
              ));
              ref.invalidate(dashboardLayoutProvider);
            },
          ),
          IconButton(
            icon: const Icon(RealCmIcons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => realCmLogoutWithConfirm(context, ref),
          ),
        ],
      ),
      drawer: _DashboardDrawer(role: auth.role ?? 'guest'),
      body: layoutAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(RealCmIcons.error, size: 48, color: RealCmColors.danger),
                const SizedBox(height: RealCmSpacing.s3),
                Text('$e', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (specs) {
          final visible = specs.where((s) => s.enabled).toList()
            ..sort((a, b) => a.order.compareTo(b.order));
          if (visible.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(RealCmSpacing.s6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RealCmIcons.report, size: 56, color: RealCmColors.textDisabled),
                    const SizedBox(height: RealCmSpacing.s3),
                    const Text('Chưa có widget nào hiển thị',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: RealCmSpacing.s2),
                    const Text('Vào "Tuỳ chỉnh" để bật widget bạn muốn xem.',
                        style: TextStyle(color: RealCmColors.textMuted)),
                    const SizedBox(height: RealCmSpacing.s4),
                    ElevatedButton.icon(
                      icon: const Icon(RealCmIcons.settings),
                      label: const Text('Tuỳ chỉnh dashboard'),
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const DashboardCustomizeScreen(),
                        ));
                        ref.invalidate(dashboardLayoutProvider);
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final totalCols = _gridCols(constraints.maxWidth);
              final cellW = (constraints.maxWidth - (RealCmSpacing.s4 * 2) - _gridGap * (totalCols - 1)) / totalCols;
              return Padding(
                padding: const EdgeInsets.all(RealCmSpacing.s4),
                child: ReorderableGridView.builder(
                  itemCount: visible.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: totalCols,
                    mainAxisSpacing: _gridGap,
                    crossAxisSpacing: _gridGap,
                    childAspectRatio: 1.5,
                  ),
                  onReorder: (oldIdx, newIdx) async {
                    final reordered = [...visible];
                    final item = reordered.removeAt(oldIdx);
                    reordered.insert(newIdx, item);
                    // Combine với hidden widgets giữ nguyên order tương đối.
                    final hidden = specs.where((s) => !s.enabled).toList();
                    final newList = <DashboardWidgetSpec>[];
                    for (var i = 0; i < reordered.length; i++) {
                      newList.add(reordered[i].copyWith(order: i));
                    }
                    for (var i = 0; i < hidden.length; i++) {
                      newList.add(hidden[i].copyWith(order: reordered.length + i));
                    }
                    try {
                      await ref.read(dashboardRepoProvider).save(DashboardLayout(widgets: newList));
                      ref.invalidate(dashboardLayoutProvider);
                    } catch (e) {
                      if (context.mounted) {
                        realCmToast(context, 'Lưu vị trí thất bại: $e', type: RealCmToastType.error);
                      }
                    }
                  },
                  itemBuilder: (ctx, i) {
                    final spec = visible[i];
                    final meta = DashboardWidgetRegistry.meta(spec.type);
                    final cols = _widgetCols(spec.size, totalCols);
                    final widgetW = cellW * cols + _gridGap * (cols - 1);
                    return Container(
                      key: ValueKey(spec.type),
                      width: widgetW,
                      height: _widgetHeight(spec.size),
                      child: meta == null
                          ? _UnknownWidget(type: spec.type)
                          : meta.builder(ref, spec),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _UnknownWidget extends StatelessWidget {
  const _UnknownWidget({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RealCmColors.surfaceVariant,
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
      ),
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      child: Center(
        child: Text('Widget không xác định: $type', style: const TextStyle(color: RealCmColors.textMuted)),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: RealCmColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(RealCmIcons.parish, color: Colors.white, size: 36),
                const SizedBox(height: RealCmSpacing.s2),
                const Text('Quản lý Giáo xứ',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: RealCmSpacing.s1),
                Text(_roleLabel(role), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _navItem(context, RealCmIcons.home, 'Bảng điều khiển'),
          _navItem(context, RealCmIcons.member, 'Giáo dân'),
          _navItem(context, RealCmIcons.family, 'Gia đình'),
          _navItem(context, RealCmIcons.district, 'Giáo họ'),
          const Divider(),
          _navItem(context, RealCmIcons.baptism, 'Sổ Rửa Tội'),
          _navItem(context, RealCmIcons.confirmation, 'Sổ Thêm Sức'),
          _navItem(context, RealCmIcons.marriage, 'Sổ Hôn Phối'),
          _navItem(context, RealCmIcons.anointing, 'Sổ Xức Dầu'),
          _navItem(context, RealCmIcons.funeral, 'Sổ An Táng'),
          const Divider(),
          _navItem(context, RealCmIcons.group, 'Đoàn thể'),
          _navItem(context, RealCmIcons.mass, 'Lễ ý cầu nguyện'),
          _navItem(context, RealCmIcons.calendar, 'Lịch phụng vụ'),
          _navItem(context, RealCmIcons.donation, 'Sổ thu chi'),
          _navItem(context, RealCmIcons.report, 'Báo cáo'),
          const Divider(),
          _navItem(context, RealCmIcons.settings, 'Cấu hình giáo xứ'),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext ctx, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(ctx).pop();
        realCmToast(ctx, 'Module "$label" sẽ làm phase tiếp', type: RealCmToastType.info);
      },
    );
  }

  static String _roleLabel(String role) {
    switch (role) {
      case 'priest_pastor':
        return 'Cha xứ';
      case 'priest_assistant':
        return 'Cha phó';
      case 'secretary':
        return 'Thư ký';
      case 'council_member':
        return 'Hội đồng mục vụ';
      default:
        return 'Khách';
    }
  }
}
