// Dashboard widget registry — đăng ký các loại widget có sẵn.
// Mọi widget mới phải đăng ký ở đây + thêm vào _defaultLayout.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/icons.dart';
import '../../domain/dashboard/widget_spec.dart';
import 'widgets/baptism_count_card.dart';
import 'widgets/family_count_card.dart';
import 'widgets/funeral_count_card.dart';
import 'widgets/marriage_count_card.dart';
import 'widgets/member_count_card.dart';
import 'widgets/members_by_age_chart.dart';
import 'widgets/members_by_gender_chart.dart';
import 'widgets/recent_baptisms_list.dart';
import 'widgets/upcoming_birthdays_list.dart';
import 'widgets/upcoming_feast_days_list.dart';

class DashboardWidgetMeta {
  const DashboardWidgetMeta({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.defaultSize,
    required this.builder,
  });

  final String type;
  final String title;
  final String description;
  final IconData icon;
  final DashboardWidgetSize defaultSize;
  final Widget Function(WidgetRef ref, DashboardWidgetSpec spec) builder;
}

class DashboardWidgetRegistry {
  DashboardWidgetRegistry._();

  static final Map<String, DashboardWidgetMeta> _registry = {
    'stats.member_count': DashboardWidgetMeta(
      type: 'stats.member_count',
      title: 'Tổng giáo dân',
      description: 'Số giáo dân đang hoạt động trong giáo xứ',
      icon: RealCmIcons.member,
      defaultSize: DashboardWidgetSize.sm,
      builder: (ref, spec) => MemberCountCard(spec: spec),
    ),
    'stats.family_count': DashboardWidgetMeta(
      type: 'stats.family_count',
      title: 'Tổng gia đình',
      description: 'Số gia đình đăng ký trong giáo xứ',
      icon: RealCmIcons.family,
      defaultSize: DashboardWidgetSize.sm,
      builder: (ref, spec) => FamilyCountCard(spec: spec),
    ),
    'stats.baptism_year': DashboardWidgetMeta(
      type: 'stats.baptism_year',
      title: 'Rửa tội năm nay',
      description: 'Số rửa tội thực hiện trong năm hiện tại',
      icon: RealCmIcons.baptism,
      defaultSize: DashboardWidgetSize.sm,
      builder: (ref, spec) => BaptismCountCard(spec: spec),
    ),
    'stats.marriage_year': DashboardWidgetMeta(
      type: 'stats.marriage_year',
      title: 'Hôn phối năm nay',
      description: 'Số hôn phối thực hiện trong năm',
      icon: RealCmIcons.marriage,
      defaultSize: DashboardWidgetSize.sm,
      builder: (ref, spec) => MarriageCountCard(spec: spec),
    ),
    'stats.funeral_year': DashboardWidgetMeta(
      type: 'stats.funeral_year',
      title: 'An táng năm nay',
      description: 'Số an táng/qua đời trong năm',
      icon: RealCmIcons.funeral,
      defaultSize: DashboardWidgetSize.sm,
      builder: (ref, spec) => FuneralCountCard(spec: spec),
    ),
    'chart.members_by_age': DashboardWidgetMeta(
      type: 'chart.members_by_age',
      title: 'Phân bổ theo độ tuổi',
      description: 'Biểu đồ cột phân nhóm giáo dân theo độ tuổi',
      icon: RealCmIcons.report,
      defaultSize: DashboardWidgetSize.lg,
      builder: (ref, spec) => MembersByAgeChart(spec: spec),
    ),
    'chart.members_by_gender': DashboardWidgetMeta(
      type: 'chart.members_by_gender',
      title: 'Phân bổ theo giới tính',
      description: 'Biểu đồ tròn nam/nữ',
      icon: RealCmIcons.report,
      defaultSize: DashboardWidgetSize.md,
      builder: (ref, spec) => MembersByGenderChart(spec: spec),
    ),
    'list.recent_baptisms': DashboardWidgetMeta(
      type: 'list.recent_baptisms',
      title: 'Rửa tội gần nhất',
      description: '5 rửa tội mới nhất',
      icon: RealCmIcons.baptism,
      defaultSize: DashboardWidgetSize.lg,
      builder: (ref, spec) => RecentBaptismsList(spec: spec),
    ),
    'list.upcoming_birthdays': DashboardWidgetMeta(
      type: 'list.upcoming_birthdays',
      title: 'Sinh nhật sắp tới',
      description: 'Giáo dân có sinh nhật trong 30 ngày tới',
      icon: RealCmIcons.calendar,
      defaultSize: DashboardWidgetSize.lg,
      builder: (ref, spec) => UpcomingBirthdaysList(spec: spec),
    ),
    'list.upcoming_feast_days': DashboardWidgetMeta(
      type: 'list.upcoming_feast_days',
      title: 'Bổn mạng sắp tới',
      description: 'Lễ Thánh bổn mạng trong 30 ngày tới + danh sách giáo dân',
      icon: RealCmIcons.parish,
      defaultSize: DashboardWidgetSize.lg,
      builder: (ref, spec) => UpcomingFeastDaysList(spec: spec),
    ),
  };

  static Map<String, DashboardWidgetMeta> get all => Map.unmodifiable(_registry);

  static DashboardWidgetMeta? meta(String type) => _registry[type];

  /// Layout mặc định khi user chưa custom: 5 stats cards + 2 chart + 2 list.
  static List<DashboardWidgetSpec> defaultLayout() => [
        const DashboardWidgetSpec(type: 'stats.member_count', order: 0, size: DashboardWidgetSize.sm),
        const DashboardWidgetSpec(type: 'stats.family_count', order: 1, size: DashboardWidgetSize.sm),
        const DashboardWidgetSpec(type: 'stats.baptism_year', order: 2, size: DashboardWidgetSize.sm),
        const DashboardWidgetSpec(type: 'stats.marriage_year', order: 3, size: DashboardWidgetSize.sm),
        const DashboardWidgetSpec(type: 'chart.members_by_age', order: 4, size: DashboardWidgetSize.lg),
        const DashboardWidgetSpec(type: 'chart.members_by_gender', order: 5, size: DashboardWidgetSize.md),
        const DashboardWidgetSpec(type: 'stats.funeral_year', order: 6, size: DashboardWidgetSize.sm, enabled: false),
        const DashboardWidgetSpec(type: 'list.recent_baptisms', order: 7, size: DashboardWidgetSize.lg),
        const DashboardWidgetSpec(type: 'list.upcoming_birthdays', order: 8, size: DashboardWidgetSize.lg),
      ];

  /// Merge layout đã save với registry hiện tại — thêm widget mới (chưa có trong save) ở cuối.
  static List<DashboardWidgetSpec> mergeWithDefaults(List<DashboardWidgetSpec> saved) {
    if (saved.isEmpty) return defaultLayout();
    final knownTypes = saved.map((s) => s.type).toSet();
    final defaults = defaultLayout();
    final additions = defaults.where((d) => !knownTypes.contains(d.type)).toList();
    final maxOrder = saved.fold<int>(0, (m, s) => s.order > m ? s.order : m);
    final addedReindexed = <DashboardWidgetSpec>[];
    for (var i = 0; i < additions.length; i++) {
      addedReindexed.add(additions[i].copyWith(order: maxOrder + 1 + i, enabled: false));
    }
    return [...saved, ...addedReindexed]..sort((a, b) => a.order.compareTo(b.order));
  }
}
