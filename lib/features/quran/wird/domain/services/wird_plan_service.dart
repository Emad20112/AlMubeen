class WirdReadingRange {
  const WirdReadingRange({required this.startPage, required this.endPage})
    : pageCount = endPage - startPage + 1;

  final int startPage;
  final int endPage;
  final int pageCount;
}

class WirdPlanService {
  static const int _defaultMinPage = 1;
  static const int _defaultMaxPage = 604;

  static void validateRange({
    required int startPage,
    required int endPage,
    required int pagesPerDay,
    int minPage = _defaultMinPage,
    int maxPage = _defaultMaxPage,
  }) {
    if (startPage < minPage || startPage > maxPage) {
      throw ArgumentError.value(
        startPage,
        'startPage',
        'must be between $minPage and $maxPage',
      );
    }

    if (endPage < minPage || endPage > maxPage) {
      throw ArgumentError.value(
        endPage,
        'endPage',
        'must be between $minPage and $maxPage',
      );
    }

    if (startPage > endPage) {
      throw ArgumentError.value(startPage, 'startPage', 'must be <= endPage');
    }

    if (pagesPerDay <= 0) {
      throw ArgumentError.value(
        pagesPerDay,
        'pagesPerDay',
        'must be greater than zero',
      );
    }
  }

  static List<WirdReadingRange> generateDailyRanges({
    required int startPage,
    required int endPage,
    required int pagesPerDay,
    int minPage = _defaultMinPage,
    int maxPage = _defaultMaxPage,
  }) {
    validateRange(
      startPage: startPage,
      endPage: endPage,
      pagesPerDay: pagesPerDay,
      minPage: minPage,
      maxPage: maxPage,
    );

    final ranges = <WirdReadingRange>[];
    var cursor = startPage;

    while (cursor <= endPage) {
      final nextEnd = (cursor + pagesPerDay - 1) > endPage
          ? endPage
          : (cursor + pagesPerDay - 1);
      ranges.add(WirdReadingRange(startPage: cursor, endPage: nextEnd));
      cursor = nextEnd + 1;
    }

    return ranges;
  }

  static WirdReadingRange resolveRangeForDay({
    required int startPage,
    required int endPage,
    required int pagesPerDay,
    required int dayIndex,
    int minPage = _defaultMinPage,
    int maxPage = _defaultMaxPage,
  }) {
    validateRange(
      startPage: startPage,
      endPage: endPage,
      pagesPerDay: pagesPerDay,
      minPage: minPage,
      maxPage: maxPage,
    );

    final absoluteStart = startPage + (dayIndex * pagesPerDay);
    if (absoluteStart > endPage) {
      throw RangeError.index(
        dayIndex,
        List<int>.empty(growable: true),
        'dayIndex exceeds the total number of planned ranges',
      );
    }

    final rangeEnd = (absoluteStart + pagesPerDay - 1) > endPage
        ? endPage
        : (absoluteStart + pagesPerDay - 1);

    return WirdReadingRange(startPage: absoluteStart, endPage: rangeEnd);
  }

  static int calculatePageCount({
    required int startPage,
    required int endPage,
  }) {
    if (startPage > endPage) {
      throw ArgumentError.value(
        startPage,
        'startPage',
        'must be less than or equal to endPage',
      );
    }

    return endPage - startPage + 1;
  }
}
