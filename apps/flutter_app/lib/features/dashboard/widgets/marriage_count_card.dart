import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/stats/repository.dart';
import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '_shell.dart';

final _statsRepoProvider = Provider((_) => StatsRepository());
final _marriageYearProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.read(_statsRepoProvider).marriagesThisYear(),
);

class MarriageCountCard extends ConsumerWidget {
  const MarriageCountCard({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_marriageYearProvider);
    final yr = DateTime.now().year;
    return async.when(
      loading: () => DashboardStatsShell(
        title: 'Hôn phối năm $yr', icon: RealCmIcons.marriage,
        iconColor: RealCmColors.accent, value: '...', loading: true,
      ),
      error: (e, _) => DashboardStatsShell(
        title: 'Hôn phối năm $yr', icon: RealCmIcons.marriage,
        iconColor: RealCmColors.accent, value: '0', error: 'Lỗi tải',
      ),
      data: (n) => DashboardStatsShell(
        title: 'Hôn phối năm $yr', icon: RealCmIcons.marriage,
        iconColor: RealCmColors.accent, value: '$n', subtitle: 'sổ Hôn Phối',
      ),
    );
  }
}
