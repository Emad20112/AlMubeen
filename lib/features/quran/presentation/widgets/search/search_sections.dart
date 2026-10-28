import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/application/quran_search_provider.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/search/search_result_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// قسم نتائج الآيات القرآنية.
class QuranTextSearchSection extends ConsumerWidget {
  const QuranTextSearchSection({
    super.key,
    required this.query,
    required this.onSelectAyah,
    required this.onCopyText,
  });

  final String query;
  final ValueChanged<AyahRef> onSelectAyah;
  final ValueChanged<String> onCopyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(
      quranSearchResultsProvider((query: query, exactMatch: false)),
    );

    if (results.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SearchSectionDivider(title: 'الآيات القرآنية'),
        const SizedBox(height: AppSpacing.sm),
        for (final result in results.take(25))
          QuranVerseResultTile(
            key: ValueKey('quran-${result.surahNumber}-${result.verseNumber}'),
            result: result,
            onTap: () => onSelectAyah(result.ayahRef),
            onShare: () => onCopyText(
              '${result.verseText}\n[${result.surahName}: ${result.verseNumber}]',
            ),
          ),
      ],
    );
  }
}

/// قسم نتائج كتب التفسير.
class TafsirBookSearchSection extends ConsumerWidget {
  const TafsirBookSearchSection({
    super.key,
    required this.query,
    required this.onOpenBook,
  });

  final String query;
  final ValueChanged<int> onOpenBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(tafsirNameSearchProvider(query));

    return resultsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
      data: (results) {
        if (results.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SearchSectionDivider(title: 'كتب التفسير'),
            const SizedBox(height: AppSpacing.sm),
            for (final tafsir in results.take(10))
              BookResultTile(
                key: ValueKey('tafsir-book-${tafsir.id}'),
                name: tafsir.name,
                author: tafsir.authorName ?? tafsir.translatedAuthorName,
                resourceName: tafsir.resourceName,
                icon: Icons.auto_stories_rounded,
                onTap: () => onOpenBook(tafsir.id),
              ),
          ],
        );
      },
    );
  }
}

/// قسم نتائج كتب الترجمة.
class TranslationBookSearchSection extends ConsumerWidget {
  const TranslationBookSearchSection({
    super.key,
    required this.query,
    required this.onOpenBook,
  });

  final String query;
  final ValueChanged<int> onOpenBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(translationNameSearchProvider(query));

    return resultsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
      data: (results) {
        if (results.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SearchSectionDivider(title: 'كتب الترجمات'),
            const SizedBox(height: AppSpacing.sm),
            for (final translation in results.take(10))
              BookResultTile(
                key: ValueKey('trans-book-${translation.id}'),
                name: translation.name,
                author:
                    translation.authorName ?? translation.translatedAuthorName,
                resourceName: translation.resourceName,
                icon: Icons.translate_rounded,
                onTap: () => onOpenBook(translation.id),
              ),
          ],
        );
      },
    );
  }
}

/// قسم نتائج القراء.
class ReciterSearchSection extends ConsumerWidget {
  const ReciterSearchSection({
    super.key,
    required this.query,
    required this.onSelectReciter,
  });

  final String query;
  final ValueChanged<int> onSelectReciter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(reciterNameSearchProvider(query));

    return resultsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
      data: (results) {
        if (results.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SearchSectionDivider(title: 'القراء والتلاوات'),
            const SizedBox(height: AppSpacing.sm),
            for (final recitation in results.take(10))
              BookResultTile(
                key: ValueKey('reciter-${recitation.id}'),
                name: recitation.reciterName,
                author: recitation.translatedName,
                resourceName: recitation.style,
                icon: Icons.headphones_rounded,
                onTap: () => onSelectReciter(recitation.id),
              ),
          ],
        );
      },
    );
  }
}
