import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/stats/repository.dart';
import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '_shell.dart';

final _statsRepoProvider = Provider((_) => StatsRepository());
final _genderProvider = FutureProvider.autoDispose<Map<String, int>>(
  (ref) => ref.read(_statsRepoProvider).membersByGender(),
);

class MembersByGenderChart extends ConsumerWidget {
  const MembersByGenderChart({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_genderProvider);
    return DashboardWidgetShell(
      title: 'Phân bổ theo giới tính',
      icon: RealCmIcons.report,
      iconColor: RealCmColors.accent,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Không tải được')),
        data: (m) {
          final total = (m['male'] ?? 0) + (m['female'] ?? 0) + (m['other'] ?? 0);
          if (total == 0) {
            return const Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: RealCmColors.textMuted)));
          }
          final sections = <PieChartSectionData>[
            if ((m['male'] ?? 0) > 0)
              PieChartSectionData(
                value: (m['male']!).toDouble(),
                color: RealCmColors.info,
                title: 'Nam\n${m['male']}',
                radius: 56,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            if ((m['female'] ?? 0) > 0)
              PieChartSectionData(
                value: (m['female']!).toDouble(),
                color: RealCmColors.primary,
                title: 'Nữ\n${m['female']}',
                radius: 56,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            if ((m['other'] ?? 0) > 0)
              PieChartSectionData(
                value: (m['other']!).toDouble(),
                color: RealCmColors.textMuted,
                title: 'Khác\n${m['other']}',
                radius: 56,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
          ];
          return PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 32,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          );
        },
      ),
    );
  }
}
