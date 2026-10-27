import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// شريط موحد لعرض التقدم في عمليات التنزيل الجارية (Resource Download Progress Banner).
///
/// يدعم:
/// - حالات التنزيل، الإيقاف المؤقت، والفشل.
/// - مؤشر تقدم دقيق ونسبة مئوية.
/// - أزرار تفاعلية موحدة للإيقاف، الاستئناف، الإلغاء، أو إعادة المحاولة.
class ResourceDownloadProgressBanner extends StatelessWidget {
  const ResourceDownloadProgressBanner({
    super.key,
    required this.title,
    this.subtitle,
    required this.progress,
    this.progressDetail,
    required this.isDownloading,
    required this.isPaused,
    this.isFailed = false,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRetry,
  });

  final String title;
  final String? subtitle;
  final double progress;
  final String? progressDetail;
  final bool isDownloading;
  final bool isPaused;
  final bool isFailed;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final accent = isFailed
        ? colors.error
        : (isPaused ? colors.warning : colors.primaryStrong);

    return Container(
      margin: AppSpacing.directional(
        start: AppSpacing.screenPadding,
        top: AppSpacing.screenPadding,
        end: AppSpacing.screenPadding,
      ),
      padding: AppSpacing.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  isPaused
                      ? Icons.pause_rounded
                      : isFailed
                      ? Icons.info_outline_rounded
                      : Icons.downloading_rounded,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            color: accent,
            backgroundColor: accent.withValues(alpha: 0.15),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (progressDetail != null)
                Text(
                  progressDetail!,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                )
              else
                const SizedBox.shrink(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDownloading && !isPaused && onPause != null)
                TextButton.icon(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause_rounded, size: 18),
                  label: const Text('إيقاف مؤقت'),
                ),
              if (isPaused && onResume != null)
                TextButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('استئناف'),
                ),
              if (isFailed && onRetry != null)
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('إعادة المحاولة'),
                ),
              if (onCancel != null) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('إلغاء'),
                  style: TextButton.styleFrom(foregroundColor: colors.error),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
