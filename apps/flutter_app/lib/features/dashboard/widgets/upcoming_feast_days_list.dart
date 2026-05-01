// Dashboard widget — Lễ bổn mạng (Tên Thánh) sắp tới + giáo dân mang tên đó.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../design/icons.dart';
import '../../../design/tokens.dart';
import '../../../domain/dashboard/widget_spec.dart';
import '../../../domain/saint_feast/feast_days.dart';
import '../../../platform/pocketbase/client.dart';
import '_shell.dart';

class _FeastEntry {
  _FeastEntry({required this.feast, required this.date, required this.members});
  final SaintFeastDay feast;
  final DateTime date;
  final List<RecordModel> members;
}

final _upcomingFeastsProvider = FutureProvider.autoDispose<List<_FeastEntry>>((ref) async {
  final pb = RealCmPocketBase.instance();
  final upcoming = upcomingFeastDays(withinDays: 30);
  final out = <_FeastEntry>[];
  for (final entry in upcoming) {
    try {
      final res = await pb.collection('members').getList(
        page: 1, perPage: 20,
        filter: 'deleted_at = null && saint_name ~ "${entry.key.name}"',
        sort: 'full_name',
      );
      if (res.items.isNotEmpty) {
        out.add(_FeastEntry(feast: entry.key, date: entry.value, members: res.items));
      }
    } catch (_) {}
  }
  return out;
});

class UpcomingFeastDaysList extends ConsumerWidget {
  const UpcomingFeastDaysList({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_upcomingFeastsProvider);
    final df = DateFormat('dd/MM', 'vi');
    return DashboardWidgetShell(
      title: 'Bổn mạng 30 ngày tới',
      icon: RealCmIcons.parish,
      iconColor: RealCmColors.warning,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Không tải được')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Text('Không có lễ bổn mạng nào trong 30 ngày tới',
                  style: TextStyle(color: RealCmColors.textMuted)),
            );
          }
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (_, i) {
              final e = entries[i];
              final names = e.members
                  .map((m) => '${m.data['saint_name'] ?? ''} ${m.data['full_name'] ?? ''}'.trim())
                  .take(3)
                  .join(', ');
              final extra = e.members.length > 3 ? ' +${e.members.length - 3}' : '';
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: RealCmColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(RealCmIcons.parish, size: 18, color: RealCmColors.warning),
                  ),
                  const SizedBox(width: RealCmSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text('Thánh ${e.feast.name}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Text(df.format(e.date),
                              style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
                        ]),
                        if (e.feast.note != null)
                          Text(e.feast.note!,
                              style: const TextStyle(fontSize: 11, color: RealCmColors.textMuted)),
                        const SizedBox(height: 2),
                        Text('${e.members.length} giáo dân: $names$extra',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
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
