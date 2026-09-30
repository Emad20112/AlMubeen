import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_motion.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_shadows.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// حاوية Design Tokens الخاصة بالتطبيق، مسجّلة كـ`ThemeExtension`.
///
/// ## لماذا `ThemeExtension`؟
///
/// التوكنز **لا تنتمي إلى `ColorScheme` ولا إلى `TextTheme`** — المسافات
/// والاستدارات والمدد ليست ألوانًا ولا نصوصًا، لكن Material توفّر مكانًا
/// رسميًا لها: [`ThemeExtension`]. به يقرأ أي Widget
/// `context.tokens.radii.medium` بالطريقة نفسها التي يقرأ بها
/// `context.colorScheme.primary`، ويظل كل شيء مسجّلًا مرة واحدة في
/// `AppTheme` بدل تكراره في 40 ملف.
///
/// ## ما لا يُوضع هنا عمدًا
///
/// - **الألوان** → [AppColorScheme]، وهو نفسه `ThemeExtension` لـ`ColorScheme`،
///   فيُقرأ `Theme.of(context).colorScheme.primaryStrong` مباشرة.
/// - **النصوص** → `TextTheme` القياسي في Material 3.
/// - **خط المصحف** → حزمة `qcf_quran` حصرًا.
@immutable
class AppDesignTokens extends ThemeExtension<AppDesignTokens> {
  const AppDesignTokens({
    required this.radii,
    required this.shadows,
    required this.motion,
    required this.spacing,
  });

  /// القيم الافتراضية الموحّدة (متطابقة بين الوضعين الفاتح والداكن).
  ///
  /// تُستخدم كـfallback عند استدعاء [of] خارج شجرة `MaterialApp`.
  const AppDesignTokens.standard()
    : radii = const AppRadiusTokens.standard(),
      shadows = const AppShadowsTokens(Brightness.light),
      motion = const AppMotionTokens(),
      spacing = const AppSpacingTokens();

  final AppRadiusTokens radii;
  final AppShadowsTokens shadows;
  final AppMotionTokens motion;
  final AppSpacingTokens spacing;

  // ---------------------------------------------------------------------------
  // الوصول من السياق
  // ---------------------------------------------------------------------------

  /// يقرأ التوكنز من السياق مع fallback آمن يعمل خارج `MaterialApp`
  /// (اختبارات، أو `Preview` بسيط).
  static AppDesignTokens of(BuildContext context) {
    return Theme.of(context).extension<AppDesignTokens>() ??
        const AppDesignTokens.standard();
  }

  // ---------------------------------------------------------------------------

  @override
  AppDesignTokens copyWith({
    AppRadiusTokens? radii,
    AppShadowsTokens? shadows,
    AppMotionTokens? motion,
    AppSpacingTokens? spacing,
  }) {
    return AppDesignTokens(
      radii: radii ?? this.radii,
      shadows: shadows ?? this.shadows,
      motion: motion ?? this.motion,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  AppDesignTokens lerp(covariant AppDesignTokens? other, double t) {
    if (other == null) return this;
    return AppDesignTokens(
      radii: radii,
      shadows: t < 0.5 ? shadows : other.shadows,
      motion: motion,
      spacing: spacing,
    );
  }
}

// ---------------------------------------------------------------------------
// Spacing tokens
// ---------------------------------------------------------------------------

/// نسخة المسافات المُخزَّنة داخل `ThemeExtension`.
///
/// القيم مطابقة تمامًا لـ[AppSpacing] — الغرض منها تمكين
/// `context.tokens.spacing.md` كبديل موحّد عن الاستيراد المباشر.
class AppSpacingTokens {
  const AppSpacingTokens();

  double get xs => AppSpacing.xs;
  double get sm => AppSpacing.sm;
  double get md => AppSpacing.md;
  double get lg => AppSpacing.lg;
  double get xl => AppSpacing.xl;
  double get xxl => AppSpacing.xxl;
  double get xxxl => AppSpacing.xxxl;
  double get screenPadding => AppSpacing.screenPadding;
  double get cardPadding => AppSpacing.cardPadding;
  double get listItemSpacing => AppSpacing.listItemSpacing;
  double get sectionSpacing => AppSpacing.sectionSpacing;
  double get touchTarget => AppSpacing.touchTarget;
  double get appBarHeight => AppSpacing.appBarHeight;
  double get contentMaxWidth => AppSpacing.contentMaxWidth;
  double get readingMaxWidth => AppSpacing.readingMaxWidth;
}

// ---------------------------------------------------------------------------
// Motion tokens
// ---------------------------------------------------------------------------

/// نسخة الحركة المُخزَّنة داخل `ThemeExtension`.
class AppMotionTokens {
  const AppMotionTokens();

  Duration get instant => AppMotion.instant;
  Duration get micro => AppMotion.micro;
  Duration get fast => AppMotion.fast;
  Duration get standard => AppMotion.standard;
  Duration get page => AppMotion.page;
  Duration get modal => AppMotion.modal;
  Duration get hero => AppMotion.hero;
  Curve get curve => AppMotion.standardCurve;
}

// ---------------------------------------------------------------------------
// Shadow tokens
// ---------------------------------------------------------------------------

/// نسخة الظلال المُخزَّنة داخل `ThemeExtension`، مربوطة بسطوع الثيم.
///
/// هذه هي الحالة التي يجب أن يعتمد عليها أي Widget: هي تتكيّف تلقائيًا مع
/// الوضع الفاتح/الداكن، وهو ما لم يكن موجودًا في المشروع قبل هذه المرحلة
/// (كانت الظلال سوداء واحدة للطرفين، فيختفي الإحساس بالارتفاع في الداكن).
class AppShadowsTokens {
  const AppShadowsTokens(this.brightness);

  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  List<BoxShadow> get none => AppShadows.none;

  List<BoxShadow> get subtle =>
      isDark ? AppShadows.subtleDark : AppShadows.subtleLight;

  List<BoxShadow> get medium =>
      isDark ? AppShadows.mediumDark : AppShadows.mediumLight;

  List<BoxShadow> get elevated =>
      isDark ? AppShadows.elevatedDark : AppShadows.elevatedLight;

  Color get color =>
      isDark ? AppShadows.darkShadowColor : AppShadows.lightShadowColor;

  double get blurSmall => AppShadows.blurSmall;
  double get blurMedium => AppShadows.blurMedium;
  double get blurLarge => AppShadows.blurLarge;

  /// ظل حسب المستوى: `0` بلا ظل، `1` subtle، `2` medium، `≥3` elevated.
  List<BoxShadow> at(int level) =>
      AppShadows.forLevel(brightness, level: level);
}

// ---------------------------------------------------------------------------
// اختصارات السياق
// ---------------------------------------------------------------------------

extension AppDesignTokensContext on BuildContext {
  /// `context.tokens` — اختصار لـ[AppDesignTokens.of].
  AppDesignTokens get tokens => AppDesignTokens.of(this);

  /// `context.semanticColors` — اختصار لـ[AppColorScheme.of].
  AppColorScheme get semanticColors => AppColorScheme.of(this);
}
