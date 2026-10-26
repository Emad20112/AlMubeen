import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.icon, super.key});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final color = colors.primaryStrong;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: SvgPicture.asset(
            AppAssets.decorativeDivider,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              color.withValues(alpha: 0.5),
              BlendMode.srcIn,
            ),
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(icon, color: color, size: 20),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Flexible(
          child: SvgPicture.asset(
            AppAssets.decorativeDivider,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              color.withValues(alpha: 0.5),
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
