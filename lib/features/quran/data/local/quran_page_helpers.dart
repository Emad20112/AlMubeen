import 'package:flutter/foundation.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:qcf_quran/qcf_quran.dart';

/// Helper functions for Quran page-related calculations that are not
/// directly available in the qcf_quran package.

// ---------------------------------------------------------------------------
// Lightweight Arabic-digit converter (avoids repeated string splits/maps)
// ---------------------------------------------------------------------------
const _kArabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Converts an integer to its Arabic-digit string representation.
/// E.g. 123 → '١٢٣'
String convertToArabicDigits(int number) {
  if (number == 0) return _kArabicDigits[0];
  final buf = StringBuffer();
  final s = number.toString();
  for (var i = 0; i < s.length; i++) {
    buf.write(_kArabicDigits[s.codeUnitAt(i) - 0x30]);
  }
  return buf.toString();
}

// ---------------------------------------------------------------------------
// Pre-computed page metadata cache (built once, O(1) lookup thereafter)
// ---------------------------------------------------------------------------

/// Holds pre-computed metadata for a single Mushaf page.
@immutable
class PageMetadata {
  const PageMetadata({
    required this.surahNameArabic,
    required this.juzHizbText,
  });

  /// Placeholder used while the list is being populated.
  const PageMetadata._empty()
      : surahNameArabic = '',
        juzHizbText = '';

  /// The Arabic name of the primary surah on this page.
  final String surahNameArabic;

  /// Formatted "الجزء … الحزب …" string for the page header.
  final String juzHizbText;
}

/// Lazily-initialized, process-wide cache for page metadata.
///
/// Metadata is computed on-demand per page instead of all 604 at once,
/// preventing main-thread blocking on first access.
class QuranPageMetadataCache {
  QuranPageMetadataCache._();

  static final QuranPageMetadataCache instance = QuranPageMetadataCache._();

  final Map<int, PageMetadata> _cache = {};

  /// Returns the cached metadata for [pageNumber] (1-based, clamped).
  PageMetadata forPage(int pageNumber) {
    final idx = (pageNumber - 1).clamp(0, totalPagesCount - 1);
    return _cache.putIfAbsent(idx, () => _buildOne(idx + 1));
  }

  /// Builds metadata for a single page (~microseconds).
  static PageMetadata _buildOne(int page) {
    final surah = getSurahNumberFromPage(page);
    final surahName = getSurahNameArabic(surah);

    final first = getFirstAyahOnPage(page);
    final juz = getJuzNumber(first.surah, first.ayah);
    final quarter = getQuarterNumber(first.surah, first.ayah);
    final hizb = ((quarter - 1) ~/ 4) + 1;

    return PageMetadata(
      surahNameArabic: surahName,
      juzHizbText:
          'الجزء ${convertToArabicDigits(juz)}  الحزب ${convertToArabicDigits(hizb)}',
    );
  }
}

// ---------------------------------------------------------------------------
// Pre-computed surah metadata (name, page, verse count) for search & lists
// ---------------------------------------------------------------------------

/// Holds pre-computed metadata for a single surah, useful for search and picker
/// screens where we iterate all 114 surahs on every keystroke.
@immutable
class SurahMetadata {
  const SurahMetadata({
    required this.number,
    required this.nameArabic,
    required this.firstPage,
    required this.verseCount,
  });

  final int number;
  final String nameArabic;
  final int firstPage;
  final int verseCount;
}

/// Lazily-built list of all 114 surahs. Construction is ~1 ms.
class QuranSurahMetadataCache {
  QuranSurahMetadataCache._();

  static final QuranSurahMetadataCache instance = QuranSurahMetadataCache._();

  late final List<SurahMetadata> _surahs = _buildAll();

  List<SurahMetadata> get all => _surahs;

  static List<SurahMetadata> _buildAll() {
    return List<SurahMetadata>.generate(totalSurahCount, (i) {
      final num = i + 1;
      return SurahMetadata(
        number: num,
        nameArabic: getSurahNameArabic(num),
        firstPage: getPageNumber(num, 1),
        verseCount: getVerseCount(num),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Raw helpers (still used by the cache builder and by AudioController etc.)
// ---------------------------------------------------------------------------

/// Returns the surah number for a given page number.
/// If the page contains multiple surahs, returns the first one.
int getSurahNumberFromPage(int pageNumber) {
  try {
    final pageData = getPageData(pageNumber);
    if (pageData.isEmpty) return 1;

    final first = pageData.first;
    if (first is Map && first.containsKey('surah')) {
      final v = first['surah'];
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 1;
    }
  } catch (e, st) {
    debugPrint('getSurahNumberFromPage failed for page=$pageNumber: $e\n$st');
  }

  return 1;
}

/// Returns the first ayah reference on [pageNumber].
AyahRef getFirstAyahOnPage(int pageNumber) {
  try {
    final data = getPageData(pageNumber);
    if (data.isNotEmpty && data.first is Map) {
      final first = data.first as Map;
      final surah = first['surah'];
      final start = first['start'];
      if (surah is int && start is int) {
        return AyahRef.fromSurahAyah(surah: surah, ayah: start);
      }
    }
  } catch (e, st) {
    debugPrint('getFirstAyahOnPage failed for page=$pageNumber: $e\n$st');
  }

  return AyahRef.fromSurahAyah(
    surah: getSurahNumberFromPage(pageNumber),
    ayah: 1,
  );
}

/// Returns the Rub' al-Hizb (quarter) number (1-240) for a given surah and verse.
int getQuarterNumber(int surahNumber, int verseNumber) {
  final juzNum = getJuzNumber(surahNumber, verseNumber);
  if (juzNum < 1) return 1;
  return ((juzNum - 1) * 8) + 1;
}
