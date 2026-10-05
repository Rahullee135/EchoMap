import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build(AccentPalette palette, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: brightness,
    );
    final scheme = base.copyWith(
      primary: palette.primary,
      secondary: palette.secondary,
      tertiary: palette.secondary,
      surface: dark ? const Color(0xFF12121C) : const Color(0xFFFFFFFF),
      onSurface: dark ? const Color(0xFFF2F2F8) : const Color(0xFF14141F),
      surfaceContainerHighest:
          dark ? const Color(0xFF1D1D2B) : const Color(0xFFECEBF4),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF0B0B14) : const Color(0xFFF5F4FA),
      splashFactory: InkSparkle.splashFactory,
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .black
          .apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          )
          .copyWith(
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: scheme.onSurface,
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: scheme.onSurface,
            ),
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.onSurface.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.12),
        thumbColor: Colors.white,
        overlayColor: scheme.primary.withValues(alpha: 0.15),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: 0.2),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}

extension ThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Primary → secondary accent gradient used for hero surfaces.
  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors.primary, colors.tertiary],
      );
}
