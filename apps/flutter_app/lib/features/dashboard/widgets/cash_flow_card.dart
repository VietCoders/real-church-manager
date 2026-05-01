// Dashboard widget — Cash flow tháng hiện tại + biểu đồ 6 tháng gần nhất.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '../../../platform/pocketbase/client.dart';
import '_shell.dart';

class _CashFlowSummary {
  _CashFlowSummary({required this.thisMonthIn, required this.thisMonthOut, required this.monthlyHistory});
  final num thisMonthIn;
  final num thisMonthOut;
  final List<({DateTime month, num income, num expense})> monthlyHistory;

  num get balance => thisMonthIn - thisMonthOut;
}

final _cashFlowProvider = FutureProvider.autoDispose<_CashFlowSummary>((ref) async {
  final pb = RealCmPocketBase.instance();
  final now = DateTime.now();
  // 6 tháng gần nhất
  final months = List.generate(6, (i) {
    final m = DateTime(now.year, now.month - 5 + i, 1);
    return m;
  });
  final history = <({DateTime month, num income, num expense})>[];
  num thisIn = 0, thisOut = 0;
  for (var i = 0; i < months.length; i++) {
    final start = months[i];
    final end = i + 1 < months.length ? months[i + 1] : DateTime(now.year, now.month + 1, 1);
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);
    try {
      final res = await pb.collection('donations').getList(
        page: 1, perPage: 500,
        filter: 'date >= "$startStr" && date < "$endStr"',
      );
      num inSum = 0, outSum = 0;
      for (final r in res.items) {
        final amt = (r.data['amount'] as num?) ?? 0;
        if (r.data['type']?.toString() == 'expense') {
          outSum += amt;
        } else {
          inSum += amt;
        }
      }
      history.add((month: start, income: inSum, expense: outSum));
      if (start.year == now.year && start.month == now.month) {
        thisIn = inSum;
        thisOut = outSum;
      }
    } catch (_) {
      history.add((month: start, income: 0, expense: 0));
    }
  }
  return _CashFlowSummary(thisMonthIn: thisIn, thisMonthOut: thisOut, monthlyHistory: history);
});

class CashFlowCard extends ConsumerWidget {
  const CashFlowCard({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_cashFlowProvider);
    final fmt = NumberFormat.compactCurrency(locale: 'vi', symbol: '₫', decimalDigits: 0);
    return DashboardWidgetShell(
      title: 'Cash flow tháng',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: RealCmColors.success,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: RealCmColors.danger))),
        data: (s) {
          final maxV = s.monthlyHistory.fold<num>(0, (m, e) {
            final v = e.income > e.expense ? e.income : e.expense;
            return v > m ? v : m;
          });
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: _Stat(label: 'Thu tháng này', value: fmt.format(s.thisMonthIn), color: RealCmColors.success)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(label: 'Chi tháng này', value: fmt.format(s.thisMonthOut), color: RealCmColors.danger)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(
                label: 'Số dư',
                value: fmt.format(s.balance),
                color: s.balance >= 0 ? RealCmColors.primary : RealCmColors.warning,
              )),
            ]),
            const SizedBox(height: RealCmSpacing.s2),
            Expanded(
              child: maxV == 0
                  ? const Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: RealCmColors.textMuted)))
                  : BarChart(BarChartData(
                      maxY: maxV.toDouble() * 1.2,
                      alignment: BarChartAlignment.spaceAround,
                      groupsSpace: 8,
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true, reservedSize: 22,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= s.monthlyHistory.length) return const SizedBox();
                            final m = s.monthlyHistory[i].month;
                            return Padding(padding: const EdgeInsets.only(top: 4),
                              child: Text('T${m.month}', style: const TextStyle(fontSize: 10)));
                          },
                        )),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: List.generate(s.monthlyHistory.length, (i) {
                        final h = s.monthlyHistory[i];
                        return BarChartGroupData(
                          x: i,
                          barsSpace: 2,
                          barRods: [
                            BarChartRodData(toY: h.income.toDouble(), color: RealCmColors.success, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                            BarChartRodData(toY: h.expense.toDouble(), color: RealCmColors.danger, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                          ],
                        );
                      }),
                    )),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              _Legend(color: RealCmColors.success, label: 'Thu'),
              SizedBox(width: 12),
              _Legend(color: RealCmColors.danger, label: 'Chi'),
            ]),
          ]);
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: RealCmColors.textMuted)),
    ]);
  }
}
