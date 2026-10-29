import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/widgets/app_state_views.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/search/search_result_cards.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/search/search_sections.dart';
import 'package:flutter/material.dart';

/// واجهة الحالة الفارغة للبحث القرآني.
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyStateView(
      icon: Icons.manage_search_rounded,
      title: 'ابدأ البحث في القرآن الكريم',
      message:
          'اكتب كلمة أو آية للبحث في نص المصحف، أسماء السور، التفاسير، والترجمات.',
    );
  }
}

/// واجهة حالة التحميل أثناء المعالجة.
class SearchLoadingState extends StatelessWidget {
  const SearchLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

/// جسم نتائج البحث القرآني المتعدد.
class SearchResultsBody extends StatelessWidget {
  const SearchResultsBody({
    super.key,
    required this.query,
    required this.surahs,
    required this.showSurahNames,
    required this.showQuranText,
    required this.showTafsir,
    required this.showTranslations,
    required this.showReciters,
    required this.onSelectPage,
    required this.onSelectAyah,
    required this.onCopyText,
    required this.onOpenTafsirBook,
    required this.onOpenTranslationBook,
    required this.onSelectReciter,
  });

  final String query;
  final List<SurahMetadata> surahs;
  final bool showSurahNames;
  final bool showQuranText;
  final bool showTafsir;
  final bool showTranslations;
  final bool showReciters;
  final ValueChanged<int> onSelectPage;
  final ValueChanged<AyahRef> onSelectAyah;
  final ValueChanged<String> onCopyText;
  final ValueChanged<int> onOpenTafsirBook;
  final ValueChanged<int> onOpenTranslationBook;
  final ValueChanged<int> onSelectReciter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (showSurahNames && surahs.isNotEmpty) ...[
          const SearchSectionDivider(title: 'السور القرآنية'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final surah in surahs)
                SurahResultCard(
                  key: ValueKey('surah-${surah.number}'),
                  surah: surah,
                  onTap: () => onSelectPage(surah.firstPage),
                  onShare: () => onCopyText(
                    'سورة ${surah.nameArabic} - صفحة ${convertToArabicDigits(surah.firstPage)}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (showQuranText) ...[
          QuranTextSearchSection(
            query: query,
            onSelectAyah: onSelectAyah,
            onCopyText: onCopyText,
          ),
        ],
        if (showTafsir) ...[
          TafsirBookSearchSection(query: query, onOpenBook: onOpenTafsirBook),
        ],
        if (showTranslations) ...[
          TranslationBookSearchSection(
            query: query,
            onOpenBook: onOpenTranslationBook,
          ),
        ],
        if (showReciters) ...[
          ReciterSearchSection(query: query, onSelectReciter: onSelectReciter),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
