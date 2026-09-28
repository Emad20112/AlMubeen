import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/widgets/shimmer_group.dart';
import 'package:al_mubeen/features/names_of_allah/data/names_of_allah_providers.dart';
import 'package:al_mubeen/features/names_of_allah/domain/models/allah_name_entry.dart';
import 'package:al_mubeen/features/names_of_allah/presentation/widgets/allah_name_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NamesOfAllahScreen extends ConsumerStatefulWidget {
  const NamesOfAllahScreen({super.key});

  static const routePath = '/names-of-allah';

  @override
  ConsumerState<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends ConsumerState<NamesOfAllahScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(
        ref.read(namesOfAllahLocalDataSourceProvider).warmUp().catchError((
          error,
          stackTrace,
        ) {
          debugPrint('NamesOfAllah warm-up failed: $error');
          debugPrint('$stackTrace');
        }),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateQuery(String value) {
    setState(() {
      _query = value;
    });
  }

  void _clearSearch() {
    if (_query.isEmpty) {
      return;
    }

    setState(() {
      _query = '';
    });
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkScaffold
        : AppColors.parchment;
    final foregroundColor = isDark ? AppColors.darkInk : AppColors.maroon800;
    final surfaceColor = isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.parchmentLight;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final windowClass = AdaptiveBreakpoints.fromWidth(screenWidth);
    final contentMaxWidth = switch (windowClass) {
      AdaptiveWindowClass.compact => screenWidth,
      AdaptiveWindowClass.medium => 820.0,
      AdaptiveWindowClass.expanded => 1040.0,
    };
    final sidePadding = math.max((screenWidth - contentMaxWidth) / 2, 16.0);
    final cardExtent = (math.max(
      196.0,
      196.0 + (textScale - 1).clamp(0.0, 1.0) * 34.0,
    )).toDouble();
    final headerExtent = (154.0 + (textScale - 1).clamp(0.0, 1.0) * 28.0)
        .toDouble();

    final namesAsync = ref.watch(namesOfAllahEntriesProvider);
    final summaryText = namesAsync.when<String>(
      data: (entries) {
        final filtered = _filterEntries(entries);
        if (_query.trim().isEmpty) {
          return '${entries.length} اسمًا محفوظًا محليًا';
        }

        return '${filtered.length} نتيجة من ${entries.length}';
      },
      loading: () => 'جارٍ تجهيز البيانات المحلية...',
      error: (_, _) => 'تعذر تحميل الأسماء الآن',
    );

    final slivers = <Widget>[
      SliverPersistentHeader(
        pinned: true,
        delegate: _AllahNamesHeaderDelegate(
          title: 'أسماء الله الحسنى',
          subtitle: summaryText,
          backgroundColor: backgroundColor,
          surfaceColor: surfaceColor,
          foregroundColor: foregroundColor,
          extent: headerExtent,
          controller: _searchController,
          onChanged: _updateQuery,
          onClear: _clearSearch,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
      ...namesAsync.when<List<Widget>>(
        data: (entries) {
          final filteredEntries = _filterEntries(entries);
          if (filteredEntries.isEmpty) {
            return [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _AllahNamesEmptyState(
                  isDark: isDark,
                  query: _query,
                  onClear: _clearSearch,
                ),
              ),
            ];
          }

          return [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(sidePadding, 14, sidePadding, 24),
              sliver: SliverGrid.builder(
                itemCount: filteredEntries.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: cardExtent,
                ),
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return AllahNameCard(
                    key: ValueKey(entry.id),
                    entry: entry,
                    isDark: isDark,
                    onTap: () {
                      showAllahNameDetailSheet(
                        context: context,
                        entries: filteredEntries,
                        initialIndex: index,
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
            padding: EdgeInsets.fromLTRB(sidePadding, 14, sidePadding, 24),
            // 🛡️ PERF: ticker واحد لكل الـ skeletons بدلاً من واحد لكل عنصر.
            sliver: SliverToBoxAdapter(
              child: ShimmerGroup(
                itemCount: 1,
                builder: (context, _) => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: 8,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: cardExtent,
                  ),
                  itemBuilder: (context, index) =>
                      const _AllahNameSkeletonCard(),
                ),
              ),
            ),
          ),
        ],
        error: (error, stackTrace) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _AllahNamesErrorState(
              isDark: isDark,
              error: error,
              onRetry: () => ref.invalidate(namesOfAllahEntriesProvider),
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          key: const PageStorageKey<String>('names-of-allah-scroll'),
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          cacheExtent: 1200,
          slivers: slivers,
        ),
      ),
    );
  }

  List<AllahNameEntry> _filterEntries(List<AllahNameEntry> entries) {
    final query = _query.trim();
    if (query.isEmpty) {
      return entries;
    }

    return entries.where((entry) => entry.matchesQuery(query)).toList();
  }
}

class _AllahNamesHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _AllahNamesHeaderDelegate({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.foregroundColor,
    required this.extent,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color foregroundColor;
  final double extent;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final borderColor = foregroundColor.withValues(alpha: 0.08);
    final shadowColor = foregroundColor.withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: foregroundColor,
                visualDensity: VisualDensity.compact,
                tooltip: 'رجوع',
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foregroundColor.withValues(alpha: 0.72),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 48, child: const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 12),
          _AllahNamesSearchField(
            controller: controller,
            backgroundColor: surfaceColor,
            foregroundColor: foregroundColor,
            onChanged: onChanged,
            onClear: onClear,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AllahNamesHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.subtitle != subtitle ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.extent != extent ||
        oldDelegate.controller != controller;
  }
}

class _AllahNamesSearchField extends StatelessWidget {
  const _AllahNamesSearchField({
    required this.controller,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final Color backgroundColor;
  final Color foregroundColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.maroon700.withValues(alpha: 0.14)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        cursorColor: AppColors.maroon700,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم أو المعنى',
          hintStyle: TextStyle(
            color: foregroundColor.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: foregroundColor.withValues(alpha: 0.7),
            size: 21,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'مسح البحث',
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  color: foregroundColor.withValues(alpha: 0.7),
                  size: 20,
                ),
              );
            },
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class AllahNameCard extends StatelessWidget {
  const AllahNameCard({
    required this.entry,
    required this.isDark,
    this.onTap,
    super.key,
  });

  final AllahNameEntry entry;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.cardCream;
    final borderColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.goldenAccent;
    final titleColor = isDark ? AppColors.darkInk : AppColors.maroon800;
    final meaningColor = isDark ? AppColors.darkInk : AppColors.ink;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  backgroundColor,
                  isDark ? AppColors.darkSurface : AppColors.parchmentLight,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor.withValues(alpha: 0.58)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon900.withValues(
                    alpha: isDark ? 0.24 : 0.14,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Eye Icon Button
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: titleColor.withValues(
                                  alpha: isDark ? 0.12 : 0.08,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: titleColor.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Icon(
                                Icons.visibility_rounded,
                                color: titleColor.withValues(alpha: 0.8),
                                size: 15,
                              ),
                            ),
                            _AllahIndexBadge(number: entry.id, isDark: isDark),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          entry.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 30,
                            height: 1.02,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.meaning,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: meaningColor.withValues(
                              alpha: isDark ? 0.92 : 0.88,
                            ),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                      ],
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
}

class _AllahIndexBadge extends StatelessWidget {
  const _AllahIndexBadge({required this.number, required this.isDark});

  final int number;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark
        ? AppColors.maroon800.withValues(alpha: 0.9)
        : AppColors.maroon700.withValues(alpha: 0.12);
    final foregroundColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.maroon700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: foregroundColor.withValues(alpha: isDark ? 0.35 : 0.28),
        ),
      ),
      child: Text(
        '#$number',
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _AllahNamesEmptyState extends StatelessWidget {
  const _AllahNamesEmptyState({
    required this.isDark,
    required this.query,
    required this.onClear,
  });

  final bool isDark;
  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDark ? AppColors.darkInk : AppColors.maroon800;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 54,
              color: foregroundColor.withValues(alpha: 0.65),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'لا توجد بيانات لعرضها الآن'
                  : 'لا توجد نتائج مطابقة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'سنحاول مجددًا عند فتح الشاشة أو بعد اكتمال التحميل.'
                  : 'جرّب لفظًا آخر أو امسح البحث لتظهر جميع الأسماء.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor.withValues(alpha: 0.72),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
                label: const Text('مسح البحث'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AllahNamesErrorState extends StatelessWidget {
  const _AllahNamesErrorState({
    required this.isDark,
    required this.error,
    required this.onRetry,
  });

  final bool isDark;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDark ? AppColors.darkInk : AppColors.maroon800;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AppColors.maroon700.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'تعذر تحميل الأسماء الحسنى',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllahNameSkeletonCard extends StatelessWidget {
  const _AllahNameSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final cardColor = skeletonCardColor(context);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.maroon700.withValues(alpha: 0.08)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: SkeletonBox(width: 48, height: 22, borderRadius: 999),
            ),
            Spacer(),
            SkeletonBox(width: 120, height: 26, borderRadius: 8),
            SizedBox(height: 10),
            SkeletonBox(width: 150, height: 12, borderRadius: 6),
            SizedBox(height: 8),
            SkeletonBox(width: 110, height: 12, borderRadius: 6),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
