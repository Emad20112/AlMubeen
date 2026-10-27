import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/application/translation_download_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شريط تقدم تنزيل الترجمة، مع أزرار الإيقاف المؤقت والاستئناف والإلغاء.
class TranslationDownloadProgressBanner extends ConsumerWidget {
  const TranslationDownloadProgressBanner({super.key, required this.state});

  final TranslationDownloadState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.semanticColors;
    final controller = ref.read(translationDownloadControllerProvider.notifier);

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
              Expanded(
                child: Text(
                  state.message ?? 'جاري تنزيل الترجمة...',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (state.isPaused)
                Icon(Icons.pause_circle_outline, color: colors.error, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(value: state.progress),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السورة ${state.currentChapter ?? 0} من ${state.totalChapters}',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              Text(
                '${(state.progress * 100).toInt()}%',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (state.isDownloading && !state.isPaused)
                TextButton.icon(
                  onPressed: controller.pauseDownload,
                  icon: const Icon(Icons.pause_rounded, size: 18),
                  label: const Text('إيقاف مؤقت'),
                ),
              if (state.isPaused)
                TextButton.icon(
                  onPressed: controller.resumeDownload,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('استئناف'),
                ),
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                onPressed: controller.cancelDownload,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('إلغاء'),
                style: TextButton.styleFrom(foregroundColor: colors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
