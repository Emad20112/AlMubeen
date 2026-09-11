import 'package:al_mubeen/app/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1715) : AppColors.parchmentLight;
    final fgColor = isDark ? AppColors.darkInk : AppColors.maroon800;
    final accentColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.goldenAccent;
    final cardColor = isDark ? AppColors.darkSurfaceHigh : Colors.white;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: fgColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: fgColor.withValues(alpha: 0.1)),
                      ),
                    ),
                    tooltip: 'الاسم السابق',
                  ),
                  const Spacer(),

                  // Counter Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${_currentIndex + 1} من ${widget.entries.length}',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
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
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: fgColor.withValues(alpha: 0.1)),
                      ),
                    ),
                    tooltip: 'الاسم التالي',
                  ),

                  const SizedBox(width: 8),

                  // Close Button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: fgColor.withValues(alpha: 0.7),
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: fgColor.withValues(alpha: 0.1)),
                      ),
                    ),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

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
                  return _AllahNameDetailPage(entry: entry, isDark: isDark);
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
  const _AllahNameDetailPage({required this.entry, required this.isDark});

  final AllahNameEntry entry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurfaceHigh : Colors.white;
    final fgColor = isDark ? AppColors.darkInk : AppColors.maroon800;
    final meaningColor = isDark ? AppColors.darkInk : AppColors.ink;
    final accentColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.goldenAccent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: RepaintBoundary(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon900.withValues(
                  alpha: isDark ? 0.2 : 0.08,
                ),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
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
                  color: AppColors.maroon700.withValues(
                    alpha: isDark ? 0.25 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.maroon700.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'الاسم #${entry.id}',
                  style: TextStyle(
                    color: AppColors.maroon800,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

              const SizedBox(height: 16),

              // Decorative Divider
              SvgPicture.asset(
                AppAssets.decorativeDivider,
                width: 130,
                colorFilter: ColorFilter.mode(
                  accentColor.withValues(alpha: 0.5),
                  BlendMode.srcIn,
                ),
              ),

              const SizedBox(height: 20),

              // Meaning Text
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SelectableText(
                    entry.meaning,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: meaningColor.withValues(
                        alpha: isDark ? 0.95 : 0.88,
                      ),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      height: 1.7,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      final text = '${entry.name}\n${entry.meaning}';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('تم نسخ اسم الله ومعناه'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('نسخ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fgColor,
                      side: BorderSide(color: fgColor.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      visualDensity: VisualDensity.compact,
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
