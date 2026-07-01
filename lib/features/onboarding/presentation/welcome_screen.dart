import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkScaffold
        : AppColors.parchment;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final foregroundColor = isDark ? AppColors.darkInk : AppColors.ink;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Card(
                      elevation: 0,
                      color: surfaceColor,
                      shadowColor: AppColors.maroon900.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                          color: AppColors.maroon800.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.maroon800.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.maroon800,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Al-Mubeen',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: foregroundColor,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'ابدأ رحلتك القرآنية بهدوء وطمأنينة، وسيبقى كل شيء مرتبًا لك على هذا الجهاز.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: foregroundColor.withValues(
                                      alpha: 0.82,
                                    ),
                                    height: 1.7,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: () async {
                                await ref
                                    .read(appUserPreferencesProvider.notifier)
                                    .completeWelcome();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.maroon800,
                                foregroundColor: AppColors.parchmentLight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('ابدأ الآن'),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'يمكنك تخصيص النمط والخط والقارئ لاحقًا من الصفحة الرئيسية.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: foregroundColor.withValues(
                                      alpha: 0.62,
                                    ),
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
