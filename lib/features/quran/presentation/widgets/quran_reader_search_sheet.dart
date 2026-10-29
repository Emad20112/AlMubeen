import 'dart:async';

import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/core/widgets/app_search_bar.dart';
import 'package:al_mubeen/features/quran/application/quran_search_provider.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/translation_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/search/quran_search_body.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/search/search_filter_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/search/search_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

export 'package:al_mubeen/features/quran/presentation/widgets/search/search_models.dart';

/// يعرض صفحة البحث القرآني المتكاملة عبر نافذة متحركة وسلسة.
Future<void> showQuranReaderSearchSheet({
  required BuildContext context,
  required int currentPage,
  required ValueChanged<int> onPageSelected,
  ValueChanged<AyahRef>? onAyahSelected,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 260),
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
  Timer? _searchDebounce;
  String _query = '';
  String _debouncedQuery = '';
  SearchFilter _activeFilter = SearchFilter.all;

  static final _surahCache = QuranSurahMetadataCache.instance;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
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

  void _navigateToTafsir(int resourceId) {
    Navigator.of(context).pop();
    context.push(TafsirDownloadScreen.routeName, extra: resourceId);
  }

  void _navigateToTranslation(int resourceId) {
    Navigator.of(context).pop();
    context.push(TranslationDownloadScreen.routeName, extra: resourceId);
  }

  void _onSelectReciter(int reciterId) {
    final recitations = ref.read(quranRecitationsProvider).asData?.value ?? [];
    for (final r in recitations) {
      if (r.id == reciterId) {
        ref.read(selectedQuranRecitationProvider.notifier).state = r;
        ref.read(appUserPreferencesProvider.notifier).setPreferredReciter(r);
        break;
      }
    }
    Navigator.of(context).pop();
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ النص للمشاركة'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );
  }

  List<SurahMetadata> _surahResults(String query) {
    final normalized = QuranSearchNormalizer.normalize(query);
    if (normalized.isEmpty) return const [];

    return _surahCache.all
        .where((surah) {
          final name = QuranSearchNormalizer.normalize(surah.nameArabic);
          final numberStr = surah.number.toString();
          return name.contains(normalized) || numberStr == query.trim();
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final hasTypedQuery = _query.trim().isNotEmpty;
    final canShowResults = _debouncedQuery.trim().isNotEmpty;

    final showSurahs =
        _activeFilter == SearchFilter.all ||
        _activeFilter == SearchFilter.surahNames;
    final surahs = canShowResults && showSurahs
        ? _surahResults(_debouncedQuery)
        : const <SurahMetadata>[];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchBar(
                        controller: _searchController,
                        autofocus: true,
                        hintText: 'ابحث في الآيات، السور، التفسير...',
                        onChanged: _onQueryChanged,
                        onClear: _clearQuery,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.textSecondary,
                      ),
                      tooltip: 'إغلاق',
                    ),
                  ],
                ),
              ),
              SearchFilterBar(
                activeFilter: _activeFilter,
                onFilterChanged: (f) => setState(() => _activeFilter = f),
              ),
              Expanded(
                child: canShowResults
                    ? SearchResultsBody(
                        query: _debouncedQuery,
                        surahs: surahs,
                        showSurahNames: showSurahs,
                        showQuranText:
                            _activeFilter == SearchFilter.all ||
                            _activeFilter == SearchFilter.quranText,
                        showTafsir:
                            _activeFilter == SearchFilter.all ||
                            _activeFilter == SearchFilter.tafsir,
                        showTranslations:
                            _activeFilter == SearchFilter.all ||
                            _activeFilter == SearchFilter.translations,
                        showReciters:
                            _activeFilter == SearchFilter.all ||
                            _activeFilter == SearchFilter.reciters,
                        onSelectPage: _selectPage,
                        onSelectAyah: _selectAyah,
                        onCopyText: _copyText,
                        onOpenTafsirBook: _navigateToTafsir,
                        onOpenTranslationBook: _navigateToTranslation,
                        onSelectReciter: _onSelectReciter,
                      )
                    : hasTypedQuery
                    ? const SearchLoadingState()
                    : const SearchEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
