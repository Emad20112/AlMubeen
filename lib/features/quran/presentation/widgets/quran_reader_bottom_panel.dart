import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_page_carousel.dart';
import 'package:flutter/material.dart';

/// Approximate height of the bottom panel for layout calculations.
const double kQuranReaderBottomPanelHeight = 82;

class QuranReaderBottomPanel extends StatelessWidget {
  const QuranReaderBottomPanel({
    required this.currentPage,
    required this.onPageSelected,
    this.rightControls,
    this.leftControls,
    this.reciterButton,
    super.key,
  });

  final int currentPage;
  final ValueChanged<int> onPageSelected;
  final Widget? rightControls;
  final Widget? leftControls;
  final Widget? reciterButton;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final backgroundColor = isDark
        ? const Color(0xFF171311).withValues(alpha: 0.72)
        : const Color(0xFFF4EBDD).withValues(alpha: 0.76);
    final borderColor = primaryColor.withValues(alpha: isDark ? 0.16 : 0.10);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 64,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: rightControls ?? const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: QuranPageCarousel(
                            currentPage: currentPage,
                            onPageSelected: onPageSelected,
                            compact: true,
                          ),
                        ),
                        if (reciterButton != null) ...[
                          const SizedBox(width: 4),
                          reciterButton!,
                        ],
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 64,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: leftControls ?? const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
