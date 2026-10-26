import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const String routePath = '/about';

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final theme = Theme.of(context);
    final accentColor = colors.primaryStrong;
    final surfaceColor = colors.surfaceElevated;
    final titleColor = colors.textPrimary;
    final mutedColor = colors.textSecondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          title: const Text('حول التطبيق'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(color: colors.border),
                    boxShadow: context.tokens.shadows.medium,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: accentColor,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'المبين',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'تطبيق إسلامي يجمع قراءة القرآن الكريم، الأذكار، الأدعية، والمكتبات المساندة بتجربة هادئة وسلسة.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mutedColor,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          'الإصدار 1.0.0',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
