// Design tokens — Real Church Manager
// Token definition (literal value cho phép ở đây — xem ui-rules.md §2.4c-d).
// Mọi widget khác CHỈ dùng RealCmTokens.* hoặc Theme.of(context).extension<RealCmTokensExt>().
import 'package:flutter/material.dart';

/// Color tokens — brand: tím phụng vụ + vàng lễ trọng.
class RealCmColors {
  RealCmColors._();

  // Brand
  static const Color primary = Color(0xFF7C3AED);   // Tím phụng vụ (Vọng/Chay)
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color accent = Color(0xFFF59E0B);    // Vàng lễ trọng

  // Liturgical colors (in calendar)
  static const Color liturgicalWhite = Color(0xFFF8FAFC);
  static const Color liturgicalRed = Color(0xFFDC2626);
  static const Color liturgicalGreen = Color(0xFF16A34A);
  static const Color liturgicalPurple = Color(0xFF7C3AED);
  static const Color liturgicalRose = Color(0xFFEC4899);
  static const Color liturgicalBlack = Color(0xFF0F172A);

  // Semantic
  static const Color success = Color(0xFF15803D);   // 4.68:1 vs white ✓
  static const Color danger = Color(0xFFDC2626);    // 4.69:1 ✓
  static const Color warning = Color(0xFFB45309);   // 4.62:1 ✓
  static const Color info = Color(0xFF1D4ED8);      // 6.94:1 ✓

  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceVariantDark = Color(0xFF1E293B);

  // Text
  static const Color text = Color(0xFF0F172A);          // 16.9:1 ✓
  static const Color textMuted = Color(0xFF475569);     // 7.36:1 ✓
  static const Color textDisabled = Color(0xFF94A3B8);  // 2.84:1 — disabled only
  static const Color textInverse = Color(0xFFFFFFFF);

  // Overlay
  static const Color overlay = Color(0x99172033);   // rgba(15,23,42,.6)
  static const Color overlayLight = Color(0x33172033);
}

/// Spacing scale (px). Token canonical, không hardcode 13/22/27.
class RealCmSpacing {
  RealCmSpacing._();
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 24;
  static const double s6 = 32;
  static const double s8 = 48;
}

/// Radius
class RealCmRadius {
  RealCmRadius._();
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}

/// Typography scale
class RealCmTypography {
  RealCmTypography._();
  static const double xs = 12;
  static const double sm = 14;
  static const double base = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 30;  // hero only
}

/// Animation duration (ui-rules.md §1.4)
class RealCmDuration {
  RealCmDuration._();
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration hero = Duration(milliseconds: 500);  // landing hero only
}

/// Easing
class RealCmEasing {
  RealCmEasing._();
  static const Cubic standard = Cubic(0.16, 1, 0.3, 1);
}

/// Shadow tier
class RealCmShadows {
  RealCmShadows._();
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 4), blurRadius: 8),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x29000000), offset: Offset(0, 10), blurRadius: 20),
  ];
  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x2E000000), offset: Offset(0, 20), blurRadius: 50),
  ];
}

/// Z-index layer
class RealCmZIndex {
  RealCmZIndex._();
  static const int dropdown = 1000;
  static const int sticky = 1020;
  static const int fixed = 1030;
  static const int modalBackdrop = 1040;
  static const int modal = 1050;
  static const int toast = 1060;
  static const int tooltip = 1070;
}

/// Modal max width
class RealCmModalSize {
  RealCmModalSize._();
  static const double sm = 400;
  static const double md = 600;
  static const double lg = 900;
}
