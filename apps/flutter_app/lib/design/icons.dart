// IconMap — semantic name → IconData. Đổi icon set = sửa 1 file (ui-rules.md §3.5).
import 'package:flutter/material.dart';

class RealCmIcons {
  RealCmIcons._();

  // Navigation
  static const IconData home = Icons.home_outlined;
  static const IconData back = Icons.arrow_back;
  static const IconData close = Icons.close;
  static const IconData menu = Icons.menu;
  static const IconData more = Icons.more_vert;
  static const IconData settings = Icons.settings_outlined;
  static const IconData search = Icons.search;

  // Action
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData save = Icons.save_outlined;
  static const IconData cancel = Icons.cancel_outlined;
  static const IconData refresh = Icons.refresh;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData download = Icons.download_outlined;
  static const IconData upload = Icons.upload_outlined;
  static const IconData print = Icons.print_outlined;
  static const IconData share = Icons.share_outlined;
  static const IconData copy = Icons.copy_outlined;

  // Status
  static const IconData success = Icons.check_circle_outline;
  static const IconData error = Icons.error_outline;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData info = Icons.info_outline;
  static const IconData loading = Icons.hourglass_empty;
  static const IconData done = Icons.check;

  // Auth
  static const IconData login = Icons.login;
  static const IconData logout = Icons.logout;
  static const IconData user = Icons.person_outline;
  static const IconData lock = Icons.lock_outline;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;

  // Domain — Church
  static const IconData parish = Icons.church_outlined;
  static const IconData member = Icons.person_outline;
  static const IconData family = Icons.family_restroom;
  static const IconData district = Icons.map_outlined;
  static const IconData group = Icons.groups_outlined;
  static const IconData mass = Icons.event_outlined;
  static const IconData calendar = Icons.calendar_month_outlined;
  static const IconData donation = Icons.volunteer_activism_outlined;
  static const IconData report = Icons.bar_chart_outlined;

  // Sacrament
  static const IconData baptism = Icons.water_drop_outlined;
  static const IconData confirmation = Icons.local_fire_department_outlined;
  static const IconData marriage = Icons.favorite_border;
  static const IconData anointing = Icons.healing_outlined;
  static const IconData funeral = Icons.spa_outlined;

  // Connection
  static const IconData wifi = Icons.wifi;
  static const IconData wifiOff = Icons.wifi_off;
  static const IconData sync = Icons.sync;
  static const IconData syncDone = Icons.cloud_done_outlined;
  static const IconData syncError = Icons.cloud_off_outlined;

  /// Resolve semantic name → IconData. Trả null nếu không có.
  static IconData? resolve(String name) {
    switch (name) {
      case 'home': return home;
      case 'back': return back;
      case 'close': return close;
      case 'menu': return menu;
      case 'more': return more;
      case 'settings': return settings;
      case 'search': return search;
      case 'add': return add;
      case 'edit': return edit;
      case 'delete': return delete;
      case 'save': return save;
      case 'parish': return parish;
      case 'member': return member;
      case 'family': return family;
      case 'district': return district;
      case 'group': return group;
      case 'mass': return mass;
      case 'calendar': return calendar;
      case 'donation': return donation;
      case 'report': return report;
      case 'baptism': return baptism;
      case 'confirmation': return confirmation;
      case 'marriage': return marriage;
      case 'anointing': return anointing;
      case 'funeral': return funeral;
      default: return null;
    }
  }
}
