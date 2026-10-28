import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran/qcf_quran.dart';
// ignore: implementation_imports
import 'package:qcf_quran/src/data/quran_text.dart' as qcf_text;

typedef QuranSearchRequest = ({String query, bool exactMatch});

final quranSearchResultsProvider = Provider.autoDispose
    .family<List<QuranSearchResult>, QuranSearchRequest>((ref, request) {
      final trimmedQuery = request.query.trim();
      if (trimmedQuery.isEmpty) {
        return const <QuranSearchResult>[];
      }

      return _searchQuranWords(
        query: trimmedQuery,
        exactMatch: request.exactMatch,
      );
    });

void warmUpQuranSearchMetadata() {
  _QuranSearchMetadataCache.instance.warmUp();
}

/// نتيجة البحث القرآني.
@immutable
class QuranSearchResult {
  const QuranSearchResult({
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
    required this.verseText,
    required this.pageNumber,
    required this.juzNumber,
    required this.hizbNumber,
    required this.normalizedQuery,
  });

  final int surahNumber;
  final int verseNumber;
  final String surahName;
  final String verseText;
  final int pageNumber;
  final int juzNumber;
  final int hizbNumber;
  final String normalizedQuery;

  AyahRef get ayahRef =>
      AyahRef(surah: surahNumber, ayah: verseNumber, page: pageNumber);
}

@immutable
class _VerseSearchMetadata {
  const _VerseSearchMetadata({
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
    required this.verseText,
    required this.normalizedText,
    required this.pageNumber,
  });

  final int surahNumber;
  final int verseNumber;
  final String surahName;
  final String verseText;
  final String normalizedText;
  final int pageNumber;
}

/// مطبّع النصوص العربية والقرآنية فائق الذكاء والأداء للبحث.
abstract final class QuranSearchNormalizer {
  const QuranSearchNormalizer._();

  /// تطبيع شامل وموحد لأي نص قرآني أو استعلام بحث.
  static String normalize(String input) {
    if (input.isEmpty) return '';

    return normalise(input)
        // إزالة الحركات وعلامات الضبط القرآني والوقف والتنوين
        .replaceAll(
          RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
          '',
        )
        // إزالة التطويل (الكشيدة)
        .replaceAll('ـ', '')
        // توحيد جميع أشكال الألف والهمزات
        .replaceAll('ٱ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        // توحيد الياء والألف المقصورة
        .replaceAll('ى', 'ي')
        // توحيد الهمزات على النبرة والسطر
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و')
        // توحيد التاء المربوطة والهاء
        .replaceAll('ة', 'ه')
        .trim()
        .toLowerCase();
  }

  /// إزالة سوابق الجر والعطف الشائعة من الكلمة العربية.
  static String stripCommonPrefixes(String word) {
    if (word.length <= 3) return word;

    const compoundPrefixes = ['بال', 'فال', 'وال', 'كال', 'ولل'];
    for (final prefix in compoundPrefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length + 2) {
        return word.substring(prefix.length);
      }
    }

    if (word.startsWith('ال') && word.length > 4) {
      return word.substring(2);
    }

    const singlePrefixes = ['و', 'ف', 'ب', 'ك', 'ل'];
    for (final prefix in singlePrefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length + 2) {
        return word.substring(prefix.length);
      }
    }

    return word;
  }
}

class _QuranSearchMetadataCache {
  _QuranSearchMetadataCache._();

  static final _QuranSearchMetadataCache instance =
      _QuranSearchMetadataCache._();

  late final Map<int, _VerseSearchMetadata> _verseMetadata =
      _buildVerseMetadata();

  void warmUp() {
    _verseMetadata.length;
  }

  _VerseSearchMetadata? forAyah(int surahNumber, int verseNumber) {
    return _verseMetadata[_cacheKey(surahNumber, verseNumber)];
  }

  Iterable<_VerseSearchMetadata> get allVerses => _verseMetadata.values;

  Map<int, _VerseSearchMetadata> _buildVerseMetadata() {
    final pageByAyah = _buildPageIndex();
    final surahNames = <int, String>{};
    final metadata = <int, _VerseSearchMetadata>{};

    for (final rawVerse in qcf_text.quranText) {
      if (rawVerse is! Map) {
        continue;
      }

      final surahNumber = _asInt(rawVerse['surah_number']);
      final verseNumber = _asInt(rawVerse['verse_number']);
      final verseText = rawVerse['content']?.toString();
      if (surahNumber == null || verseNumber == null || verseText == null) {
        continue;
      }

      final key = _cacheKey(surahNumber, verseNumber);
      metadata[key] = _VerseSearchMetadata(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        surahName: surahNames.putIfAbsent(
          surahNumber,
          () => getSurahNameArabic(surahNumber),
        ),
        verseText: verseText,
        normalizedText: QuranSearchNormalizer.normalize(verseText),
        pageNumber: pageByAyah[key] ?? getPageNumber(surahNumber, verseNumber),
      );
    }

    return Map<int, _VerseSearchMetadata>.unmodifiable(metadata);
  }

  Map<int, int> _buildPageIndex() {
    final pageByAyah = <int, int>{};
    for (var page = 1; page <= totalPagesCount; page++) {
      final pageSegments = getPageData(page);
      for (final rawSegment in pageSegments) {
        if (rawSegment is! Map) {
          continue;
        }

        final surahNumber = _asInt(rawSegment['surah']);
        final startAyah = _asInt(rawSegment['start']);
        final endAyah = _asInt(rawSegment['end']);
        if (surahNumber == null || startAyah == null || endAyah == null) {
          continue;
        }

        for (var ayah = startAyah; ayah <= endAyah; ayah++) {
          pageByAyah[_cacheKey(surahNumber, ayah)] = page;
        }
      }
    }

    return pageByAyah;
  }
}

/// دالة البحث الذكي الهجين: تجمع بين البحث بالعبارات المتعددة في الكاش
/// المطبّع والبحث الموضعي عن الكلمات.
List<QuranSearchResult> _searchQuranWords({
  required String query,
  required bool exactMatch,
}) {
  final metadataCache = _QuranSearchMetadataCache.instance;
  final normalizedQuery = QuranSearchNormalizer.normalize(query);
  if (normalizedQuery.isEmpty) return const [];

  final queryWords = normalizedQuery
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  final seenAyahs = <int>{};
  final exactPhraseResults = <QuranSearchResult>[];
  final allWordsResults = <QuranSearchResult>[];

  // 1. فحص مباشر فائق السرعة عبر الكاش المطبّع في الذاكرة (يدعم العبارات والكلمات المتعددة)
  for (final metadata in metadataCache.allVerses) {
    final text = metadata.normalizedText;

    if (text.contains(normalizedQuery)) {
      final key = _cacheKey(metadata.surahNumber, metadata.verseNumber);
      if (seenAyahs.add(key)) {
        exactPhraseResults.add(_buildResult(metadata, normalizedQuery));
        if (exactPhraseResults.length >= 50) {
          return List<QuranSearchResult>.unmodifiable(exactPhraseResults);
        }
      }
    } else if (!exactMatch && queryWords.length > 1) {
      // فحص اشتمال الآية على جميع كلمات الاستعلام
      final containsAllWords = queryWords.every((word) {
        if (text.contains(word)) return true;
        final stripped = QuranSearchNormalizer.stripCommonPrefixes(word);
        return stripped != word && text.contains(stripped);
      });

      if (containsAllWords) {
        final key = _cacheKey(metadata.surahNumber, metadata.verseNumber);
        if (seenAyahs.add(key)) {
          allWordsResults.add(_buildResult(metadata, normalizedQuery));
        }
      }
    }
  }

  // 2. دمج نتائج مطابقة الكلمات المنفردة عبر qcf_quran
  if (exactPhraseResults.length + allWordsResults.length < 50) {
    for (final candidate in _qcfSearchQueryCandidates(query)) {
      final response = Map<Object?, Object?>.from(searchWords(candidate));
      final rawResults = response['result'];
      if (rawResults is! List) continue;

      for (final rawResult in rawResults) {
        if (rawResult is! Map) continue;

        final result = Map<Object?, Object?>.from(rawResult);
        final surahNumber = _asInt(result['suraNumber']);
        final verseNumber = _asInt(result['verseNumber']);
        if (surahNumber == null || verseNumber == null) continue;

        final key = _cacheKey(surahNumber, verseNumber);
        if (!seenAyahs.add(key)) continue;

        final metadata = metadataCache.forAyah(surahNumber, verseNumber);
        if (metadata != null) {
          allWordsResults.add(_buildResult(metadata, normalizedQuery));
          if (exactPhraseResults.length + allWordsResults.length >= 50) {
            break;
          }
        }
      }
      if (exactPhraseResults.length + allWordsResults.length >= 50) break;
    }
  }

  final combined = [...exactPhraseResults, ...allWordsResults];
  return List<QuranSearchResult>.unmodifiable(combined.take(50));
}

QuranSearchResult _buildResult(_VerseSearchMetadata metadata, String query) {
  return QuranSearchResult(
    surahNumber: metadata.surahNumber,
    verseNumber: metadata.verseNumber,
    surahName: metadata.surahName,
    verseText: metadata.verseText,
    pageNumber: metadata.pageNumber,
    juzNumber: getJuzNumber(metadata.surahNumber, metadata.verseNumber),
    hizbNumber: getHizbNumber(metadata.surahNumber, metadata.verseNumber),
    normalizedQuery: query,
  );
}

Iterable<String> _qcfSearchQueryCandidates(String query) sync* {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return;

  final candidates = <String>{};
  void add(String value) {
    final candidate = value.trim();
    if (candidate.isNotEmpty) {
      candidates.add(candidate);
    }
  }

  add(trimmed);
  add(removeDiacritics(trimmed));
  add(normalise(trimmed));

  final normalized = QuranSearchNormalizer.normalize(trimmed);
  add(normalized);

  yield* candidates;
}

int _cacheKey(int surahNumber, int verseNumber) =>
    (surahNumber * 1000) + verseNumber;

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
