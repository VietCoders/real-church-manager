// Real Church Manager — Entry point
// Author: Đạo Trần · License: MIT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/logging/logger.dart';
import 'platform/storage/adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RealCmLogger.init();
  await Hive.initFlutter();
  await RealCmStorageAdapter.openCoreBoxes();

  runApp(const ProviderScope(child: RealCmApp()));
}
