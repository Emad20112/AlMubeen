import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// 🛡️ PERF: يتم بناء الثيم مرة واحدة فقط (lazy) وإعادة استخدامه.
  /// سابقاً كان `ColorScheme.fromSeed()` يُنفَّذ في كل نداء لـ `light()`/`dark()`.
  static final ThemeData _lightTheme = _buildLight();
  static final ThemeData _darkTheme = _buildDark();

  static ThemeData light() => _lightTheme;

  static ThemeData dark() => _darkTheme;

  static ThemeData _buildLight() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.goldenAccent,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: AppColors.goldenAccent,
        onPrimary: AppColors.darkScaffold,
        secondary: AppColors.maroon800,
        onSecondary: AppColors.parchmentLight,
        surface: AppColors.parchmentLight,
        onSurface: AppColors.ink,
      ),
      scaffoldBackgroundColor: AppColors.parchment,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.parchmentLight,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }

  static ThemeData _buildDark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.goldenAccentDark,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: AppColors.goldenAccentDark,
        onPrimary: AppColors.darkScaffold,
        secondary: AppColors.parchmentMuted,
        onSecondary: AppColors.darkScaffold,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkInk,
      ),
      scaffoldBackgroundColor: AppColors.darkScaffold,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkScaffold,
        foregroundColor: AppColors.darkInk,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: AppColors.darkInk,
        displayColor: AppColors.darkInk,
      ),
    );
  }
}
