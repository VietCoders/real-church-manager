import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/stats/repository.dart';
import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '_shell.dart';

final _statsRepoProvider = Provider((_) => StatsRepository());
final _funeralYearProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.read(_statsRepoProvider).funeralsThisYear(),
);

class FuneralCountCard extends ConsumerWidget {
  const FuneralCountCard({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_funeralYearProvider);
    final yr = DateTime.now().year;
    return async.when(
      loading: () => DashboardStatsShell(
        title: 'An táng năm $yr', icon: RealCmIcons.funeral,
        iconColor: RealCmColors.textMuted, value: '...', loading: true,
      ),
      error: (e, _) => DashboardStatsShell(
        title: 'An táng năm $yr', icon: RealCmIcons.funeral,
        iconColor: RealCmColors.textMuted, value: '0', error: 'Lỗi tải',
      ),
      data: (n) => DashboardStatsShell(
        title: 'An táng năm $yr', icon: RealCmIcons.funeral,
        iconColor: RealCmColors.textMuted, value: '$n', subtitle: 'sổ An Táng',
      ),
    );
  }
}
