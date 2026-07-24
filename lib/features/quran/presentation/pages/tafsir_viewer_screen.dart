import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_reader_content.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

class TafsirViewerScreen extends StatefulWidget {
  const TafsirViewerScreen({
    required this.chapterNumber,
    this.ayahNumber,
    super.key,
  });

  static const String routeName = '/tafsir-viewer';

  final int chapterNumber;
  final int? ayahNumber;

  @override
  State<TafsirViewerScreen> createState() => _TafsirViewerScreenState();
}

class _TafsirViewerScreenState extends State<TafsirViewerScreen> {
  late final PageController _pageController;
  late final int _totalAyahs;
  late int _currentAyah;

  @override
  void initState() {
    super.initState();
    _totalAyahs = getVerseCount(widget.chapterNumber);
    _currentAyah = (widget.ayahNumber ?? 1).clamp(1, _totalAyahs);
    _pageController = PageController(initialPage: _currentAyah - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextAyah() {
    if (_currentAyah < _totalAyahs) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousAyah() {
    if (_currentAyah > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openLibrary() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (context) => const TafsirDownloadScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahName = getSurahName(widget.chapterNumber);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      appBar: AppBar(
        title: Text(
          widget.ayahNumber != null
              ? 'تفسير سورة $surahName - الآية $_currentAyah من $_totalAyahs'
              : 'تفسير سورة $surahName',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1210) : AppColors.maroon800,
        foregroundColor: isDark
            ? const Color(0xFFD8B457)
            : AppColors.parchmentLight,
        elevation: 0,
        actions: [
          if (widget.ayahNumber != null) ...[
            IconButton(
              onPressed: _currentAyah > 1 ? _previousAyah : null,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              tooltip: 'الآية السابقة',
            ),
            IconButton(
              onPressed: _currentAyah < _totalAyahs ? _nextAyah : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              tooltip: 'الآية التالية',
            ),
          ],
          IconButton(
            tooltip: 'تحميل تفاسير أخرى',
            onPressed: _openLibrary,
            icon: const Icon(Icons.library_books_rounded),
          ),
        ],
      ),
      body: widget.ayahNumber != null
          ? PageView.builder(
              controller: _pageController,
              itemCount: _totalAyahs,
              onPageChanged: (index) {
                setState(() => _currentAyah = index + 1);
              },
              itemBuilder: (context, index) {
                return TafsirReaderContent(
                  chapterNumber: widget.chapterNumber,
                  ayahNumber: index + 1,
                  onOpenLibrary: _openLibrary,
                );
              },
            )
          : TafsirReaderContent(
              chapterNumber: widget.chapterNumber,
              ayahNumber: null,
              onOpenLibrary: _openLibrary,
            ),
    );
  }
}
