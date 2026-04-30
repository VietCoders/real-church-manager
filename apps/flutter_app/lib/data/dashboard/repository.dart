// Dashboard layout repository — đọc/ghi từ user.dashboard_layout JSON.
import '../../core/logging/logger.dart';
import '../../domain/dashboard/widget_spec.dart';
import '../../platform/pocketbase/client.dart';

class DashboardLayoutRepository {
  DashboardLayoutRepository();
  final _log = RealCmLogger.of('dashboard.repo');

  Future<DashboardLayout> load() async {
    final pb = RealCmPocketBase.instance();
    final user = pb.authStore.record;
    if (user == null) return DashboardLayout.empty();
    try {
      final raw = user.data['dashboard_layout'];
      if (raw == null || (raw is List && raw.isEmpty)) return DashboardLayout.empty();
      return DashboardLayout.fromJson(raw);
    } catch (e) {
      _log.warning('Lỗi parse dashboard_layout: $e');
      return DashboardLayout.empty();
    }
  }

  Future<DashboardLayout> save(DashboardLayout layout) async {
    final pb = RealCmPocketBase.instance();
    final user = pb.authStore.record;
    if (user == null) throw StateError('Chưa đăng nhập.');
    final res = await pb.collection('users').update(user.id, body: {
      'dashboard_layout': layout.toJson(),
    });
    pb.authStore.save(pb.authStore.token, res);
    _log.info('Đã lưu dashboard layout (${layout.widgets.length} widget)');
    return layout;
  }
}
