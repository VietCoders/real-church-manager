import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/stats/repository.dart';
import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '_shell.dart';

final _statsRepoProvider = Provider((_) => StatsRepository());
final _memberCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.read(_statsRepoProvider).totalActiveMembers(),
);

class MemberCountCard extends ConsumerWidget {
  const MemberCountCard({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_memberCountProvider);
    return async.when(
      loading: () => DashboardStatsShell(
        title: 'Tổng giáo dân', icon: RealCmIcons.member,
        iconColor: RealCmColors.primary, value: '...', loading: true,
      ),
      error: (e, _) => DashboardStatsShell(
        title: 'Tổng giáo dân', icon: RealCmIcons.member,
        iconColor: RealCmColors.primary, value: '0', error: 'Lỗi tải',
      ),
      data: (n) => DashboardStatsShell(
        title: 'Tổng giáo dân', icon: RealCmIcons.member,
        iconColor: RealCmColors.primary, value: '$n', subtitle: 'đang hoạt động',
      ),
    );
  }
}
