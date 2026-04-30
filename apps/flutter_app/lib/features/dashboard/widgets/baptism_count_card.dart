import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/stats/repository.dart';
import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '_shell.dart';

final _statsRepoProvider = Provider((_) => StatsRepository());
final _baptismYearProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.read(_statsRepoProvider).baptismsThisYear(),
);

class BaptismCountCard extends ConsumerWidget {
  const BaptismCountCard({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_baptismYearProvider);
    final yr = DateTime.now().year;
    return async.when(
      loading: () => DashboardStatsShell(
        title: 'Rửa tội năm $yr', icon: RealCmIcons.baptism,
        iconColor: RealCmColors.info, value: '...', loading: true,
      ),
      error: (e, _) => DashboardStatsShell(
        title: 'Rửa tội năm $yr', icon: RealCmIcons.baptism,
        iconColor: RealCmColors.info, value: '0', error: 'Lỗi tải',
      ),
      data: (n) => DashboardStatsShell(
        title: 'Rửa tội năm $yr', icon: RealCmIcons.baptism,
        iconColor: RealCmColors.info, value: '$n', subtitle: 'sổ Rửa Tội',
      ),
    );
  }
}
