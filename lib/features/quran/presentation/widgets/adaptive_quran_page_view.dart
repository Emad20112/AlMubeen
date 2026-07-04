import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
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
                builder: (context, isTajweed, _) {
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
                            builder: (context, highlights, _) {
                              final pageHighlights = highlights
                                  .where(
                                    (highlight) => highlight.page == pageNumber,
                                  )
                                  .toList(growable: false);

                              return _QuranPageWithMetadata(
                                key: ValueKey('quran_page_$pageNumber'),
                                page: _pages[index],
                                pageNumber: pageNumber,
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

class _QuranPageWithMetadata extends StatelessWidget {
  const _QuranPageWithMetadata({
    super.key,
    required this.page,
    required this.pageNumber,
    required this.highlights,
    required this.onLongPress,
    required this.pageController,
    required this.isDark,
    required this.isTajweed,
    required this.ayahStyle,
  });

  final QuranPage page;
  final int pageNumber;
  final List<HighlightVerse> highlights;
  final void Function(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details,
  )
  onLongPress;
  final PageController pageController;
  final bool isDark;
  final bool isTajweed;
  final TextStyle ayahStyle;

  @override
  Widget build(BuildContext context) {
    final firstAyah = getFirstAyahOnPage(pageNumber);
    final surahNumber = firstAyah.surah;
    final juzNumber = math.max(1, getJuzNumber(surahNumber, firstAyah.ayah));
    final quarterNumber = getQuarterNumber(surahNumber, firstAyah.ayah);
    final hizbNumber = ((quarterNumber - 1) ~/ 4) + 1;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final borderColor = AppColors.maroon800.withValues(
      alpha: isDark ? 0.22 : 0.14,
    );
    final surfaceColor = isDark ? AppColors.darkSurfaceHigh : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _PageMetadataSizing.pageWidth(context);
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        final effectivePageHeight = _PageMetadataSizing.pageHeight(
          availableHeight,
        );

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                const SizedBox(height: 6),
                SizedBox(
                  height: _PageMetadataSizing.topBlockHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              getSurahNameArabic(surahNumber),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: availableWidth),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: Size(availableWidth, effectivePageHeight),
                        ),
                        child: QuranSinglePageWidget(
                          key: ValueKey('quran_page_$pageNumber'),
                          page: page,
                          pageIndex: pageNumber,
                          highlights: highlights,
                          onLongPress: onLongPress,
                          pageController: pageController,
                          isDark: isDark,
                          isTajweed: isTajweed,
                          ayahStyle: ayahStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: _PageMetadataSizing.bottomBlockHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'الجزء ${_toArabicDigits(juzNumber)}، الحزب ${_toArabicDigits(hizbNumber)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: mutedColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceColor.withValues(
                                alpha: isDark ? 0.9 : 0.96,
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.08 : 0.04,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _toArabicDigits(pageNumber),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageMetadataSizing {
  static const double topBlockHeight = 48;
  static const double bottomBlockHeight = 30;

  static double pageWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double pageHeight(double totalHeight) {
    return math.max(0.0, totalHeight - topBlockHeight - bottomBlockHeight - 16);
  }
}

String _toArabicDigits(int number) {
  const digits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  return number
      .toString()
      .split('')
      .map((digit) => digits[digit] ?? digit)
      .join();
}
