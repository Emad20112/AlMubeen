import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/decorative_badge.dart';
import 'package:al_mubeen/core/widgets/decorative_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';

class AdhkarGridCard extends StatelessWidget {
  const AdhkarGridCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;
    final secondaryColor = isDark
        ? AppColors.parchmentMuted
        : AppColors.maroon700;
    final textScaler = MediaQuery.textScalerOf(context);

    return DecorativeCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 32), // Balance the badge space
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  icon,
                  color: foregroundColor,
                  size: textScaler.scale(42).clamp(38, 52).toDouble(),
                ),
              ),
              SizedBox.square(
                dimension: textScaler.scale(32).clamp(30, 36).toDouble(),
                child: DecorativeBadge(label: count.toString()),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: secondaryColor.withValues(alpha: 0.8),
              fontSize: 11,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 12,
            child: SvgPicture.asset(
              AppAssets.decorativeDivider,
              colorFilter: ColorFilter.mode(secondaryColor.withValues(alpha: 0.5), BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}
