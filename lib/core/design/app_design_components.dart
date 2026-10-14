/// Design System components — الأساس المشترك (Foundation).
///
/// كل ما في هذا المجلد **tokens-driven**: لا لون مكتوب يدويًا، ولا رقم
/// مسافة، ولا استدارة. المصدر هو `AppTheme` عبر `ThemeExtension`، فأي
/// تعديل على الثيم ينتقل إلى كل هذه المكوّنات تلقائيًا.
///
/// هذه المكوّنات **لا تُستخدم بعد داخل الـFeatures** — эта مقصود. الـAudit
/// والتأسيس مكتملان هنا؛ نقل الـFeatures الحالية إلى هذه المكوّنات هو
/// عمل المراحل التالية، وليس هذا الملف.
///
/// الملفات:
/// - [AppSurface] — الأسطح (خلفية، بطاقة، زجاج).
/// - [AppStateView] — حالة موحّدة: تحميل / فارغ / خطأ / بدون اتصال.
/// - [AppAsyncView] — تحويل `AsyncValue` إلى [AppStateView].
/// - [installReleaseErrorWidget] — شبكة أمان الإنتاج: استبدال
///   `ErrorWidget` الخام بشاشة خطأ عربية + RTL. **ليست** boundary حول
///   الشاشات؛ اقرأ توثيقها لسبب typedef.
/// - [AppPageHeader] — ترويسة صفحة واحدة بدل أربعة أنماط.
/// - [AppSkeleton] — هيكل تحميل بوميض يتوقف تلقائيًا.
library;

export 'app_async_view.dart';
export 'app_error_boundary.dart';
export 'app_page_header.dart';
export 'app_skeleton.dart';
export 'app_state_view.dart';
export 'app_surface.dart';
