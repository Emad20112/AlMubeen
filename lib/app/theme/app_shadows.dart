import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// نظام الظلال والشفافية الموحّد للتطبيق (Design Token: Shadows).
///
/// **لماذا هذا الملف موجود:** قبله كان المشروع يستخدم **13 قيمة `blurRadius`
/// مختلفة** (من 3 إلى 40، أي فرق 13×)، و **5 قيم Blur** مختلفة
/// (`sigmaX` 10, 12, 14, 18)، مع **اختلاف صريح بين الوضعين**: لم تكن هناك
/// أي تفرقة بين Light و Dark إطلاقًا — البطاقات في الوضع الداكن تحصل على
/// ظلال سوداء لا معنى لها بصريًا، فيختفي الإحساس بالارتفاع تمامًا.
///
/// القيم هنا **مأخوذة منBlur الموجود فعلًا** (8 و 16 ضمن الـ13 قيمة
/// المستخدمة)، و `elevated` يتبنى عائلة الـ24 المستخدمة بكثرة.
abstract final class AppShadows {
  const AppShadows._();

  /// لون الظل في الوضع الفاتح — بني دافئ ليتوافق مع لوحة التراب/الذهب.
  static const Color lightShadowColor = Color(0xFF1A120C);

  /// لون الظل في الوضع الداكن — أسود نقي لرفع التباين على الأسطح الداكنة.
  static const Color darkShadowColor = Color(0xFF000000);

  // ---------------------------------------------------------------------------
  // الظلال — الوضع الفاتح
  // ---------------------------------------------------------------------------

  /// لا ظل.
  static const List<BoxShadow> none = <BoxShadow>[];

  /// 8 / offset 2 / alpha 6 % — حدود دقيقة: فواصل، بطاقات مسطّحة، أشرطة.
  static const List<BoxShadow> subtleLight = <BoxShadow>[
    BoxShadow(color: Color(0x0F1A120C), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// 16 / offset 4 / alpha 10 % — البطاقات المرفوعة فوق الخلفية.
  static const List<BoxShadow> mediumLight = <BoxShadow>[
    BoxShadow(color: Color(0x1A1A120C), blurRadius: 16, offset: Offset(0, 4)),
  ];

  /// 28 / spread −2 / offset 10 / alpha 14 % — الألواح العائمة و BottomSheet.
  static const List<BoxShadow> elevatedLight = <BoxShadow>[
    BoxShadow(
      color: Color(0x241A120C),
      blurRadius: 28,
      spreadRadius: -2,
      offset: Offset(0, 10),
    ),
  ];

  // ---------------------------------------------------------------------------
  // الظلال — الوضع الداكن
  // ---------------------------------------------------------------------------

  /// 8 / offset 2 / alpha 40 % — حدود دقيقة على أسطح داكنة.
  static const List<BoxShadow> subtleDark = <BoxShadow>[
    BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// 16 / offset 4 / alpha 55 % — البطاقات المرفوعة.
  static const List<BoxShadow> mediumDark = <BoxShadow>[
    BoxShadow(color: Color(0x8C000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  /// 28 / spread −2 / offset 10 / alpha 70 % — الألواح العائمة.
  static const List<BoxShadow> elevatedDark = <BoxShadow>[
    BoxShadow(
      color: Color(0xB3000000),
      blurRadius: 28,
      spreadRadius: -2,
      offset: Offset(0, 10),
    ),
  ];

  // ---------------------------------------------------------------------------
  // مستويات الارتفاع (Elevation) — قيم M3 المكافئة
  // ---------------------------------------------------------------------------

  static const double elevationNone = 0;
  static const double elevationSubtle = 1;
  static const double elevationMedium = 3;
  static const double elevationElevated = 6;

  // ---------------------------------------------------------------------------
  // مساعدات ديناميكية
  // ---------------------------------------------------------------------------

  /// الظل المناسب حسب سطوع الثيم الحالي.
  static List<BoxShadow> forLevel(Brightness brightness, {int level = 2}) {
    if (level <= 0) return none;
    return switch (level) {
      1 => brightness == Brightness.dark ? subtleDark : subtleLight,
      2 => brightness == Brightness.dark ? mediumDark : mediumLight,
      _ => brightness == Brightness.dark ? elevatedDark : elevatedLight,
    };
  }

  /// ظل مخصّص بقيم صريحة — للحالات التي تحتاج تحكمًا دقيقًا.
  static List<BoxShadow> custom({
    required Color color,
    double blurRadius = 16,
    double spreadRadius = 0,
    Offset offset = Offset.zero,
  }) => <BoxShadow>[
    BoxShadow(
      color: color,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      offset: offset,
    ),
  ];

  /// ظل علوي ناعم — يُستخدم مع BottomSheet في أسفل الشاشة.
  static List<BoxShadow> topSheet(Brightness brightness) {
    return brightness == Brightness.dark ? elevatedDark : elevatedLight;
  }

  // ---------------------------------------------------------------------------
  // الضباب (Glass / BackdropFilter)
  // ---------------------------------------------------------------------------

  /// قيم الضباب الموحّدة. Previously there were 4 different sigma values (10, 12, 14, 18).
  static const double blurSmall = 10;
  static const double blurMedium = 14;
  static const double blurLarge = 18;

  /// معامل التعتيم خلف الزجاج (Overlay scrim).
  static const double glassOverlayOpacity = 0.04;

  /// `ImageFilter.blur` جاهز للاستخدام في `BackdropFilter`.
  static ImageFilter blur(double sigma) =>
      ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

  /// `ClipRRect` مع blur متزامن (الأكثر استخدامًا في الشيفرة الحالية).
  static ClipRRect glass(
    Widget child, {
    required BorderRadius borderRadius,
    double sigma = blurMedium,
    Clip clipBehavior = Clip.antiAlias,
  }) => ClipRRect(
    borderRadius: borderRadius,
    clipBehavior: clipBehavior,
    child: BackdropFilter(filter: blur(sigma), child: child),
  );
}
