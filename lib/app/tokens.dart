import 'package:flutter/material.dart';

/// ÉLISE — central design tokens.
///
/// These are the only place in the codebase where colors, spacing, radii,
/// breakpoints, and motion timings are defined. Anything visual reaches for
/// a token first.
/// Brand palette — botanical sage, blush pink, and warm white.
class SsColors {
  SsColors._();

  // Surfaces
  static const Color ivory = Color(0xFFF7F8F3);
  static const Color surface = Color(0xFFFFFCFD);
  static const Color surfaceMuted = Color(0xFFF0F3EC);
  static const Color divider = Color(0xFFD9E1D5);
  static const Color grain = Color(0xFFE7ECE2);

  // Ink
  static const Color ink = Color(0xFF1E2720);
  static const Color inkMuted = Color(0xFF566158);
  static const Color inkSoft = Color(0xFF889286);

  // Accents
  // Legacy names are retained so older widgets inherit the new theme without
  // duplicating color values. `clay` is now the primary sage accent.
  static const Color clay = Color(0xFF7F947A);
  static const Color claySoft = Color(0xFFE9B8C5);
  static const Color sage = Color(0xFF72866D);
  static const Color sageSoft = Color(0xFFBFCDBA);
  static const Color rose = Color(0xFFD58FA5);
  static const Color gold = Color(0xFFF0CBD6);

  // Status
  static const Color error = Color(0xFFB04545);
  static const Color success = Color(0xFF4F7A4D);

  // Imagery placeholder fills (so we never show a broken image)
  static const List<Color> placeholderPalette = <Color>[
    Color(0xFFF4E5EA),
    Color(0xFFDDE7D8),
    Color(0xFFF8F9F5),
    Color(0xFFBFCDBA),
    Color(0xFFD58FA5),
    Color(0xFFE9B8C5),
    Color(0xFF72866D),
    Color(0xFF889286),
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
