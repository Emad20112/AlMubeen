import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/screens/contact_style_menu_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/translation_download_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuranLibrariesScreen extends StatelessWidget {
  const QuranLibrariesScreen({super.key});

  static const String routePath = '/quran/libraries';

  @override
  Widget build(BuildContext context) {
    return ContactStyleMenuScreen(
      title: 'المكتبات',
      subtitle: 'إدارة مكتبات القرآن الثلاثة: الصوت، التفسير، والترجمات.',
      icon: Icons.local_library_rounded,
      sections: [
        ContactStyleMenuSection(
          items: [
            ContactStyleMenuItem(
              icon: Icons.headphones_rounded,
              title: 'المكتبة الصوتية',
              subtitle: 'جميع القرّاء مع التحميل المحلي.',
              accentColor: const Color(0xFF9B5E2E),
              onTap: () => context.push(QuranAudioDownloadScreen.routePath),
            ),
            ContactStyleMenuItem(
              icon: Icons.menu_book_rounded,
              title: 'مكتبة كتب التفسير',
              subtitle: 'تحميل التفاسير واستخدامها محليًا.',
              accentColor: AppColors.maroon800,
              onTap: () => context.push(TafsirDownloadScreen.routeName),
            ),
            ContactStyleMenuItem(
              icon: Icons.translate_rounded,
              title: 'مكتبة كتب الترجمات',
              subtitle: 'ترجمات المعاني والآيات.',
              accentColor: const Color(0xFF2E6E6A),
              onTap: () => context.push(TranslationDownloadScreen.routeName),
            ),
          ],
        ),
      ],
    );
  }
}
