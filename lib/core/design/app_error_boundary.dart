/// ## لماذا لا يوجد "error boundary" حول الشاشات؟
///
/// **قرار معماري مقصود.** المشروع كان يملك `AppErrorBoundary` وهو وودجت
/// `StatefulWidget` يدّعي أنه "يلتقط أخطاء الودجت الفرعية ويعرض
/// [AppStateView] مع زر إعادة محاولة". التدقيق كشف أن هذا الوعد **غير
/// قابل للتحقيق في Flutter**:
///
/// - استثناءات مرحلة `build` يلتقطها إطار العمل نفسه ويتحوّل بها إلى
///   `ErrorWidget`. لا توجد نقطة في شجرة الودجت يصل فيها الاستثناء إلى
///   والدٍ (parent) ليخزّنه ويعرض بديلاً — على عكس React.
/// - الحقول `_error` و`_stackTrace` التي كان يعتمد عليها المكوّن **لا
///   شيء في الكود يعيّنها**، فلم يصل الخطأ إلى حالة `_error == null`
///   أبدًا، وكان `build` يُرجع `widget.child` دائمًا.
/// - النتيجة: مسار [AppStateView] و`_reset()` كانا **كودًا ميتًا**، ولم
///   يكن هناك أي استدعاء للمكوّن في المشروع أصلًا.
///
/// استُبدل ذلك بالاستراتيجية الصحيحة، وهي على مستويين:
///
/// 1. **الأخطاء المتوقَّعة** (شبكة، قاعدة بيانات، تخزين) — Fadiha من
///    البنية: `AsyncValue` ← [AppAsyncView] / [AppStateView]، وهو
///    الموضع الصحيح الوحيد لهذه الحالات لأنه يحمل `onRetry` وحالة
///    `offline` وبيانات جزئية.
/// 2. **الأخطاء غير المتوقَّعة** في `build` — شبكة أمان عامة عبر
///    [installReleaseErrorWidget]، لأن الإطار لا يسمح بأي حل آخر.
///
/// ### لماذا لا زر "إعادة المحاولة" في الشبكة العامة؟
///
/// زر بلا `State` نظيف خلفه لا يفعل شيئًا. عند فشل `build` لا نعرف أي
/// شجرة هي التالفة، فلا resurfacing صحيح ممكن — ولهذا نعرض رسالة صريحة
/// بدل زر مضلّل. (المبدأ نفسه: لا أزرار ميتة.)
///
/// تسجيل الأخطاء في خدمة خارجية (Crashlytics / Sentry) يحتاج dependency
/// جديدة وهو خارج نطاق هذه المرحلة، فتبقى الدالة على
/// [FlutterError.presentError] لضمان عدم ضياع التقرير محليًا.
library;

import 'package:al_mubeen/app/theme/app_theme.dart';
import 'package:al_mubeen/core/design/app_state_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// يثبّت بديلًا صديقًا لـ`ErrorWidget.builder` الافتراضي.
///
/// **حصرًا في الإنتاج**: في `debug` نُبقي على السلوك الافتراضي لأنه يعرض
/// الـstack trace على الشاشة (إطار أحمر)، وهو جزء من أدوات التطوير.
///
/// ```dart
/// // lib/main.dart
/// void main() {
///   installReleaseErrorWidget();
///   runApp(...);
/// }
/// ```
///
/// في الإنتاج، افتراضيًا، أي استثناء غير معالَج أثناء `build` يُنتج
/// `ErrorWidget` يعرض نص الاستثناء الخام داخل مساحة فارغة — وهو أسوأ
/// شكل ممكن للفشل: لا رسالة مفهومة ولا تمييز ولا اتجاه صحيح للمستخدم.
void installReleaseErrorWidget() {
  if (!kReleaseMode) return;
  ErrorWidget.builder = buildReleaseErrorScreen;
}

/// يبني شاشة الخطأ التي تُعرض في الإنتاج عند استثناء غير معالَج في `build`.
///
/// مُستخرَجة كدالة مستقلة (وليست lambda مغلقة داخل
/// [installReleaseErrorWidget]) لسببين:
///
/// - `kReleaseMode` يساوي `false` في الاختبارات، فكان استدعاء الدالة
///   أعلاه لن يُثبّت شيئًا أثناء `flutter test` ولا يمكن التحقق منه.
/// - الفصل يجعل سلوك الفشل قابلًا للاختبار فعليًا.
///
/// تعرض رسالة عربية مع RTL وثيم التطبيق، وتُبقي التقرير الأصلي عبر
/// [FlutterError.presentError].
Widget buildReleaseErrorScreen(FlutterErrorDetails details) {
  // نُبقي التقرير الأصلي متاحًا (سجل، Crashlytics لاحقًا).
  FlutterError.presentError(details);

  // الشاشة تُبنى خارج `MaterialApp`، لذا نغلّفها بثيم صريح — بعدّه
  // `Theme.of` يسقط إلى ثيم فاتح افتراضي وتظهر الشاشة بإضاءة خاطئة.
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    builder: (context, child) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AppStateView.error(
          title: 'تعذّر عرض هذا الجزء من الشاشة',
          message:
              'حدث خطأ غير متوقع في الواجهة. '
              'جرّب إغلاق التطبيق وفتحه مرة أخرى.',
        ),
      );
    },
  );
}
