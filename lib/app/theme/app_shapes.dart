import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// الأشكال الموحّدة (Shapes) — المصدر الوحيد لـ`RoundedRectangleBorder`
/// وحقول الإدخال.
///
/// التطبيق كان يكرّر `BorderRadius.circular(10)` و`12` و`16` في عشرات الملفات
/// بقيم متقاربة بصريًا، فكل تعديل على سُلّم الاستدارة كان يتطلب مسحًا يدويًا.
/// كل شكل هنا يربط [AppRadiusTokens] بدور واجهة محدّد.
abstract final class AppShapes {
  const AppShapes._();

  // ---------------------------------------------------------------------------
  // الأزرار
  // ---------------------------------------------------------------------------

  /// الزر الأساسي: استدارة متوسطة تعطي إحساس "كبسولة" وتتحمّل النصوص
  /// العربية الطويلة دون أن تبدو الحواف حادة.
  static const RoundedRectangleBorder buttonMedium = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
  );

  /// الأزرار النصية والأيقونية: استدارة أصغر، حتى لا تبدو ككبسولة في
  /// المواضع الضيقة.
  static const RoundedRectangleBorder buttonSmall = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
  );

  /// الشريحة المحدّدة (`SegmentedButton`).
  static const RoundedRectangleBorder segmented = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
  );

  // ---------------------------------------------------------------------------
  // حقول الإدخال
  //
  // تحتاج `AppColorScheme` (لأن لون الحد يتغيّر بين الوضعين)، لذا لا يمكن
  // أن تكون `const` واحدة مشتركة — ولهذا لا يوجد `inputMedium` ثابت هنا،
  // بل دوال تُستدعى داخل `AppTheme`.
  // ---------------------------------------------------------------------------

  static OutlineInputBorder input(AppColorScheme colors) =>
      _outline(colors.border);

  static OutlineInputBorder inputFocused(AppColorScheme colors) =>
      _outline(colors.primaryStrong, width: AppSizes.focusBorderWidth);

  static OutlineInputBorder inputError(AppColorScheme colors) =>
      _outline(colors.error, width: AppSizes.focusBorderWidth);

  static OutlineInputBorder inputDisabled(AppColorScheme colors) =>
      _outline(colors.border.withValues(alpha: 0.5));

  static OutlineInputBorder _outline(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // ---------------------------------------------------------------------------
  // الأسطح
  // ---------------------------------------------------------------------------

  /// البطاقة الافتراضية.
  ///
  /// `elevation: 0` مع حدّ خفيف صريح: الـelevation الافتراضي في Material 3
  /// يترك صبغة السطح (الذهبية هنا) فوق البطاقة، وهو أثر بصري غير مقصود.
  static CardThemeData cardTheme(
    AppColorScheme colors, {
    double radius = AppRadii.lg,
  }) {
    return CardThemeData(
      color: colors.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: colors.border),
      ),
    );
  }
}
