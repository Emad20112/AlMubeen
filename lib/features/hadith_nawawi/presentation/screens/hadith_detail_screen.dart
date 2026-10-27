import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/features/hadith_nawawi/domain/models/hadith_nawawi_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HadithDetailScreen extends StatefulWidget {
  const HadithDetailScreen({
    required this.entries,
    required this.initialIndex,
    super.key,
  });

  final List<HadithNawawiEntry> entries;
  final int initialIndex;

  static const routePath = '/hadith-nawawi/:id';

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.entries.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < widget.entries.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final windowClass = AdaptiveBreakpoints.fromWidth(screenWidth);
    final contentMaxWidth = switch (windowClass) {
      AdaptiveWindowClass.compact => screenWidth,
      AdaptiveWindowClass.medium => 720.0,
      AdaptiveWindowClass.expanded => 860.0,
    };
    final sidePadding = math.max((screenWidth - contentMaxWidth) / 2, 20.0);

    return Scaffold(
      backgroundColor: colors.pageSurface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(context, colors),

            // ── PageView ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.entries.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return _HadithDetailPageContent(
                    entry: widget.entries[index],
                    sidePadding: sidePadding,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppColorScheme colors) {
    final cardBg = colors.surfaceElevated;
    final fgColor = colors.textPrimary;
    final currentEntry = widget.entries[_currentIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: fgColor,
              size: 20,
            ),
            visualDensity: VisualDensity.compact,
            tooltip: 'رجوع',
          ),
          Expanded(
            child: Text(
              'الحديث ${_ordinalNumber(currentEntry.hadithNumber)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fgColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
          ),

          // Previous button
          IconButton(
            onPressed: _currentIndex > 0 ? _previousPage : null,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              foregroundColor: fgColor,
              disabledForegroundColor: fgColor.withValues(alpha: 0.2),
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                side: BorderSide(color: colors.border.withValues(alpha: 0.2)),
              ),
            ),
            tooltip: 'الحديث السابق',
          ),

          const SizedBox(width: 6),

          // Next button
          IconButton(
            onPressed: _currentIndex < widget.entries.length - 1
                ? _nextPage
                : null,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              foregroundColor: fgColor,
              disabledForegroundColor: fgColor.withValues(alpha: 0.2),
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                side: BorderSide(color: colors.border.withValues(alpha: 0.2)),
              ),
            ),
            tooltip: 'الحديث التالي',
          ),
        ],
      ),
    );
  }

  String _ordinalNumber(int n) {
    const arabicNumerals = {
      1: 'الأول',
      2: 'الثاني',
      3: 'الثالث',
      4: 'الرابع',
      5: 'الخامس',
      6: 'السادس',
      7: 'السابع',
      8: 'الثامن',
      9: 'التاسع',
      10: 'العاشر',
      11: 'الحادي عشر',
      12: 'الثاني عشر',
      13: 'الثالث عشر',
      14: 'الرابع عشر',
      15: 'الخامس عشر',
      16: 'السادس عشر',
      17: 'السابع عشر',
      18: 'الثامن عشر',
      19: 'التاسع عشر',
      20: 'العشرون',
      21: 'الحادي والعشرون',
      22: 'الثاني والعشرون',
      23: 'الثالث والعشرون',
      24: 'الرابع والعشرون',
      25: 'الخامس والعشرون',
      26: 'السادس والعشرون',
      27: 'السابع والعشرون',
      28: 'الثامن والعشرون',
      29: 'التاسع والعشرون',
      30: 'الثلاثون',
      31: 'الحادي والثلاثون',
      32: 'الثاني والثلاثون',
      33: 'الثالث والثلاثون',
      34: 'الرابع والثلاثون',
      35: 'الخامس والثلاثون',
      36: 'السادس والثلاثون',
      37: 'السابع والثلاثون',
      38: 'الثامن والثلاثون',
      39: 'التاسع والثلاثون',
      40: 'الأربعون',
      41: 'الحادي والأربعون',
      42: 'الثاني والأربعون',
    };
    return arabicNumerals[n] ?? '$n';
  }
}

class _HadithDetailPageContent extends StatelessWidget {
  const _HadithDetailPageContent({
    required this.entry,
    required this.sidePadding,
  });

  final HadithNawawiEntry entry;
  final double sidePadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = colors.textPrimary;
    final surfaceColor = colors.surfaceElevated;
    final mutedColor = colors.textSecondary;
    final goldFg = colors.accent;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(sidePadding, 12, sidePadding, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Number + Source row ──
          Row(
            children: [
              // Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: goldFg.withValues(alpha: isDark ? 0.15 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: goldFg.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '${entry.hadithNumber}',
                    style: TextStyle(
                      color: goldFg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (entry.source.isNotEmpty)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      entry.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primaryStrong,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              // Copy button
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: entry.fullText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نسخ الحديث'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.copy_rounded, color: mutedColor, size: 18),
                visualDensity: VisualDensity.compact,
                tooltip: 'نسخ الحديث',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Divider ──
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  goldFg.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Full Hadith Text ──
          SelectableText(
            entry.fullText,
            style: TextStyle(
              color: fgColor,
              fontSize: 16.5,
              fontWeight: FontWeight.w500,
              height: 1.95,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // ── Divider ──
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  colors.border.withValues(alpha: isDark ? 0.2 : 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Sharh section ──
          if (entry.description.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.auto_stories_rounded, color: goldFg, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'شرح وفوائد الحديث',
                  style: TextStyle(
                    color: fgColor,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: colors.border.withValues(alpha: isDark ? 0.12 : 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.surfaceSunken.withValues(
                      alpha: isDark ? 0.2 : 0.04,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SelectableText(
                entry.description,
                style: TextStyle(
                  color: fgColor.withValues(alpha: 0.88),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  height: 1.9,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
