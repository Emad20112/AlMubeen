import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_library_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

/// An elegant glassmorphism header overlay that appears when the user
/// taps on the reading screen. Slides in/out from the top.
class QuranReaderHeader extends StatelessWidget {
  const QuranReaderHeader({
    required this.currentPage,
    required this.onSurahSelected,
    super.key,
  });

  final int currentPage;

  /// Called when the user selects a surah from the picker.
  final ValueChanged<int> onSurahSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = MediaQuery.paddingOf(context);
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final iconColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon700;
    final textColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    // Current surah info from page
    final surahNumber = getSurahNumberFromPage(currentPage);
    final surahName = getSurahNameArabic(surahNumber);
    final hizbText = getCurrentHizbTextForPage(currentPage, isArabic: true);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.only(top: padding.top),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1A1210).withValues(alpha: 0.92),
                        const Color(0xFF2C2118).withValues(alpha: 0.82),
                      ]
                    : [
                        const Color(0xFFF7F0E3).withValues(alpha: 0.94),
                        const Color(0xFFF2EBDC).withValues(alpha: 0.86),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: primaryColor.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── Top action row ───
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      // Opens the unified library sheet.
                      _HeaderIconButton(
                        icon: Icons.local_library_rounded,
                        tooltip: 'المكتبة',
                        color: iconColor,
                        onTap: () => showQuranLibrarySheet(context: context),
                      ),

                      // Tool icons
                      _HeaderIconButton(
                        icon: Icons.share_outlined,
                        tooltip: 'مشاركة',
                        color: iconColor,
                        onTap: () {
                          // Reserved for future feature
                        },
                      ),

                      const Spacer(),

                      // ─── Center: Surah picker button ───
                      _SurahPickerButton(
                        surahName: surahName,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        onTap: () => _openSurahPicker(context),
                      ),

                      const Spacer(),

                      // Left side (RTL): back button
                      _HeaderIconButton(
                        icon: Icons.arrow_forward_rounded,
                        tooltip: 'العودة للقائمة الرئيسية',
                        color: iconColor,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // ─── Info subtitle ───
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '$hizbText • صفحة ${_toArabicNumber(currentPage)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.65),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSurahPicker(BuildContext context) async {
    final surahNumber = await showSurahPicker(context);
    if (surahNumber != null) {
      onSurahSelected(surahNumber);
    }
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
    return number.toString().split('').map((d) => digits[d] ?? d).join();
  }
}

/// A tappable surah name chip in the center of the header.
class _SurahPickerButton extends StatelessWidget {
  const _SurahPickerButton({
    required this.surahName,
    required this.primaryColor,
    required this.textColor,
    required this.onTap,
  });

  final String surahName;
  final Color primaryColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                surahName,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A styled header icon button with ripple effect.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}
