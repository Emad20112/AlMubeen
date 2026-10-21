import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DecorativeCard extends StatelessWidget {
  const DecorativeCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
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
    final colors = context.semanticColors;
    final backgroundColor = colors.surfaceElevated;
    final accentColor = colors.primaryStrong;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: colors.border.withValues(alpha: isImportant ? 0.8 : 0.4),
              ),
              boxShadow: isImportant
                  ? context.tokens.shadows.elevated
                  : context.tokens.shadows.subtle,
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
                        accentColor.withValues(alpha: 0.25),
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
