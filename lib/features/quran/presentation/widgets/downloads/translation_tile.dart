import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/material.dart';

/// بطاقة عرض خيار الترجمة للتنزيل أو التفعيل.
class TranslationTile extends StatelessWidget {
  const TranslationTile({
    super.key,
    required this.translation,
    required this.isSelected,
    required this.isDownloaded,
    required this.isDownloading,
    required this.isPaused,
    required this.downloadProgress,
    required this.onTap,
  });

  final Translation translation;
  final bool isSelected;
  final bool isDownloaded;
  final bool isDownloading;
  final bool isPaused;
  final double? downloadProgress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final primaryColor = colors.primaryStrong;
    final statusWidgets = <Widget>[];
    Widget trailingWidget = const SizedBox.shrink();

    if (isDownloading) {
      statusWidgets.addAll([
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: downloadProgress,
          color: primaryColor,
          backgroundColor: primaryColor.withValues(alpha: 0.15),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'جاري التنزيل...',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
          ),
        ),
      ]);
      trailingWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
        ),
      );
    } else if (isPaused) {
      statusWidgets.addAll([
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: downloadProgress,
          color: primaryColor,
          backgroundColor: primaryColor.withValues(alpha: 0.15),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'متوقف مؤقتًا',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
          ),
        ),
      ]);
      trailingWidget = Icon(
        Icons.pause_circle_outline_rounded,
        color: primaryColor,
        size: 24,
      );
    } else if (isDownloaded) {
      statusWidgets.addAll([
        const SizedBox(height: AppSpacing.xs),
        Text(
          'محمّلة محليًا',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
          ),
        ),
      ]);
      trailingWidget = Icon(
        Icons.download_done_rounded,
        color: primaryColor,
        size: 24,
      );
    } else {
      trailingWidget = IconButton(
        icon: const Icon(Icons.download_rounded),
        color: primaryColor,
        tooltip: 'تنزيل الترجمة',
        onPressed: onTap,
      );
    }

    if (isSelected && isDownloaded) {
      trailingWidget = Icon(Icons.check_circle, color: primaryColor, size: 24);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : colors.border.withValues(alpha: 0.15),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.surfaceSunken.withValues(alpha: isSelected ? 0.15 : 0.05),
            blurRadius: isSelected ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translation.name,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (translation.resourceName != null &&
                          translation.resourceName != translation.name) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          translation.resourceName!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (translation.authorName != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'المترجم: ${translation.authorName!}',
                          style: TextStyle(
                            color: colors.textSecondary.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (translation.translatedAuthorName != null &&
                          translation.translatedAuthorName !=
                              translation.authorName) ...[
                        const SizedBox(height: 2),
                        Text(
                          translation.translatedAuthorName!,
                          style: TextStyle(
                            color: colors.textSecondary.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      ...statusWidgets,
                    ],
                  ),
                ),
                trailingWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
