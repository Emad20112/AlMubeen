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
/// للInterface فقط، [`fontFamily`] هو ثابت واحد يمكن تفعيله لاحقًا.
/// نبقيه `null` في المرحلة الأولى لأن `pubspec.yaml` **لا يحتوي قسم `fonts:`
/// إطلاقًا** — أي أن التطبيق اليوم لا يحزم أي خط، ويعتمد على خط النظام.
/// تفعيل خط جديد هنا قبل إضافة ملف الخط إلى `pubspec.yaml` سيكسر العرض،
/// لذلك نتركه `null` عمدًا:
///
/// ```yaml
/// # الخطوة 1 (مهمة لاحقة): أضف ملفات الخط إلى assets/fonts/
/// # الخطوة 2: سجّلها في pubspec.yaml
/// #   fonts:
/// #     - family: IBM_Plex_Sans_Arabic
/// #       fonts:
/// #         - asset: assets/fonts/IBMPlexSansArabic-Regular.ttf
/// #         - asset: assets/fonts/IBMPlexSansArabic-Bold.ttf
/// #           weight: 700
/// # الخطوة 3: غيّر السطر التالي من null إلى اسم العائلة
/// ```
abstract final class AppTypography {
  const AppTypography._();

  /// خط الـUI. `null` = خط النظام (سلوك التطبيق الحالي بالضبط).
  ///
  /// عند تفعيله، يجب أن يكون مسجّلًا في قسم `fonts:` من `pubspec.yaml`.
  static const String? fontFamily = null;

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

  /// الـTextTheme الفاتح — **مطابق تمامًا** لما كان يستخدمه `AppTheme` قبل
  /// هذا الملف (`Typography.blackMountainView.apply(bodyColor: ink, …)`)،
  /// حتى لا يتغير أي حرف في الشاشة.
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
    return base.apply(
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
