import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';

/// نظام النوافذ المنبثقة والقوائم السفلية الموحد (Unified Modals & Sheets).
abstract final class AppBottomSheet {
  const AppBottomSheet._();

  /// عرض قائمة سفلية قياسية موحدة الهوية البصرية.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    double maxWidth = 560.0,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final colors = bottomSheetContext.semanticColors;
        final screenWidth = MediaQuery.sizeOf(bottomSheetContext).width;
        final sheetWidth = math.min(screenWidth, maxWidth);

        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: sheetWidth,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.xl),
                ),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.surfaceSunken.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 38,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: colors.border.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    ),
                    // Standard Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                if (subtitle != null && subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          AppIconButton(
                            icon: Icons.close_rounded,
                            tooltip: 'إغلاق',
                            onPressed: () => Navigator.of(bottomSheetContext).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Content
                    Flexible(
                      child: builder(bottomSheetContext),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// نظام مربعات الحوار التفاعلية الموحدة (Unified Dialog System).
abstract final class AppDialog {
  const AppDialog._();

  /// عرض مربع حوار تفاعلي قياسي.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    IconData? icon,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    double maxWidth = 420.0,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.semanticColors;
        final screenWidth = MediaQuery.sizeOf(dialogContext).width;
        final dialogWidth = math.min(screenWidth - 48, maxWidth);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SizedBox(
            width: dialogWidth,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.surfaceSunken.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (icon != null) ...[
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDestructive ? colors.error : colors.accent)
                              .withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          icon,
                          size: 26,
                          color: isDestructive ? colors.error : colors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                  if (content != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    content,
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      if (cancelLabel != null) ...[
                        Expanded(
                          child: AppSecondaryButton(
                            label: cancelLabel,
                            onPressed: onCancel ?? () => Navigator.of(dialogContext).pop(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      if (confirmLabel != null)
                        Expanded(
                          child: AppPrimaryButton(
                            label: confirmLabel,
                            onPressed: () {
                              if (onConfirm != null) {
                                onConfirm();
                              } else {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
