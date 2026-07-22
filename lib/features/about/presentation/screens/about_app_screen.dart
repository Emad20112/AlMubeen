import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const String routePath = '/about';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.goldenAccentDark : AppColors.maroon800;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
        appBar: AppBar(
          title: const Text('حول التطبيق'),
          centerTitle: true,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.maroon800,
          foregroundColor: isDark ? AppColors.goldenAccentDark : AppColors.parchmentLight,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: accentColor.withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: accentColor,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'المبين',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تطبيق إسلامي يجمع قراءة القرآن الكريم، الأذكار، الأدعية، والمكتبات المساندة بتجربة هادئة وسلسة.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: mutedColor,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'الإصدار 1.0.0',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
