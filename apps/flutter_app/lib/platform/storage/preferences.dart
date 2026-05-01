// User preferences — theme mode + language (lưu Hive local).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'adapter.dart';

class RealCmPreferences {
  RealCmPreferences._();

  static ThemeMode loadThemeMode() {
    final raw = RealCmStorageAdapter.settings().get('theme_mode') as String?;
    switch (raw) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await RealCmStorageAdapter.settings().put('theme_mode', mode.name);
  }

  static Locale loadLocale() {
    final raw = RealCmStorageAdapter.settings().get('locale') as String?;
    return Locale(raw ?? 'vi');
  }

  static Future<void> saveLocale(Locale locale) async {
    await RealCmStorageAdapter.settings().put('locale', locale.languageCode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(),
);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(RealCmPreferences.loadThemeMode());

  Future<void> set(ThemeMode mode) async {
    await RealCmPreferences.saveThemeMode(mode);
    state = mode;
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(),
);

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(RealCmPreferences.loadLocale());

  Future<void> set(Locale locale) async {
    await RealCmPreferences.saveLocale(locale);
    state = locale;
  }
}
