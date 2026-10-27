import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// شريط تنبيه موحد يُعرض عندما تفشل قائمة الموارد الكاملة ويُكتفى بالمحمّل محليًا.
class ResourceFallbackNotice extends StatelessWidget {
  const ResourceFallbackNotice({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return Padding(
      padding: AppSpacing.directional(
        start: AppSpacing.screenPadding,
        top: AppSpacing.screenPadding,
        end: AppSpacing.screenPadding,
      ),
      child: Container(
        width: double.infinity,
        padding: AppSpacing.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: colors.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: colors.primaryStrong,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('إعادة')),
          ],
        ),
      ),
    );
  }
}
