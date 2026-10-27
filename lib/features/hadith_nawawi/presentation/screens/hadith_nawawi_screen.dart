import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/widgets/shimmer_group.dart';
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
    final colors = context.semanticColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final windowClass = AdaptiveBreakpoints.fromWidth(screenWidth);
    final contentMaxWidth = switch (windowClass) {
      AdaptiveWindowClass.compact => screenWidth,
      AdaptiveWindowClass.medium => 720.0,
      AdaptiveWindowClass.expanded => 900.0,
    };
    final sidePadding = math.max((screenWidth - contentMaxWidth) / 2, 16.0);

    final entriesAsync = ref.watch(hadithNawawiEntriesProvider);

    return Scaffold(
      backgroundColor: colors.pageSurface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(colors, isDark)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 8),
                child: _buildSearchBar(colors, isDark),
              ),
            ),
            ...entriesAsync.when<List<Widget>>(
              data: (entries) {
                final filtered = _filterEntries(entries);
                if (filtered.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(colors),
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
                  // 🛡️ PERF: ticker واحد لكل الـ skeletons بدلاً من واحد لكل عنصر.
                  sliver: SliverToBoxAdapter(
                    child: ShimmerGroup(
                      itemCount: 1,
                      builder: (context, _) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var index = 0; index < 6; index++) ...[
                            if (index > 0) const SizedBox(height: 14),
                            const _SkeletonCard(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(colors, e),
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

  Widget _buildHeader(AppColorScheme colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.textPrimary,
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
                color: colors.textPrimary,
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
              color: colors.accent.withValues(
                alpha: isDark ? 0.15 : 0.12,
              ),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: colors.accent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppColorScheme colors, bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: colors.border.withValues(alpha: isDark ? 0.18 : 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.surfaceSunken.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        cursorColor: colors.primaryStrong,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث في الأحاديث...',
          hintStyle: TextStyle(
            color: colors.textSecondary.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.textSecondary,
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
                  color: colors.textSecondary,
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

  Widget _buildEmptyState(AppColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 18),
            Text(
              'لا توجد نتائج مطابقة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'جرّب كلمة بحث مختلفة أو امسح شريط البحث.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
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

  Widget _buildErrorState(AppColorScheme colors, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: colors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'تعذر تحميل الأحاديث',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
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
}

// ─── Hadith Card ──────────────────────────────────────────────

class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.entry, required this.isDark, this.onTap});

  final HadithNawawiEntry entry;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final cardBg = colors.surfaceElevated;
    final fgColor = colors.textPrimary;
    final mutedColor = colors.textSecondary;

    final chipBg = colors.surfaceMuted;
    final chipFg = colors.primaryStrong;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: colors.border.withValues(alpha: isDark ? 0.12 : 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.surfaceSunken.withValues(
                    alpha: isDark ? 0.3 : 0.06,
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
                        color: colors.border.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Icon(
                      Icons.visibility_rounded,
                      color: mutedColor,
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

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

                      const SizedBox(height: AppSpacing.sm),

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

                      const SizedBox(height: AppSpacing.md),

                      // Source chip
                      if (entry.source.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
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
                _OctagonBadge(number: entry.hadithNumber),
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
  const _OctagonBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = colors.accent.withValues(alpha: isDark ? 0.12 : 0.1);
    final fgColor = colors.accent;
    final borderColor = colors.accent.withValues(alpha: isDark ? 0.25 : 0.35);

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

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white12 : Colors.black12;
    final cardBg = colors.surfaceElevated;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: colors.border.withValues(alpha: isDark ? 0.08 : 0.06),
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
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 80,
                  height: 22,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
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
    );
  }
}
