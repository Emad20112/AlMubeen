import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/screens/contact_style_menu_screen.dart';
import 'package:al_mubeen/features/about/presentation/screens/about_app_screen.dart';
import 'package:al_mubeen/features/hadith_nawawi/presentation/screens/hadith_nawawi_screen.dart';
import 'package:al_mubeen/features/names_of_allah/presentation/screens/names_of_allah_screen.dart';
import 'package:al_mubeen/features/qibla/presentation/screens/qibla_compass_screen.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_surah_player_screen.dart';
import 'package:al_mubeen/features/tasbih/presentation/screens/tasbih_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuranMoreScreen extends StatelessWidget {
  const QuranMoreScreen({this.readerActions, super.key});

  static const String routePath = '/quran/more';

  final QuranReaderMoreActions? readerActions;

  @override
  Widget build(BuildContext context) {
    final actions = readerActions;

    return ContactStyleMenuScreen(
      title: 'المزيد',
      subtitle: 'مساحات إضافية وأدوات مساندة داخل التطبيق.',
      icon: Icons.more_horiz_rounded,
      sections: [
        if (actions != null)
          ContactStyleMenuSection(
            title:
                'أدوات القارئ - صفحة ${convertToArabicDigits(actions.currentPage)}',
            items: [
              ContactStyleMenuItem(
                icon: Icons.search_rounded,
                title: 'البحث',
                subtitle: 'ابحث عن صفحة أو سورة داخل المصحف.',
                accentColor: AppColors.maroon800,
                onTap: () => _runReaderAction(context, actions.onSearch),
              ),
              ContactStyleMenuItem(
                icon: Icons.menu_book_rounded,
                title: 'السور',
                subtitle: 'انتقال سريع إلى أي سورة.',
                accentColor: const Color(0xFF2E6E6A),
                onTap: () => _runReaderAction(context, actions.onSurahPicker),
              ),
              ContactStyleMenuItem(
                icon: Icons.bookmarks_rounded,
                title: 'المحفوظات',
                subtitle: 'العلامات والصفحات المحفوظة.',
                accentColor: const Color(0xFF9B5E2E),
                onTap: () => _runReaderAction(context, actions.onBookmarks),
              ),
              ContactStyleMenuItem(
                icon: Icons.settings_rounded,
                title: 'إعدادات القارئ',
                subtitle: 'الوضع، الخط، الترجمة، وخيارات القراءة.',
                accentColor: const Color(0xFF5E5B8A),
                onTap: () => _runReaderAction(context, actions.onSettings),
              ),
              ContactStyleMenuItem(
                icon: Icons.library_music_rounded,
                title: 'المكتبة الصوتية',
                subtitle: 'مكتبة القراء وتنزيل التلاوات الكاملة.',
                accentColor: const Color(0xFF7B6A2E),
                onTap: () => context.push(QuranAudioDownloadScreen.routePath),
              ),
              ContactStyleMenuItem(
                icon: Icons.headphones_rounded,
                title: 'استماع القرآن الكريم',
                subtitle: 'مشغّل السور مع تنزيل السورة الحالية مباشرة.',
                accentColor: const Color(0xFF6A5A2E),
                onTap: () => context.push(QuranSurahPlayerScreen.routePath),
              ),
            ],
          ),
        ContactStyleMenuSection(
          title: 'المزيد من التطبيق',
          items: [
            ContactStyleMenuItem(
              icon: Icons.auto_awesome_rounded,
              title: 'أسماء الله الحسنى',
              subtitle: 'تصفح الأسماء ومعانيها.',
              accentColor: AppColors.maroon800,
              onTap: () => context.push(NamesOfAllahScreen.routePath),
            ),
            ContactStyleMenuItem(
              icon: Icons.format_quote_rounded,
              title: 'الأربعون النووية',
              subtitle: 'قراءة أحاديث الأربعين النووية.',
              accentColor: const Color(0xFF9B5E2E),
              onTap: () => context.push(HadithNawawiScreen.routePath),
            ),
            ContactStyleMenuItem(
              icon: Icons.task_alt_rounded,
              title: 'منبهات المهام اليومية',
              subtitle: 'سنضيفها لاحقًا بإذن الله.',
              accentColor: const Color(0xFF5E5B8A),
              badge: 'قريبًا',
              enabled: false,
            ),
            ContactStyleMenuItem(
              icon: Icons.explore_rounded,
              title: 'تحديد القبلة',
              subtitle: 'اعرف اتجاه القبلة من موقعك.',
              accentColor: const Color(0xFF2E6E6A),
              onTap: () => context.push(QiblaCompassScreen.routePath),
            ),
            ContactStyleMenuItem(
              icon: Icons.radio_button_checked_rounded,
              title: 'التسبيح',
              subtitle: 'عداد تسبيح بسيط وسريع.',
              accentColor: const Color(0xFF8B2532),
              onTap: () => context.push(TasbihScreen.routePath),
            ),
            ContactStyleMenuItem(
              icon: Icons.info_rounded,
              title: 'حول التطبيق',
              subtitle: 'معلومات مختصرة عن تطبيق المبين.',
              accentColor: const Color(0xFF556B2F),
              onTap: () => context.push(AboutAppScreen.routePath),
            ),
          ],
        ),
      ],
    );
  }

  void _runReaderAction(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    unawaited(Future<void>.delayed(const Duration(milliseconds: 180), action));
  }
}

class QuranReaderMoreActions {
  const QuranReaderMoreActions({
    required this.currentPage,
    required this.onSearch,
    required this.onSurahPicker,
    required this.onBookmarks,
    required this.onSettings,
  });

  final int currentPage;
  final VoidCallback onSearch;
  final VoidCallback onSurahPicker;
  final VoidCallback onBookmarks;
  final VoidCallback onSettings;
}
