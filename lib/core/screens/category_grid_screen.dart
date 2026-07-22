import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/data/category_favorites_provider.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/widgets/adhkar_custom_header.dart';
import 'package:al_mubeen/core/widgets/adhkar_grid_card.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_icon_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoryGridScreen extends ConsumerStatefulWidget {
  const CategoryGridScreen({
    required this.title,
    required this.categoriesAsync,
    required this.onCategoryTap,
    required this.type,
    this.backRoute = '/',
    this.loadingItemCount = 8,
    super.key,
  });

  final String title;
  final AsyncValue<List<dynamic>> categoriesAsync;
  final void Function(String categoryId) onCategoryTap;
  final String type;
  final String backRoute;
  final int loadingItemCount;

  @override
  ConsumerState<CategoryGridScreen> createState() =>
      _CategoryGridScreenState();
}

class _CategoryGridScreenState extends ConsumerState<CategoryGridScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryFavoritesProvider.notifier).init(widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;

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
                onSearch: (query) {},
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            widget.categoriesAsync.when(
              data: (categories) => _CategoryGrid(
                categories: categories,
                onCategoryTap: widget.onCategoryTap,
                screenWidth: screenWidth,
              ),
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                sliver: SliverGrid.builder(
                  itemCount: widget.loadingItemCount,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    // 🛡️ تم التعديل من 100 إلى 160 لحل مشكلة الفائض في الـ Skeleton
                    mainAxisExtent: 160.0,
                  ),
                  itemBuilder: (context, index) {
                    return const _CategorySkeleton();
                  },
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
  });

  final List<dynamic> categories;
  final void Function(String categoryId) onCategoryTap;
  final double screenWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(categoryFavoritesProvider);

    final sorted = List<dynamic>.from(categories)..sort((a, b) {
      final aFav = favoriteIds.contains(a.id) ? 0 : 1;
      final bFav = favoriteIds.contains(b.id) ? 0 : 1;
      if (aFav != bFav) return aFav - bFav;
      return a.priority.compareTo(b.priority);
    });

    final windowClass = AdaptiveBreakpoints.fromWidth(screenWidth);
    final contentMaxWidth = switch (windowClass) {
      AdaptiveWindowClass.compact => screenWidth,
      AdaptiveWindowClass.medium => 760.0,
      AdaptiveWindowClass.expanded => 980.0,
    };
    final side = math.max((screenWidth - contentMaxWidth) / 2, 16.0);

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

class _CategorySkeleton extends StatefulWidget {
  const _CategorySkeleton();

  @override
  State<_CategorySkeleton> createState() => _CategorySkeletonState();
}

class _CategorySkeletonState extends State<_CategorySkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white12 : Colors.black12;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceHigh
                  : AppColors.parchmentLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.maroon700.withValues(alpha: 0.05),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // 🛡️ حماية إضافية ضد الفائض
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}