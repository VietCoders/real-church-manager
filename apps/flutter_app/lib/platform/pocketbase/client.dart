// PocketBase client wrapper — singleton + auth state restore + retry.
import 'package:pocketbase/pocketbase.dart';

import '../../core/logging/logger.dart';
import '../storage/adapter.dart';

class RealCmPocketBase {
  RealCmPocketBase._();

  static PocketBase? _instance;
  static final _log = RealCmLogger.of('pb');

  /// Get hoặc tạo client với base URL từ Hive settings.
  static PocketBase instance() {
    if (_instance != null) return _instance!;
    final url = backendUrl();
    if (url == null || url.isEmpty) {
      throw StateError('Backend URL chưa được cấu hình. Vào màn hình Setup để nhập.');
    }
    final store = AsyncAuthStore(
      save: (s) async => RealCmStorageAdapter.auth().put('token', s),
      initial: RealCmStorageAdapter.auth().get('token') as String?,
    );
    _instance = PocketBase(url, authStore: store);
    _log.info('PocketBase client init với URL: $url');
    return _instance!;
  }

  /// Reset client (vd khi đổi backend URL).
  static void reset() {
    _instance = null;
  }

  static String? backendUrl() {
    return RealCmStorageAdapter.settings().get('backend_url') as String?;
  }

  static Future<void> setBackendUrl(String url) async {
    await RealCmStorageAdapter.settings().put('backend_url', url);
    reset();
  }
}
