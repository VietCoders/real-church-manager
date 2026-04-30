import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/stats/repository.dart';
import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '_shell.dart';

final _statsRepoProvider = Provider((_) => StatsRepository());
final _upcomingBirthdaysProvider = FutureProvider.autoDispose<List<RecordModel>>(
  (ref) => ref.read(_statsRepoProvider).upcomingBirthdays(withinDays: 30),
);

class UpcomingBirthdaysList extends ConsumerWidget {
  const UpcomingBirthdaysList({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_upcomingBirthdaysProvider);
    final df = DateFormat('dd/MM', 'vi');
    final now = DateTime.now();
    return DashboardWidgetShell(
      title: 'Sinh nhật 30 ngày tới',
      icon: RealCmIcons.calendar,
      iconColor: RealCmColors.accent,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Không tải được')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Text('Không có sinh nhật nào trong 30 ngày tới',
                  style: TextStyle(color: RealCmColors.textMuted)),
            );
          }
          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (_, i) {
              final r = records[i];
              final saint = r.data['saint_name']?.toString() ?? '';
              final name = r.data['full_name']?.toString() ?? '';
              final displayName = saint.isNotEmpty ? '$saint $name' : name;
              final birthRaw = r.data['birth_date']?.toString() ?? '';
              final birth = DateTime.tryParse(birthRaw);
              final age = birth != null ? now.year - birth.year : null;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: RealCmColors.accent.withValues(alpha: 0.15),
                    child: const Icon(RealCmIcons.calendar, size: 16, color: RealCmColors.accent),
                  ),
                  const SizedBox(width: RealCmSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(
                          birth != null ? '${df.format(birth)}${age != null ? ' · sắp $age tuổi' : ''}' : '',
                          style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
