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
import 'package:al_mubeen/features/quran/presentation/widgets/quran_page_view.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_bottom_panel.dart';

import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_header.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_icon_nav_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_search_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_settings_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_scrim.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/wird_dialog.dart';

import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_more_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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

  void _showOverlay() {
    if (_isOverlayVisible) {
      return;
    }

    setState(() {
      _isOverlayVisible = true;
      _overlayAnimation.forward();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

  // 🛡️ PERF: أنماط ثابتة (static final) تُبنى مرة واحدة فقط بدلاً من إنشاء
  // TextStyle + Shadow جديدة في كل `itemBuilder` لكل صفحة أثناء التمرير.
  static final TextStyle _headerJuzStyleLight = TextStyle(
    fontSize: 15,
    color: const Color(0xFF2A070D),
    fontWeight: FontWeight.w700,
    height: 1.2,
    shadows: [
      Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 3),
    ],
  );
  static final TextStyle _headerJuzStyleDark = TextStyle(
    fontSize: 15,
    color: const Color(0xFFE8C860),
    fontWeight: FontWeight.w700,
    height: 1.2,
    shadows: [
      Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 3),
    ],
  );
  static final TextStyle _headerSurahStyleLight = TextStyle(
    fontSize: 16,
    color: const Color(0xFF2A070D),
    fontWeight: FontWeight.w800,
    height: 1.2,
    shadows: [
      Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 3),
    ],
  );
  static final TextStyle _headerSurahStyleDark = TextStyle(
    fontSize: 16,
    color: const Color(0xFFE8C860),
    fontWeight: FontWeight.w800,
    height: 1.2,
    shadows: [
      Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 3),
    ],
  );
  static final TextStyle _footerPageStyleLight = TextStyle(
    fontSize: 15,
    color: const Color(0xFF3F1D20),
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.5,
    shadows: [
      Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 3),
    ],
  );
  static final TextStyle _footerPageStyleDark = TextStyle(
    fontSize: 15,
    color: const Color(0xFFD8B457).withValues(alpha: 0.95),
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.5,
    shadows: [
      Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 3),
    ],
  );

  /// 🛡️ PERF: يُبنى الـ `PageView` مباشرة بدون `LayoutBuilder`، لأن
  /// `LayoutBuilder` كان يعيد حساب الـ constraints لكل الصفحات المرئية
  /// مع كل سحب/تمرير مما يُنتج jank. الأبعاد تُمرَّر من `build()` الأب
  /// الذي يقرأ `MediaQuery` مرة واحدة فقط.
  Widget _buildPageView(
    BuildContext context, {
    required List<HighlightVerse> highlights,
    required bool isDark,
    required double fontScale,
    required double availableHeight,
    required double screenWidth,
  }) {
    final highlightMap = buildHighlightMap(highlights);

    Color? getVerseHighlight(int surah, int verse) =>
        highlightMap.isEmpty ? null : highlightMap[(surah, verse)];

    const int linesPerPage = 15;
    const double internalPadding = 62.0;
    final fontSize = getFontSize(1, context);

    final screenAdaptiveFactor = (screenWidth / 390).clamp(0.82, 1.18);
    final safeFontScale = (fontScale * screenAdaptiveFactor).clamp(0.55, 1.15);
    final effectiveFontSize = fontSize * safeFontScale;

    final computedVerseHeight =
        (availableHeight - internalPadding) /
        (linesPerPage * effectiveFontSize);

    final baseTheme = isDark ? QcfThemeData.dark() : const QcfThemeData();
    final theme = baseTheme.copyWith(
      verseHeight: computedVerseHeight,
      headerTextColor: isDark ? const Color(0xFF2A070D) : null,
    );

    final headerJuzStyle = isDark ? _headerJuzStyleDark : _headerJuzStyleLight;
    final headerSurahStyle = isDark
        ? _headerSurahStyleDark
        : _headerSurahStyleLight;
    final footerPageStyle = isDark
        ? _footerPageStyleDark
        : _footerPageStyleLight;

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      itemCount: totalPagesCount,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        final meta = QuranPageMetaCache.instance.forPage(pageNumber);

        // 🛡️ PERF: [QuranPageView] يعزل كل طبقة (QCF / header / footer) في
        // `RepaintBoundary` مستقلة، فلا يُعاد رسم صفحة QCF عند تغيّر التظليل فقط.
        return QuranPageView(
          key: ValueKey<int>(pageNumber),
          pageNumber: pageNumber,
          juzHizbText: meta.juzHizbText,
          surahNameArabic: meta.surahNameArabic,
          theme: theme,
          fontScale: safeFontScale,
          headerJuzStyle: headerJuzStyle,
          headerSurahStyle: headerSurahStyle,
          footerPageStyle: footerPageStyle,
          getVerseHighlight: getVerseHighlight,
          onLongPressDown: _handleLongPress,
        );
      },
    );
  }

  /// 🛡️ حل مشكلة إعادة الآية الثانية وتضليل التالية
  void _syncAudioHighlight({
    required AyahRef? currentAyah,
    required bool isPlaying,
  }) {
    // 1. إذا توقف الصوت، نظّف التظليل وارجع
    if (currentAyah == null || !isPlaying) {
      if (_lastSyncedAyah != null) {
        _lastSyncedAyah = null;
        _highlightController.clear();
      }
      return;
    }

    // 2. إذا كانت الآية هي نفسها التي تم مزامنتها مسبقاً، تجاهل الطلب لمنع الحلقة المفرغة
    if (_lastSyncedAyah?.surah == currentAyah.surah &&
        _lastSyncedAyah?.ayah == currentAyah.ayah) {
      return;
    }

    _lastSyncedAyah = currentAyah;

    // 3. نكتفي بتحديث التظليل فقط بصمت بدون إعادة تحريك الصفحة إذا كنا في نفس الصفحة
    _highlightController.highlightSingle(currentAyah, _highlightColor(context));

    // 4. لا ننتقل للصفحة إلا إذا كانت الآية الجديدة في صفحة "مختلفة تماماً" عن الصفحة المعروضة حالياً
    if (currentAyah.page != _currentPage.value) {
      // نغير الصفحة بصمت وبدون إرسال إشارات إعادة تشغيل للمشغل
      _pageController.jumpToPage(currentAyah.page - 1);
      _currentPage.value = currentAyah.page;
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
      onPlayRequested: _showOverlay,
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

  Future<void> _navigateToWirdBoundary(int endPage) async {
    final boundary = getFirstAyahOnNextPage(endPage);
    _highlightController.highlightSingle(boundary, _highlightColor(context));
    _lastSyncedAyah = null;
    await _goToPage(boundary.page);
    _hideOverlay();
  }

  Future<void> _openWirdDialog() async {
    await showWirdHotelDoorsDialog(
      context,
      onNavigateToPage: _goToPage,
      onNavigateToWirdEnd: _navigateToWirdBoundary,
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

        if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.white),
                  const Gap(12),
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
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final iconNavBarOffset =
        kQuranReaderIconNavBarHeight + mediaQuery.padding.bottom;

    // 🛡️ PERF: تُحسب أبعاد الصفحة مرة واحدة هنا (خارج `LayoutBuilder`)،
    // وارتفاع المساحة المتاحة للـ PageView = ارتفاع الشاشة ناقص شريط التنقل السفلي.
    final availablePageHeight = (screenSize.height - iconNavBarOffset).clamp(
      0.0,
      screenSize.height,
    );

    final fontScale = ref.watch(
      appUserPreferencesProvider.select(
        (preferences) => switch (preferences) {
          AsyncData(:final value) => value.fontScale,
          _ => const AppUserPreferences.initial().fontScale,
        },
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleOverlay,
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                top: false,
                child: MediaQuery(
                  data: mediaQuery.copyWith(textScaler: TextScaler.linear(1)),
                  child: ValueListenableBuilder<List<HighlightVerse>>(
                    valueListenable: _highlightController,
                    builder: (context, highlights, _) {
                      return _buildPageView(
                        context,
                        highlights: highlights,
                        isDark: isDark,
                        fontScale: fontScale,
                        availableHeight: availablePageHeight,
                        screenWidth: screenSize.width,
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
                          rightControls: AyahRightAudioControls(
                            currentPage: page,
                          ),
                          leftControls: AyahLeftAudioControls(
                            currentPage: page,
                          ),
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
                      onWird: _openWirdDialog,
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
                child: QuranReaderHeader(
                  onSearchTapped: _openSearchSheet,
                  onSurahListTapped: _openSurahPicker,
                  onSettingsTapped: _openSettingsSheet,
                  onWirdTapped: _openWirdDialog,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
