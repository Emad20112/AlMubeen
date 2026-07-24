import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_reader_content.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

void showTafsirBottomSheet({
  required BuildContext context,
  required int chapterNumber,
  required int ayahNumber,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TafsirBottomSheet(
      chapterNumber: chapterNumber,
      ayahNumber: ayahNumber,
    ),
  );
}

class TafsirBottomSheet extends StatefulWidget {
  const TafsirBottomSheet({
    required this.chapterNumber,
    required this.ayahNumber,
    super.key,
  });

  final int chapterNumber;
  final int ayahNumber;

  @override
  State<TafsirBottomSheet> createState() => _TafsirBottomSheetState();
}

class _TafsirBottomSheetState extends State<TafsirBottomSheet> {
  late final PageController _pageController;
  late final int _totalAyahs;
  late int _currentAyah;

  @override
  void initState() {
    super.initState();
    _totalAyahs = getVerseCount(widget.chapterNumber);
    _currentAyah = widget.ayahNumber.clamp(1, _totalAyahs);
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
    Navigator.pop(context);
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
    final bgColor = isDark
        ? const Color(0xFF1E1715)
        : AppColors.parchment;
    final fgColor = isDark ? Colors.white : Colors.black87;
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final cardBg = isDark ? const Color(0xFF2B211E) : Colors.white;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),

            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Previous Ayah Button
                  IconButton(
                    onPressed: _currentAyah > 1 ? _previousAyah : null,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: fgColor,
                      disabledForegroundColor: fgColor.withValues(alpha: 0.2),
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: accentColor.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    tooltip: 'الآية السابقة',
                  ),

                  const Spacer(),

                  // Surah & Ayah Badge
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'سورة $surahName',
                        style: TextStyle(
                          color: fgColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'الآية $_currentAyah من $_totalAyahs',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Next Ayah Button
                  IconButton(
                    onPressed: _currentAyah < _totalAyahs ? _nextAyah : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: fgColor,
                      disabledForegroundColor: fgColor.withValues(alpha: 0.2),
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: accentColor.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    tooltip: 'الآية التالية',
                  ),

                  const SizedBox(width: 8),

                  // Library Button
                  IconButton(
                    onPressed: _openLibrary,
                    icon: const Icon(Icons.library_books_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: accentColor,
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    tooltip: 'المكتبة',
                  ),

                  const SizedBox(width: 6),

                  // Close Button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: fgColor.withValues(alpha: 0.7),
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: fgColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // PageView content
            Expanded(
              child: PageView.builder(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
