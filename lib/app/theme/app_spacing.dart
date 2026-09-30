import 'package:flutter/widgets.dart';

/// نظام المسافات الموحّد للتطبيق (Design Token: Spacing).
///
/// **لماذا هذا الملف موجود:** قبل هذا الملف كان المشروع يستخدم **33 قيمة مختلفة**
/// داخل `SizedBox` و **15 قيمة** داخل `EdgeInsets.all`، بقيمة شاذة مثل
/// `SizedBox(height: 7)` أو `EdgeInsets.all(9)`. هذه السلالم تلتقط الـ
/// القيم الأكثر استخدامًا في الكود الحالي (4/8/12/16/24/32/48) تمريريًا حتى
/// لا يتغيّر أي شيء بصريًا في هذه المرحلة.
///
/// **قاعدة الاستخدام:**
/// - داخل `Column` / `Row` / `Flex` استخدم `Gap(AppSpacing.md)` (حزمة `gap`).
/// - على الحواف والمساحات الخارجية استخدم `AppSpacing.all(...)` / `.symmetric(...)`.
/// - **لا تكتب أرقامًا عشوائية** — إن احتجت قيمة خارج السلم، أضفها هنا مرة واحدة
///   باسم دلالي، لا في 40 ملف.
abstract final class AppSpacing {
  const AppSpacing._();

  // ---------------------------------------------------------------------------
  // السلم الأساسي (4pt base)
  // ---------------------------------------------------------------------------

  /// 4 — الفاصل الأدق: بين أيقونة وسطر، أو حشو داخلي دقيقة. (يستبدل 1,2,3,4,5)
  static const double xs = 4;

  /// 8 — الفاصل الافتراضي بين العناصر المترابطة. (يستبدل 6,8,9,10)
  static const double sm = 8;

  /// 12 — المسافة بين بنود القائمة. (يستبدل 11,12,14)
  static const double md = 12;

  /// 16 — المسافة القياسية بين الكتل. المسافة الأساسية لحواف الشاشة. (يستبدل 15,16,18,20)
  static const double lg = 16;

  /// 24 — المسافة بين الأقسام. (يستبدل 22,24,26,28)
  static const double xl = 24;

  /// 32 — المسافة بين المجموعات الكبيرة. (يستبدل 30,32,36,40)
  static const double xxl = 32;

  /// 48 — المسافة الأبعد بين الكتل. (يستبدل 44,48,52,60)
  static const double xxxl = 48;

  // ---------------------------------------------------------------------------
  // قياسات ثابتة مشتقة من السلم
  // ---------------------------------------------------------------------------

  /// الحد الأدنى الآمن لهدف اللمس (Material accessibility minimum).
  static const double touchTarget = 48;

  /// هدف لمس مضغوط (40dp) — الحد الأدنى في إرشادات Material 2، ويُستخدم
  /// للأزرار النصية داخل شريط densely packed.
  static const double touchTargetCompact = 40;

  /// ارتفاع شريط التطبيق الافتراضي (M3 default).
  static const double appBarHeight = 56;

  /// أقصى عرض للمحتوى المقروء على الشاشات الكبيرة والأجهزة اللوحية.
  ///
  /// مستخدم حاليًا بقيمة `560` في `ContactStyleMenuScreen` و `520` في
  /// `AppErrorView` / `AppLoadingView` — نوحّدها هنا على `560`.
  static const double contentMaxWidth = 560;

  /// أقصى عرض لنص Quran/التفسير الطويل.
  static const double readingMaxWidth = 640;

  // ---------------------------------------------------------------------------
  // مسافات دلالية (Semantic spacing)
  // ---------------------------------------------------------------------------

  /// الحشو الأفقي/الرأسي لحواف الشاشة.
  static const double screenPadding = lg;

  /// الحشو الداخلي الافتراضي لبطاقة (Card).
  static const double cardPadding = lg;

  /// المسافة الرأسية بين بنود القائمة.
  static const double listItemSpacing = md;

  /// المسافة الرأسية قبل عنوان قسم جديد.
  static const double sectionSpacing = xl;

  /// أقصى عرض لعناصر شريط التنقل السفلي.
  static const double bottomNavMaxWidth = 640;

  // ---------------------------------------------------------------------------
  // مسافات الاستجابة (Responsive gutters)
  // ---------------------------------------------------------------------------

  /// حشو الشاشة حسب عرضها — يُقرأ مرة واحدة في `build` الأب لتفادي
  /// إعادة الحساب في كل إطار تمرير.
  static double screenGutter(double width) {
    if (width < 360) return md;
    if (width < 600) return lg;
    return xl;
  }

  // ---------------------------------------------------------------------------
  // مساعدات EdgeInsets
  // ---------------------------------------------------------------------------

  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// `EdgeInsets.symmetric` — آمن مع RTL.
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// `EdgeInsets.directional` — **الطريقة المفضّلة** في تطبيق عربي 100 % RTL.
  ///
  /// ⚠️ لا تستخدم `EdgeInsets.fromLTRB` / `EdgeInsets.only(left:, right:)`
  /// في أي مكان جديد: الترتيب فيها LTR فيقلب اليمين/اليسار في RTL.
  static EdgeInsetsDirectional directional({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) => EdgeInsetsDirectional.fromSTEB(start, top, end, bottom);

  /// حشو أفقي فقط.
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  /// حشو رأسي فقط.
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  /// حشو قياسي لحواف البطاقة.
  static EdgeInsets get card => const EdgeInsets.all(cardPadding);

  /// حشو قياسي لحواف الشاشة.
  static EdgeInsets get screen => const EdgeInsets.all(screenPadding);

  /// حشو خفيف (يستخدمه `AppErrorView` و `AppLoadingView` حاليًا بقيمة 24).
  static EdgeInsets get state => const EdgeInsets.all(xl);
}

/// قياسات المكوّنات (Component sizes) — الأبعاد التي لا تنتمي للسلم الخطي.
///
/// الأطوال الرأسية (ارتفاع، عرض) ليست "مسافات" بين العناصر، لذا لها صنف
/// مستقل بدل إفساد [AppSpacing] بقيم خارج سلّم 4/8/12/16/24/32/48.
abstract final class AppSizes {
  const AppSizes._();

  /// ارتفاع شريط التنقل السفلي (Material 3 NavigationBar default).
  static const double navBarHeight = 80;

  /// سماكة مسار `Slider` (Material 3 default).
  static const double sliderTrack = 4;

  /// سماكة الحد عند التركيز أو الخطأ — أوضح من الحد الافتراضي (1dp).
  static const double focusBorderWidth = 2;

  /// أصغر عرض مسموح لزر نصي قبل أن يتحوّل إلى أيقونة.
  static const double minButtonWidth = 64;

  // ---------------------------------------------------------------------------
  // ⚠️ فخّ يجب ألّا يقع فيه أحد
  // ---------------------------------------------------------------------------

  /// ‏`Size.fromHeight(48)` هو حرفيًا `Size(double.infinity, 48)`.
  ///
  /// وضعه في `minimumSize` داخل `ButtonTheme` يجعل **كل** زر يطلب عرضًا
  /// لا نهائيًّا، فيرمي Flutter في كل إطار:
  ///
  /// ```
  /// BoxConstraints forces an infinite width.
  ///   The offending constraints were:
  ///   BoxConstraints(w=Infinity, 40.0<=h<=Infinity)
  /// ```
  ///
  /// ولا يظهر إلا على الشاشات التي تضع الزر داخل `Row` (مثل زر «تخطّي»
  /// في `onboarding_screen.dart`)، لأن الزر المفرد يتمدّد بلا تفسير.
  ///
  /// استعمل [minButtonWidth] مع ارتفاع صريح، أو `Size(0, h)` حين لا تريد
  /// حدًّا أدنى للعرض.
  static const Size minButtonTarget = Size(minButtonWidth, 48);
}
