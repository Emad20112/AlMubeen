import 'dart:async';
import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranPageCarousel extends StatefulWidget {
  const QuranPageCarousel({
    required this.currentPage,
    required this.onPageSelected,
    this.compact = false,
    super.key,
  });

  final int currentPage;
  final ValueChanged<int> onPageSelected;
  final bool compact;

  @override
  State<QuranPageCarousel> createState() => _QuranPageCarouselState();
}

/// Represents the drag direction for the repeat scroll logic.
enum _DragDirection { forward, backward }

class _QuranPageCarouselState extends State<QuranPageCarousel> {
  static const double _dragThreshold = 18.0;

  Timer? _scrollTimer;
  Timer? _hideBadgeTimer;
  double _dragExtent = 0.0;
  bool _isDragging = false;
  bool _showPageBadge = false;

  /// Local preview page used during drag to avoid calling onPageSelected
  /// on every tick. Only when the drag ends is onPageSelected invoked once.
  /// When not dragging, this is kept in sync with widget.currentPage.
  int _dragPreviewPage = 1;

  /// The page at which the current drag started.
  int _dragStartPage = 1;

  /// Direction for the repeat scroll timer (set on first page change).
  _DragDirection _repeatDirection = _DragDirection.forward;

  @override
  void initState() {
    super.initState();
    _dragPreviewPage = widget.currentPage;
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _hideBadgeTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuranPageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the page changes externally (e.g. from parent pressing buttons),
    // sync the preview page and show a brief badge.
    if (oldWidget.currentPage != widget.currentPage && !_isDragging) {
      _dragPreviewPage = widget.currentPage;
      _showTemporaryBadge();
    }
  }

  /// The effective page to display:
  /// - During drag: show the local preview page (no Quran page rebuild)
  /// - Otherwise: show the actual currentPage from the parent
  int get _effectivePage => _isDragging ? _dragPreviewPage : widget.currentPage;

  // ---------------------------------------------------------------------------
  // Badge helpers
  // ---------------------------------------------------------------------------

  void _showTemporaryBadge() {
    _hideBadgeTimer?.cancel();
    if (!_showPageBadge) {
      setState(() {
        _showPageBadge = true;
      });
    }
    _hideBadgeTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !_isDragging) {
        setState(() {
          _showPageBadge = false;
        });
      }
    });
  }

  void _scheduleBadgeHide() {
    _hideBadgeTimer?.cancel();
    _hideBadgeTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !_isDragging) {
        setState(() {
          _showPageBadge = false;
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Repeat scroll (auto-scroll when held at edge)
  // ---------------------------------------------------------------------------

  void _beginRepeatScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 320), () {
      if (!mounted || !_isDragging) return;
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
        if (!mounted || !_isDragging) {
          timer.cancel();
          return;
        }
        final nextPage = _repeatDirection == _DragDirection.forward
            ? _dragPreviewPage + 1
            : _dragPreviewPage - 1;
        if (nextPage >= 1 && nextPage <= totalPagesCount) {
          // Update local preview only – no onPageSelected call.
          _dragPreviewPage = nextPage;
          setState(() {});
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Drag handlers
  // ---------------------------------------------------------------------------

  void _handleDragStart(DragStartDetails details) {
    _scrollTimer?.cancel();
    _dragStartPage = widget.currentPage;
    setState(() {
      _isDragging = true;
      _dragExtent = 0.0;
      _dragPreviewPage = widget.currentPage;
      _showPageBadge = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0.0;
    if (delta == 0.0) return;

    _dragExtent += delta;

    bool pageChanged = false;

    // Forward (right swipe) → next page
    while (_dragExtent > _dragThreshold && _dragPreviewPage < totalPagesCount) {
      _dragPreviewPage++;
      _dragExtent -= _dragThreshold;
      pageChanged = true;
    }

    // Backward (left swipe) → previous page
    while (_dragExtent < -_dragThreshold && _dragPreviewPage > 1) {
      _dragPreviewPage--;
      _dragExtent += _dragThreshold;
      pageChanged = true;
    }

    if (pageChanged) {
      // Determine repeat direction from start page (reliable).
      _repeatDirection = _dragPreviewPage > _dragStartPage
          ? _DragDirection.forward
          : _DragDirection.backward;
      // Restart the repeat scroll timer on every page change.
      _beginRepeatScroll();
    }

    // Single setState per frame: updates visual dragProgress + badge + markers.
    setState(() {});
  }

  void _endDrag() {
    _scrollTimer?.cancel();

    // Call onPageSelected ONCE with the final preview page.
    // This is the KEY performance improvement: the Quran PageView only
    // rebuilds once per drag session instead of on every tick.
    if (_dragPreviewPage != widget.currentPage) {
      widget.onPageSelected(_dragPreviewPage);
    }

    if (!mounted) return;
    setState(() {
      _dragExtent = 0.0;
      _isDragging = false;
    });

    _scheduleBadgeHide();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final mutedColor = isDark
        ? AppColors.parchmentLight.withValues(alpha: 0.48)
        : AppColors.maroon800.withValues(alpha: 0.45);

    // Center the page window around the effective page (preview during drag).
    final centerPage = _effectivePage;
    final pageWindow = <int>[
      for (var page = centerPage - 5; page <= centerPage + 5; page++)
        if (page >= 1 && page <= totalPagesCount) page,
    ];
    final dragProgress = (_dragExtent / 90.0).clamp(-1.0, 1.0);
    final markerTrackHeight = widget.compact ? 24.0 : 34.0;
    const overlayGap = 8.0;
    final overlayReservedHeight = widget.compact ? 26.0 : 30.0;
    final totalHeight =
        markerTrackHeight +
        (_showPageBadge ? overlayReservedHeight + overlayGap : 0.0);

    // Build the overlay content from page metadata (lightweight, no rebuild of Quran page).
    final meta = QuranPageMetadataCache.instance.forPage(_effectivePage);
    final surahNumber = getSurahNumberFromPage(_effectivePage);
    final surahName = getSurahNameArabic(surahNumber);

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Simple text overlay – reserve enough vertical space for it
            // inside the carousel so ancestor clipping does not hide it.
            Positioned(
              bottom: markerTrackHeight + overlayGap,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showPageBadge ? 1.0 : 0.0,
                  child: _PageInfoOverlay(
                    isDark: isDark,
                    pageNumber: _effectivePage,
                    surahName: surahName,
                    juzHizbText: meta.juzHizbText,
                  ),
                ),
              ),
            ),
            // Drag gesture area wrapping the page markers.
            // We use translucent so that taps on InkWell markers pass through
            // to the marker's own gesture recognizer without competition from
            // the drag recognizer for stationary taps.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: _handleDragStart,
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: (_) => _endDrag(),
                onHorizontalDragCancel: _endDrag,
                child: SizedBox(
                  height: markerTrackHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < pageWindow.length; index++)
                        _PageMarker(
                          page: pageWindow[index],
                          isActive: pageWindow[index] == _effectivePage,
                          primaryColor: primaryColor,
                          mutedColor: mutedColor,
                          dragProgress: dragProgress,
                          compact: widget.compact,
                          onTap: () {
                            // Direct tap: navigate immediately.
                            _showTemporaryBadge();
                            widget.onPageSelected(pageWindow[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal text overlay showing surah name, page number, juz & hizb.
/// Wrapped in IgnorePointer so it never interferes with drag/tap gestures.
class _PageInfoOverlay extends StatelessWidget {
  const _PageInfoOverlay({
    required this.isDark,
    required this.pageNumber,
    required this.surahName,
    required this.juzHizbText,
  });

  final bool isDark;
  final int pageNumber;
  final String surahName;
  final String juzHizbText;

  @override
  Widget build(BuildContext context) {
    final centerColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final sideColor = isDark
        ? AppColors.parchmentLight.withValues(alpha: 0.78)
        : AppColors.maroon800.withValues(alpha: 0.72);

    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, minWidth: 220),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 86,
              child: Text(
                juzHizbText,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: sideColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                convertToArabicDigits(pageNumber),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  color: centerColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 86,
              child: Text(
                surahName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: sideColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageMarker extends StatelessWidget {
  const _PageMarker({
    required this.page,
    required this.isActive,
    required this.primaryColor,
    required this.mutedColor,
    required this.dragProgress,
    required this.compact,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final Color primaryColor;
  final Color mutedColor;
  final double dragProgress;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = isActive ? 1.0 : 0.92;
    final width = compact ? (isActive ? 8.0 : 5.0) : (isActive ? 10.0 : 6.0);
    final height = compact
        ? (isActive ? 16.0 : 11.0)
        : (isActive ? 22.0 : 16.0);
    final yOffset = isActive ? -1.5 : 0.0;
    final xOffset = isActive ? dragProgress * 6.0 : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Transform.translate(
            offset: Offset(xOffset, yOffset),
            child: Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: isActive ? primaryColor : mutedColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : const [],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
