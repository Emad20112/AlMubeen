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
    required this.pageNumber,
  });

  final int surahNumber;
  final int verseNumber;
  final String surahName;
  final String verseText;
  final int pageNumber;
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

List<QuranSearchResult> _searchQuranWords({
  required String query,
  required bool exactMatch,
}) {
  final metadataCache = _QuranSearchMetadataCache.instance;
  final highlightQuery = normalise(query).trim();
  final exactCandidates = exactMatch
      ? _exactSearchCandidates(query)
      : const <String>{};
  final seenAyahs = <int>{};
  final results = <QuranSearchResult>[];

  for (final searchQuery in _qcfSearchQueryCandidates(query)) {
    final response = Map<Object?, Object?>.from(searchWords(searchQuery));
    final rawResults = response['result'];
    if (rawResults is! List) {
      continue;
    }

    for (final rawResult in rawResults) {
      if (rawResult is! Map) {
        continue;
      }

      final result = Map<Object?, Object?>.from(rawResult);
      final surahNumber = _asInt(result['suraNumber']);
      final verseNumber = _asInt(result['verseNumber']);
      if (surahNumber == null || verseNumber == null) {
        continue;
      }

      final key = _cacheKey(surahNumber, verseNumber);
      if (!seenAyahs.add(key)) {
        continue;
      }

      final metadata = metadataCache.forAyah(surahNumber, verseNumber);
      if (metadata == null ||
          (exactMatch &&
              !_verseContainsExactMatch(metadata.verseText, exactCandidates))) {
        continue;
      }

      results.add(
        QuranSearchResult(
          surahNumber: metadata.surahNumber,
          verseNumber: metadata.verseNumber,
          surahName: metadata.surahName,
          verseText: metadata.verseText,
          pageNumber: metadata.pageNumber,
          juzNumber: getJuzNumber(surahNumber, verseNumber),
          hizbNumber: getHizbNumber(surahNumber, verseNumber),
          normalizedQuery: highlightQuery,
        ),
      );

      if (results.length >= 50) {
        return List<QuranSearchResult>.unmodifiable(results);
      }
    }
  }

  return List<QuranSearchResult>.unmodifiable(results);
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

  final qcfTextNormalForm = _toQcfTextNormalSearchForm(trimmed);
  add(qcfTextNormalForm);
  add(_replaceWordFinalHehWithTaMarbuta(qcfTextNormalForm));
  add(_replaceWordFinalHehWithTaMarbuta(trimmed));

  yield* candidates;
}

Set<String> _exactSearchCandidates(String query) {
  return {
    for (final candidate in _qcfSearchQueryCandidates(query))
      ..._normalizedWordTokens(candidate),
  }..removeWhere((candidate) => candidate.isEmpty);
}

bool _verseContainsExactMatch(String verseText, Set<String> exactCandidates) {
  if (exactCandidates.isEmpty) {
    return false;
  }

  for (final token in _normalizedWordTokens(verseText)) {
    if (exactCandidates.contains(token) ||
        exactCandidates.contains(_withoutOneLetterArabicPrefix(token))) {
      return true;
    }
  }
  return false;
}

Set<String> _normalizedWordTokens(String input) {
  final normalizedForms = <String>{
    _normalizeExactText(input),
    _toQcfTextNormalSearchForm(input),
  };

  final tokens = <String>{};
  final wordPattern = RegExp(r'[\u0621-\u064A\u066E-\u06D3]+');
  for (final normalizedForm in normalizedForms) {
    for (final match in wordPattern.allMatches(normalizedForm)) {
      tokens.add(match.group(0) ?? '');
    }
  }

  return tokens;
}

String _normalizeExactText(String input) {
  return normalise(input)
      .replaceAll('ٱ', 'ا')
      .replaceAll(
        RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      )
      .toLowerCase();
}

String _withoutOneLetterArabicPrefix(String token) {
  if (token.length < 3) {
    return token;
  }

  const prefixes = {'و', 'ف', 'ب', 'ك', 'ل'};
  if (prefixes.contains(token.substring(0, 1))) {
    return token.substring(1);
  }
  return token;
}

String _toQcfTextNormalSearchForm(String input) {
  return removeDiacritics(input)
      .replaceAll('ٱ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ى', 'ي')
      .replaceAll('ـ', '')
      .toLowerCase();
}

String _replaceWordFinalHehWithTaMarbuta(String input) {
  return input.replaceAllMapped(RegExp(r'ه(?=\s|$)'), (match) => 'ة');
}

int _cacheKey(int surahNumber, int verseNumber) =>
    (surahNumber * 1000) + verseNumber;

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
