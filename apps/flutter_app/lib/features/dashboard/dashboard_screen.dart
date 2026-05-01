// Dashboard screen — view mode wrap qua RealCmAppShell (responsive sidebar).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/dashboard/repository.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../domain/dashboard/widget_spec.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../platform/storage/adapter.dart';
import '../../ui/scaffold/app_shell.dart';
import 'customize_screen.dart';
import 'widget_registry.dart';

const _kOnboardingDismissedKey = 'onboarding.dismissed';

/// Check parish_settings rỗng và đề xuất onboarding cho priest_pastor.
Future<void> _maybeShowOnboarding(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(realCmAuthProvider);
  if (!auth.isPriestPastor) return;
  final box = RealCmStorageAdapter.settings();
  if ((box.get(_kOnboardingDismissedKey) as bool?) ?? false) return;
  try {
    final pb = RealCmPocketBase.instance();
    final list = await pb.collection('parish_settings').getList(page: 1, perPage: 1);
    if (list.items.isNotEmpty) return; // đã có config
    if (!context.mounted) return;
    // Hiển thị banner suggest onboarding
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(RealCmIcons.parish, size: 40, color: RealCmColors.primary),
        title: const Text('Chào mừng tới Real Church Manager'),
        content: const Text(
          'Đây là lần đầu mở app. Bạn có muốn cấu hình thông tin giáo xứ ngay?\n\n'
          'Cha xứ + tên giáo xứ sẽ hiển thị trên chứng chỉ Bí Tích.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await box.put(_kOnboardingDismissedKey, true);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Để sau'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Cấu hình ngay'),
            onPressed: () {
              Navigator.of(ctx).pop();
              ctx.push('/onboarding');
            },
          ),
        ],
      ),
    );
  } catch (_) {
    // Bỏ qua nếu không kết nối được — sẽ check lại lần sau
  }
}

final dashboardRepoProvider = Provider((_) => DashboardLayoutRepository());

final dashboardLayoutProvider =
    FutureProvider.autoDispose<List<DashboardWidgetSpec>>((ref) async {
  final layout = await ref.read(dashboardRepoProvider).load();
  return DashboardWidgetRegistry.mergeWithDefaults(layout.widgets);
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();

  static double _widthFor(DashboardWidgetSize size, double available) {
    switch (size) {
      case DashboardWidgetSize.sm:
        return 240.0.clamp(160.0, available);
      case DashboardWidgetSize.md:
        return 380.0.clamp(280.0, available);
      case DashboardWidgetSize.lg:
        return 580.0.clamp(280.0, available);
      case DashboardWidgetSize.xl:
        return available;
    }
  }

  static double _heightFor(DashboardWidgetSize size) {
    switch (size) {
      case DashboardWidgetSize.sm: return 140.0;
      case DashboardWidgetSize.md: return 320.0;
      case DashboardWidgetSize.lg: return 360.0;
      case DashboardWidgetSize.xl: return 400.0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutAsync = ref.watch(dashboardLayoutProvider);
    return RealCmAppShell(
      title: 'Bảng điều khiển',
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
      ],
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
            return _EmptyDashboardCta(onCustomize: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const DashboardCustomizeScreen(),
              ));
              ref.invalidate(dashboardLayoutProvider);
            });
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardLayoutProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(RealCmSpacing.s4),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final available = constraints.maxWidth;
                  return Wrap(
                    spacing: RealCmSpacing.s3,
                    runSpacing: RealCmSpacing.s3,
                    children: visible.map((spec) {
                      final meta = DashboardWidgetRegistry.meta(spec.type);
                      return SizedBox(
                        width: _widthFor(spec.size, available),
                        height: _heightFor(spec.size),
                        child: meta == null
                            ? _UnknownWidget(type: spec.type)
                            : meta.builder(ref, spec),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyDashboardCta extends StatelessWidget {
  const _EmptyDashboardCta({required this.onCustomize});
  final VoidCallback onCustomize;
  @override
  Widget build(BuildContext context) {
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
              onPressed: onCustomize,
            ),
          ],
        ),
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
      child: Center(child: Text('Widget không xác định: $type', style: const TextStyle(color: RealCmColors.textMuted))),
    );
  }
}
