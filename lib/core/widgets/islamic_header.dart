import 'package:al_mubeen/app/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final accentColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.goldenAccent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon900.withValues(alpha: isDark ? 0.28 : 0.10),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minWidth: 48),
                  child: leading ?? const SizedBox.shrink(),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                  constraints: const BoxConstraints(minWidth: 48),
                  child: trailing ?? const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 18,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.82 : 0.92),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(
                          alpha: isDark ? 0.8 : 0.72,
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
