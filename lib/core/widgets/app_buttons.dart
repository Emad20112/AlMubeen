import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// زر تفاعلي أساسي موحد (Primary CTA Button).
///
/// يتميز بـ:
/// - ارتفاع قياسي لا يقل عن 48dp لتحقيق شروط إمكانية الوصول (WCAG Touch Target).
/// - مؤشر تحميل داخلي متناسق `isLoading`.
/// - رد فعل لمسي خفيف عند الضغط (Haptic Feedback).
/// - دعم الأيقونة الاختيارية، وتمدد العرض بالكامل `isFullWidth`.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 48.0,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final isEnabled = onPressed != null && !isLoading;
    final radius = borderRadius ?? AppRadii.lg;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimaryStrong),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isEnabled
                ? colors.onPrimaryStrong
                : colors.textDisabled,
            height: 1.1,
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: isEnabled
            ? colors.primaryStrong
            : colors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: isEnabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

/// زر تفاعلي ثانوي موحد بإطار أو خلفية مخففة (Secondary / Outlined Button).
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 48.0,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final isEnabled = onPressed != null && !isLoading;
    final radius = borderRadius ?? AppRadii.lg;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primaryStrong),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isEnabled
                ? colors.textPrimary
                : colors.textDisabled,
            height: 1.1,
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: isEnabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: isEnabled
                    ? colors.border
                    : colors.border.withValues(alpha: 0.4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

/// زر نصي خفيف بدون حدود أو خلفية (Ghost / Text Button).
class AppGhostButton extends StatelessWidget {
  const AppGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final isEnabled = onPressed != null;
    final textColor = foregroundColor ?? colors.textSecondary;

    return TextButton.icon(
      onPressed: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          : null,
      icon: icon ?? const SizedBox.shrink(),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isEnabled ? textColor : colors.textDisabled,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );
  }
}

/// زر أيقونة موحد بمساحة لمس آمنة لا تقل عن 48x48 (AppIconButton).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 22.0,
    this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final iconColor = color ?? colors.textPrimary;

    Widget button = IconButton(
      tooltip: tooltip,
      onPressed: onPressed != null
          ? () {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          : null,
      icon: Icon(icon, size: size, color: iconColor),
      style: backgroundColor != null
          ? IconButton.styleFrom(backgroundColor: backgroundColor)
          : null,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: button,
    );
  }
}
