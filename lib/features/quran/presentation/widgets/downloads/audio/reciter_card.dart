import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';

/// بطاقة عرض القارئ في شاشة تنزيل التلاوات الصوتية.
class ReciterCard extends StatelessWidget {
  const ReciterCard({
    super.key,
    required this.recitation,
    required this.isSelected,
    required this.isDownloadTarget,
    required this.hasAnotherActiveDownload,
    required this.isDownloading,
    required this.isPaused,
    required this.onTap,
    required this.onDownload,
  });

  final QuranRecitation recitation;
  final bool isSelected;
  final bool isDownloadTarget;
  final bool hasAnotherActiveDownload;
  final bool isDownloading;
  final bool isPaused;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final accent = isSelected ? colors.primaryStrong : colors.textSecondary;

    final buttonLabel = isPaused
        ? 'استئناف'
        : isDownloading
        ? 'قيد التنزيل'
        : 'تنزيل كامل';
    final buttonIcon = isPaused
        ? Icons.play_arrow_rounded
        : isDownloading
        ? Icons.downloading_rounded
        : Icons.download_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: accent.withValues(alpha: isSelected ? 0.35 : 0.12),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.surfaceSunken.withValues(
              alpha: isSelected ? 0.14 : 0.05,
            ),
            blurRadius: isSelected ? 14 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primaryStrong.withValues(alpha: 0.12),
                          border: Border.all(
                            color: colors.primaryStrong.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.mic_none_rounded,
                          color: colors.primaryStrong,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    recitation.reciterName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primaryStrong.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.pill,
                                      ),
                                    ),
                                    child: Text(
                                      'المحدد',
                                      style: TextStyle(
                                        color: colors.primaryStrong,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _reciterSubtitle(recitation),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.tonalIcon(
                  onPressed: hasAnotherActiveDownload ? null : onDownload,
                  icon: Icon(buttonIcon, size: 16),
                  label: Text(
                    buttonLabel,
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _reciterSubtitle(QuranRecitation recitation) {
    final style = recitation.style?.trim();
    if (style != null && style.isNotEmpty) {
      return style;
    }
    final translated = recitation.translatedName?.trim();
    if (translated != null && translated.isNotEmpty) {
      return translated;
    }
    return 'رواية حفص عن عاصم';
  }
}
