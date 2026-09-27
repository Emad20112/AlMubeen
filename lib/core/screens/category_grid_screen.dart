import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/data/category_favorites_provider.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/widgets/adhkar_custom_header.dart';
import 'package:al_mubeen/core/widgets/adhkar_grid_card.dart';
import 'package:al_mubeen/core/widgets/shimmer_group.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_icon_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CategoryGridScreenTab {
  const CategoryGridScreenTab({
    required this.label,
    required this.routePath,
    required this.type,
    required this.categoriesAsync,
    required this.onCategoryTap,
  });

  final String label;
  final String routePath;
  final String type;
  final AsyncValue<List<dynamic>> categoriesAsync;
  final void Function(String categoryId) onCategoryTap;
}

class CategoryGridScreen extends ConsumerStatefulWidget {
  const CategoryGridScreen({
    required this.title,
    required this.categoriesAsync,
    required this.onCategoryTap,
    required this.type,
    this.backRoute = '/',
    this.loadingItemCount = 8,
    this.tabs = const [],
    this.selectedTabIndex = 0,
    super.key,
  });

  final String title;
  final AsyncValue<List<dynamic>> categoriesAsync;
  final void Function(String categoryId) onCategoryTap;
  final String type;
  final String backRoute;
  final int loadingItemCount;
  final List<CategoryGridScreenTab> tabs;
  final int selectedTabIndex;

  @override
  ConsumerState<CategoryGridScreen> createState() => _CategoryGridScreenState();
}

class _CategoryGridScreenState extends ConsumerState<CategoryGridScreen> {
  static const Duration _searchDebounceDuration = Duration(milliseconds: 300);

  String _query = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFavorites(widget.type);
    });
  }

  @override
  void didUpdateWidget(covariant CategoryGridScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initFavorites(widget.type);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _initFavorites(String type) {
    ref.read(categoryFavoritesProvider.notifier).init(type);
  }

  /// 🛡️ PERF: تأخير تحديث البحث 300ms لمنع إعادة بناء الشبكة مع كل حرف يُكتب.
  void _updateQuery(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted || _query == value) return;
      setState(() {
        _query = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hasTabs = widget.tabs.isNotEmpty;
    final selectedTabIndex = widget.selectedTabIndex.clamp(
      0,
      hasTabs ? widget.tabs.length - 1 : 0,
    );
    final activeTab = hasTabs ? widget.tabs[selectedTabIndex] : null;
    final categoriesAsync =
        activeTab?.categoriesAsync ?? widget.categoriesAsync;
    final onCategoryTap = activeTab?.onCategoryTap ?? widget.onCategoryTap;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      bottomNavigationBar: QuranReaderIconNavBar(
        selectedIndex: 1,
        onQuranTapped: () => context.go('/'),
        onAdhkarTapped: () {},
        onLibrariesTapped: () => context.go('/quran/libraries'),
        onMoreTapped: () => context.go('/quran/more'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AdhkarCustomHeader(
                title: widget.title,
                onSearch: _updateQuery,
                tabs: hasTabs
                    ? _CategoryTypeTabs(
                        tabs: widget.tabs,
                        selectedIndex: selectedTabIndex,
                      )
                    : null,
              ),
            ),
            categoriesAsync.when(
              data: (categories) => _CategoryGrid(
                categories: categories,
                onCategoryTap: onCategoryTap,
                screenWidth: screenWidth,
                query: _query,
              ),
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                // 🛡️ PERF: ticker واحد لكل الـ skeletons بدلاً من واحد لكل عنصر.
                sliver: SliverToBoxAdapter(
                  child: ShimmerGroup(
                    itemCount: 1,
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, _) => _CategorySkeletonGrid(
                      itemCount: widget.loadingItemCount,
                    ),
                  ),
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Text('خطأ في تحميل البيانات: $error'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends ConsumerWidget {
  const _CategoryGrid({
    required this.categories,
    required this.onCategoryTap,
    required this.screenWidth,
    required this.query,
  });

  final List<dynamic> categories;
  final void Function(String categoryId) onCategoryTap;
  final double screenWidth;
  final String query;

  /// 🛡️ PERF: ذاكرة مؤقتة لنتيجة الفلترة/الترتيب — نمنع نسخ القائمة
  /// وترتيبها (O(n log n)) في كل build عند عدم تغيّر المدخلات.
  static List<dynamic>? _cachedSource;
  static Set<String>? _cachedFavoriteIds;
  static String? _cachedQuery;
  static List<dynamic> _cachedResult = const [];

  List<dynamic> _resolveSortedCategories(Set<String> favoriteIds) {
    final trimmedQuery = query.trim().toLowerCase();

    if (identical(_cachedSource, categories) &&
        _cachedQuery == trimmedQuery &&
        _setEquals(_cachedFavoriteIds, favoriteIds)) {
      return _cachedResult;
    }

    final filtered = trimmedQuery.isEmpty
        ? List<dynamic>.of(categories)
        : categories.where((category) {
            final searchableText = '${category.title} ${category.subtitle}'
                .toLowerCase();
            return searchableText.contains(trimmedQuery);
          }).toList();

    filtered.sort((a, b) {
      final aFav = favoriteIds.contains(a.id) ? 0 : 1;
      final bFav = favoriteIds.contains(b.id) ? 0 : 1;
      if (aFav != bFav) return aFav - bFav;
      return a.priority.compareTo(b.priority);
    });

    _cachedSource = categories;
    _cachedFavoriteIds = Set<String>.of(favoriteIds);
    _cachedQuery = trimmedQuery;
    _cachedResult = filtered;
    return filtered;
  }

  static bool _setEquals(Set<String>? a, Set<String> b) {
    if (a == null || a.length != b.length) return false;
    for (final value in b) {
      if (!a.contains(value)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoriteIds = ref.watch(categoryFavoritesProvider);
    final sorted = _resolveSortedCategories(favoriteIds);

    final windowClass = AdaptiveBreakpoints.fromWidth(screenWidth);
    final contentMaxWidth = switch (windowClass) {
      AdaptiveWindowClass.compact => screenWidth,
      AdaptiveWindowClass.medium => 760.0,
      AdaptiveWindowClass.expanded => 980.0,
    };
    final side = math.max((screenWidth - contentMaxWidth) / 2, 16.0);

    if (sorted.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 48, side, 24),
          child: Center(
            child: Text(
              'لا توجد نتائج مطابقة',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.darkInk : AppColors.maroon800,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(side, 10, side, 24),
      sliver: SliverGrid.builder(
        itemCount: sorted.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          // 🛡️ تم التعديل من 100 إلى 160 ليتطابق مع حجم الـ Skeleton ويعطي البطاقة مظهراً فخماً
          mainAxisExtent: 160.0,
        ),
        itemBuilder: (context, index) {
          final category = sorted[index];
          return AdhkarGridCard(
            key: ValueKey(category.id),
            title: category.title,
            subtitle: category.subtitle,
            isFavorite: favoriteIds.contains(category.id),
            onFavoriteToggle: () => ref
                .read(categoryFavoritesProvider.notifier)
                .toggleFavorite(category.id),
            onTap: () => onCategoryTap(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryTypeTabs extends StatelessWidget {
  const _CategoryTypeTabs({required this.tabs, required this.selectedIndex});

  final List<CategoryGridScreenTab> tabs;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.parchment;
    final selectedColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.goldenAccent;
    final textColor = isDark ? AppColors.darkInk : AppColors.maroon800;

    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: selectedColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < tabs.length; index++)
            Expanded(
              child: _CategoryTypeTabButton(
                label: tabs[index].label,
                selected: index == selectedIndex,
                selectedColor: selectedColor,
                textColor: textColor,
                onTap: () {
                  if (index == selectedIndex) {
                    return;
                  }
                  context.go(tabs[index].routePath);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTypeTabButton extends StatelessWidget {
  const _CategoryTypeTabButton({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: Duration.zero,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? textColor : textColor.withValues(alpha: 0.64),
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySkeletonGrid extends StatelessWidget {
  const _CategorySkeletonGrid({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        mainAxisExtent: 160.0,
      ),
      itemBuilder: (context, index) => const _CategorySkeleton(),
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: skeletonCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.maroon700.withValues(alpha: 0.05),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // 🛡️ حماية إضافية ضد الفائض
          children: [
            SkeletonBox.circle(size: 44),
            Gap(14),
            SkeletonBox(width: 80, height: 12),
            Gap(8),
            SkeletonBox(width: 40, height: 10),
          ],
        ),
      ),
    );
  }
}
