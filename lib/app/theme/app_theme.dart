import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.maroon800,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: AppColors.maroon800,
        secondary: AppColors.maroon700,
        surface: AppColors.parchmentLight,
      ),
      scaffoldBackgroundColor: AppColors.parchment,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.maroon800,
        foregroundColor: AppColors.parchmentLight,
      ),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.maroon700,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: AppColors.parchmentLight,
        secondary: AppColors.parchmentMuted,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkScaffold,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkScaffold,
        foregroundColor: AppColors.parchmentLight,
      ),
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: AppColors.darkInk,
        displayColor: AppColors.darkInk,
      ),
    );
  }
}
