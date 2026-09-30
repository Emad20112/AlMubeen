import 'package:al_mubeen/core/design/app_state_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// حدّ أخطاء على مستوى الودجت.
///
/// ## لماذا هذا المكوّن؟
///
/// التدقيق وجد **صفر استخدام لـ`ErrorWidget.builder`** في المشروع، أي أن
/// أي استثناء في `build` كان يطبع إطارًا أحمر في وضع debug و**شاشة سوداء
/// تمامًا** في الإنتاج. هذا أسوأ شكل ممكن للفشل: لا رسالة، ولا زر، ولا
/// تمييز، ولاعرف أن التطبيق ما زال حيًّا.
///
/// [AppErrorBoundary] يلتقط أخطاء الودجت الفرعية ويعرض [AppStateView]
/// مع زر "إعادة المحاولة" بدل الشاشة السوداء.
///
/// ```dart
/// AppErrorBoundary(
///   onRetry: () => ref.invalidate(someProvider),
///   child: MyScreen(),
/// )
/// ```
class AppErrorBoundary extends StatefulWidget {
  const AppErrorBoundary({
    required this.child,
    this.onRetry,
    this.isOffline,
    this.title,
    this.message,
    super.key,
  });

  final Widget child;
  final VoidCallback? onRetry;
  final bool? isOffline;
  final String? title;

  /// الرسالة في الإنتاج. في `debug` تُعرض رسالة الاستثناء الأصلية دائمًا
  /// لأن الـstack trace هو ما نحتاجه أثناء التطوير.
  final String? message;

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error == null) {
      return widget.child;
    }

    final details = kDebugMode
        ? '$_error\n\n${_stackTrace ?? ''}'
        : (widget.message ?? 'تعذّر عرض هذا الجزء من الشاشة.');

    if (widget.isOffline ?? false) {
      return AppStateView.offline(
        title: widget.title,
        onAction: widget.onRetry,
      );
    }

    return AppStateView.error(
      title: widget.title,
      message: details,
      onAction: widget.onRetry ?? _reset,
    );
  }

  void _reset() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
}

/// يُسجَّل بديلًا لـ`ErrorWidget.builder` الافتراضي.
///
/// حصرًا في **الإنتاج**: في `debug` نُبقي على السلوك الافتراضي لأنه يعرض
/// الـstack trace على الشاشة (إطار أحمر)، وهو جزء من أدوات التطوير.
///
/// ```dart
/// // lib/app/al_mubeen_app.dart — في main() قبل runApp
/// installReleaseErrorWidget();
/// ```
///
/// ملاحظة: تسجيل الأخطاء في خدمة خارجية (Crashlytics / Sentry) يحتاج
/// dependency جديدة، وهو خارج نطاق هذه المرحلة. الدالة تُبقي
/// `FlutterError.presentError` فقط، وهو ما يضمن عدم ضياع التقرير محليًا.
void installReleaseErrorWidget() {
  if (!kReleaseMode) return;
  ErrorWidget.builder = (details) {
    FlutterError.presentError(details);
    return ErrorWidget(details.exception);
  };
}
