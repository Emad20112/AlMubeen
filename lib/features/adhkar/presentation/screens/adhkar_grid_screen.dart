import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/widgets/adhkar_grid_card.dart';
import 'package:al_mubeen/core/widgets/custom_bottom_nav.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/adhkar/data/adhkar_providers.dart';
import 'package:al_mubeen/features/adhkar/presentation/widgets/adhkar_icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdhkarGridScreen extends ConsumerWidget {
  const AdhkarGridScreen({super.key});

  static const String routePath = '/adhkar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(adhkarCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 2,
        onSelected: (index) {
          if (index == 4) {
            context.go('/');
          } else if (index == 3) {
            // go to quran
          }
        },
        items: const [
          CustomBottomNavItem(icon: Icons.more_horiz_outlined, label: 'المزيد'),
          CustomBottomNavItem(icon: Icons.bookmark_border, label: 'المفضلة'),
          CustomBottomNavItem(
            icon: FlutterIslamicIcons.tasbih,
            label: 'الأذكار',
          ),
          CustomBottomNavItem(
            icon: FlutterIslamicIcons.quran2,
            label: 'القرآن',
          ),
          CustomBottomNavItem(icon: Icons.home_outlined, label: 'الرئيسية'),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: IslamicHeader(
                title: 'الأذكار',
                subtitle: 'ذكر الله تعالى يطمئن القلب',
                leading: IconButton(
                  tooltip: 'رجوع',
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
                trailing: const Icon(FlutterIslamicIcons.quran2),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              sliver: SliverToBoxAdapter(child: _QuickActionsRow()),
            ),
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final windowClass = AdaptiveBreakpoints.fromWidth(width);
                final contentMaxWidth = switch (windowClass) {
                  AdaptiveWindowClass.compact => width,
                  AdaptiveWindowClass.medium => 760.0,
                  AdaptiveWindowClass.expanded => 980.0,
                };
                final side = math.max((width - contentMaxWidth) / 2, 16.0);
                final gridWidth = math.max(width - side * 2, 0.0);
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                const crossAxisCount = 2; // Always 2 columns for adhkar grid
                const spacing = 16.0;
                final cardWidth = (gridWidth - spacing) / 2;
                final extent = math
                    .max(
                      cardWidth * 1.05,
                      180 + (math.max(textScale, 1) - 1) * 46,
                    )
                    .toDouble();

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(side, 10, side, 24),
                  sliver: SliverGrid.builder(
                    itemCount: categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      mainAxisExtent: extent,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];

                      return AdhkarGridCard(
                        icon: AdhkarIconMapper.iconFor(category.iconKey),
                        title: category.title,
                        subtitle: category.subtitle,
                        count: category.count,
                        onTap: () => context.push('/adhkar/${category.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.parchmentLight;
    final shadowColor = AppColors.maroon900.withValues(
      alpha: isDark ? 0.28 : 0.08,
    );

    const actions = [
      (Icons.search_outlined, 'بحث'),
      (FlutterIslamicIcons.tasbih, 'التسبيح'),
      (Icons.done_all_outlined, 'تم قراءته'),
      (Icons.bookmark_border, 'المفضلة'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final action in actions)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.maroon700.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action.$1, size: 24, color: AppColors.maroon800),
                          const SizedBox(height: 6),
                          Text(
                            action.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.maroon800,
                                ),
                          ),
                        ],
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
