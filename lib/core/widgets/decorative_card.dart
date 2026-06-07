import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DecorativeCard extends StatelessWidget {
  const DecorativeCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.isImportant = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isImportant;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.parchmentLight;
    final accentColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final shadowColor = AppColors.maroon900.withValues(
      alpha: isDark ? 0.28 : 0.13,
    );

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accentColor.withValues(alpha: isImportant ? 0.46 : 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: isImportant ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: SvgPicture.asset(
                      AppAssets.decorativeCardFrame,
                      fit: BoxFit.fill,
                      colorFilter: ColorFilter.mode(
                        accentColor.withValues(alpha: 0.42),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
