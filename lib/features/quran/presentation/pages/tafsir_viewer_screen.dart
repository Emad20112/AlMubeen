import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_html_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class TafsirViewerScreen extends ConsumerWidget {
  const TafsirViewerScreen({
    required this.chapterNumber,
    required this.ayahNumber,
    super.key,
  });

  static const String routeName = '/tafsir-viewer';

  final int chapterNumber;
  final int? ayahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTafsirId = ref.watch(selectedTafsirProvider);

    final tafsirAsync = ayahNumber != null
        ? ref.watch(
            tafsirAyahProvider((
              resourceId: selectedTafsirId,
              chapterNumber: chapterNumber,
              ayahNumber: ayahNumber!,
            )),
          )
        : ref.watch(
            tafsirChapterProvider((
              resourceId: selectedTafsirId,
              chapterNumber: chapterNumber,
            )),
          );

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
      ),
      body: tafsirAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ أثناء تحميل التفسير',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (ayahNumber != null) {
                    ref.invalidate(
                      tafsirAyahProvider((
                        resourceId: selectedTafsirId,
                        chapterNumber: chapterNumber,
                        ayahNumber: ayahNumber!,
                      )),
                    );
                  } else {
                    ref.invalidate(
                      tafsirChapterProvider((
                        resourceId: selectedTafsirId,
                        chapterNumber: chapterNumber,
                      )),
                    );
                  }
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (tafsirText) {
          final accentColor = isDark
              ? const Color(0xFFD8B457)
              : AppColors.maroon800;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (tafsirText.resourceName.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tafsirText.resourceName,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF231A17)
                          : const Color(0xFFFFFCF3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.14),
                      ),
                    ),
                    child: TafsirHtmlContent(
                      text: tafsirText.text,
                      accentColor: accentColor,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                      textStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        height: 1.95,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
