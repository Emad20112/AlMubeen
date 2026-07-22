import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_reader_content.dart';
import 'package:flutter/material.dart';

void showTafsirBottomSheet({
  required BuildContext context,
  required int chapterNumber,
  required int ayahNumber,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        TafsirBottomSheet(chapterNumber: chapterNumber, ayahNumber: ayahNumber),
  );
}

class TafsirBottomSheet extends StatelessWidget {
  const TafsirBottomSheet({
    required this.chapterNumber,
    required this.ayahNumber,
    super.key,
  });

  final int chapterNumber;
  final int ayahNumber;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: _TafsirBottomSheetFrame(
        isDark: isDark,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: TafsirReaderContent(
                chapterNumber: chapterNumber,
                ayahNumber: ayahNumber,
                onOpenLibrary: () {
                  Navigator.pop(context);
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const TafsirDownloadScreen(),
                    ),
                  );
                },
                onClose: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TafsirBottomSheetFrame extends StatelessWidget {
  const _TafsirBottomSheetFrame({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1210).withValues(alpha: 0.95)
                    : AppColors.parchment.withValues(alpha: 0.98),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
