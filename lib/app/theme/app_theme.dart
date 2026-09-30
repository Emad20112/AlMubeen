import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_icon.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_shapes.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// **المصدر الوحيد للثيم** في التطبيق.
///
/// قبل هذه المرحلة كان `AppTheme` يعرّف 5 قيم فقط: `useMaterial3`،
/// `colorScheme`، `scaffoldBackgroundColor`، `appBarTheme`، `textTheme`،
/// ويترك كل شيء آخر لـ`ThemeData` الافتراضي. النتيجة أن 151 زرًا كانت كل
/// واحدة منها تستدعي `ButtonStyle` خاصًا بـ`BorderRadius.circular(12)` أو
/// padding مكتوب يدويًا، و28 `InputDecoration` كانت كل واحدة تستدعي
/// `OutlineInputBorder(...)`.
///
/// كل ما تحت هذا الصنف هو **الافتراضي المُعلن مرة واحدة**. أي Widget يقرأ
/// `Theme.of(context)` يجد القيم الموحّدة تلقائيًا دون أن يستدعي `styleFrom`،
/// والمواقع الشاذة تُصحَّح لاحقًا في مهام الـmigration — وليس هنا — حتى لا
/// يمسّ هذا الملف أي Feature.
abstract final class AppTheme {
  /// 🛡️ PERF: يُبنى كل ثيم مرة واحدة فقط (lazy) وتُعاد إعادة استخدامه.
  /// سابقًا كان `ColorScheme.fromSeed()` يُنفَّذ في كل نداء لـ`light()`/`dark()`.
  static final ThemeData _lightTheme = _buildLight();
  static final ThemeData _darkTheme = _buildDark();

  /// الثيم الفاتح الجاهز.
  static ThemeData light() => _lightTheme;

  /// الثيم الداكن الجاهز.
  static ThemeData dark() => _darkTheme;

  // ===========================================================================
  // Light
  // ===========================================================================

  static ThemeData _buildLight() {
    final colorScheme = _lightColorScheme;
    final colors = AppColorScheme.from(colorScheme, isDark: false);
    final text = AppTypography.light(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.canvas,
      appBarTheme: _appBar(colors, text, systemOverlay: _lightSystemOverlay),
      textTheme: text,
      primaryTextTheme: text,
      iconTheme: _iconTheme(colors),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: AppShapes.cardTheme(colors, radius: AppRadii.lg),
      filledButtonTheme: _filledButton(colors, text),
      elevatedButtonTheme: _elevatedButton(colors, text),
      outlinedButtonTheme: _outlinedButton(colors, text),
      textButtonTheme: _textButton(colors, text),
      iconButtonTheme: _iconButton(colors),
      segmentedButtonTheme: _segmentedButton(colors, text),
      inputDecorationTheme: _inputDecoration(colors, text),
      bottomSheetTheme: _bottomSheet(colors, text),
      dialogTheme: _dialog(colors, text),
      snackBarTheme: _snackBar(colors, text),
      chipTheme: _chip(colors, text),
      listTileTheme: _listTile(colors, text),
      bottomNavigationBarTheme: _bottomNav(colors, text),
      navigationBarTheme: _navBar(colors, text),
      progressIndicatorTheme: _progressIndicator(colors),
      switchTheme: _switch(colors),
      sliderTheme: _slider(colors),
      floatingActionButtonTheme: _fab(colors),
      tooltipTheme: _tooltip(colors, text),
      extensions: <ThemeExtension<dynamic>>[
        colors,
        const AppDesignTokens(
          radii: AppRadiusTokens.standard(),
          shadows: AppShadowsTokens(Brightness.light),
          motion: AppMotionTokens(),
          spacing: AppSpacingTokens(),
        ),
      ],
    );
  }

  /// قيم `ColorScheme` التي كان يستخدمها التطبيق قبل هذه المرحلة،
  /// محفوظة حرفيًا حتى لا يتغيّر أي عنصر بصري.
  static final ColorScheme _lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.goldLight,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.goldLight,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.brandBrown,
        onSecondary: AppColors.lightSurface,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightInk,
      );

  // ===========================================================================
  // Dark
  // ===========================================================================

  static ThemeData _buildDark() {
    final colorScheme = _darkColorScheme;
    final colors = AppColorScheme.from(colorScheme, isDark: true);
    final text = AppTypography.dark(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.canvas,
      appBarTheme: _appBar(colors, text, systemOverlay: _darkSystemOverlay),
      textTheme: text,
      primaryTextTheme: text,
      iconTheme: _iconTheme(colors),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: AppShapes.cardTheme(colors, radius: AppRadii.lg),
      filledButtonTheme: _filledButton(colors, text),
      elevatedButtonTheme: _elevatedButton(colors, text),
      outlinedButtonTheme: _outlinedButton(colors, text),
      textButtonTheme: _textButton(colors, text),
      iconButtonTheme: _iconButton(colors),
      segmentedButtonTheme: _segmentedButton(colors, text),
      inputDecorationTheme: _inputDecoration(colors, text),
      bottomSheetTheme: _bottomSheet(colors, text),
      dialogTheme: _dialog(colors, text),
      snackBarTheme: _snackBar(colors, text),
      chipTheme: _chip(colors, text),
      listTileTheme: _listTile(colors, text),
      bottomNavigationBarTheme: _bottomNav(colors, text),
      navigationBarTheme: _navBar(colors, text),
      progressIndicatorTheme: _progressIndicator(colors),
      switchTheme: _switch(colors),
      sliderTheme: _slider(colors),
      floatingActionButtonTheme: _fab(colors),
      tooltipTheme: _tooltip(colors, text),
      extensions: <ThemeExtension<dynamic>>[
        colors,
        const AppDesignTokens(
          radii: AppRadiusTokens.standard(),
          shadows: AppShadowsTokens(Brightness.dark),
          motion: AppMotionTokens(),
          spacing: AppSpacingTokens(),
        ),
      ],
    );
  }

  /// قيم `ColorScheme` التي كان يستخدمها التطبيق قبل هذه المرحلة،
  /// محفوظة حرفيًا حتى لا يتغيّر أي عنصر بصري.
  static final ColorScheme _darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.goldPale,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.goldPale,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.lightSurfaceMuted,
        onSecondary: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkInk,
      );

  // ===========================================================================
  // Component themes
  // ===========================================================================

  static AppBarTheme _appBar(
    AppColorScheme colors,
    TextTheme text, {
    required SystemUiOverlayStyle systemOverlay,
  }) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      // `surfaceTintColor` شفاف عمدًا: صبغة السطح في Material 3 تُلوّن
      // الأجسام المرتفعة بلون الـ`primary`، وهذا كان يُعطي أشرطة الاستخدام
      // العلوية درجة ذهبية غير مقصودة فوق خلفية ورقية.
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: systemOverlay,
      iconTheme: IconThemeData(color: colors.textPrimary, size: AppIcon.xl),
      titleTextStyle: AppTypography.headline(text),
    );
  }

  static IconThemeData _iconTheme(AppColorScheme colors) {
    return IconThemeData(color: colors.textPrimary, size: AppIcon.xl);
  }

  /// الأزرار المملوءة (`.filled`).
  ///
  /// اللون هنا **[AppColorScheme.primaryStrong] وليس `colorScheme.primary`**:
  /// الـ`primary` ذهبي (`#D4AF37`) ونصّه يجب أن يكون داكنًا، بينما الأزرار
  /// الفعلية في التطبيق بنية بنص فاتح. خلط الاثنين هو ما يُنتج أزرارًا ذهبية
  /// بنص غير مقروء، أو أزرارًا بنية تتضارب مع التدرّج الذهبي.
  static FilledButtonThemeData _filledButton(
    AppColorScheme colors,
    TextTheme text,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primaryStrong,
        foregroundColor: colors.onPrimaryStrong,
        disabledBackgroundColor: colors.surfaceSunken,
        disabledForegroundColor: colors.textDisabled,
        elevation: 0,
        minimumSize: const Size(
          AppSizes.minButtonWidth,
          AppSpacing.touchTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        shape: AppShapes.buttonMedium,
        textStyle: _buttonText(text),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButton(
    AppColorScheme colors,
    TextTheme text,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.surfaceElevated,
        foregroundColor: colors.textPrimary,
        disabledBackgroundColor: colors.surfaceSunken,
        disabledForegroundColor: colors.textDisabled,
        elevation: 1,
        minimumSize: const Size(
          AppSizes.minButtonWidth,
          AppSpacing.touchTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        shape: AppShapes.buttonMedium,
        textStyle: _buttonText(text),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButton(
    AppColorScheme colors,
    TextTheme text,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primaryStrong,
        disabledForegroundColor: colors.textDisabled,
        minimumSize: const Size(
          AppSizes.minButtonWidth,
          AppSpacing.touchTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        side: BorderSide(color: colors.borderStrong),
        shape: AppShapes.buttonMedium,
        textStyle: _buttonText(text),
      ),
    );
  }

  static TextButtonThemeData _textButton(
    AppColorScheme colors,
    TextTheme text,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primaryStrong,
        disabledForegroundColor: colors.textDisabled,
        minimumSize: const Size(0, AppSpacing.touchTargetCompact),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: AppShapes.buttonSmall,
        textStyle: _buttonText(text),
      ),
    );
  }

  static IconButtonThemeData _iconButton(AppColorScheme colors) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colors.textPrimary,
        disabledForegroundColor: colors.textDisabled,
        minimumSize: Size.square(AppSpacing.touchTarget),
        shape: AppShapes.buttonSmall,
      ),
    );
  }

  static SegmentedButtonThemeData _segmentedButton(
    AppColorScheme colors,
    TextTheme text,
  ) {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll<TextStyle?>(
          AppTypography.label(text)?.copyWith(fontWeight: AppTypography.medium),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.surfaceElevated;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryStrong;
          }
          return colors.textSecondary;
        }),
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: colors.border),
        ),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(
          AppShapes.segmented,
        ),
      ),
    );
  }

  static TextStyle? _buttonText(TextTheme text) {
    return AppTypography.label(
      text,
    )?.copyWith(fontWeight: AppTypography.semiBold);
  }

  // ---------------------------------------------------------------------------

  /// حقول الإدخال — 28 استدعاء لـ`OutlineInputBorder` كانت شاذة، وكلها الآن
  /// ترث شكلًا واحدًا من `AppShapes` تلقائيًا.
  static InputDecorationThemeData _inputDecoration(
    AppColorScheme colors,
    TextTheme text,
  ) {
    return InputDecorationThemeData(
      filled: true,
      fillColor: colors.surfaceSunken,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      hintStyle: AppTypography.body(text)?.copyWith(color: colors.textTertiary),
      labelStyle: AppTypography.bodySmall(
        text,
      )?.copyWith(color: colors.textSecondary),
      floatingLabelStyle: AppTypography.bodySmall(
        text,
      )?.copyWith(color: colors.primaryStrong),
      errorStyle: AppTypography.caption(
        text,
      )?.copyWith(color: colors.error, fontWeight: AppTypography.medium),
      border: AppShapes.input(colors),
      enabledBorder: AppShapes.input(colors),
      focusedBorder: AppShapes.inputFocused(colors),
      errorBorder: AppShapes.inputError(colors),
      focusedErrorBorder: AppShapes.inputError(colors),
      disabledBorder: AppShapes.inputDisabled(colors),
    );
  }

  // ---------------------------------------------------------------------------

  static BottomSheetThemeData _bottomSheet(
    AppColorScheme colors,
    TextTheme text,
  ) {
    return BottomSheetThemeData(
      backgroundColor: colors.surface,
      modalBackgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      showDragHandle: true,
      dragHandleColor: colors.borderStrong,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
    );
  }

  static DialogThemeData _dialog(AppColorScheme colors, TextTheme text) {
    return DialogThemeData(
      backgroundColor: colors.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.lg)),
      ),
      titleTextStyle: AppTypography.title(text)?.copyWith(
        color: colors.textPrimary,
        fontWeight: AppTypography.semiBold,
      ),
      contentTextStyle: AppTypography.body(
        text,
      )?.copyWith(color: colors.textSecondary),
    );
  }

  static SnackBarThemeData _snackBar(AppColorScheme colors, TextTheme text) {
    return SnackBarThemeData(
      backgroundColor: colors.textPrimary,
      contentTextStyle: AppTypography.bodySmall(
        text,
      )?.copyWith(color: colors.textInverse),
      actionTextColor: colors.accent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
    );
  }

  // ---------------------------------------------------------------------------

  static ChipThemeData _chip(AppColorScheme colors, TextTheme text) {
    return ChipThemeData(
      backgroundColor: colors.surfaceMuted,
      selectedColor: colors.surfaceElevated,
      disabledColor: colors.surfaceSunken,
      side: BorderSide(color: colors.border),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
      ),
      labelStyle: AppTypography.labelSmall(
        text,
      )?.copyWith(color: colors.textSecondary),
      secondaryLabelStyle: AppTypography.labelSmall(
        text,
      )?.copyWith(color: colors.textPrimary, fontWeight: AppTypography.medium),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    );
  }

  static ListTileThemeData _listTile(AppColorScheme colors, TextTheme text) {
    return ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: colors.surfaceMuted,
      iconColor: colors.textSecondary,
      textColor: colors.textPrimary,
      titleTextStyle: AppTypography.bodyLarge(
        text,
      )?.copyWith(color: colors.textPrimary),
      subtitleTextStyle: AppTypography.bodySmall(
        text,
      )?.copyWith(color: colors.textSecondary),
      minVerticalPadding: AppSpacing.sm,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
      ),
    );
  }

  // ---------------------------------------------------------------------------

  static BottomNavigationBarThemeData _bottomNav(
    AppColorScheme colors,
    TextTheme text,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colors.surface,
      selectedItemColor: colors.primaryStrong,
      unselectedItemColor: colors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTypography.caption(text)?.copyWith(
        fontWeight: AppTypography.semiBold,
        color: colors.primaryStrong,
      ),
      unselectedLabelStyle: AppTypography.caption(
        text,
      )?.copyWith(color: colors.textTertiary),
    );
  }

  static NavigationBarThemeData _navBar(AppColorScheme colors, TextTheme text) {
    return NavigationBarThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colors.surfaceMuted,
      elevation: 0,
      height: AppSizes.navBarHeight,
      labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
        AppTypography.caption(text),
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        return IconThemeData(
          size: AppIcon.xl,
          color: states.contains(WidgetState.selected)
              ? colors.primaryStrong
              : colors.textTertiary,
        );
      }),
    );
  }

  static ProgressIndicatorThemeData _progressIndicator(AppColorScheme colors) {
    return ProgressIndicatorThemeData(
      color: colors.primaryStrong,
      linearTrackColor: colors.surfaceSunken,
      circularTrackColor: colors.surfaceSunken,
    );
  }

  static SwitchThemeData _switch(AppColorScheme colors) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.textDisabled;
        }
        return states.contains(WidgetState.selected)
            ? colors.onPrimaryStrong
            : colors.surface;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.surfaceSunken;
        }
        return states.contains(WidgetState.selected)
            ? colors.primaryStrong
            : colors.surfaceSunken;
      }),
      trackOutlineColor: WidgetStatePropertyAll<Color>(colors.border),
    );
  }

  static SliderThemeData _slider(AppColorScheme colors) {
    return SliderThemeData(
      activeTrackColor: colors.primaryStrong,
      inactiveTrackColor: colors.surfaceSunken,
      thumbColor: colors.primaryStrong,
      overlayColor: colors.overlay,
      trackHeight: AppSizes.sliderTrack,
    );
  }

  static FloatingActionButtonThemeData _fab(AppColorScheme colors) {
    return FloatingActionButtonThemeData(
      backgroundColor: colors.primaryStrong,
      foregroundColor: colors.onPrimaryStrong,
      elevation: 2,
      highlightElevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.lg)),
      ),
    );
  }

  static TooltipThemeData _tooltip(AppColorScheme colors, TextTheme text) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.textPrimary,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      textStyle: AppTypography.labelSmall(
        text,
      )?.copyWith(color: colors.textInverse),
    );
  }

  // ---------------------------------------------------------------------------

  /// ألوان شريط النظام — كانت شفافة، فيختفي مؤشّر الوقت في الوضع الداكن فوق
  /// خلفية فاتحة والعكس.
  static const SystemUiOverlayStyle _lightSystemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  static const SystemUiOverlayStyle _darkSystemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );
}
