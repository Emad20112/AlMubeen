import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class IslamicHeader extends StatelessWidget {
  const IslamicHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final backgroundColor = colors.surface;
    final titleColor = colors.textPrimary;
    final accentColor = colors.accent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: context.tokens.shadows.medium,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.touchTarget,
                  ),
                  child: leading ?? const SizedBox.shrink(),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.touchTarget,
                  ),
                  child: trailing ?? const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 18,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(
                      alpha: colors.isDark ? 0.82 : 0.92,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: accentColor.withValues(
                          alpha: colors.isDark ? 0.8 : 0.72,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
