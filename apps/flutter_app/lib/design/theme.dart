// Theme — Material 3 light/dark từ tokens.
import 'package:flutter/material.dart';
import 'tokens.dart';

class RealCmTheme {
  RealCmTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: RealCmColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: RealCmColors.primary,
      secondary: RealCmColors.accent,
      surface: RealCmColors.surface,
      surfaceContainerHighest: RealCmColors.surfaceVariant,
      error: RealCmColors.danger,
    );
    return _build(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: RealCmColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: RealCmColors.primaryLight,
      secondary: RealCmColors.accent,
      surface: RealCmColors.surfaceDark,
      surfaceContainerHighest: RealCmColors.surfaceVariantDark,
      error: RealCmColors.danger,
    );
    return _build(scheme, Brightness.dark);
  }

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: scheme.surface,

      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: RealCmTypography.xl3, fontWeight: FontWeight.w700, color: scheme.onSurface),
        headlineMedium: TextStyle(fontSize: RealCmTypography.xl2, fontWeight: FontWeight.w600, color: scheme.onSurface),
        titleLarge: TextStyle(fontSize: RealCmTypography.xl, fontWeight: FontWeight.w600, color: scheme.onSurface),
        bodyLarge: TextStyle(fontSize: RealCmTypography.base, color: scheme.onSurface),
        bodyMedium: TextStyle(fontSize: RealCmTypography.sm, color: scheme.onSurface),
        labelLarge: TextStyle(fontSize: RealCmTypography.sm, fontWeight: FontWeight.w500, color: scheme.onSurface),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.lg)),
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s5, vertical: RealCmSpacing.s3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.md)),
          textStyle: const TextStyle(fontSize: RealCmTypography.sm, fontWeight: FontWeight.w500),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s5, vertical: RealCmSpacing.s3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.md)),
          side: BorderSide(color: scheme.primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: RealCmSpacing.s2),
        ),
      ),

      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(RealCmSpacing.s2)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? RealCmColors.surfaceVariantDark : RealCmColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RealCmRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RealCmRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: RealCmSpacing.s3),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.lg)),
      ),
    );
  }
}
