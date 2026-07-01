import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class QuranPageCarousel extends StatefulWidget {
  const QuranPageCarousel({
    required this.currentPage,
    required this.onPageSelected,
    super.key,
  });

  final int currentPage;
  final ValueChanged<int> onPageSelected;

  @override
  State<QuranPageCarousel> createState() => _QuranPageCarouselState();
}

class _QuranPageCarouselState extends State<QuranPageCarousel> {
  static const double _dragThreshold = 18.0;

  Timer? _scrollTimer;
  double _dragExtent = 0.0;
  bool _hasSwipedOnce = false;
  bool _isDragging = false;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
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
    setState(() {
      _isDragging = true;
      _dragExtent = 0.0;
      _hasSwipedOnce = false;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0.0;
    if (delta == 0.0) return;

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: (_) => _endDrag(),
          onHorizontalDragCancel: _endDrag,
          child: SizedBox(
            height: 38,
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
                    onTap: () => widget.onPageSelected(pageWindow[index]),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.14 : 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
          ),
          child: Text(
            'صفحة ${_toArabicDigits(widget.currentPage)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w900,
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
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final Color primaryColor;
  final Color mutedColor;
  final double dragProgress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = isActive ? 1.0 : 0.92;
    final width = isActive ? 10.0 : 6.0;
    final height = isActive ? 22.0 : 16.0;
    final yOffset = isActive ? -1.5 : 0.0;
    final xOffset = isActive ? dragProgress * 6.0 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
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

String _toArabicDigits(int number) {
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
