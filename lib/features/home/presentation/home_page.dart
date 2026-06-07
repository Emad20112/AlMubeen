import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_bottom_navigation.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_feature_grid.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_header.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _minHorizontalPadding = 16;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: HomeHeader()),
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final contentMaxWidth = _contentMaxWidthFor(
                      constraints.crossAxisExtent,
                    );
                    final side = math.max(
                      (constraints.crossAxisExtent - contentMaxWidth) / 2,
                      _minHorizontalPadding,
                    );

                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(side, 16, side, 112),
                        child: const HomeFeatureGrid(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: HomeBottomNavigation(),
          ),
        ],
      ),
    );
  }

  static double _contentMaxWidthFor(double width) {
    return switch (AdaptiveBreakpoints.fromWidth(width)) {
      AdaptiveWindowClass.compact => width,
      AdaptiveWindowClass.medium => 760,
      AdaptiveWindowClass.expanded => 980,
    };
  }
}
