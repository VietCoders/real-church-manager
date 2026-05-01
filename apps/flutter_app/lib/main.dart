// Real Church Manager — Entry point
// Author: Đạo Trần · License: MIT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/logging/logger.dart';
import 'platform/health/health_monitor.dart';
import 'platform/storage/adapter.dart';
import 'platform/sync/queue.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RealCmLogger.init();
  await Hive.initFlutter();
  await RealCmStorageAdapter.openCoreBoxes();
  RealCmSyncQueue.instance.start();

  final container = ProviderContainer();
  // Khởi động health monitor sau khi backend URL được resolve.
  // Health monitor sẽ tự handle case backend chưa setup (catch lỗi).
  Future<void>.delayed(const Duration(seconds: 2)).then((_) {
    container.read(serverHealthProvider.notifier).start();
  });

  runApp(UncontrolledProviderScope(container: container, child: const RealCmApp()));
}
