import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/features/hadith_nawawi/data/hadith_nawawi_providers.dart';
import 'package:al_mubeen/features/hadith_nawawi/domain/models/hadith_nawawi_entry.dart';
import 'package:al_mubeen/features/hadith_nawawi/presentation/screens/hadith_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HadithNawawiScreen extends ConsumerStatefulWidget {
  const HadithNawawiScreen({super.key});

  static const routePath = '/hadith-nawawi';

  @override
  ConsumerState<HadithNawawiScreen> createState() => _HadithNawawiScreenState();
}

class _HadithNawawiScreenState extends ConsumerState<HadithNawawiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(hadithNawawiLocalDataSourceProvider).warmUp().catchError((
          e,
          s,
        ) {
          debugPrint('HadithNawawi warm-up failed: $e');
          debugPrint('$s');
        }),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final windowClass = AdaptiveBreakpoints.fromWidth(screenWidth);
    final contentMaxWidth = switch (windowClass) {
      AdaptiveWindowClass.compact => screenWidth,
      AdaptiveWindowClass.medium => 720.0,
      AdaptiveWindowClass.expanded => 900.0,
    };
    final sidePadding = math.max((screenWidth - contentMaxWidth) / 2, 16.0);

    final bgColor = _bgColor(isDark);
    final fgColor = _fgColor(isDark);
    final surfaceColor = _surfaceColor(isDark);

    final entriesAsync = ref.watch(hadithNawawiEntriesProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(isDark, fgColor, bgColor)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 8),
                child: _buildSearchBar(isDark, fgColor, surfaceColor),
              ),
            ),
            ...entriesAsync.when<List<Widget>>(
              data: (entries) {
                final filtered = _filterEntries(entries);
                if (filtered.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(isDark, fgColor),
                    ),
                  ];
                }
                return [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      12,
                      sidePadding,
                      32,
                    ),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _HadithCard(
                          entry: filtered[index],
                          isDark: isDark,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HadithDetailScreen(
                                  entries: filtered,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ];
              },
              loading: () => [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    sidePadding,
                    12,
                    sidePadding,
                    32,
                  ),
                  sliver: SliverList.separated(
                    itemCount: 6,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, _) => _SkeletonCard(isDark: isDark),
                  ),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(isDark, fgColor, e),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<HadithNawawiEntry> _filterEntries(List<HadithNawawiEntry> entries) {
    final q = _query.trim();
    if (q.isEmpty) return entries;
    return entries.where((e) => e.matchesQuery(q)).toList();
  }

  Widget _buildHeader(bool isDark, Color fgColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: fgColor,
              size: 22,
            ),
            tooltip: 'رجوع',
          ),
          Expanded(
            child: Text(
              'الأربعون النووية',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fgColor,
                fontFamily: 'DiwaniBent',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldenAccent.withValues(
                alpha: isDark ? 0.15 : 0.12,
              ),
              border: Border.all(
                color: AppColors.goldenAccent.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.goldenAccent.withValues(
                alpha: isDark ? 0.9 : 0.8,
              ),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color fgColor, Color surfaceColor) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.maroon700.withValues(alpha: isDark ? 0.18 : 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon900.withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        cursorColor: AppColors.maroon700,
        style: TextStyle(
          color: fgColor,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث في الأحاديث...',
          hintStyle: TextStyle(
            color: fgColor.withValues(alpha: 0.45),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: fgColor.withValues(alpha: 0.55),
            size: 22,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'مسح',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: fgColor.withValues(alpha: 0.55),
                  size: 20,
                ),
              );
            },
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color fgColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: fgColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 18),
            Text(
              'لا توجد نتائج مطابقة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fgColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب كلمة بحث مختلفة أو امسح شريط البحث.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fgColor.withValues(alpha: 0.65),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Color fgColor, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.maroon700.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'تعذر تحميل الأحاديث',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fgColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fgColor.withValues(alpha: 0.65),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => ref.invalidate(hadithNawawiEntriesProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Color _bgColor(bool isDark) =>
      isDark ? AppColors.darkScaffold : const Color(0xFFFAF8F3);
  Color _fgColor(bool isDark) =>
      isDark ? AppColors.darkInk : const Color(0xFF2C2420);
  Color _surfaceColor(bool isDark) =>
      isDark ? AppColors.darkSurfaceHigh : Colors.white;
}

// ─── Hadith Card ──────────────────────────────────────────────

class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.entry, required this.isDark, this.onTap});

  final HadithNawawiEntry entry;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurfaceHigh : Colors.white;
    final fgColor = isDark ? AppColors.darkInk : const Color(0xFF2C2420);
    final mutedColor = isDark
        ? AppColors.darkInk.withValues(alpha: 0.6)
        : const Color(0xFF8A7D72);

    final chipBg = isDark
        ? AppColors.maroon800.withValues(alpha: 0.6)
        : AppColors.maroon700.withValues(alpha: 0.08);
    final chipFg = isDark ? AppColors.cardRedDark : AppColors.cardRed;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.maroon700.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon900.withValues(
                    alpha: isDark ? 0.2 : 0.06,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Eye action icon button
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fgColor.withValues(alpha: isDark ? 0.12 : 0.06),
                      border: Border.all(
                        color: fgColor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Icon(
                      Icons.visibility_rounded,
                      color: fgColor.withValues(alpha: 0.75),
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Middle: Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fgColor,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Preview
                      Text(
                        entry.preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Source chip
                      if (entry.source.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            entry.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: chipFg,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right: Number badge
                _OctagonBadge(number: entry.hadithNumber, isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Octagonal Badge ──────────────────────────────────────────

class _OctagonBadge extends StatelessWidget {
  const _OctagonBadge({required this.number, required this.isDark});

  final int number;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? AppColors.goldenAccentDark.withValues(alpha: 0.12)
        : AppColors.goldenAccent.withValues(alpha: 0.1);
    final fgColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.goldenAccent;
    final borderColor = isDark
        ? AppColors.goldenAccentDark.withValues(alpha: 0.25)
        : AppColors.goldenAccent.withValues(alpha: 0.35);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: fgColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton Card ────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({required this.isDark});

  final bool isDark;

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark ? Colors.white12 : Colors.black12;
    final cardBg = widget.isDark ? AppColors.darkSurfaceHigh : Colors.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.maroon700.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bookmark placeholder
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 140,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 80,
                        height: 22,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Badge placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
