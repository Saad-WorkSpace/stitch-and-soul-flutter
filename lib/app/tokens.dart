import 'package:flutter/material.dart';

/// Stitch & Soul — central design tokens.
///
/// These are the only place in the codebase where colors, spacing, radii,
/// breakpoints, and motion timings are defined. Anything visual reaches for
/// a token first.
/// Brand palette — warm ivory, ink, clay, muted sage.
class SsColors {
  SsColors._();

  // Surfaces
  static const Color ivory = Color(0xFFF5EFE6);
  static const Color surface = Color(0xFFFBF7F1);
  static const Color surfaceMuted = Color(0xFFEDE6D8);
  static const Color divider = Color(0xFFE0D7C5);
  static const Color grain = Color(0xFFE8E0CE);

  // Ink
  static const Color ink = Color(0xFF1B1A17);
  static const Color inkMuted = Color(0xFF5A554C);
  static const Color inkSoft = Color(0xFF8A8478);

  // Accents
  static const Color clay = Color(0xFFB4724B);
  static const Color claySoft = Color(0xFFD9B59A);
  static const Color sage = Color(0xFF7A8C73);
  static const Color sageSoft = Color(0xFFB7C2B0);
  static const Color rose = Color(0xFFB57A7A);
  static const Color gold = Color(0xFFB89A5A);

  // Status
  static const Color error = Color(0xFFB04545);
  static const Color success = Color(0xFF4F7A4D);

  // Imagery placeholder fills (so we never show a broken image)
  static const List<Color> placeholderPalette = <Color>[
    Color(0xFFE9DBC6),
    Color(0xFFD9C2A6),
    Color(0xFFC8B59A),
    Color(0xFFB7C2B0),
    Color(0xFFB57A7A),
    Color(0xFFB4724B),
    Color(0xFF7A8C73),
    Color(0xFF8A8478),
  ];
}

/// Spacing scale — 4-pt base.
class SsSpace {
  SsSpace._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 72;
  static const double gutter = 24;
}

class SsRadii {
  SsRadii._();
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 18;
  static const double pill = 999;
}

/// Breakpoints (logical px).
class SsBreakpoints {
  SsBreakpoints._();
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1280;
  static const double wide = 1600;
}

enum SsDevice { phone, tablet, desktop, wide }

SsDevice deviceOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < SsBreakpoints.phone) return SsDevice.phone;
  if (w < SsBreakpoints.tablet) return SsDevice.tablet;
  if (w < SsBreakpoints.desktop) return SsDevice.desktop;
  return SsDevice.wide;
}

/// Layout helpers
double pageMaxWidth(SsDevice d) {
  switch (d) {
    case SsDevice.phone:
      return 720;
    case SsDevice.tablet:
      return 980;
    case SsDevice.desktop:
      return 1280;
    case SsDevice.wide:
      return 1440;
  }
}

EdgeInsets pagePadding(SsDevice d) {
  switch (d) {
    case SsDevice.phone:
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    case SsDevice.tablet:
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    case SsDevice.desktop:
    case SsDevice.wide:
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
  }
}
