import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';

/// بطاقة اختيار القارئ في قائمة وقوائم القراء.
class ReciterPickerTile extends StatelessWidget {
  const ReciterPickerTile({
    super.key,
    required this.recitation,
    required this.isSelected,
    required this.onTap,
  });

  final QuranRecitation recitation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final isDark = colors.isDark;
    final titleColor = colors.textPrimary;
    final mutedColor = colors.textSecondary;
    final accentColor = colors.accent;

    final isIslamicApp = recitation.id < 0;
    final sourceBadge = isIslamicApp ? 'Islamic.app' : 'Quran.com';
    final sourceBadgeColor = isIslamicApp
        ? const Color(0xFF2E7D55)
        : colors.primaryStrong;

    final arabicName = recitation.reciterName;
    final englishName =
        (recitation.translatedName?.trim().isNotEmpty == true &&
            recitation.translatedName != recitation.reciterName)
        ? recitation.translatedName!
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08)
                : accentColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.35)
                  : accentColor.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
                      accentColor.withValues(alpha: isDark ? 0.10 : 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(
                  Icons.record_voice_over_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arabicName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: accentColor,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              'القارئ المستخدم حالياً',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),
                    if (englishName != null) ...[
                      Text(
                        englishName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: mutedColor.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ] else
                      const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: sourceBadgeColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Text(
                        sourceBadge,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: sourceBadgeColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  size: isSelected ? 22 : 16,
                  color: isSelected
                      ? accentColor
                      : mutedColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
