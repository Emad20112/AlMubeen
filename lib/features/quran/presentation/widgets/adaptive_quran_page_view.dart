import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
// ignore: implementation_imports
import 'package:qcf_quran_plus/src/services/get_page.dart';

class AdaptiveQuranPageView extends StatefulWidget {
  const AdaptiveQuranPageView({
    required this.pageController,
    required this.highlightsListenable,
    required this.isTajweedListenable,
    required this.onPageChanged,
    required this.onLongPress,
    super.key,
  });

  final PageController pageController;
  final ValueListenable<List<HighlightVerse>> highlightsListenable;
  final ValueListenable<bool> isTajweedListenable;
  final ValueChanged<int> onPageChanged;
  final void Function(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details,
  )
  onLongPress;

  @override
  State<AdaptiveQuranPageView> createState() => _AdaptiveQuranPageViewState();
}

class _AdaptiveQuranPageViewState extends State<AdaptiveQuranPageView> {
  late final List<QuranPage> _pages = _loadPages();
  final Map<int, Future<void>> _fontFutures = {};

  static List<QuranPage> _loadPages() {
    final processor = GetPage()..getQuran(totalPagesCount);
    return List<QuranPage>.unmodifiable(processor.staticPages);
  }

  Future<void> _fontFutureFor(int pageNumber) {
    return _fontFutures.putIfAbsent(pageNumber, () {
      if (QcfFontLoader.isFontLoaded(pageNumber)) {
        return Future<void>.value();
      }

      return QcfFontLoader.ensureFontLoaded(pageNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        final windowClass = AdaptiveBreakpoints.fromWidth(availableWidth);
        final pageMaxWidth = switch (windowClass) {
          AdaptiveWindowClass.compact => availableWidth,
          AdaptiveWindowClass.medium => 720.0,
          AdaptiveWindowClass.expanded => 820.0,
        };
        final effectivePageWidth = math.min(availableWidth, pageMaxWidth);
        final qcfMediaQuery = MediaQuery.of(
          context,
        ).copyWith(size: Size(effectivePageWidth, availableHeight));

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: pageMaxWidth),
            child: MediaQuery(
              data: qcfMediaQuery,
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.isTajweedListenable,
                builder: (context, isTajweed, child) {
                  return PageView.builder(
                    controller: widget.pageController,
                    itemCount: _pages.length,
                    allowImplicitScrolling: false,
                    onPageChanged: (index) {
                      widget.onPageChanged(index + 1);
                    },
                    itemBuilder: (context, index) {
                      final pageNumber = index + 1;

                      return FutureBuilder<void>(
                        future: _fontFutureFor(pageNumber),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return _QuranPageLoading(pageNumber: pageNumber);
                          }

                          if (snapshot.hasError) {
                            return _QuranPageLoadError(
                              pageNumber: pageNumber,
                              onRetry: () {
                                setState(() {
                                  _fontFutures.remove(pageNumber);
                                });
                              },
                            );
                          }

                          return ValueListenableBuilder<List<HighlightVerse>>(
                            valueListenable: widget.highlightsListenable,
                            builder: (context, highlights, child) {
                              final pageHighlights = highlights
                                  .where(
                                    (highlight) => highlight.page == pageNumber,
                                  )
                                  .toList(growable: false);

                              return QuranSinglePageWidget(
                                key: ValueKey('quran_page_$pageNumber'),
                                page: _pages[index],
                                pageIndex: pageNumber,
                                highlights: pageHighlights,
                                onLongPress: widget.onLongPress,
                                pageController: widget.pageController,
                                isDark: isDark,
                                isTajweed: isTajweed,
                                ayahStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuranPageLoading extends StatelessWidget {
  const _QuranPageLoading({required this.pageNumber});

  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator.adaptive(),
              const SizedBox(height: 16),
              Text(
                'جاري تجهيز صفحة $pageNumber...',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuranPageLoadError extends StatelessWidget {
  const _QuranPageLoadError({required this.pageNumber, required this.onRetry});

  final int pageNumber;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.maroon700,
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                'تعذر تجهيز صفحة $pageNumber',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'حاول إعادة تحميل خط الصفحة.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'إعادة المحاولة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
