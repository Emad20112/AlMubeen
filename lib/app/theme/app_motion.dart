import 'package:flutter/animation.dart';

/// نظام الحركة الموحّد للتطبيق (Design Token: Motion).
///
/// **لماذا هذا الملف موجود:** قبله كان المشروع يستخدم **26 قيمة مدة مختلفة**
/// (من 16 ms إلى 1500 ms) و **7 منحنيات** مختلفة. أكثر قيمة متكرّرة كانت
/// `280 ms` (10 مرات) و `easeOutCubic` (15 مرة) — أي كان هناك إجماع فعلي
/// غير مكتوب، وهذا الملف يجعله صريحًا.
///
/// **قاعدة الأداء:** لا تُنشئ `AnimationController` من الصفر إلا للسمات
/// المتكررة بلا نهاية (مثل نبض الـshimmer). للحالات البسيطة استخدم
/// `AppMotion.standard` مع `AnimatedContainer` / `AnimatedSwitcher`.
abstract final class AppMotion {
  const AppMotion._();

  // ---------------------------------------------------------------------------
  // المدد — Token: instant / micro / fast / standard / page / modal / hero
  // ---------------------------------------------------------------------------

  /// 100 ms — استجابة فورية: ضغط/إفلات زر.
  static const Duration instant = Duration(milliseconds: 100);

  /// 150 ms — تبديل أيقونة، علامة صح، Ripple مخصّص.
  static const Duration micro = Duration(milliseconds: 150);

  /// 200 ms — تعتيم سريع، تغيّر حالة بسيط.
  static const Duration fast = Duration(milliseconds: 200);

  /// 280 ms — **المدة الافتراضية.** التوسيع والانهيار، تغيّر محتوى الورقة.
  ///
  /// ملاحظة: 280 ms هي المدة التي يستخدمها قارئ القرآن داخليًا للتظليل
  /// المتحرّك، ولذلك اخترناها هي لا غير. لا تُغيّرها دون مراجعة
  /// `quran_page_reader.dart`.
  static const Duration standard = Duration(milliseconds: 280);

  /// 320 ms — انتقالات الصفحات.
  static const Duration page = Duration(milliseconds: 320);

  /// 400 ms — ظهور الحوارات وأوراق BottomSheet.
  static const Duration modal = Duration(milliseconds: 400);

  /// 600 ms — رحلات `Hero` بين الشاشات.
  static const Duration hero = Duration(milliseconds: 600);

  /// 1400 ms — دورة كاملة للوميض (shimmer) في هياكل التحميل.
  ///
  /// القيمة نفسها التي كانت مستخدمة في `ShimmerGroup`، محفوظة بصريًا.
  static const Duration skeletonCycle = Duration(milliseconds: 1400);

  /// 2000 ms — نبضة لطيفة (``.repeat()``) تنتهي تلقائيًا في `AppSkeleton`.
  static const Duration skeletonPulse = Duration(milliseconds: 2000);

  // ---------------------------------------------------------------------------
  // المنحنيات (Curves)
  // ---------------------------------------------------------------------------

  /// المنحنى الافتراضي لكل شيء (15 استخدامًا سابقًا).
  static const Curve standardCurve = Curves.easeOutCubic;

  /// للحركات البارزة (توسيع، إبراز).
  static const Curve emphasized = Curves.easeOutCubic;

  /// للتباطؤ في النهاية (fade out, morph).
  static const Curve decelerate = Curves.easeOut;

  /// للتسارع في البداية (fade in, entrance).
  static const Curve accelerate = Curves.easeInCubic;

  /// للحركة المتناظرة (تشغيل/إيقاف، تعبئة متبادلة).
  static const Curve symmetric = Curves.easeInOutCubic;

  // ---------------------------------------------------------------------------
  // مساعدات
  // ---------------------------------------------------------------------------

  /// تدرّج خطي (0.0 → 1.0) مع منحنى توحيدي.
  ///
  /// مفيد للـstagger داخل `TweenAnimationBuilder`، بحيث لا يتكرر
  /// `Curves.easeOutCubic` في عشرات الملفات.
  ///
  /// ملاحظة: نعيد `Animatable<double>` لأن `Tween.chain` يُرجع
  /// `Animatable<Tween>` لا `Tween` — وهو مقبول تمامًا في `TweenAnimationBuilder`
  /// لأنه يقبل `Animatable<double>`.
  static Animatable<double> tween({
    double begin = 0,
    double end = 1,
    Curve? curve,
  }) {
    final resolved = Tween<double>(begin: begin, end: end);
    if (curve == null) return resolved;
    return resolved.chain(CurveTween(curve: curve));
  }

  /// `Interval` جاهزة للـstagger: تبدأ عند `begin` من إجمالي المدة.
  static Interval stagger({
    required int index,
    required int count,
    double overlap = 0.5,
  }) {
    if (count <= 1) return const Interval(0, 1, curve: standardCurve);
    final step = (1 - overlap) / count;
    final begin = (index * step).clamp(0.0, 1.0);
    final end = (begin + step).clamp(0.0, 1.0);
    return Interval(begin, end, curve: standardCurve);
  }
}
