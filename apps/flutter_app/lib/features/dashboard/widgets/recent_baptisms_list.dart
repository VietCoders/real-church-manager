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
final _recentBaptismsProvider = FutureProvider.autoDispose<List<RecordModel>>(
  (ref) => ref.read(_statsRepoProvider).recentBaptisms(limit: 5),
);

class RecentBaptismsList extends ConsumerWidget {
  const RecentBaptismsList({super.key, required this.spec});
  final DashboardWidgetSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_recentBaptismsProvider);
    final df = DateFormat('dd/MM/yyyy', 'vi');
    return DashboardWidgetShell(
      title: 'Rửa tội gần nhất',
      icon: RealCmIcons.baptism,
      iconColor: RealCmColors.info,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Không tải được')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Text('Chưa có sổ Rửa Tội nào', style: TextStyle(color: RealCmColors.textMuted)),
            );
          }
          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (_, i) {
              final r = records[i];
              final memberName = (r.expand['member_id'] as List?)?.firstOrNull?.data['full_name'] as String? ?? '(không rõ tên)';
              final dateRaw = r.data['baptism_date']?.toString() ?? '';
              final date = DateTime.tryParse(dateRaw);
              return Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: RealCmColors.info.withValues(alpha: 0.15),
                    child: const Icon(RealCmIcons.baptism, size: 16, color: RealCmColors.info),
                  ),
                  const SizedBox(width: RealCmSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(memberName, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (date != null)
                          Text(df.format(date), style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
                      ],
                    ),
                  ),
                  if (r.data['book_number'] != null && r.data['book_number'].toString().isNotEmpty)
                    Text('#${r.data['book_number']}', style: const TextStyle(fontSize: 11, color: RealCmColors.textMuted)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
