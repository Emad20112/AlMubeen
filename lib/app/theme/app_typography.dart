import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// نظام الطباعة الموحّد للتطبيق (Design Token: Typography).
///
/// ## القاعدة الذهبية: `UI Typography ≠ Quran Typography`
///
/// خط المصحف يأتي من حزمة `qcf_quran` (v0.0.5) التي تُسجّل **604 عائلة خط**
/// باسم `QCF_P001 … QCF_P604` وتُصيّر النص عبر widgets خاصة بها.
/// **لا يمسّ هذا الملف حرفًا من ذلك الخط، ولا يجوز أن يمسّه.**
///
/// للInterface فقط، [`fontFamily`] هو ثابت واحد مفعَّل حاليًا على **IBM Plex
/// Sans Arabic** (أربعة أوزان: 400/500/600/700)، والملفات مسجّلة في
/// `pubspec.yaml` تحت `assets/fonts/` (ترخيص SIL OFL 1.1)، فلا حاجة لأي
/// إجراء إضافي لتفعيله.
///
/// **لماذا هذا الخط:** حزمة `qcf_quran` تعتمد على خطوط QCF المخصّصة للصفحات
/// فقط، وخط المصحف ملك لـ`Text(page)` من الحزمة، لذلك تُقرأ **الواجهة**
/// كلها (العناوين، الأزرار، القوائم، النصوص التعريفية) بخط عربي موحّد بدل
/// خط النظام المتغيّر بين الأجهزة. عند تبديل الخط مستقبلًا:
///
/// ```yaml
/// # 1) ضع ملفات الخط في assets/fonts/
/// # 2) سجّلها في pubspec.yaml تحت fonts:
/// #   fonts:
/// #     - family: IBM_Plex_Sans_Arabic
/// #       fonts:
/// #         - asset: assets/fonts/IBMPlexSansArabic-Regular.ttf
/// #         - asset: assets/fonts/IBMPlexSansArabic-Bold.ttf
/// #           weight: 700
/// # 3) غيّر [fontFamily] أدناه إلى اسم العائلة الجديد
/// ```
abstract final class AppTypography {
  const AppTypography._();

  /// خط الـUI العربي الموحّد.
  ///
  /// مسجّل في `pubspec.yaml` (`fonts:` → `IBMPlexSansArabic`) بأوزان
  /// 400/500/600/700. أي تبديل هنا **يجب** أن يسبقه تسجيل العائلة نفسها في
  /// `pubspec.yaml`، وإلا سقط Flutter بصمت إلى [fontFamilyFallback].
  static const String fontFamily = 'IBMPlexSansArabic';

  /// خطوط احتياطية للنصوص العربية عند عدم توفّر [fontFamily].
  ///
  /// Android: Noto Naskh / Noto Sans Arabic — iOS: Geeza Pro / SF Arabic.
  static const List<String> fontFamilyFallback = <String>[
    'Noto Naskh Arabic',
    'Noto Sans Arabic',
    'Geeza Pro',
    'Arial',
  ];

  /// خط المصحف — **لا يُضبط هنا أبدًا**.
  ///
  /// ملك حزمة `qcf_quran` حصرًا. وجود هذا الثابت هنا توثيقي فقط: وجود قيمة
  /// لـ`quranFontFamily == null` يعني «الخط يديره الـpackage، لا نتدخل فيه».
  static const String? quranFontFamily = null;

  /// أوزان الحروف المسموح بها فقط.
  ///
  /// الكود الحالي يستخدم `w300 … w900` بما فيها `w800` (غير قياسي في سلم
  /// التصميم). السلم المعتمد هنا أربعة أوزان فقط.
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ---------------------------------------------------------------------------
  // بناء الـTextTheme
  // ---------------------------------------------------------------------------

  /// الـTextTheme الفاتح — مبني على `Typography.blackMountainView` (السلم
  /// المرجعي لـMaterial 3) مع سلم حجم صريح في [_build]، ثم تُطبَّق عليه
  /// عائلة الخط العربي وألوان النص.
  static TextTheme light(ColorScheme scheme) => _build(
    base: Typography.blackMountainView,
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );

  /// الـTextTheme الداكن — مطابق لـ`Typography.whiteMountainView.apply(…)`.
  static TextTheme dark(ColorScheme scheme) => _build(
    base: Typography.whiteMountainView,
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );

  static TextTheme _build({
    required TextTheme base,
    required Color bodyColor,
    required Color displayColor,
  }) {
    return base
        .apply(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          bodyColor: bodyColor,
          displayColor: displayColor,
        )
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(fontSize: 57, height: 1.12),
          displayMedium: base.displayMedium?.copyWith(
            fontSize: 45,
            height: 1.16,
          ),
          displaySmall: base.displaySmall?.copyWith(fontSize: 36, height: 1.22),
          headlineLarge: base.headlineLarge?.copyWith(
            fontSize: 32,
            height: 1.25,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: 28,
            height: 1.29,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 24,
            height: 1.33,
          ),
          titleLarge: base.titleLarge?.copyWith(fontSize: 22, height: 1.27),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 16,
            height: 1.5,
            letterSpacing: 0.15,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontSize: 14,
            height: 1.43,
            letterSpacing: 0.1,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontSize: 16,
            height: 1.5,
            letterSpacing: 0.5,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 14,
            height: 1.43,
            letterSpacing: 0.25,
          ),
          bodySmall: base.bodySmall?.copyWith(
            fontSize: 12,
            height: 1.33,
            letterSpacing: 0.4,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontSize: 14,
            height: 1.43,
            letterSpacing: 0.1,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontSize: 12,
            height: 1.33,
            letterSpacing: 0.5,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontSize: 11,
            height: 1.45,
            letterSpacing: 0.5,
          ),
        )
        .apply(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          bodyColor: bodyColor,
          displayColor: displayColor,
        );
  }

  // ---------------------------------------------------------------------------
  // أدوار دلالية فوق Material 3
  // ---------------------------------------------------------------------------

  /// عناوين العرض الكبيرة (Onboarding، الحالات الفارغة الكبرى).
  static TextStyle? display(TextTheme t) => t.displaySmall;

  /// عناوين الشاشات الرئيسية.
  static TextStyle? headline(TextTheme t) => t.headlineSmall;

  /// عناوين البطاقات والبنود.
  static TextStyle? title(TextTheme t) => t.titleLarge;

  /// عناوين الأقسام («أذكار الصباح»).
  static TextStyle sectionTitle(BuildContext context) {
    return TextTheme.of(context).titleMedium?.copyWith(
          fontWeight: bold,
          color: AppColorScheme.of(context).primaryStrong,
        ) ??
        const TextStyle();
  }

  /// النص الأساسي للقراءة.
  static TextStyle? bodyLarge(TextTheme t) => t.bodyLarge;

  /// النص الافتراضي في القوائم والنصوص.
  static TextStyle? body(TextTheme t) => t.bodyMedium;

  /// النص الثانوي والوصف.
  static TextStyle? bodySmall(TextTheme t) => t.bodySmall;

  /// نصوص الأزرار والرقائق.
  static TextStyle? label(TextTheme t) => t.labelLarge;

  /// نصوص الرقائق والوسوم وأزرار `SegmentedButton`.
  static TextStyle? labelSmall(TextTheme t) => t.labelMedium;

  /// عناوين فرعية: «الفهرس»، «تفسير الآية».
  static TextStyle? subtitle(TextTheme t) => t.titleMedium;

  /// الطوابع الزمنية والأعداد.
  static TextStyle? caption(TextTheme t) => t.labelSmall;

  // ---------------------------------------------------------------------------
  // مساعدات
  // ---------------------------------------------------------------------------

  /// قراءة آمنة لأحد أنماط `TextTheme` عند إمكانية أن يكون `null`.
  static TextStyle read(TextTheme theme, TextStyle? style) =>
      style ?? const TextStyle();

  /// نمط نص القرآن — **لا يضبط خط الـUI أبدًا**.
  ///
  /// تستخدمه لتوحيد ارتفاع السطر وأحجام قراءة المصحف عبر الشيفرة الحالية
  /// (`tafsir_reader_content.dart` وأخواتها) دون المساس بعائلة الخط.
  ///
  /// ملاحظة: `TextStyle` لا يحمل اتجاهًا؛ الاتجاه يُضبط على مستوى الودجت
  /// عبر `Directionality` أو `textDirection:` في `Text`/`RichText`. لذلك
  /// لا يقبل هذا الـhelper معامل `textDirection` عمدًا.
  static TextStyle quranText({
    required double fontSize,
    double height = 1.9,
    FontWeight weight = regular,
    Color? color,
  }) => TextStyle(
    fontFamily: quranFontFamily,
    fontSize: fontSize,
    height: height,
    fontWeight: weight,
    color: color,
  );
}
