
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
  static const int _visibleRadius = 2;
  static const double _dragThreshold = 22.0;
  static const Duration _repeatDelay = Duration(milliseconds: 360);
  static const Duration _repeatInterval = Duration(milliseconds: 170);

  Timer? _scrollTimer;
  double _dragExtent = 0.0;
  bool _hasSwipedOnce = false;
  bool _isDragging = false;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _startContinuousScroll(bool forward) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(_repeatInterval, (timer) {
      final targetPage = forward ? widget.currentPage + 1 : widget.currentPage - 1;
      if (targetPage >= 1 && targetPage <= totalPagesCount) {
        widget.onPageSelected(targetPage);
      } else {
        timer.cancel();
      }
    });
  }

  void _beginRepeatScroll(bool forward) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(_repeatDelay, () {
      if (mounted && _isDragging && _hasSwipedOnce) {
        _startContinuousScroll(forward);
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
        ? AppColors.parchmentLight.withValues(alpha: 0.5)
        : AppColors.maroon800.withValues(alpha: 0.55);

    final startPage = (widget.currentPage - _visibleRadius).clamp(1, totalPagesCount);
    final endPage = (widget.currentPage + _visibleRadius).clamp(1, totalPagesCount);
    final pages = [for (var page = startPage; page <= endPage; page++) page];
    final activeIndex = pages.indexOf(widget.currentPage);

    final dragProgress = (_dragExtent / 110.0).clamp(-1.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 78,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: _handleDragStart,
                  onHorizontalDragUpdate: _handleDragUpdate,
                  onHorizontalDragEnd: (_) => _endDrag(),
                  onHorizontalDragCancel: _endDrag,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          for (var i = 0; i < pages.length; i++)
                            _CoverFlowPage(
                              page: pages[i],
                              index: i,
                              activeIndex: activeIndex,
                              dragProgress: dragProgress,
                              primaryColor: primaryColor,
                              onTap: () => widget.onPageSelected(pages[i]),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1.5,
          height: 7,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < pages.length; i++)
              _PageNumberBadge(
                page: pages[i],
                isActive: pages[i] == widget.currentPage,
                primaryColor: primaryColor,
                mutedColor: mutedColor,
                onTap: () => widget.onPageSelected(pages[i]),
              ),
          ],
        ),
      ],
    );
  }
}

class _CoverFlowPage extends StatelessWidget {
  const _CoverFlowPage({
    required this.page,
    required this.index,
    required this.activeIndex,
    required this.dragProgress,
    required this.primaryColor,
    required this.onTap,
  });

  final int page;
  final int index;
  final int activeIndex;
  final double dragProgress;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final relative = index - activeIndex;
    final distance = relative.abs();
    final isLeft = relative < 0;

    final opacity = switch (distance) {
      0 => 1.0,
      1 => 0.78,
      _ => 0.40,
    };

    final scale = switch (distance) {
      0 => 1.0,
      1 => 0.84,
      _ => 0.68,
    };

    final xOffset = relative * 38.0 + (dragProgress * 10.0);
    final yOffset = distance == 0 ? -4.0 : (distance == 1 ? 1.8 : 5.0);

    final rotationY = distance == 0
        ? dragProgress * 0.18
        : (isLeft ? 0.34 : -0.34);

    final rotationX = distance == 0 ? -0.06 : 0.03;

    final depth = distance == 0
        ? 0.006
        : (distance == 1 ? 0.0035 : 0.0022);

    final shadowOpacity = distance == 0 ? 0.22 : (distance == 1 ? 0.10 : 0.05);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, depth)
              ..translate(xOffset, yOffset, 0.0)
              ..rotateX(rotationX)
              ..rotateY(rotationY)
              ..scale(scale),
            child: _MushafBookThumbnail(
              isActive: distance == 0,
              primaryColor: primaryColor,
              shadowOpacity: shadowOpacity,
            ),
          ),
        ),
      ),
    );
  }
}

class _MushafBookThumbnail extends StatelessWidget {
  const _MushafBookThumbnail({
    required this.isActive,
    required this.primaryColor,
    required this.shadowOpacity,
  });

  final bool isActive;
  final Color primaryColor;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ظل خفيف أسفل المصحف لزيادة الإحساس بالعمق.
          Positioned(
            bottom: 2,
            child: Container(
              width: 98,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.maroon900.withValues(alpha: shadowOpacity),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // الصفحتان اليسرى واليمنى خلف الصفحة النشطة.
          Positioned(
            left: 8,
            child: _BookLeaf(
              width: 46,
              height: 38,
              flip: true,
              opacity: isActive ? 0.9 : 0.55,
            ),
          ),
          Positioned(
            right: 8,
            child: _BookLeaf(
              width: 46,
              height: 38,
              flip: false,
              opacity: isActive ? 0.9 : 0.55,
            ),
          ),

          // الغلاف/الصفحة النشطة في المنتصف.
          Container(
            width: 56,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.parchmentLight,
                  AppColors.parchmentLight.withValues(alpha: 0.92),
                  AppColors.parchmentLight.withValues(alpha: 0.82),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive
                    ? primaryColor.withValues(alpha: 0.85)
                    : AppColors.maroon800.withValues(alpha: 0.10),
                width: isActive ? 1.6 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon900.withValues(alpha: isActive ? 0.20 : 0.08),
                  blurRadius: isActive ? 10 : 5,
                  offset:  Offset(0, isActive ? 4 : 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Column(
                children: [
                  Container(
                    height: 2.2,
                    margin: const EdgeInsets.only(top: 1.5),
                    width: isActive ? 18 : 12,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isActive ? 0.55 : 0.25),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                for (var i = 0; i < 6; i++)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 0.8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.maroon800.withValues(
                                            alpha: i.isEven ? 0.10 : 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(0.6),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 2.2,
                    color: primaryColor.withValues(alpha: 0.12),
                  ),
                ],
              ),
            ),
          ),

          // نقطة الربط الدقيقة في الأعلى لتعزيز شكل المصحف المفتوح.
          Positioned(
            top: -2,
            child: Container(
              width: 12,
              height: 6,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookLeaf extends StatelessWidget {
  const _BookLeaf({
    required this.width,
    required this.height,
    required this.flip,
    required this.opacity,
  });

  final double width;
  final double height;
  final bool flip;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: flip ? Alignment.centerRight : Alignment.centerLeft,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.003)
          ..rotateY(flip ? 0.24 : -0.24)
          ..translate(flip ? -2.0 : 2.0, 0.0, 0.0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: flip ? Alignment.topRight : Alignment.topLeft,
              end: flip ? Alignment.bottomLeft : Alignment.bottomRight,
              colors: [
                AppColors.parchmentLight.withValues(alpha: 0.95),
                AppColors.parchmentLight.withValues(alpha: 0.82),
                AppColors.parchmentLight.withValues(alpha: 0.74),
              ],
            ),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: AppColors.maroon800.withValues(alpha: 0.08),
              width: 0.7,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon900.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(2.8),
              child: Column(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.65),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.maroon800.withValues(
                              alpha: i.isEven ? 0.06 : 0.035,
                            ),
                            borderRadius: BorderRadius.circular(0.6),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageNumberBadge extends StatelessWidget {
  const _PageNumberBadge({
    required this.page,
    required this.isActive,
    required this.primaryColor,
    required this.mutedColor,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final Color primaryColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 9 : 3,
            vertical: isActive ? 4 : 2,
          ),
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              color: isActive ? AppColors.parchmentLight : mutedColor,
              fontSize: isActive ? 12 : 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}


