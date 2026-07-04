import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_highlight_controller.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/adaptive_quran_page_view.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/ayah_audio_player_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/ayah_interaction_overlay.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_back_button.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_bottom_panel.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_header.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_search_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_settings_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_scrim.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _QuranPageReaderState extends ConsumerState<QuranPageReader>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentPage;
  late final ValueNotifier<bool> _isTajweed;
  late final QuranHighlightController _highlightController;

  /// Controls the header/footer overlay visibility.
  late final AnimationController _overlayAnimation;
  bool _isOverlayVisible = false;

  /// Tracks the last ayah we synced so we don't re-highlight redundantly.
  AyahRef? _lastSyncedAyah;

  @override
  void initState() {
    super.initState();
    debugPrint(
      'QuranPageReader.initState: widget.initialPage=${widget.initialPage} runtimeType=${widget.initialPage.runtimeType}',
    );
    late final int initialPage;
    try {
      initialPage = widget.initialPage.clamp(1, totalPagesCount).toInt();
    } catch (e, st) {
      debugPrint(
        'QuranPageReader.initState: failed to clamp initialPage=${widget.initialPage} - $e\n$st',
      );
      initialPage = 1;
    }

    _pageController = PageController(initialPage: initialPage - 1);
    _currentPage = ValueNotifier<int>(initialPage);
    _isTajweed = ValueNotifier<bool>(true);
    _highlightController = QuranHighlightController();
    _overlayAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveCurrentProgress(initialPage);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    _currentPage.dispose();
    _isTajweed.dispose();
    _highlightController.dispose();
    _overlayAnimation.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    _currentPage.value = page;
    unawaited(QcfFontLoader.preloadPages(page, radius: 3));
    _saveCurrentProgress(page);
  }

  void _saveCurrentProgress(int page) {
    final surahNumber = getSurahNumberFromPage(page);
    ref
        .read(quranReadingProgressServiceProvider)
        .savePosition(page: page, surahNumber: surahNumber);
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

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
      if (_isOverlayVisible) {
        _overlayAnimation.forward();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        _overlayAnimation.reverse();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    });
  }

  void _hideOverlay() {
    if (!_isOverlayVisible) {
      return;
    }
    _toggleOverlay();
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
    _highlightController.highlightSingle(currentAyah, _highlightColor(context));

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

    showAyahOverlay(
      context: context,
      ayahRef: ayahRef,
      globalPosition: details.globalPosition,
      isHighlighted: !isHighlighted,
      onToggleHighlight: () {
        _highlightController.toggleSingle(ayahRef, _highlightColor(context));
      },
      onClearHighlight: _highlightController.clear,
    );
  }

  Future<void> _openSearchSheet() async {
    await showQuranReaderSearchSheet(
      context: context,
      currentPage: _currentPage.value,
      onPageSelected: _goToPage,
    );
  }

  Future<void> _openSurahPicker() async {
    final surahNumber = await showSurahPicker(context);
    if (surahNumber == null) {
      return;
    }

    _goToPage(getPageNumber(surahNumber, 1));
    _hideOverlay();
  }

  Widget _buildAnimatedOverlay({
    required Offset beginOffset,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        if (_overlayAnimation.isDismissed) {
          return const SizedBox.shrink();
        }

        final animation = CurvedAnimation(
          parent: _overlayAnimation,
          curve: Curves.easeOutQuint,
        );

        final slideOffset = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(animation).value;

        final opacity = CurvedAnimation(
          parent: _overlayAnimation,
          curve: Curves.easeInOutCubic,
        ).value;

        return FractionalTranslation(
          translation: slideOffset,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to audio state changes and sync the highlight / page.
    ref.listen<QuranAudioState>(quranAudioControllerProvider, (previous, next) {
      _syncAudioHighlight(next);

      // Show elegant snackbar if there's an error (e.g., no internet)
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    next.errorMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioBottomInset = _isOverlayVisible
        ? kQuranReaderBottomPanelHeight + 16
        : 60.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            // Ensure taps hit the scrim overlay first when visible.
            child: GestureDetector(
              onTap: _toggleOverlay,
              behavior: HitTestBehavior.translucent,
              child: SafeArea(
                top: false,
                child: AdaptiveQuranPageView(
                  pageController: _pageController,
                  highlightsListenable: _highlightController,
                  isTajweedListenable: _isTajweed,
                  onPageChanged: _handlePageChanged,
                  onLongPress: _handleLongPress,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: QuranReaderScrim(
              animation: _overlayAnimation,
              onTap: _hideOverlay,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: (audioBottomInset - 60.0)),
              child: AyahAudioPlayerBar(bottomInset: audioBottomInset),
            ),
          ),

          ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (context, page, _) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildAnimatedOverlay(
                  beginOffset: const Offset(0, 1),
                  child: QuranReaderBottomPanel(
                    currentPage: page,
                    onPageSelected: _goToPage,
                  ),
                ),
              );
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildAnimatedOverlay(
              beginOffset: const Offset(0, -1),
              child: QuranReaderHeader(
                onSearchTapped: _openSearchSheet,
                onMenuTapped: _openSurahPicker,
                onSettingsTapped: () => showQuranReaderSettingsSheet(
                  context: context,
                  currentPage: _currentPage.value,
                  isTajweedListenable: _isTajweed,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 18,
            left: 16,
            child: _buildAnimatedOverlay(
              beginOffset: const Offset(-.35, 0),
              child: QuranReaderBackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
