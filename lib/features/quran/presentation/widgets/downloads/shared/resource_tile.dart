import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// بطاقة عرض مورد موحدة (Resource Tile) للتنزيلات (ترجمة، تفسير، قراء).
///
/// مصممة بأعلى معايير الأداء والوصول وتوحيد الهوية البصرية:
/// - حاوية مرتفعة دلالية [context.semanticColors.surfaceElevated].
/// - مؤشرات حالة واضحة (تنزيل، إيقاف مؤقت، اكتمال، تحديد).
/// - استجابة لمسية سلسة ومتوافقة مع RTL.
class ResourceTile extends StatelessWidget {
  const ResourceTile({
    super.key,
    required this.title,
    this.subtitle,
    this.author,
    this.additionalInfo,
    this.leadingIcon = Icons.menu_book_rounded,
    required this.isSelected,
    required this.isDownloaded,
    required this.isDownloading,
    required this.isPaused,
    this.downloadProgress,
    required this.onTap,
    this.downloadTooltip = 'تنزيل',
    this.downloadedLabel = 'محمّل محليًا',
  });

  final String title;
  final String? subtitle;
  final String? author;
  final String? additionalInfo;
  final IconData leadingIcon;
  final bool isSelected;
  final bool isDownloaded;
  final bool isDownloading;
  final bool isPaused;
  final double? downloadProgress;
  final VoidCallback onTap;
  final String downloadTooltip;
  final String downloadedLabel;

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
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
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
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
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
          downloadedLabel,
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
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
        tooltip: downloadTooltip,
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
            color: colors.surfaceSunken.withValues(
              alpha: isSelected ? 0.15 : 0.05,
            ),
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
                  child: Icon(leadingIcon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null && subtitle != title) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (author != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          author!,
                          style: TextStyle(
                            color: colors.textSecondary.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (additionalInfo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          additionalInfo!,
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
