import 'dart:ui';
import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_library_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_page_carousel.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Approximate height of the bottom panel for layout calculations.
const double kQuranReaderBottomPanelHeight = 200;

class QuranReaderBottomPanel extends ConsumerWidget {
  const QuranReaderBottomPanel({
    required this.currentPage,
    required this.isTajweedListenable,
    required this.onPageSelected,
    required this.onCloseOverlay,
    super.key,
  });

  final int currentPage;
  final ValueNotifier<bool> isTajweedListenable;
  final ValueChanged<int> onPageSelected;
  final VoidCallback onCloseOverlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Elevated Library and Options Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ElevatedButton(
                  icon: Icons.local_library_rounded,
                  label: 'المكتبة',
                  onTap: () => showQuranLibrarySheet(context: context),
                ),
                const SizedBox(width: 12),
                _ElevatedButton(
                  icon: Icons.settings_outlined,
                  label: 'الخيارات',
                  onTap: () => showQuranReaderSettingsSheet(
                    context: context,
                    currentPage: currentPage,
                    isTajweedListenable: isTajweedListenable,
                  ),
                ),
              ],
            ),
          ),
          // The Bottom Bar itself
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
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
                    top: BorderSide(
                      color: primaryColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                    child: QuranPageCarousel(
                      currentPage: currentPage,
                      onPageSelected: onPageSelected,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElevatedButton extends StatelessWidget {
  const _ElevatedButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1210).withValues(alpha: 0.7)
                    : const Color(0xFFF7F0E3).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.maroon800,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
