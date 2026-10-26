import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';

/// واجهة الحالة الفارغة الموحدة (Empty State View).
class AppEmptyStateView extends StatelessWidget {
  const AppEmptyStateView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accent.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 36,
                color: colors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppSecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// واجهة حالة الخطأ الموحدة (Error State View).
class AppErrorStateView extends StatelessWidget {
  const AppErrorStateView({
    super.key,
    this.title = 'حدث خطأ ما',
    required this.errorMessage,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String errorMessage;
  final String retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.error.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 34,
                color: colors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                label: retryLabel,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
