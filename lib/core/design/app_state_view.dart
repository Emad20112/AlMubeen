import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_icon.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// نوع الحالة المعروضة.
enum AppStateKind {
  /// جارٍ التحميل (بيانات أو خط أنابيب).
  loading,

  /// لا توجد بيانات بعد (لم يبحث المستخدم، أو القائمة فارغة فعلًا).
  empty,

  /// فشل الجلب.
  error,

  /// لا يوجد اتصال بالإنترنت.
  offline,

  /// التطبيق مشغّل (اختياري، للتمييز البصري).
  busy,
}

/// حالة واحدة موحّدة: تحميل / فارغ / خطأ / بدون اتصال.
///
/// ## لماذا هذا المكوّن؟
///
/// التدقيق وجد أن **12 شاشة موجّهة** تعيد بناء نفس الحالة يدويًا بـ
/// `Column` + `Icon` + `SizedBox(18)` + `Text` + `FilledButton.icon`، وبأرقام
/// مسافات مختلفة في كل مرة (18، 20، 22، 26). كما أن 11 `SnackBar` في
/// المشروع بلا `action`، فالمستخدم لا يستطيع "إعادة المحاولة" إلا بإغلاق
/// التطبيق.
///
/// هذا المكوّن يجعل الحالة **قرارًا واحدًا**: نوع + عنوان + رسالة + إجراء
/// اختياري، والتنسيق يأتي من الـ`Theme`.
class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.kind,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.progress,
    this.icon,
    this.retryLabel,
    super.key,
  });

  /// خطأ مع زر إعادة محاولة جاهز.
  const AppStateView.error({
    this.title = 'حدث خطأ',
    this.message,
    this.retryLabel = 'إعادة المحاولة',
    this.onAction,
    this.progress,
    this.icon,
    super.key,
  }) : kind = AppStateKind.error,
       actionLabel = null;

  /// لا يوجد اتصال — الإجراء المقترح هو "أعد المحاولة" لا "إغلاق".
  const AppStateView.offline({
    this.title = 'لا يوجد اتصال بالإنترنت',
    this.message = 'تحقّق من اتصالك ثم أعد المحاولة.',
    this.retryLabel = 'إعادة المحاولة',
    this.onAction,
    this.progress,
    this.icon,
    super.key,
  }) : kind = AppStateKind.offline,
       actionLabel = null;

  /// حالة فارغة.
  const AppStateView.empty({
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.progress,
    this.icon,
    this.retryLabel,
    super.key,
  }) : kind = AppStateKind.empty;

  /// جارٍ التحميل.
  const AppStateView.loading({
    this.title = 'جارٍ التحميل…',
    this.message,
    this.actionLabel,
    this.onAction,
    this.progress,
    this.icon,
    this.retryLabel,
    super.key,
  }) : kind = AppStateKind.loading;

  final AppStateKind kind;
  final String? title;
  final String? message;

  /// نص الزر. استخدم [retryLabel] لزر إعادة المحاولة السريع.
  final String? actionLabel;

  /// إجراء زر إعادة المحاولة (يُدمج مع [retryLabel] تلقائيًا).
  final String? retryLabel;
  final VoidCallback? onAction;

  /// قيمة التقدّم (0..1) — تُعرض كشريط خطي بدل الدوّارة عندما لا تكون
  /// `null`. `null` = indeterminate (دوّارة).
  final double? progress;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final text = Theme.of(context).textTheme;

    final effectiveLabel = retryLabel ?? actionLabel;
    final hasAction = effectiveLabel != null && onAction != null;

    // ⚠️ `LayoutBuilder` **خارج** `SingleChildScrollView` عن قصد: داخل
    // الـscroll view تكون الارتفاع غير محدود (`maxHeight == infinity`)،
    // و`BoxConstraints(minHeight: infinity)` يرمي عند التخطيط. لهذا نقرأ
    // `hasBoundedHeight` بدل مقارنة `maxHeight` بقيمة ثابتة.
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight - AppSpacing.state.vertical * 2
            : 0.0;

        return SingleChildScrollView(
          padding: AppSpacing.state,
          child: ConstrainedBox(
            // نحافظ على التوسيط الرأسي دون أن يفيض المحتوى على الشاشات
            // القصيرة أو داخل حاوية بلا ارتفاع محدود.
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.contentMaxWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Indicator(kind: kind, progress: progress),
                    const SizedBox(height: AppSpacing.lg),
                    if (title != null) ...[
                      Text(
                        title!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.headline(text)?.copyWith(
                          color: _titleColor(colors),
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (message != null) ...[
                      Text(
                        message!,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          text,
                        )?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                    if (hasAction) ...[
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        onPressed: onAction,
                        icon: Icon(
                          kind == AppStateKind.error ||
                                  kind == AppStateKind.offline
                              ? AppIcon.refresh
                              : AppIcon.chevronForward,
                          size: AppIcon.md,
                        ),
                        label: Text(
                          effectiveLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _titleColor(AppColorScheme colors) {
    return switch (kind) {
      AppStateKind.error || AppStateKind.offline => colors.error,
      _ => colors.textPrimary,
    };
  }
}

/// المؤشّر (شريط أو دوّارة) بلون الحالة.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.kind, required this.progress});

  final AppStateKind kind;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final tint = switch (kind) {
      AppStateKind.error => colors.error,
      AppStateKind.offline => colors.warning,
      _ => colors.primaryStrong,
    };

    return SizedBox(
      height: AppIcon.huge + AppSpacing.xl,
      child: Center(
        child: switch (kind) {
          AppStateKind.loading || AppStateKind.busy => SizedBox(
            height: AppIcon.huge,
            width: AppIcon.huge,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: colors.surfaceSunken,
              color: tint,
            ),
          ),
          _ => Icon(_defaultIcon(kind), size: AppIcon.huge, color: tint),
        },
      ),
    );
  }

  static IconData _defaultIcon(AppStateKind kind) {
    return switch (kind) {
      AppStateKind.error => AppIcon.error,
      AppStateKind.offline => AppIcon.offline,
      AppStateKind.empty => AppIcon.empty,
      _ => AppIcon.info,
    };
  }
}
