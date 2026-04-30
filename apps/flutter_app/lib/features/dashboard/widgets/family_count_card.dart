import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/stats/repository.dart';
import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '_shell.dart';

final _statsRepoProvider = Provider((_) => StatsRepository());
final _familyCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.read(_statsRepoProvider).totalFamilies(),
);

class FamilyCountCard extends ConsumerWidget {
  const FamilyCountCard({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_familyCountProvider);
    return async.when(
      loading: () => DashboardStatsShell(
        title: 'Tổng gia đình', icon: RealCmIcons.family,
        iconColor: RealCmColors.info, value: '...', loading: true,
      ),
      error: (e, _) => DashboardStatsShell(
        title: 'Tổng gia đình', icon: RealCmIcons.family,
        iconColor: RealCmColors.info, value: '0', error: 'Lỗi tải',
      ),
      data: (n) => DashboardStatsShell(
        title: 'Tổng gia đình', icon: RealCmIcons.family,
        iconColor: RealCmColors.info, value: '$n', subtitle: 'gia đình đăng ký',
      ),
    );
  }
}
