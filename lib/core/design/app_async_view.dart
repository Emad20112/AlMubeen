import 'package:al_mubeen/core/design/app_state_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// يحوّل `AsyncValue` إلى واجهة واحدة، بلا تكرار `when` في كل شاشة.
///
/// ## لماذا هذا المكوّن؟
///
/// التدقيق لم يجد استخدامًا واحدًا لـ`FutureBuilder` لأن المشروع يمرّ على
/// Riverpod — لكن النتيجة أن **كل شاشة تكتب نفس الشجرة يدويًا**:
/// `value.when(data: …, loading: …, error: …)`، وغالبًا بحالات خطأ مختلفة
/// (بعضها `SnackBar`، وبعضها نص عادي، وبعضها لا يعرض شيئًا أصلًا).
///
/// هذا المكوّن يجعل شكل الحالة **واحدًا في كل التطبيق**، ويسمح بتخصيص
/// الرسالة حسب نوع الخطأ عبر [messageBuilder] دون تغيير البنية.
///
/// ```dart
/// AppAsyncView(
///   value: ref.watch(recitationsProvider),
///   onRetry: () => ref.invalidate(recitationsProvider),
///   data: (list) => ListView.builder(itemCount: list.length, …),
/// )
/// ```
class AppAsyncView<T> extends StatelessWidget {
  const AppAsyncView({
    required this.value,
    required this.data,
    this.loading,
    this.loadingTitle,
    this.loadingMessage,
    this.onRetry,
    this.messageBuilder,
    this.isOffline,
    super.key,
  });

  /// القيمة المرصودة من Riverpod.
  final AsyncValue<T> value;

  /// واجهة البيانات. لا تُبنى إلا عند وجود بيانات فعلًا، وهذا ما يمنع
  /// بناء شجرة ثقيلة في كل إطار تحميل.
  final Widget Function(T data) data;

  /// واجهة التحميل المخصّصة (افتراضيًا [AppStateView.loading]).
  final Widget? loading;
  final String? loadingTitle;
  final String? loadingMessage;

  /// إعادة المحاولة — تظهر كزر داخل حالة الخطأ.
  final VoidCallback? onRetry;

  /// يبني رسالة الخطأ من كائنه. يسمح بتمييز خطأ الشبكة عن غيره
  /// دون `if` متكرر في كل استدعاء.
  final String Function(Object error, StackTrace stackTrace)? messageBuilder;

  /// هل الجهاز غير متصل؟ يُحوّل الخطأ إلى حالة "offline" تلقائيًا.
  final bool? isOffline;

  @override
  Widget build(BuildContext context) {
    return value.when(
      // لا نُخفي حالة التحميل عند التحديث: الوميض إلى "لا يوجد شيء" ثم
      // التحميل هو أسوأ شعور ممكن للمستخدم في قائمة.
      skipLoadingOnRefresh: false,
      skipError: false,
      data: data,
      loading: () =>
          loading ??
          AppStateView.loading(title: loadingTitle, message: loadingMessage),
      error: (error, stackTrace) {
        if (isOffline ?? _looksOffline(error)) {
          return AppStateView.offline(onAction: onRetry);
        }
        return AppStateView.error(
          message:
              messageBuilder?.call(error, stackTrace) ?? _defaultMessage(error),
          onAction: onRetry,
        );
      },
    );
  }

  /// كشف الشبكة عبر اسم النوع بدل استيراد `NoInternetException` هنا، حتى
  /// يبقى هذا الملف طبقة عرض بحتة لا يعرف طبقة البيانات.
  static bool _looksOffline(Object error) {
    return error.runtimeType.toString().toLowerCase().contains('internet');
  }

  static String _defaultMessage(Object error) {
    if (kDebugMode) return error.toString();
    return 'تعذّر تحميل المحتوى. حاول مرة أخرى.';
  }
}

/// يميّز بين "فشل التحميل" و"لا توجد نتائج".
///
/// [AppAsyncView] يعرض الخطأ فقط. هذا الغلاف يضيف حالة "البيانات موجودة
/// لكنها فارغة" — وهي حالة منفصلة تمامًا عن الخطأ في UX، وكثيرًا ما كانت
/// الشاشات تعرض نفس المعالج لكليهما.
class AppAsyncContentView<T> extends StatelessWidget {
  const AppAsyncContentView({
    required this.value,
    required this.data,
    required this.isEmpty,
    required this.emptyMessage,
    this.emptyTitle,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.onRetry,
    this.isOffline,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  /// هل البيانات الحالية فارغة؟ عادةً دالة على الطول أو على نتيجة البحث.
  final bool Function(T data) isEmpty;

  final String? emptyTitle;
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final VoidCallback? onRetry;
  final bool? isOffline;

  @override
  Widget build(BuildContext context) {
    return AppAsyncView<T>(
      value: value,
      isOffline: isOffline,
      onRetry: onRetry,
      data: (data) => isEmpty(data)
          ? AppStateView.empty(
              title: emptyTitle,
              message: emptyMessage,
              actionLabel: emptyActionLabel,
              onAction: onEmptyAction,
            )
          : this.data(data),
    );
  }
}
