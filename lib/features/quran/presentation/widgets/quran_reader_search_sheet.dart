import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_search_provider.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/translation_download_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qcf_quran/qcf_quran.dart';

enum SearchFilter { all, quranText, tafsir, reciters, translations, surahNames }

extension SearchFilterLabel on SearchFilter {
  String get label => switch (this) {
    SearchFilter.all => 'الكل',
    SearchFilter.quranText => 'النص القراني',
    SearchFilter.tafsir => 'كتب التفسير',
    SearchFilter.reciters => 'القراء',
    SearchFilter.translations => 'كتب الترجمات',
    SearchFilter.surahNames => 'أسماء السور',
  };
}

Future<void> showQuranReaderSearchSheet({
  required BuildContext context,
  required int currentPage,
  required ValueChanged<int> onPageSelected,
  ValueChanged<AyahRef>? onAyahSelected,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Search',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _QuranReaderSearchPage(
        currentPage: currentPage,
        onPageSelected: onPageSelected,
        onAyahSelected: onAyahSelected,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      );
    },
  );
}

class _QuranReaderSearchPage extends ConsumerStatefulWidget {
  const _QuranReaderSearchPage({
    required this.currentPage,
    required this.onPageSelected,
    required this.onAyahSelected,
  });

  final int currentPage;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<AyahRef>? onAyahSelected;

  @override
  ConsumerState<_QuranReaderSearchPage> createState() =>
      _QuranReaderSearchPageState();
}

class _QuranReaderSearchPageState
    extends ConsumerState<_QuranReaderSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _searchDebounce;
  String _query = '';
  String _debouncedQuery = '';
  SearchFilter _activeFilter = SearchFilter.all;

  static final _surahCache = QuranSurahMetadataCache.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _debouncedQuery = value.trim());
    });
  }

  void _clearQuery() {
    _searchDebounce?.cancel();
    setState(() {
      _query = '';
      _debouncedQuery = '';
      _searchController.clear();
    });
    _focusNode.requestFocus();
  }

  Future<void> _selectPage(int page) async {
    Navigator.of(context).pop();
    widget.onPageSelected(page);
  }

  Future<void> _selectAyah(AyahRef ayahRef) async {
    Navigator.of(context).pop();
    final onAyahSelected = widget.onAyahSelected;
    if (onAyahSelected != null) {
      onAyahSelected(ayahRef);
      return;
    }
    widget.onPageSelected(ayahRef.page);
  }

  void _navigateToTafsirScreen(int resourceId) {
    Navigator.of(context).pop();
    context.push(TafsirDownloadScreen.routeName, extra: resourceId);
  }

  void _navigateToTranslationScreen(int resourceId) {
    Navigator.of(context).pop();
    context.push(TranslationDownloadScreen.routeName, extra: resourceId);
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ النص للمشاركة'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<SurahMetadata> _surahResults(String query) {
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return const <SurahMetadata>[];

    final queryCandidates = <String>{
      normalizedQuery,
      _normalizeSearchText(_replaceWordFinalHehWithTaMarbuta(query)),
    };

    return _surahCache.all
        .where((surah) {
          final normalizedName = _normalizeSearchText(surah.nameArabic);
          return queryCandidates.contains(normalizedName);
        })
        .toList(growable: false);
  }

  bool get _showSurahNames =>
      _activeFilter == SearchFilter.all ||
      _activeFilter == SearchFilter.surahNames;
  bool get _showQuranText =>
      _activeFilter == SearchFilter.all ||
      _activeFilter == SearchFilter.quranText;
  bool get _showTafsir =>
      _activeFilter == SearchFilter.all || _activeFilter == SearchFilter.tafsir;
  bool get _showTranslations =>
      _activeFilter == SearchFilter.all ||
      _activeFilter == SearchFilter.translations;
  bool get _showReciters =>
      _activeFilter == SearchFilter.all ||
      _activeFilter == SearchFilter.reciters;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final hasTypedQuery = _query.trim().isNotEmpty;
    final canShowResults = _debouncedQuery.trim().isNotEmpty;
    final surahs = canShowResults && _showSurahNames
        ? _surahResults(_debouncedQuery)
        : const <SurahMetadata>[];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: SafeArea(
          child: Column(
            children: [
              _SearchHeader(
                focusNode: _focusNode,
                controller: _searchController,
                query: _query,
                isDark: isDark,
                titleColor: titleColor,
                mutedColor: mutedColor,
                onQueryChanged: _onQueryChanged,
                onClearQuery: _clearQuery,
                onClose: () => Navigator.of(context).pop(),
              ),
              _SearchFilterBar(
                activeFilter: _activeFilter,
                isDark: isDark,
                onFilterChanged: (f) => setState(() => _activeFilter = f),
              ),
              Expanded(
                child: canShowResults
                    ? _SearchResultsBody(
                        query: _debouncedQuery,
                        surahs: surahs,
                        showSurahNames: _showSurahNames,
                        showQuranText: _showQuranText,
                        showTafsir: _showTafsir,
                        showTranslations: _showTranslations,
                        showReciters: _showReciters,
                        titleColor: titleColor,
                        mutedColor: mutedColor,
                        onSelectPage: _selectPage,
                        onSelectAyah: _selectAyah,
                        onCopyText: _copyText,
                        onOpenTafsirBook: _navigateToTafsirScreen,
                        onOpenTranslationBook: _navigateToTranslationScreen,
                      )
                    : hasTypedQuery
                    ? _SearchLoadingState(mutedColor: mutedColor)
                    : _SearchEmptyState(
                        titleColor: titleColor,
                        mutedColor: mutedColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.focusNode,
    required this.controller,
    required this.query,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onClose,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final String query;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1210) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 22),
            color: mutedColor,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              onChanged: onQueryChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب كلمة للبحث...',
                hintStyle: TextStyle(color: mutedColor, fontSize: 15),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: mutedColor,
                  size: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: onClearQuery,
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: mutedColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceHigh
                    : AppColors.parchmentLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  const _SearchFilterBar({
    required this.activeFilter,
    required this.isDark,
    required this.onFilterChanged,
  });

  final SearchFilter activeFilter;
  final bool isDark;
  final ValueChanged<SearchFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SearchFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final filter = SearchFilter.values[index];
          final isSelected = activeFilter == filter;
          return _FilterChip(
            label: filter.label,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => onFilterChanged(filter),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.maroon800;
    final bgColor = isSelected
        ? accentColor.withValues(alpha: 0.14)
        : (isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04));
    final borderColor = isSelected
        ? accentColor.withValues(alpha: 0.35)
        : (isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08));
    final textColor = isSelected
        ? accentColor
        : (isDark ? Colors.white70 : Colors.black54);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.check_rounded, size: 14, color: accentColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultsBody extends ConsumerWidget {
  const _SearchResultsBody({
    required this.query,
    required this.surahs,
    required this.showSurahNames,
    required this.showQuranText,
    required this.showTafsir,
    required this.showTranslations,
    required this.showReciters,
    required this.titleColor,
    required this.mutedColor,
    required this.onSelectPage,
    required this.onSelectAyah,
    required this.onCopyText,
    required this.onOpenTafsirBook,
    required this.onOpenTranslationBook,
  });

  final String query;
  final List<SurahMetadata> surahs;
  final bool showSurahNames;
  final bool showQuranText;
  final bool showTafsir;
  final bool showTranslations;
  final bool showReciters;
  final Color titleColor;
  final Color mutedColor;
  final ValueChanged<int> onSelectPage;
  final ValueChanged<AyahRef> onSelectAyah;
  final ValueChanged<String> onCopyText;
  final ValueChanged<int> onOpenTafsirBook;
  final ValueChanged<int> onOpenTranslationBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (showSurahNames && surahs.isNotEmpty) ...[
          _SectionDivider(title: 'أسماء السور'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final surah in surahs)
                _SurahResultCard(
                  key: ValueKey('surah-${surah.number}'),
                  surah: surah,
                  titleColor: titleColor,
                  mutedColor: mutedColor,
                  onTap: () => onSelectPage(surah.firstPage),
                  onShare: () => onCopyText(
                    'سورة ${surah.nameArabic} - صفحة ${convertToArabicDigits(surah.firstPage)}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (showQuranText) ...[
          _QuranTextSearchSection(
            query: query,
            titleColor: titleColor,
            mutedColor: mutedColor,
            onSelectAyah: onSelectAyah,
            onCopyText: onCopyText,
          ),
        ],
        if (showTafsir) ...[
          _TafsirBookSearchSection(
            query: query,
            titleColor: titleColor,
            mutedColor: mutedColor,
            onSelectAyah: onSelectAyah,
            onOpenBook: onOpenTafsirBook,
          ),
        ],
        if (showTranslations) ...[
          _TranslationBookSearchSection(
            query: query,
            titleColor: titleColor,
            mutedColor: mutedColor,
            onSelectAyah: onSelectAyah,
            onOpenBook: onOpenTranslationBook,
          ),
        ],
        if (showReciters) ...[
          _ReciterSearchSection(
            query: query,
            titleColor: titleColor,
            mutedColor: mutedColor,
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.maroon800;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: accentColor.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: accentColor.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranTextSearchSection extends ConsumerWidget {
  const _QuranTextSearchSection({
    required this.query,
    required this.titleColor,
    required this.mutedColor,
    required this.onSelectAyah,
    required this.onCopyText,
  });

  final String query;
  final Color titleColor;
  final Color mutedColor;
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
        _SectionDivider(title: 'النص القراني'),
        const SizedBox(height: 8),
        for (final result in results.take(20))
          _QuranVerseResultTile(
            key: ValueKey('quran-${result.surahNumber}-${result.verseNumber}'),
            result: result,
            titleColor: titleColor,
            mutedColor: mutedColor,
            onTap: () => onSelectAyah(result.ayahRef),
            onShare: () => onCopyText(
              '${result.verseText}\n${result.surahName} - الآية ${convertToArabicDigits(result.verseNumber)}',
            ),
          ),
      ],
    );
  }
}

class _TafsirBookSearchSection extends ConsumerWidget {
  const _TafsirBookSearchSection({
    required this.query,
    required this.titleColor,
    required this.mutedColor,
    required this.onSelectAyah,
    required this.onOpenBook,
  });

  final String query;
  final Color titleColor;
  final Color mutedColor;
  final ValueChanged<AyahRef> onSelectAyah;
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
            _SectionDivider(title: 'كتب التفسير'),
            const SizedBox(height: 8),
            for (final tafsir in results.take(10))
              _BookResultTile(
                key: ValueKey('tafsir-book-${tafsir.id}'),
                name: tafsir.name,
                author: tafsir.authorName ?? tafsir.translatedAuthorName,
                resourceName: tafsir.resourceName,
                icon: Icons.auto_stories_rounded,
                titleColor: titleColor,
                mutedColor: mutedColor,
                onTap: () => onOpenBook(tafsir.id),
              ),
          ],
        );
      },
    );
  }
}

class _TranslationBookSearchSection extends ConsumerWidget {
  const _TranslationBookSearchSection({
    required this.query,
    required this.titleColor,
    required this.mutedColor,
    required this.onSelectAyah,
    required this.onOpenBook,
  });

  final String query;
  final Color titleColor;
  final Color mutedColor;
  final ValueChanged<AyahRef> onSelectAyah;
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
            _SectionDivider(title: 'كتب الترجمات'),
            const SizedBox(height: 8),
            for (final translation in results.take(10))
              _BookResultTile(
                key: ValueKey('trans-book-${translation.id}'),
                name: translation.name,
                author:
                    translation.authorName ?? translation.translatedAuthorName,
                resourceName: translation.resourceName,
                icon: Icons.translate_rounded,
                titleColor: titleColor,
                mutedColor: mutedColor,
                onTap: () => onOpenBook(translation.id),
              ),
          ],
        );
      },
    );
  }
}

class _ReciterSearchSection extends ConsumerWidget {
  const _ReciterSearchSection({
    required this.query,
    required this.titleColor,
    required this.mutedColor,
  });

  final String query;
  final Color titleColor;
  final Color mutedColor;

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
            _SectionDivider(title: 'القراء'),
            const SizedBox(height: 8),
            for (final recitation in results.take(10))
              _BookResultTile(
                key: ValueKey('reciter-${recitation.id}'),
                name: recitation.reciterName,
                author: recitation.translatedName,
                resourceName: recitation.style,
                icon: Icons.headphones_rounded,
                titleColor: titleColor,
                mutedColor: mutedColor,
                onTap: () {
                  ref.read(selectedQuranRecitationProvider.notifier).state =
                      recitation;
                  Navigator.of(context).pop();
                },
              ),
          ],
        );
      },
    );
  }
}

class _BookResultTile extends StatelessWidget {
  const _BookResultTile({
    required this.name,
    required this.icon,
    required this.titleColor,
    required this.mutedColor,
    required this.onTap,
    this.author,
    this.resourceName,
    super.key,
  });

  final String name;
  final String? author;
  final String? resourceName;
  final IconData icon;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.maroon800.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.maroon800.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.maroon800.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.maroon800, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (author != null && author!.isNotEmpty)
                        Text(
                          author!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: mutedColor, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: mutedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState({required this.mutedColor});

  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: mutedColor),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.titleColor, required this.mutedColor});

  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.manage_search_rounded, size: 54, color: mutedColor),
            const SizedBox(height: 10),
            Text(
              'ابدأ البحث',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'اكتب كلمة للبحث في القرآن والموضوعات والتفاسير.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahResultCard extends StatelessWidget {
  const _SurahResultCard({
    required this.surah,
    required this.titleColor,
    required this.mutedColor,
    required this.onTap,
    required this.onShare,
    super.key,
  });

  final SurahMetadata surah;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 158,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _ShareTextButton(onPressed: onShare),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: AppColors.maroon800.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.maroon800.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameArabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: titleColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'سورة ${convertToArabicDigits(surah.number)} • صفحة ${convertToArabicDigits(surah.firstPage)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${convertToArabicDigits(surah.verseCount)} آية',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranVerseResultTile extends StatelessWidget {
  const _QuranVerseResultTile({
    required this.result,
    required this.titleColor,
    required this.mutedColor,
    required this.onTap,
    required this.onShare,
    super.key,
  });

  final QuranSearchResult result;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final metadata =
        'صفحة ${convertToArabicDigits(result.pageNumber)} • '
        'الجزء ${convertToArabicDigits(result.juzNumber)} • '
        'الحزب ${convertToArabicDigits(result.hizbNumber)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _ShareTextButton(onPressed: onShare),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.maroon800.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.maroon800.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.maroon800.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.maroon800,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${result.surahName} • الآية ${convertToArabicDigits(result.verseNumber)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: titleColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                metadata,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: mutedColor),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: mutedColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.verseText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: titleColor,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTextButton extends StatelessWidget {
  const _ShareTextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.ios_share_rounded, size: 15),
      label: const Text('مشاركة', style: TextStyle(fontSize: 11)),
    );
  }
}

String _normalizeSearchText(String input) {
  return normalise(input.trim()).toLowerCase();
}

String _replaceWordFinalHehWithTaMarbuta(String input) {
  return input.replaceAllMapped(RegExp(r'ه(?=\s|$)'), (match) => 'ة');
}
