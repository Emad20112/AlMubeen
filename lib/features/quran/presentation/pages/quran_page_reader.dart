import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_highlight_controller.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/adaptive_quran_page_view.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/ayah_action_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class QuranPageReader extends ConsumerStatefulWidget {
  const QuranPageReader({
    this.initialPage = 1,
    this.initialHighlight,
    super.key,
  });

  static const String routeName = '/quran/page-reader';

  final int initialPage;
  final AyahRef? initialHighlight;

  @override
  ConsumerState<QuranPageReader> createState() => _QuranPageReaderState();
}

class _QuranPageReaderState extends ConsumerState<QuranPageReader> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentPage;
  late final ValueNotifier<bool> _isTajweed;
  late final QuranHighlightController _highlightController;

  /// Tracks the last ayah we synced so we don't re-highlight redundantly.
  AyahRef? _lastSyncedAyah;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.initialPage.clamp(1, totalPagesCount).toInt();

    _pageController = PageController(initialPage: initialPage - 1);
    _currentPage = ValueNotifier<int>(initialPage);
    _isTajweed = ValueNotifier<bool>(true);
    _highlightController = QuranHighlightController();

    final initialHighlight = widget.initialHighlight;
    if (initialHighlight != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _highlightController.toggleSingle(
          initialHighlight,
          _highlightColor(context),
        );
      });
    }

    unawaited(QcfFontLoader.preloadPages(initialPage, radius: 3));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    _isTajweed.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    _currentPage.value = page;
    unawaited(QcfFontLoader.preloadPages(page, radius: 3));
  }

  void _goToPage(int page) {
    final boundedPage = page.clamp(1, totalPagesCount).toInt();
    if (boundedPage == _currentPage.value) {
      return;
    }

    _pageController.animateToPage(
      boundedPage - 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Color _highlightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD8B457).withValues(alpha: 0.42)
        : AppColors.maroon700.withValues(alpha: 0.18);
  }

  /// Sync highlight and page position to the currently-playing ayah.
  void _syncAudioHighlight(QuranAudioState audioState) {
    final currentAyah = audioState.currentAyah;

    if (currentAyah == null || !audioState.isPlaying) {
      // Audio stopped – clear the audio-driven highlight.
      if (_lastSyncedAyah != null) {
        _lastSyncedAyah = null;
        _highlightController.clear();
      }
      return;
    }

    // Already synced to this ayah.
    if (_lastSyncedAyah != null &&
        _lastSyncedAyah!.surah == currentAyah.surah &&
        _lastSyncedAyah!.ayah == currentAyah.ayah) {
      return;
    }

    _lastSyncedAyah = currentAyah;
    _highlightController.highlightSingle(
      currentAyah,
      _highlightColor(context),
    );

    // Auto-navigate to the page that contains this ayah.
    if (currentAyah.page != _currentPage.value) {
      _goToPage(currentAyah.page);
    }
  }

  void _handleLongPress(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details,
  ) {
    final ayahRef = AyahRef.fromSurahAyah(
      surah: surahNumber,
      ayah: verseNumber,
    );
    final isHighlighted = _highlightController.contains(ayahRef);

    _highlightController.toggleSingle(ayahRef, _highlightColor(context));

    showAyahActionSheet(
      context: context,
      ayahRef: ayahRef,
      isHighlighted: !isHighlighted,
      onToggleHighlight: () {
        _highlightController.toggleSingle(ayahRef, _highlightColor(context));
      },
      onClearHighlight: _highlightController.clear,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to audio state changes and sync the highlight / page.
    ref.listen<QuranAudioState>(quranAudioControllerProvider, (_, next) {
      _syncAudioHighlight(next);
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      appBar: AppBar(
        leading: const BackButton(),
        title: ValueListenableBuilder<int>(
          valueListenable: _currentPage,
          builder: (context, page, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getCurrentHizbTextForPage(page, isArabic: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
                Text(
                  'صفحة ${_toArabicNumber(page)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).appBarTheme.foregroundColor?.withValues(alpha: 0.72),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          // Show a stop button when audio is actively playing.
          Consumer(
            builder: (context, ref, child) {
              final audioState = ref.watch(quranAudioControllerProvider);
              if (!audioState.isPlaying && !audioState.isLoading) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'إيقاف التلاوة',
                onPressed: () {
                  ref.read(quranAudioControllerProvider.notifier).stop();
                },
                icon: audioState.isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.stop_circle_outlined),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isTajweed,
            builder: (context, isTajweed, child) {
              return IconButton(
                tooltip: isTajweed ? 'إيقاف ألوان التجويد' : 'تفعيل التجويد',
                onPressed: () {
                  _isTajweed.value = !isTajweed;
                },
                icon: Icon(
                  isTajweed
                      ? Icons.palette_outlined
                      : Icons.format_color_reset_outlined,
                ),
              );
            },
          ),
          ValueListenableBuilder<List<HighlightVerse>>(
            valueListenable: _highlightController,
            builder: (context, highlights, child) {
              return IconButton(
                tooltip: 'مسح التظليل',
                onPressed: highlights.isEmpty
                    ? null
                    : _highlightController.clear,
                icon: const Icon(Icons.layers_clear_outlined),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AdaptiveQuranPageView(
          pageController: _pageController,
          highlightsListenable: _highlightController,
          isTajweedListenable: _isTajweed,
          onPageChanged: _handlePageChanged,
          onLongPress: _handleLongPress,
        ),
      ),
      bottomNavigationBar: _QuranReaderBottomBar(
        currentPageListenable: _currentPage,
        onPreviousPage: () => _goToPage(_currentPage.value - 1),
        onNextPage: () => _goToPage(_currentPage.value + 1),
      ),
    );
  }

  static String _toArabicNumber(int number) {
    const digits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    return number
        .toString()
        .split('')
        .map((digit) => digits[digit] ?? digit)
        .join();
  }
}

class _QuranReaderBottomBar extends StatelessWidget {
  const _QuranReaderBottomBar({
    required this.currentPageListenable,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final ValueListenable<int> currentPageListenable;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: ValueListenableBuilder<int>(
            valueListenable: currentPageListenable,
            builder: (context, page, child) {
              return Row(
                children: [
                  IconButton(
                    tooltip: 'الصفحة السابقة',
                    onPressed: page <= 1 ? null : onPreviousPage,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  Expanded(
                    child: Text(
                      'صفحة ${_QuranPageReaderState._toArabicNumber(page)} من ${_QuranPageReaderState._toArabicNumber(totalPagesCount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'الصفحة التالية',
                    onPressed: page >= totalPagesCount ? null : onNextPage,
                    icon: const Icon(Icons.chevron_left),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
