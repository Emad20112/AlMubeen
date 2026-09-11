import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:qcf_quran/qcf_quran.dart';

enum WirdAmountType { quarter, halfHizb, hizb, juz, juzAndHalf, twoJuzs }

class WirdBoundaries {
  const WirdBoundaries({required this.startPage, required this.endPage});

  final int startPage;
  final int endPage;
}

class WirdCalculator {
  static final List<int> _quarterStartPages = _buildStartPages(
    (AyahRef ayahRef) => getQuarterNumber(ayahRef.surah, ayahRef.ayah),
  );

  static final List<int> _juzStartPages = _buildStartPages(
    (AyahRef ayahRef) => getJuzNumber(ayahRef.surah, ayahRef.ayah),
  );

  static final List<int> _halfHizbStartPages = _partitionPages(
    _quarterStartPages,
    2,
  );
  static final List<int> _hizbPageStartPages = _partitionPages(
    _quarterStartPages,
    4,
  );
  static final List<int> _juzAndHalfStartPages = List<int>.generate(
    20,
    (index) => _quarterStartPages[index * 6],
  );
  static final List<int> _twoJuzStartPages = List<int>.generate(
    15,
    (index) => _juzStartPages[index * 2],
  );

  static const int _totalPages = totalPagesCount;

  static WirdBoundaries calculateCurrentWird(
    WirdAmountType type,
    int multiplier,
    int completedDaysCount,
  ) {
    final normalizedMultiplier = multiplier.clamp(1, _totalPages);
    final boundaries = _boundariesForType(type);
    if (boundaries.isEmpty) {
      return const WirdBoundaries(startPage: 1, endPage: totalPagesCount);
    }

    final selectedIndex = completedDaysCount % boundaries.length;
    final nextIndex =
        (selectedIndex + normalizedMultiplier) % boundaries.length;
    final startPage = boundaries[selectedIndex];
    final endPage = nextIndex == selectedIndex
        ? _totalPages
        : (boundaries[nextIndex] - 1).clamp(startPage, _totalPages);

    return WirdBoundaries(startPage: startPage, endPage: endPage);
  }

  static List<int> _boundariesForType(WirdAmountType type) {
    switch (type) {
      case WirdAmountType.quarter:
        return _quarterStartPages;
      case WirdAmountType.halfHizb:
        return _halfHizbStartPages;
      case WirdAmountType.hizb:
        return _hizbPageStartPages;
      case WirdAmountType.juz:
        return _juzStartPages;
      case WirdAmountType.juzAndHalf:
        return _juzAndHalfStartPages;
      case WirdAmountType.twoJuzs:
        return _twoJuzStartPages;
    }
  }

  static List<int> _buildStartPages(
    int Function(AyahRef ayahRef) groupExtractor,
  ) {
    final pages = <int>[];
    int? lastGroupValue;

    for (var page = 1; page <= totalPagesCount; page++) {
      final firstAyah = getFirstAyahOnPage(page);
      final groupValue = groupExtractor(firstAyah);
      if (groupValue != lastGroupValue) {
        pages.add(page);
        lastGroupValue = groupValue;
      }
    }

    return List<int>.unmodifiable(pages);
  }

  static List<int> _partitionPages(List<int> source, int step) {
    if (step <= 1) return List<int>.unmodifiable(source);
    return List<int>.unmodifiable(
      List<int>.generate(source.length ~/ step, (index) {
        return source[index * step];
      }),
    );
  }
}
