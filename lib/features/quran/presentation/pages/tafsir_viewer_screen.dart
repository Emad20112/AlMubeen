import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_reader_content.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

class TafsirViewerScreen extends StatelessWidget {
  const TafsirViewerScreen({
    required this.chapterNumber,
    required this.ayahNumber,
    super.key,
  });

  static const String routeName = '/tafsir-viewer';

  final int chapterNumber;
  final int? ayahNumber;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahName = getSurahName(chapterNumber);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      appBar: AppBar(
        title: Text(
          ayahNumber != null
              ? 'تفسير سورة $surahName - الآية $ayahNumber'
              : 'تفسير سورة $surahName',
        ),
        backgroundColor: isDark ? const Color(0xFF1A1210) : AppColors.maroon800,
        foregroundColor: isDark
            ? const Color(0xFFD8B457)
            : AppColors.parchmentLight,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'تحميل تفاسير أخرى',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (context) => const TafsirDownloadScreen(),
                ),
              );
            },
            icon: const Icon(Icons.library_books_rounded),
          ),
        ],
      ),
      body: TafsirReaderContent(
        chapterNumber: chapterNumber,
        ayahNumber: ayahNumber,
        onOpenLibrary: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute<void>(
              builder: (context) => const TafsirDownloadScreen(),
            ),
          );
        },
      ),
    );
  }
}
