import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/widgets/app_loading_view.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_feature_grid.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_header.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_reading_continuation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const double _minHorizontalPadding = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appUserPreferencesProvider);

    return preferencesAsync.when(
      loading: () => const AppLoadingView(
        title: 'نُجهّز الصفحة الرئيسية',
        message: 'نحمّل التفضيلات الأساسية ونستعد لعرض آخر موضع لك.',
        progress: 0.72,
      ),
      error: (error, stackTrace) {
        debugPrint('HomePage: failed to load preferences: $error\n$stackTrace');
        return const AppLoadingView(
          title: 'تعذر تحميل التفضيلات',
          message: 'سنستخدم القيم الافتراضية مؤقتًا حتى يتم إصلاح المشكلة.',
          progress: 0.35,
        );
      },
      data: (preferences) {
        final progressAsync = ref.watch(quranReadingProgressEntryProvider);
        if (progressAsync.isLoading) {
          return const AppLoadingView(
            title: 'نراجع آخر موضع',
            message: 'نستعيد بيانات المتابعة الهادئة من الجهاز.',
            progress: 0.82,
          );
        }

        final progressEntry = progressAsync.maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );

        return _HomeShell(progressEntry: progressEntry);
      },
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

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.progressEntry});

  final QuranReadingProgressEntry? progressEntry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeHeader()),
            SliverToBoxAdapter(
              child: HomeReadingContinuationCard(progressEntry: progressEntry),
            ),
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final contentMaxWidth = HomePage._contentMaxWidthFor(
                  constraints.crossAxisExtent,
                );
                final side = math.max(
                  (constraints.crossAxisExtent - contentMaxWidth) / 2,
                  HomePage._minHorizontalPadding,
                );

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(side, 18, side, 28),
                    child: const HomeFeatureGrid(),
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
