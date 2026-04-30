import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/stats/repository.dart';
import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '_shell.dart';

final _statsRepoProvider = Provider((_) => StatsRepository());
final _membersByAgeProvider = FutureProvider.autoDispose<Map<String, int>>(
  (ref) => ref.read(_statsRepoProvider).membersByAgeGroup(),
);

class MembersByAgeChart extends ConsumerWidget {
  const MembersByAgeChart({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_membersByAgeProvider);
    return DashboardWidgetShell(
      title: 'Phân bổ theo độ tuổi',
      icon: RealCmIcons.report,
      iconColor: RealCmColors.primary,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Không tải được dữ liệu')),
        data: (buckets) {
          final entries = buckets.entries.where((e) => e.key != 'Không rõ').toList();
          final maxY = entries.map((e) => e.value).fold<int>(0, (m, v) => v > m ? v : m).toDouble();
          if (maxY == 0) {
            return const Center(child: Text('Chưa có dữ liệu giáo dân', style: TextStyle(color: RealCmColors.textMuted)));
          }
          return BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: maxY / 4,
                    getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: RealCmSpacing.s1),
                        child: Text(entries[i].key, style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(entries.length, (i) {
                final e = entries[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.toDouble(),
                      color: RealCmColors.primary,
                      width: 22,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(RealCmRadius.sm)),
                    ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
