import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: SsColors.clay,
    brightness: Brightness.light,
    primary: SsColors.ink,
    onPrimary: SsColors.ivory,
    secondary: SsColors.clay,
    onSecondary: SsColors.ivory,
    surface: SsColors.ivory,
    onSurface: SsColors.ink,
    error: SsColors.error,
    onError: SsColors.ivory,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: SsColors.ivory,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
  );

  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme, SsColors.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: SsColors.ivory,
      foregroundColor: SsColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: _inputTheme(colorScheme),
    chipTheme: _chipTheme(colorScheme),
    dividerTheme: const DividerThemeData(
      color: SsColors.divider,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: SsColors.ink, size: 20),
    elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
    outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
    textButtonTheme: _textButtonTheme(colorScheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}

ThemeData buildDarkTheme() {
  // We keep the brand warm and editorial even in dark — but our primary
  // surface remains the light ivory per the PRD. Dark is provided for
  // system overrides; we still prefer light.
  return buildLightTheme();
}

TextTheme _buildTextTheme(TextTheme base, Color color) {
  final display = base.displayLarge!.copyWith(
    fontFamily: 'serif',
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    color: color,
    height: 1.05,
  );
  return base.copyWith(
    displayLarge: display.copyWith(fontSize: 64),
    displayMedium: display.copyWith(fontSize: 48),
    displaySmall: display.copyWith(fontSize: 36),
    headlineLarge: display.copyWith(fontSize: 32),
    headlineMedium: display.copyWith(fontSize: 26),
    headlineSmall: display.copyWith(fontSize: 22),
    titleLarge: base.titleLarge!.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 0.1,
    ),
    titleMedium: base.titleMedium!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
    ),
    bodyLarge: base.bodyLarge!.copyWith(
      fontSize: 16,
      height: 1.55,
      color: color,
    ),
    bodyMedium: base.bodyMedium!.copyWith(
      fontSize: 14,
      height: 1.55,
      color: color,
    ),
    bodySmall: base.bodySmall!.copyWith(
      fontSize: 12,
      height: 1.5,
      color: color.withValues(alpha: 0.7),
    ),
    labelLarge: base.labelLarge!.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
      color: color,
    ),
  );
}

InputDecorationTheme _inputTheme(ColorScheme scheme) {
  return InputDecorationTheme(
    filled: true,
    fillColor: SsColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SsRadii.sm),
      borderSide: const BorderSide(color: SsColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SsRadii.sm),
      borderSide: const BorderSide(color: SsColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SsRadii.sm),
      borderSide: const BorderSide(color: SsColors.ink, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SsRadii.sm),
      borderSide: const BorderSide(color: SsColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SsRadii.sm),
      borderSide: const BorderSide(color: SsColors.error, width: 1.5),
    ),
    labelStyle: const TextStyle(color: SsColors.inkMuted),
    hintStyle: const TextStyle(color: SsColors.inkMuted),
  );
}

ChipThemeData _chipTheme(ColorScheme scheme) {
  return ChipThemeData(
    backgroundColor: SsColors.surface,
    selectedColor: SsColors.ink,
    labelStyle: const TextStyle(
      color: SsColors.ink,
      fontSize: 12,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: const TextStyle(
      color: SsColors.ivory,
      fontSize: 12,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w500,
    ),
    side: const BorderSide(color: SsColors.divider),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    showCheckmark: false,
  );
}

ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme scheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: SsColors.ink,
      foregroundColor: SsColors.ivory,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SsRadii.sm),
      ),
      elevation: 0,
    ),
  );
}

OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: SsColors.ink,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      side: const BorderSide(color: SsColors.ink),
      textStyle: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SsRadii.sm),
      ),
    ),
  );
}

TextButtonThemeData _textButtonTheme(ColorScheme scheme) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: SsColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      textStyle: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// A simple route transition: fade the new page in with a small forward
/// translation. We keep this local so the entire app feels like one motion
/// system rather than relying on the platform default.
class FadeForwardsPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeForwardsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = CurvedAnimation(parent: animation, curve: SsCurves.entrance);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.015),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }
}
