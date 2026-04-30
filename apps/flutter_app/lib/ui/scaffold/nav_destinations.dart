// Navigation destinations — định nghĩa duy nhất cho cả Drawer + NavigationRail.
import 'package:flutter/material.dart';
import '../../design/icons.dart';

class RealCmNavDestination {
  const RealCmNavDestination({
    required this.route,
    required this.icon,
    required this.label,
    this.section,
  });

  final String route;
  final IconData icon;
  final String label;
  final String? section;
}

const List<RealCmNavDestination> realCmDestinations = [
  RealCmNavDestination(route: '/', icon: RealCmIcons.home, label: 'Bảng điều khiển'),

  RealCmNavDestination(route: '/members', icon: RealCmIcons.member, label: 'Giáo dân', section: 'Giáo xứ'),
  RealCmNavDestination(route: '/families', icon: RealCmIcons.family, label: 'Gia đình', section: 'Giáo xứ'),
  RealCmNavDestination(route: '/districts', icon: RealCmIcons.district, label: 'Giáo họ', section: 'Giáo xứ'),

  RealCmNavDestination(route: '/sacrament/baptism', icon: RealCmIcons.baptism, label: 'Sổ Rửa Tội', section: 'Sổ Bí Tích'),
  RealCmNavDestination(route: '/sacrament/confirmation', icon: RealCmIcons.confirmation, label: 'Sổ Thêm Sức', section: 'Sổ Bí Tích'),
  RealCmNavDestination(route: '/sacrament/marriage', icon: RealCmIcons.marriage, label: 'Sổ Hôn Phối', section: 'Sổ Bí Tích'),
  RealCmNavDestination(route: '/sacrament/anointing', icon: RealCmIcons.anointing, label: 'Sổ Xức Dầu', section: 'Sổ Bí Tích'),
  RealCmNavDestination(route: '/sacrament/funeral', icon: RealCmIcons.funeral, label: 'Sổ An Táng', section: 'Sổ Bí Tích'),

  RealCmNavDestination(route: '/groups', icon: RealCmIcons.group, label: 'Đoàn thể', section: 'Mục vụ'),
  RealCmNavDestination(route: '/mass', icon: RealCmIcons.mass, label: 'Lễ ý cầu nguyện', section: 'Mục vụ'),
  RealCmNavDestination(route: '/calendar', icon: RealCmIcons.calendar, label: 'Lịch phụng vụ', section: 'Mục vụ'),
  RealCmNavDestination(route: '/donations', icon: RealCmIcons.donation, label: 'Sổ thu chi', section: 'Mục vụ'),
  RealCmNavDestination(route: '/reports', icon: RealCmIcons.report, label: 'Báo cáo', section: 'Mục vụ'),

  RealCmNavDestination(route: '/settings', icon: RealCmIcons.settings, label: 'Cấu hình giáo xứ', section: 'Hệ thống'),
];
