import 'package:flutter/widgets.dart';

/// نظام الاستدارة الموحّد للتطبيق (Design Token: Radius).
///
/// **لماذا هذا الملف موجود:** قبله كان المشروع يستخدم **24 قيمة استدارة
/// مختلفة** موزّعة على `BorderRadius.circular` (18 قيمة) و`Radius.circular`
/// (6 قيم)، من `2` إلى `36`، وبقيم فردية مثل `9` و`11` و`22` و`26`.
///
/// السُلّم هنا **مبني على مضاعفات `AppSpacing`** (4/8/12/16/24) حتى تتناغم
/// الحواف مع المسافات بصريًا، وهو يغطّي الاستدخدامات الشائعة:
///
/// | المستوى | القيمة | الاستخدام                        | يستبدل          |
/// |---------|--------|----------------------------------|-----------------|
/// | `xs`    | 4      | وسوم، نقاط، حدود رفيعة            | 2, 3, 4         |
/// | `sm`    | 8      | رقائق، أزرار نصية، حقول صغيرة     | 6, 8, 9, 10, 11 |
/// | `md`    | 12     | حقول الإدخال، الأزرار، البطاقات   | 12, 14, 16      |
/// | `lg`    | 20     | حوارات، ألواح، BottomSheet        | 18, 20, 22      |
/// | `xl`    | 28     | الأوراق الكبيرة، الحاويات        | 24, 26, 28, 36  |
/// | `pill`  | 999    | كبسولات (Badge, Avatar)           | كل قيم الكبسولة |
abstract final class AppRadii {
  const AppRadii._();

  /// 4 — الأصغر: وسوم، نقاط، حدود رفيعة.
  static const double xs = 4;

  /// 8 — الرقائق، الأزرار النصية، الأيقونات، الشرائط الرفيعة.
  static const double sm = 8;

  /// 12 — المتوسطة: حقول الإدخال، الأزرار، البطاقات.
  static const double md = 12;

  /// 20 — البطاقات الكبيرة والحوارات.
  static const double lg = 20;

  /// 28 — الألواح الكبيرة وأوراق BottomSheet.
  static const double xl = 28;

  /// 999 — الكبسولات (Chips, Badge, Pill buttons).
  ///
  /// قيمة سحرية تجعل الاستدارة تقترب من نصف القطر مهما كان طول الضلع.
  static const double pill = 999;

  // ---------------------------------------------------------------------------
  // أسماء وصفية (أوضح من الأرقام في قراءة الشيفرة)
  // ---------------------------------------------------------------------------

  /// 8 — الرقائق والأيقونات. مرادف [sm].
  static const double small = sm;

  /// 20 — البطاقات والحوارات. مرادف [lg].
  static const double large = lg;

  /// 28 — الأوراق الكبيرة. مرادف [xl].
  static const double extraLarge = xl;

  // ---------------------------------------------------------------------------
  // قياسات مشتقة
  // ---------------------------------------------------------------------------

  /// كبسولة كاملة.
  static const BorderRadius allPill = BorderRadius.all(Radius.circular(pill));

  /// استدارة الحواف العلوية فقط (أوراق BottomSheet).
  static const BorderRadius topSheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );

  /// دائرة كاملة (Badges, Avatars, شريط تقدم دائري).
  static const BorderRadius full = BorderRadius.all(Radius.circular(pill));

  // ---------------------------------------------------------------------------
  // مساعدات
  // ---------------------------------------------------------------------------

  /// استدارة موحّدة من قيمة رقمية.
  static BorderRadius circular(double value) => BorderRadius.circular(value);

  /// استدارة موحّدة من قيمة `Radius`.
  static BorderRadius all(Radius radius) => BorderRadius.all(radius);

  /// استدارة من قيمة رقمية واحدة (اختصار لـ`BorderRadius.circular`).
  static Radius radius(double value) => Radius.circular(value);

  /// `ShapeBorder` بحواف دائرية — للاستخدام مع `Card` و`BottomSheet`.
  static RoundedRectangleBorder shape(
    double value, {
    BorderSide side = BorderSide.none,
  }) => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(value),
    side: side,
  );

  /// `ClipRRect` بحواف دائرية موحّدة.
  static ClipRRect clip(
    Widget child, {
    double value = md,
    Clip clipBehavior = Clip.antiAlias,
  }) => ClipRRect(
    borderRadius: BorderRadius.circular(value),
    clipBehavior: clipBehavior,
    child: child,
  );

  // ---------------------------------------------------------------------------
  // الوصول من الـTheme
  // ---------------------------------------------------------------------------

  /// سُلّم الاستدارة المفضّل في الـWidgets.
  ///
  /// `AppRadii.of(context)` غير موجود عمدًا: عند توفّر `BuildContext` استخدم
  /// `context.tokens.radii` (انظر `app_design_tokens.dart`) ليظل المصدر
  /// المركزي هو الـ`Theme`، واستخدم الثوابت `AppRadii.md` … مباشرةً في
  /// المواضع التي تحتاج `const` (مثل تعريفات `Border` الثابتة).
}

/// نسخة الـRadius المُخزَّنة داخل `ThemeExtension` (انظر `app_design_tokens.dart`).
///
/// الغرض منها أن يكون الوصول مركزيًا عبر `context.tokens.radii`، مع بقاء
/// القيم الثابتة (`AppRadii.md` …) متاحة للاستدعاءات التي لا تحتاج
/// `BuildContext` (مثل `const` في تعريفات الأنماط).
///
/// تُجعل غير قابلة للتوسعة (final fields) عمدًا: أي تعديل على سُلّم
/// الاستدارة يبقى قرارًا واحدًا مركزيًا في هذا الملف.
@immutable
class AppRadiusTokens {
  const AppRadiusTokens({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.pill,
  });

  /// القيم الافتراضية المستخدمة في الثيم الفاتح والداكن معًا.
  const AppRadiusTokens.standard()
    : xs = AppRadii.xs,
      sm = AppRadii.sm,
      md = AppRadii.md,
      lg = AppRadii.lg,
      xl = AppRadii.xl,
      pill = AppRadii.pill;

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  /// أسماء وصفية مطابقة لـ[AppRadii].
  double get small => sm;
  double get medium => md;
  double get large => lg;
  double get extraLarge => xl;

  /// كبسولة كاملة.
  BorderRadius get pillBorder => BorderRadius.circular(pill);
}
