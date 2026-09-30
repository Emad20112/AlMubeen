import 'package:flutter/material.dart';

/// لوحة الألوان الخام (Raw Palette) للتطبيق.
///
/// ⚠️ **هذه ليست الواجهة التي يجب أن يعتمد عليها الـUI.**
///
/// كل الثوابت هنا **درجات خام** بلا معنى دلالي — بل إن أسماءها نفسها
/// **مضلّلة تاريخيًا**: `maroon900` هو أزرق رمادي (`#101720`)، و
/// `cardRed` **ليس أحمر** بل بني (`#7B5A44`)، و `cardRedDark` بيج.
///
/// نتيجة ذلك أن **65 لونًا آخر** تسرّب إلى ملفات الـUI تحت forma
/// `Color(0x…)` مباشرة. الجواب هنا: لا تحذف أيًا منها الآن (607 استدعاء
/// تعتمد عليها)، بل أضف فوقها طبقة دلالية — [`AppColorScheme`] — واجعل
/// الـ`Theme` والـComponents تعتمد عليها، ثم انقل الاستدعاءات تدريجيًا
/// في المهام القادمة.
///
/// @see `AppColorScheme` — الواجهة الدلالية الصحيحة للـWidgets.
abstract final class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------------
  // درجات داكنة (تُستخدم كألوان "أساسية" و"نص" في الوضع الفاتح)
  // ---------------------------------------------------------------------------

  /// `#101720` — أعمق درجة في اللوحة.
  static const Color deepInk = Color(0xFF101720);

  /// `#8A6B3B` — **اللون الفعلي للعلامة التجارية** (156 استدعاءًا).
  /// الاسم التاريخي `maroon800` مضلّل: هو بني دافئ وليس عنّابيًا.
  static const Color brandBrown = Color(0xFF8A6B3B);

  /// `#8A7E68` — رمادي دافئ (69 استدعاءًا). الاسم التاريخي `maroon700`.
  static const Color mutedTaupe = Color(0xFF8A7E68);

  /// `#B9AB8E` — رملي فاتح. الاسم التاريخي `maroon600`.
  static const Color sand = Color(0xFFB9AB8E);

  // ---------------------------------------------------------------------------
  // درجات فاتحة (الوضع الفاتح)
  // ---------------------------------------------------------------------------

  /// `#F5F1E8` — خلفية الشاشة الفاتحة.
  static const Color lightBackground = Color(0xFFF5F1E8);

  /// `#FFFFFC7` — سطح فاتح.
  static const Color lightSurface = Color(0xFFFFFCF7);

  /// `#E4D9C6` — سطح مكتوم.
  static const Color lightSurfaceMuted = Color(0xFFE4D9C6);

  /// `#1E1E1E` — نص فاتح.
  static const Color lightInk = Color(0xFF1E1E1E);

  // ---------------------------------------------------------------------------
  // درجات داكنة (الوضع الداكن)
  // ---------------------------------------------------------------------------

  /// `#0B1018` — خلفية الوضع الداكن.
  static const Color darkBackground = Color(0xFF0B1018);

  /// `#151C27` — سطح داكن.
  static const Color darkSurface = Color(0xFF151C27);

  /// `#1F2835` — سطح داكن مرتفع.
  static const Color darkSurfaceHigh = Color(0xFF1F2835);

  /// `#F6F0E5` — نص داكن.
  static const Color darkInk = Color(0xFFF6F0E5);

  // ---------------------------------------------------------------------------
  // Accent
  // ---------------------------------------------------------------------------

  /// `#D4AF37` — ذهب فاتح (`primary` في الوضع الفاتح).
  static const Color goldLight = Color(0xFFD4AF37);

  /// `#E8D6A5` — ذهب فاتح جدًا (`primary` في الوضع الداكن).
  static const Color goldPale = Color(0xFFE8D6A5);

  /// `#D8B457` — **الذهب الفعلي المستخدَم في 44 موضعًا** (تدرجات وأوراق
  /// القرآن). مختلف عن `goldPale`، وهذا بالضبط سبب ازدواجية الهوية البصرية.
  static const Color goldDeep = Color(0xFFD8B457);

  /// `#B8943A` — شريك تدرّج `goldDeep`.
  static const Color goldDeepEnd = Color(0xFFB8943A);

  // ---------------------------------------------------------------------------
  // ألوان الحالة
  // ---------------------------------------------------------------------------

  /// `#10B981` — أخضر نجاح (15 موضعًا). غير مرتبط بلوحة التراب/الذهب.
  ///
  /// ⚠️ هذا هو **السطوع الأصلي المستخدم في الشيفرة**، وهو يمرّ على خلفية
  /// ورقية بنسبة تباين 2.48 فقط — أي أقل من الحدّ 3.0 الذي تشترطه WCAG
  /// AA لعنصر غير نصّي. لذلك:
  ///
  /// - [successLight] (أغمق) = لون النجاح في **الوضع الفاتح** (تباين 5.4).
  /// - [successDark] (أفتح) = لون النجاح في **الوضع الداكن** (تباين 7.4).
  ///
  /// الاستخدام القديم بـ15 موضعًاOutside this file غير مُغيَّر — التبديل
  /// يقع في مرحلة الـmigration، وهذه هي الدرجة الصحيحة المعتمدة.
  static const Color successLight = Color(0xFF047857);

  /// `#34D399` — أخضر نجاح للوضع الداكن (تباين 7.4:1).
  static const Color successDark = Color(0xFF34D399);

  /// `#9B5E2E` — كهرماني تحذير.
  static const Color warningLight = Color(0xFF9B5E2E);

  /// `#8B0000` — أحمر خطأ بارد، مستخدَم في `network_error_banner` فقط.
  static const Color errorLight = Color(0xFF8B0000);

  /// `#D4A0A0` — أحمر باهت للوضع الداكن.
  static const Color errorDark = Color(0xFFD4A0A0);

  // ---------------------------------------------------------------------------
  // أسطح المصحف
  // ---------------------------------------------------------------------------

  /// `#F7F4EB` — ورق صفحة المصحف في الوضع الفاتح.
  static const Color mushafPageLight = Color(0xFFF7F4EB);

  /// `#161616` — ورق صفحة المصحف في الوضع الداكن.
  static const Color mushafPageDark = Color(0xFF161616);

  // ---------------------------------------------------------------------------
  // أسماء قديمة — محفوظة للتوافق الخلفي
  // ---------------------------------------------------------------------------

  // ignore: deprecated_member_use_from_same_package
  static const Color maroon900 = deepInk;
  // ignore: deprecated_member_use_from_same_package
  static const Color maroon800 = brandBrown;
  // ignore: deprecated_member_use_from_same_package
  static const Color maroon700 = mutedTaupe;
  // ignore: deprecated_member_use_from_same_package
  static const Color maroon600 = sand;
  // ignore: deprecated_member_use_from_same_package
  static const Color parchment = lightBackground;
  // ignore: deprecated_member_use_from_same_package
  static const Color parchmentLight = lightSurface;
  // ignore: deprecated_member_use_from_same_package
  static const Color parchmentMuted = lightSurfaceMuted;
  // ignore: deprecated_member_use_from_same_package
  static const Color ink = lightInk;
  // ignore: deprecated_member_use_from_same_package
  static const Color darkScaffold = darkBackground;
  // ignore: deprecated_member_use_from_same_package
  static const Color goldenAccent = goldLight;
  // ignore: deprecated_member_use_from_same_package
  static const Color goldenAccentDark = goldPale;
  // ignore: deprecated_member_use_from_same_package
  static const Color cardCream = Color(0xFFFFF8E8);
  // ignore: deprecated_member_use_from_same_package
  static const Color cardRed = Color(0xFF7B5A44);
  // ignore: deprecated_member_use_from_same_package
  static const Color cardRedDark = Color(0xFFE8D6C6);
}

/// نظام الألوان الدلالي للتطبيق (Semantic Color System).
///
/// يُقرأ عبر:
/// ```dart
/// final colors = AppColorScheme.of(context);
/// Container(color: colors.surfaceElevated);
/// ```
///
/// ## لماذا لا نضعها داخل `ColorScheme`؟
///
/// `ColorScheme` ليست عامة (generic) في إصدار Flutter الحالي، وترويسات
/// `copyWith`/`lerp` فيها ثابتة الأسماء، فلا يمكن توسيعها بأدوار مخصّصة
/// (`primaryStrong`, `surfaceGlass`, `textTertiary`…). لذلك هي
/// `ThemeExtension` مستقلّة، وهو نفس النمط المعتمد رسميًا من Flutter
/// لتوسيع نظام التصميم.
///
/// ## قاعدة التسمية
///
/// الأدوار هنا تصف **الوظيفة** لا **الدرجة**. ممنوع في كود جديد:
/// `Color(0xFF231A17)` أو `AppColors.maroon800`. المطلوب:
/// `colors.surfaceSunken` أو `colors.primaryStrong`.
///
/// **كل قيمة هنا مأخوذة من لون مستخدَم فعليًا في الشيفرة الحالية** — لا شيء
/// مُخترع، فالتغيير بصريًا صفري عند تبديل الاستدعاءات.
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.brightness,
    required this.primaryStrong,
    required this.onPrimaryStrong,
    required this.accent,
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.surfaceSunken,
    required this.surfaceGlass,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
    required this.overlay,
    required this.overlayStrong,
    required this.pageSurface,
    required this.onPageSurface,
    required this.accentGradient,
    required this.errorSurface,
    required this.glassBorder,
    required this.glassOverlay,
  });

  /// يبني النظام الدلالي انطلاقًا من `ColorScheme` جاهز + لهجة (Light/Dark).
  ///
  /// يحترم القيم التي يمرّرها `AppTheme` في [`base`] (وهي مطابقة لما كان
  /// يستخدمه التطبيق قبل هذه المرحلة: ذهبي `primary`، بني `secondary`).
  factory AppColorScheme.from(ColorScheme base, {required bool isDark}) {
    return isDark
        ? AppColorScheme(
            brightness: Brightness.dark,
            primaryStrong: AppColors.goldDeep,
            onPrimaryStrong: AppColors.darkBackground,
            accent: AppColors.goldPale,
            canvas: AppColors.darkBackground,
            surface: AppColors.darkBackground,
            surfaceElevated: AppColors.darkSurfaceHigh,
            surfaceMuted: const Color(0xFF231A17),
            surfaceSunken: const Color(0xFF1A1210),
            surfaceGlass: const Color(0x661A1210),
            textPrimary: AppColors.darkInk,
            textSecondary: AppColors.sand,
            textTertiary: const Color(0xFF8A7D72),
            textDisabled: const Color(0xFF5A5750),
            textInverse: AppColors.darkBackground,
            border: const Color(0xFF312223),
            borderStrong: const Color(0xFF4A3A36),
            divider: const Color(0x1AFFFFFF),
            success: AppColors.successDark,
            onSuccess: AppColors.darkBackground,
            warning: const Color(0xFFD9A05B),
            onWarning: AppColors.darkBackground,
            error: AppColors.errorDark,
            onError: AppColors.darkBackground,
            overlay: const Color(0x1A000000),
            overlayStrong: const Color(0x40000000),
            pageSurface: AppColors.mushafPageDark,
            onPageSurface: AppColors.darkInk,
            accentGradient: const <Color>[
              AppColors.goldDeep,
              AppColors.goldDeepEnd,
            ],
            errorSurface: const Color(0xFF2E1215),
            glassBorder: const Color(0x1AFFFFFF),
            glassOverlay: const Color(0x0DFFFFFF),
          )
        : AppColorScheme(
            brightness: Brightness.light,
            primaryStrong: AppColors.brandBrown,
            onPrimaryStrong: AppColors.lightSurface,
            accent: AppColors.goldLight,
            canvas: AppColors.lightBackground,
            surface: AppColors.lightSurface,
            surfaceElevated: AppColors.cardCream,
            surfaceMuted: AppColors.lightSurfaceMuted,
            surfaceSunken: const Color(0xFFEDE6D8),
            surfaceGlass: const Color(0xCCFFFFFC),
            textPrimary: AppColors.lightInk,
            textSecondary: AppColors.mutedTaupe,
            textTertiary: const Color(0xFF8A7D72),
            textDisabled: AppColors.sand,
            textInverse: AppColors.lightSurface,
            border: AppColors.lightSurfaceMuted,
            borderStrong: AppColors.sand,
            divider: const Color(0x1F1E1E1E),
            success: AppColors.successLight,
            onSuccess: AppColors.lightSurface,
            warning: AppColors.warningLight,
            onWarning: AppColors.lightSurface,
            error: AppColors.errorLight,
            onError: AppColors.lightSurface,
            overlay: const Color(0x0D1E1E1E),
            overlayStrong: const Color(0x261E1E1E),
            pageSurface: AppColors.mushafPageLight,
            onPageSurface: const Color(0xFF2C2821),
            accentGradient: const <Color>[
              AppColors.goldLight,
              AppColors.goldDeep,
            ],
            errorSurface: const Color(0xFFFFF0F0),
            glassBorder: const Color(0x1A000000),
            glassOverlay: const Color(0x0D000000),
          );
  }

  final Brightness brightness;

  // --- الهوية ---------------------------------------------------------------

  /// اللون الذي تمتلئ به البطاقات والأزرار الرئيسية في الواجهة.
  ///
  /// ⚠️ **هذا ليس `colorScheme.primary`.** الـ`primary` ذهبي (`#D4AF37`)
  /// بينما الواجهة الفعلية بنية (`#8A6B3B`) في الوضع الفاتح وذهبية عميقة
  /// (`#D8B457`) في الداكن. هذا التمييز هو أهم إصلاح في المرحلة الأولى.
  final Color primaryStrong;
  final Color onPrimaryStrong;

  /// اللون الذهبي الزخرفي: خطوط، تدرّجات، شارات.
  final Color accent;

  // --- الأسطح ---------------------------------------------------------------

  /// خلفية الصفحة (ما يراه المستخدم خلف كل شيء) — `Scaffold.backgroundColor`.
  ///
  /// مسمّاة [canvas] لأنها **ليست سطح مكوّن**: لا أزرار ولا أوراق.
  final Color canvas;

  /// سطح مكوّن: `AppBar`، `BottomSheet`، شريط التنقل.
  final Color surface;

  /// سطح مرتفع فوق [surface]: بطاقة، حوار، قائمة منسدلة، عنصر مختار.
  final Color surfaceElevated;

  /// سطح مكتوم: أشرطة البحث، الخلفيات الثانوية.
  final Color surfaceMuted;

  /// سطح غائر: حقول الإدخال والحاويات المقعّرة.
  final Color surfaceSunken;

  /// سطح شبه زجاجي — يُستخدم مع `BackdropFilter` فقط.
  final Color surfaceGlass;

  // --- النص -----------------------------------------------------------------

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  /// لون النص فوق الأسطح الداكنة أو الملوّنة.
  final Color textInverse;

  // --- الحدود والفواصل -----------------------------------------------------

  final Color border;
  final Color borderStrong;
  final Color divider;

  // --- الحالات --------------------------------------------------------------

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color error;
  final Color onError;

  // --- الطبقات --------------------------------------------------------------

  /// تعتيم خفيف خلف المحتوى (فواصل، hover).
  final Color overlay;

  /// تعتيم متوسط (خلفية BottomSheet، قوائم مفتوحة).
  final Color overlayStrong;

  // --- المصحف ---------------------------------------------------------------

  /// ورق صفحة المصحف. **مفهوم دلالي مستقل** عن [surface]: صفحة المصحف
  /// تُصيَّر دائمًا بلونها الخاص، لأنها كيان طباعي لا عنصر واجهة.
  final Color pageSurface;
  final Color onPageSurface;

  // --- تدرّجات وطبقات مركّبة -----------------------------------------------

  /// تدرّج اللون الذهبي — يحلّ محل 3 تعريفات `LinearGradient` مكرّرة.
  final List<Color> accentGradient;

  /// خلفية بطاقات الخطأ (تحلّ محل `#FFF0F0` و `#2E1215` و `#3A1A1C`).
  final Color errorSurface;

  final Color glassBorder;
  final Color glassOverlay;

  bool get isDark => brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // الوصول
  // ---------------------------------------------------------------------------

  /// يقرأ النظام الدلالي من السياق، مع fallback آمن يعمل حتى خارج
  /// `MaterialApp` (اختبارات بسيطة، أو `Preview`).
  static AppColorScheme of(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppColorScheme>();
    if (extension != null) return extension;
    return AppColorScheme.from(
      theme.colorScheme,
      isDark: theme.brightness == Brightness.dark,
    );
  }

  // ---------------------------------------------------------------------------

  @override
  AppColorScheme copyWith({
    Brightness? brightness,
    Color? canvas,
    Color? primaryStrong,
    Color? onPrimaryStrong,
    Color? accent,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceMuted,
    Color? surfaceSunken,
    Color? surfaceGlass,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? error,
    Color? onError,
    Color? overlay,
    Color? overlayStrong,
    Color? pageSurface,
    Color? onPageSurface,
    List<Color>? accentGradient,
    Color? errorSurface,
    Color? glassBorder,
    Color? glassOverlay,
  }) {
    return AppColorScheme(
      brightness: brightness ?? this.brightness,
      canvas: canvas ?? this.canvas,
      primaryStrong: primaryStrong ?? this.primaryStrong,
      onPrimaryStrong: onPrimaryStrong ?? this.onPrimaryStrong,
      accent: accent ?? this.accent,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.onWarning,
      onWarning: onWarning ?? this.onWarning,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      overlay: overlay ?? this.overlay,
      overlayStrong: overlayStrong ?? this.overlayStrong,
      pageSurface: pageSurface ?? this.pageSurface,
      onPageSurface: onPageSurface ?? this.onPageSurface,
      accentGradient: accentGradient ?? this.accentGradient,
      errorSurface: errorSurface ?? this.errorSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      glassOverlay: glassOverlay ?? this.glassOverlay,
    );
  }

  @override
  AppColorScheme lerp(covariant AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      primaryStrong: Color.lerp(primaryStrong, other.primaryStrong, t)!,
      onPrimaryStrong: Color.lerp(onPrimaryStrong, other.onPrimaryStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      overlayStrong: Color.lerp(overlayStrong, other.overlayStrong, t)!,
      pageSurface: Color.lerp(pageSurface, other.pageSurface, t)!,
      onPageSurface: Color.lerp(onPageSurface, other.onPageSurface, t)!,
      accentGradient: List<Color>.generate(
        accentGradient.length,
        (index) =>
            Color.lerp(accentGradient[index], other.accentGradient[index], t)!,
      ),
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassOverlay: Color.lerp(glassOverlay, other.glassOverlay, t)!,
    );
  }
}
