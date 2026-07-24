import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_highlight_controller.dart';
import 'package:al_mubeen/features/quran/data/models/highlight_verse.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/ayah_audio_player_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/ayah_interaction_overlay.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_bookmarks_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_bottom_panel.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reciters_list_view.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_header.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_icon_nav_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_search_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_settings_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_scrim.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_more_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qcf_quran/qcf_quran.dart';

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentPage;
  late final QuranHighlightController _highlightController;
  Timer? _saveProgressDebounce;
  int? _lastPersistedPage;

  /// Controls the header/footer overlay visibility.
  late final AnimationController _overlayAnimation;
  bool _isOverlayVisible = false;

  /// Tracks the last ayah we synced so we don't re-highlight redundantly.
  AyahRef? _lastSyncedAyah;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
    _lastPersistedPage = initialPage;
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
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.removeObserver(this);
    _saveProgressDebounce?.cancel();
    // Note: _persistCurrentPage intentionally not called here because it uses
    // `ref.read()` which is unsafe in dispose() (BuildContext is deactivated).
    // The page is already persisted via _schedulePersistCurrentPage on change
    // and via didChangeAppLifecycleState when the app goes to background.
    _pageController.dispose();
    _currentPage.dispose();
    _highlightController.dispose();
    _overlayAnimation.dispose();

    super.dispose();
  }

  void _handlePageChanged(int pageIndex) {
    final pageNumber = pageIndex + 1;
    _currentPage.value = pageNumber;
    _schedulePersistCurrentPage(pageNumber);
  }

  Future<void> _goToPage(int page) async {
    final boundedPage = page.clamp(1, totalPagesCount).toInt();
    if (boundedPage == _currentPage.value) {
      return;
    }

    final pageDifference = (boundedPage - _currentPage.value).abs();

    if (pageDifference > 2) {
      if (mounted) {
        _pageController.jumpToPage(boundedPage - 1);
      }
      _currentPage.value = boundedPage;
      _schedulePersistCurrentPage(boundedPage);
    } else {
      await _pageController.animateToPage(
        boundedPage - 1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _goToAyah(AyahRef ayahRef) async {
    _lastSyncedAyah = null;
    _highlightController.highlightSingle(ayahRef, _highlightColor(context));
    await _goToPage(ayahRef.page);
    _hideOverlay();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_persistCurrentPage(_currentPage.value));
    }
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

  void _schedulePersistCurrentPage(int page) {
    _saveProgressDebounce?.cancel();
    _saveProgressDebounce = Timer(const Duration(milliseconds: 900), () {
      unawaited(_persistCurrentPage(page));
    });
  }

  Future<void> _persistCurrentPage(int page) async {
    if (_lastPersistedPage == page) {
      return;
    }

    _lastPersistedPage = page;
    await ref.read(appUserPreferencesProvider.notifier).setLastQuranPage(page);
  }

  Color _highlightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD8B457).withValues(alpha: 0.42)
        : AppColors.maroon700.withValues(alpha: 0.18);
  }

  // --- Quran page header/footer helpers ---

  // Pre-computed cache: built once, used on every page build.
  static final QuranPageMetadataCache _pageMeta =
      QuranPageMetadataCache.instance;

  // --- Quran page header/footer helpers ---

  Widget _buildPageView(
    BuildContext context,
    List<HighlightVerse> highlights,
    bool isDark,
    double fontScale,
  ) {
    const headerHeight = 38.0;
    const footerHeight = 24.0;

    // Convert highlights list to a Map keyed by (surah, verse) for O(1) lookup.
    final Map<(int, int), Color> highlightMap = highlights.isEmpty
        ? const {}
        : {for (final h in highlights) (h.surah, h.verseNumber): h.color};

    Color? getVerseHighlight(int surah, int verse) =>
        highlightMap.isEmpty ? null : highlightMap[(surah, verse)];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute verseHeight so 15 Mushaf lines fit the screen exactly.
        // QcfPage internally adds padding: top 38 + bottom 24 = 62 px.
        final availableHeight = constraints.maxHeight;
        const int linesPerPage = 15;
        const double internalPadding = 62.0;
        final fontSize = getFontSize(1, context);

        // Screen-adaptive scaling: reference width is 390px (standard phone).
        // Smaller phones get smaller fonts, larger tablets get larger fonts.
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenAdaptiveFactor = (screenWidth / 390).clamp(0.82, 1.18);

        // The Madina Mushaf layout cannot handle horizontal wrapping.
        // We tightly clamp the fontScale for the Mushaf text to prevent
        // lines from breaking, while letting the full fontScale apply
        // to Tafsir/Translations via the global text scaler.
        final safeFontScale = (fontScale * screenAdaptiveFactor).clamp(
          0.55,
          1.15,
        );
        final effectiveFontSize = fontSize * safeFontScale;

        final computedVerseHeight =
            (availableHeight - internalPadding) /
            (linesPerPage * effectiveFontSize);

        final baseTheme = isDark ? QcfThemeData.dark() : const QcfThemeData();
        final theme = baseTheme.copyWith(verseHeight: computedVerseHeight);

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          itemCount: totalPagesCount,
          onPageChanged: _handlePageChanged,
          itemBuilder: (context, index) {
            final pageNumber = index + 1;
            final meta = _pageMeta.forPage(pageNumber);
            final textColor = isDark
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF3A3A3A);

            return Stack(
              children: [
                RepaintBoundary(
                  child: QcfPage(
                    pageNumber: pageNumber,
                    verseBackgroundColor: getVerseHighlight,
                    onLongPressDown: (surah, verse, details) =>
                        _handleLongPress(surah, verse, details),
                    theme: theme,
                    sp: safeFontScale,
                  ),
                ),
                // Header: Juz/Hizb (right) & Surah name (left)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: headerHeight,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            meta.juzHizbText,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            meta.surahNameArabic,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer: Page number (right side)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: footerHeight,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            convertToArabicDigits(pageNumber),
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Sync highlight and page position to the currently-playing ayah.
  void _syncAudioHighlight({
    required AyahRef? currentAyah,
    required bool isPlaying,
  }) {
    if (currentAyah == null || !isPlaying) {
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
      onAyahSelected: _goToAyah,
    );
  }

  Future<void> _openBookmarksSheet() async {
    await showQuranBookmarksSheet(
      context: context,
      currentPage: _currentPage.value,
      onPageSelected: _goToPage,
    );
  }

  Future<void> _openSettingsSheet() async {
    await showQuranReaderSettingsSheet(
      context: context,
      currentPage: _currentPage.value,
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
    ref.listen(
      quranAudioControllerProvider.select(
        (state) => (
          currentAyah: state.currentAyah,
          isPlaying: state.isPlaying,
          errorMessage: state.errorMessage,
        ),
      ),
      (previous, next) {
        _syncAudioHighlight(
          currentAyah: next.currentAyah,
          isPlaying: next.isPlaying,
        );

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
      },
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconNavBarOffset =
        kQuranReaderIconNavBarHeight + MediaQuery.of(context).padding.bottom;

    final fontScale = ref.watch(
      appUserPreferencesProvider.select(
        (preferences) => preferences.maybeWhen(
          data: (value) => value.fontScale,
          orElse: () => const AppUserPreferences.initial().fontScale,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            // Ensure taps hit the scrim overlay first when visible.
            child: GestureDetector(
              onTap: _toggleOverlay,
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                top: false,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1)),
                  child: ValueListenableBuilder<List<HighlightVerse>>(
                    valueListenable: _highlightController,
                    builder: (context, highlights, _) {
                      return _buildPageView(
                        context,
                        highlights,
                        isDark,
                        fontScale,
                      );
                    },
                  ),
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

          ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (context, page, _) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: iconNavBarOffset,
                child: RepaintBoundary(
                  child: _buildAnimatedOverlay(
                    beginOffset: const Offset(0, 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AyahAudioErrorBanner(),
                        QuranReaderBottomPanel(
                          currentPage: page,
                          onPageSelected: _goToPage,
                          rightControls: const AyahRightAudioControls(),
                          leftControls: const AyahLeftAudioControls(),
                          reciterButton: const _ReciterButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
              child: _buildAnimatedOverlay(
                beginOffset: const Offset(0, 1),
                child: QuranReaderIconNavBar(
                  selectedIndex: 0,
                  onQuranTapped: () {},
                  onAdhkarTapped: () => context.push('/adhkar'),
                  onLibrariesTapped: () => context.push('/quran/libraries'),
                  onMoreTapped: () => context.push(
                    '/quran/more',
                    extra: QuranReaderMoreActions(
                      currentPage: _currentPage.value,
                      onSearch: _openSearchSheet,
                      onSurahPicker: _openSurahPicker,
                      onBookmarks: _openBookmarksSheet,
                      onSettings: _openSettingsSheet,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: RepaintBoundary(
              child: _buildAnimatedOverlay(
                beginOffset: const Offset(0, -1),
                child: QuranReaderHeader(onSearchTapped: _openSearchSheet),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReciterButton extends ConsumerWidget {
  const _ReciterButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(
      quranAudioControllerProvider.select(
        (state) =>
            (currentAyah: state.currentAyah, recitationId: state.recitationId),
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Tooltip(
      message: 'القارئ',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final currentAyah =
                audioState.currentAyah ??
                const AyahRef(surah: 1, ayah: 1, page: 1);
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _RecitersSheet(
                currentAyah: currentAyah,
                recitationId: audioState.recitationId,
              ),
            );
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(
              Icons.headphones_rounded,
              color: primaryColor,
              size: 17,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecitersSheet extends StatelessWidget {
  const _RecitersSheet({required this.currentAyah, required this.recitationId});

  final AyahRef currentAyah;
  final int? recitationId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.maroon800.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.maroon800.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.headphones_rounded,
                          color: AppColors.maroon800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'اختر القارئ',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'اختر القارئ المفضل لديك.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  QuranRecitersListView(
                    currentAyah: currentAyah,
                    recitationId: recitationId,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
