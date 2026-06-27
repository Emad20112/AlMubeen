import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/translation_download_screen.dart';
import 'package:flutter/material.dart';

void showQuranLibrarySheet({required BuildContext context}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _QuranLibrarySheet(),
  );
}

class _QuranLibrarySheet extends StatelessWidget {
  const _QuranLibrarySheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF1A1210)
        : AppColors.parchmentLight;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final surfaceColor = isDark ? const Color(0xFF2B201C) : Colors.white;
    final mutedColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.local_library_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المكتبة',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اختر القسم الذي تريد فتحه',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    _LibraryOptionCard(
                      icon: Icons.headphones_rounded,
                      title: 'المكتبة الصوتية',
                      subtitle: 'جميع القرّاء مع التحميل المحلي',
                      accentColor: const Color(0xFF9B5E2E),
                      backgroundColor: surfaceColor,
                      onTap: () => _openScreen(
                        context,
                        const QuranAudioDownloadScreen(),
                      ),
                    ),
                    _LibraryOptionCard(
                      icon: Icons.menu_book_rounded,
                      title: 'مكتبة كتب التفسير',
                      subtitle: 'تحميل التفاسير واستخدامها محليًا',
                      accentColor: primaryColor,
                      backgroundColor: surfaceColor,
                      onTap: () =>
                          _openScreen(context, const TafsirDownloadScreen()),
                    ),
                    _LibraryOptionCard(
                      icon: Icons.translate_rounded,
                      title: 'مكتبة كتب الترجمات',
                      subtitle: 'ترجمات المعاني والآيات',
                      accentColor: const Color(0xFF2E6E6A),
                      backgroundColor: surfaceColor,
                      onTap: () => _openScreen(
                        context,
                        const TranslationDownloadScreen(),
                      ),
                    ),
                    _LibraryOptionCard(
                      icon: Icons.auto_stories_rounded,
                      title: 'مكتبة الأحاديث',
                      subtitle: 'كتب الحديث والشروح',
                      accentColor: const Color(0xFF556B2F),
                      backgroundColor: surfaceColor,
                      onTap: () => _openPlaceholder(
                        context,
                        title: 'مكتبة الأحاديث',
                        description:
                            'سيتم هنا لاحقًا عرض كتب الأحاديث مع إمكان التصفح والتنزيل المحلي.',
                        icon: Icons.auto_stories_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (context) => screen));
  }

  void _openPlaceholder(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    Navigator.of(context).pop();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (context) => QuranLibraryPlaceholderScreen(
          title: title,
          description: description,
          icon: icon,
        ),
      ),
    );
  }
}

class _LibraryOptionCard extends StatelessWidget {
  const _LibraryOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuranLibraryPlaceholderScreen extends StatelessWidget {
  const QuranLibraryPlaceholderScreen({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: isDark
              ? const Color(0xFF1A1210)
              : AppColors.maroon800,
          foregroundColor: isDark
              ? const Color(0xFFD8B457)
              : AppColors.parchmentLight,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 460),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF231A17) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accentColor.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(icon, color: accentColor, size: 36),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.7,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('رجوع'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
