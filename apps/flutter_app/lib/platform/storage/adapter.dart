// Hive adapter — quản lý box cho cache, offline queue, settings.
import 'package:hive_flutter/hive_flutter.dart';

class RealCmStorageAdapter {
  RealCmStorageAdapter._();

  /// Tên box (theo convention `real-cm:<purpose>`).
  static const String boxSettings = 'real-cm-settings';
  static const String boxAuth = 'real-cm-auth';
  static const String boxCacheMembers = 'real-cm-cache-members';
  static const String boxCacheFamilies = 'real-cm-cache-families';
  static const String boxCacheDistricts = 'real-cm-cache-districts';
  static const String boxCacheSacraments = 'real-cm-cache-sacraments';
  static const String boxOfflineQueue = 'real-cm-offline-queue';

  /// Mở core boxes (gọi 1 lần khi app start).
  static Future<void> openCoreBoxes() async {
    await Future.wait([
      Hive.openBox<dynamic>(boxSettings),
      Hive.openBox<dynamic>(boxAuth),
      Hive.openBox<dynamic>(boxCacheMembers),
      Hive.openBox<dynamic>(boxCacheFamilies),
      Hive.openBox<dynamic>(boxCacheDistricts),
      Hive.openBox<dynamic>(boxCacheSacraments),
      Hive.openBox<dynamic>(boxOfflineQueue),
    ]);
  }

  static Box<dynamic> settings() => Hive.box<dynamic>(boxSettings);
  static Box<dynamic> auth() => Hive.box<dynamic>(boxAuth);
}
