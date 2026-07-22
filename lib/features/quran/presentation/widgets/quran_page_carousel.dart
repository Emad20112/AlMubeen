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

class _QuranPageCarouselState extends State<QuranPageCarousel> {
  static const double _dragThreshold = 18.0;

  Timer? _scrollTimer;
  Timer? _hideBadgeTimer;
  double _dragExtent = 0.0;
  bool _hasSwipedOnce = false;
  bool _isDragging = false;
  bool _showPageBadge = false;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _hideBadgeTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuranPageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _showTemporaryBadge();
    }
  }

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

  void _beginRepeatScroll(bool forward) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 320), () {
      if (mounted && _isDragging && _hasSwipedOnce) {
        _scrollTimer = Timer.periodic(const Duration(milliseconds: 180), (
          timer,
        ) {
          final targetPage = forward
              ? widget.currentPage + 1
              : widget.currentPage - 1;
          if (targetPage >= 1 && targetPage <= totalPagesCount) {
            widget.onPageSelected(targetPage);
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _handleDragStart(DragStartDetails details) {
    _scrollTimer?.cancel();
    _showTemporaryBadge();
    setState(() {
      _isDragging = true;
      _dragExtent = 0.0;
      _hasSwipedOnce = false;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0.0;
    if (delta == 0.0) return;

    _showTemporaryBadge();
    setState(() {
      _dragExtent += delta;
    });

    if (_hasSwipedOnce) return;

    if (_dragExtent > _dragThreshold) {
      _hasSwipedOnce = true;
      if (widget.currentPage < totalPagesCount) {
        widget.onPageSelected(widget.currentPage + 1);
      }
      _beginRepeatScroll(true);
    } else if (_dragExtent < -_dragThreshold) {
      _hasSwipedOnce = true;
      if (widget.currentPage > 1) {
        widget.onPageSelected(widget.currentPage - 1);
      }
      _beginRepeatScroll(false);
    }
  }

  void _endDrag() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _showTemporaryBadge();
    if (!mounted) return;
    setState(() {
      _dragExtent = 0.0;
      _hasSwipedOnce = false;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final mutedColor = isDark
        ? AppColors.parchmentLight.withValues(alpha: 0.48)
        : AppColors.maroon800.withValues(alpha: 0.45);

    final centerPage = widget.currentPage;
    final pageWindow = <int>[
      for (var page = centerPage - 5; page <= centerPage + 5; page++)
        if (page >= 1 && page <= totalPagesCount) page,
    ];
    final dragProgress = (_dragExtent / 90.0).clamp(-1.0, 1.0);
    final markerTrackHeight = widget.compact ? 24.0 : 34.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -28,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _showPageBadge ? 1.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2520) : AppColors.maroon800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'صفحة ${convertToArabicDigits(widget.currentPage)}',
                style: TextStyle(
                  color: isDark ? AppColors.goldenAccentDark : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
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
                    isActive: pageWindow[index] == widget.currentPage,
                    primaryColor: primaryColor,
                    mutedColor: mutedColor,
                    dragProgress: dragProgress,
                    compact: widget.compact,
                    onTap: () {
                      _showTemporaryBadge();
                      widget.onPageSelected(pageWindow[index]);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
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
    final width = compact
        ? (isActive ? 8.0 : 5.0)
        : (isActive ? 10.0 : 6.0);
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
