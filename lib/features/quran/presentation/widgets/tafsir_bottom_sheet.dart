import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_html_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

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

class TafsirBottomSheet extends ConsumerWidget {
  const TafsirBottomSheet({
    required this.chapterNumber,
    required this.ayahNumber,
    super.key,
  });

  final int chapterNumber;
  final int ayahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTafsirId = ref.watch(selectedTafsirProvider);
    final surahName = getSurahName(chapterNumber);

    final tafsirAsync = ref.watch(
      tafsirAyahProvider((
        resourceId: selectedTafsirId,
        chapterNumber: chapterNumber,
        ayahNumber: ayahNumber,
      )),
    );

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {}, // Prevent closing when tapping the sheet
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1210).withValues(alpha: 0.95)
                      : AppColors.parchment.withValues(alpha: 0.98),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
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
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isDark
                                          ? const Color(0xFFD8B457)
                                          : AppColors.maroon800)
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    (isDark
                                            ? const Color(0xFFD8B457)
                                            : AppColors.maroon800)
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  color: isDark
                                      ? const Color(0xFFD8B457)
                                      : AppColors.maroon800,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'تفسير',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFD8B457)
                                        : AppColors.maroon800,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surahName,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'الآية $ayahNumber',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Content
                    Expanded(
                      child: tafsirAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'حدث خطأ أثناء تحميل التفسير',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error.toString(),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.invalidate(
                                      tafsirAyahProvider((
                                        resourceId: selectedTafsirId,
                                        chapterNumber: chapterNumber,
                                        ayahNumber: ayahNumber,
                                      )),
                                    );
                                  },
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        data: (tafsirText) {
                          final accentColor = isDark
                              ? const Color(0xFFD8B457)
                              : AppColors.maroon800;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF231A17)
                                    : const Color(0xFFFFFCF3),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.14),
                                ),
                              ),
                              child: Column(
                                children: [
                                  if (tafsirText.resourceName.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        16,
                                        16,
                                        0,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentColor.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: accentColor.withValues(
                                              alpha: 0.18,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.menu_book_rounded,
                                              color: accentColor,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                tafsirText.resourceName,
                                                style: TextStyle(
                                                  color: accentColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: TafsirHtmlContent(
                                      text: tafsirText.text,
                                      accentColor: accentColor,
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        18,
                                      ),
                                      textStyle: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 17,
                                        height: 1.95,
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
