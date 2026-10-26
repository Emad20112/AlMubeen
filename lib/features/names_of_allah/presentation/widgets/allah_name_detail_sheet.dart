import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/app/theme/app_typography.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';
import 'package:al_mubeen/features/names_of_allah/domain/models/allah_name_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showAllahNameDetailSheet({
  required BuildContext context,
  required List<AllahNameEntry> entries,
  required int initialIndex,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        AllahNameDetailSheet(entries: entries, initialIndex: initialIndex),
  );
}

class AllahNameDetailSheet extends StatefulWidget {
  const AllahNameDetailSheet({
    required this.entries,
    required this.initialIndex,
    super.key,
  });

  final List<AllahNameEntry> entries;
  final int initialIndex;

  @override
  State<AllahNameDetailSheet> createState() => _AllahNameDetailSheetState();
}

class _AllahNameDetailSheetState extends State<AllahNameDetailSheet> {
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
    final bgColor = colors.surface;
    final fgColor = colors.textPrimary;
    final accentColor = colors.accent;
    final cardColor = colors.surfaceElevated;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
        border: Border.all(color: colors.border),
        boxShadow: context.tokens.shadows.elevated,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  // Previous button
                  IconButton(
                    onPressed: _currentIndex > 0 ? _previousPage : null,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                    ),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: fgColor,
                      disabledForegroundColor: fgColor.withValues(alpha: 0.2),
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                    tooltip: 'الاسم السابق',
                  ),
                  const Spacer(),

                  // Counter Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${_currentIndex + 1} من ${widget.entries.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accentColor,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Next button
                  IconButton(
                    onPressed: _currentIndex < widget.entries.length - 1
                        ? _nextPage
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: fgColor,
                      disabledForegroundColor: fgColor.withValues(alpha: 0.2),
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                    tooltip: 'الاسم التالي',
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Close Button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: fgColor.withValues(alpha: 0.7),
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.entries.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final entry = widget.entries[index];
                  return _AllahNameDetailPage(entry: entry);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllahNameDetailPage extends StatelessWidget {
  const _AllahNameDetailPage({required this.entry});

  final AllahNameEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final cardBg = colors.surfaceElevated;
    final fgColor = colors.primaryStrong;
    final meaningColor = colors.textPrimary;
    final accentColor = colors.accent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: RepaintBoundary(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: accentColor.withValues(alpha: 0.35)),
            boxShadow: context.tokens.shadows.medium,
          ),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'الاسم #${entry.id}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),

              const Spacer(),

              // Name in Arabic
              SelectableText(
                entry.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 42,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Decorative Divider
              SvgPicture.asset(
                AppAssets.decorativeDivider,
                width: 130,
                colorFilter: ColorFilter.mode(
                  accentColor.withValues(alpha: 0.45),
                  BlendMode.srcIn,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Meaning
              Flexible(
                flex: 3,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SelectableText(
                    entry.meaning,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: meaningColor.withValues(alpha: 0.9),
                      height: 1.6,
                      fontWeight: AppTypography.regular,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Action Bar (Share/Copy)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: '${entry.name}\n\n${entry.meaning}',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ الاسم ومعناه إلى الحافظة'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('نسخ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fgColor,
                      side: BorderSide(
                        color: fgColor.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
