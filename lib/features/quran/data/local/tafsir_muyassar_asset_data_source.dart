import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/domain/tafsir_defaults.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TafsirMuyassarAssetDataSource {
  TafsirMuyassarAssetDataSource();

  Map<int, List<TafsirText>>? _cachedChapterTexts;
  Map<int, List<_MuyassarRecord>>? _cachedChapterRecords;
  Future<Map<int, List<TafsirText>>>? _loadingFuture;
  Future<Map<int, List<_MuyassarRecord>>>? _recordsLoadingFuture;

  Future<Map<int, List<TafsirText>>> loadChapterTextsMap() async {
    final cached = _cachedChapterTexts;
    if (cached != null) {
      return cached;
    }

    final loadingFuture = _loadingFuture;
    if (loadingFuture != null) {
      return loadingFuture;
    }

    final completer = Completer<Map<int, List<TafsirText>>>();
    _loadingFuture = completer.future;

    try {
      final recordsByChapter = await _loadChapterRecordsMap();
      final chapterTexts = <int, List<TafsirText>>{};

      for (final entry in recordsByChapter.entries) {
        chapterTexts[entry.key] = _chapterTextsFromRecords(
          chapterId: entry.key,
          records: entry.value,
        );
      }

      _cachedChapterTexts = chapterTexts;
      completer.complete(chapterTexts);
    } catch (error, stackTrace) {
      debugPrint(
        'TafsirMuyassarAssetDataSource.loadChapterTextsMap failed: $error',
      );
      debugPrint('$stackTrace');
      completer.completeError(error, stackTrace);
    } finally {
      _loadingFuture = null;
    }

    return completer.future;
  }

  Future<Map<int, List<TafsirText>>> getAllChapterTextsMap() async {
    final cached = _cachedChapterTexts;
    if (cached != null) {
      return cached;
    }

    final recordsByChapter = await _loadChapterRecordsMap();
    final chapterTexts = <int, List<TafsirText>>{};

    for (final entry in recordsByChapter.entries) {
      chapterTexts[entry.key] = _chapterTextsFromRecords(
        chapterId: entry.key,
        records: entry.value,
      );
    }

    _cachedChapterTexts = chapterTexts;
    return chapterTexts;
  }

  Future<List<int>> getAvailableChapterNumbers() async {
    final recordsByChapter = await _loadChapterRecordsMap();
    return recordsByChapter.keys.toList()..sort();
  }

  Future<List<TafsirText>> getChapterTexts(int chapterNumber) async {
    final cached = _cachedChapterTexts?[chapterNumber];
    if (cached != null) {
      return cached;
    }

    final recordsByChapter = await _loadChapterRecordsMap();
    final records = recordsByChapter[chapterNumber];
    if (records == null || records.isEmpty) {
      return const <TafsirText>[];
    }

    final chapterTexts = _chapterTextsFromRecords(
      chapterId: chapterNumber,
      records: records,
    );

    (_cachedChapterTexts ??= <int, List<TafsirText>>{})[chapterNumber] =
        chapterTexts;
    return chapterTexts;
  }

  Future<TafsirText?> getAyahText({
    required int chapterNumber,
    required int ayahNumber,
  }) async {
    final chapterTexts = await getChapterTexts(chapterNumber);
    for (final tafsirText in chapterTexts) {
      if (tafsirText.verseNumber == ayahNumber ||
          tafsirText.verseKey == '$chapterNumber:$ayahNumber') {
        return tafsirText;
      }
    }

    return null;
  }

  Future<Map<int, List<_MuyassarRecord>>> _loadChapterRecordsMap() async {
    final cached = _cachedChapterRecords;
    if (cached != null) {
      return cached;
    }

    final loadingFuture = _recordsLoadingFuture;
    if (loadingFuture != null) {
      return loadingFuture;
    }

    final completer = Completer<Map<int, List<_MuyassarRecord>>>();
    _recordsLoadingFuture = completer.future;

    try {
      final jsonString = await rootBundle.loadString(defaultTafsirAssetPath);
      final recordsByChapter = await Isolate.run(() {
        return _parseAndGroupMuyassarAsset(jsonString);
      });
      _cachedChapterRecords = recordsByChapter;
      completer.complete(recordsByChapter);
    } catch (error, stackTrace) {
      debugPrint(
        'TafsirMuyassarAssetDataSource._loadChapterRecordsMap failed: $error',
      );
      debugPrint('$stackTrace');
      completer.completeError(error, stackTrace);
    } finally {
      _recordsLoadingFuture = null;
    }

    return completer.future;
  }

  List<TafsirText> _chapterTextsFromRecords({
    required int chapterId,
    required List<_MuyassarRecord> records,
  }) {
    return List<TafsirText>.unmodifiable(
      records.map((record) {
        final ayahNumber = record['ayahNumber'] as int;
        return TafsirText(
          resourceId: defaultTafsirResourceId,
          resourceName: defaultBuiltInTafsir.name,
          text: record['text'] as String,
          verseKey: '$chapterId:$ayahNumber',
          verseNumber: ayahNumber,
          chapterId: chapterId,
        );
      }),
    );
  }
}

typedef _MuyassarRecord = Map<String, Object?>;

Map<int, List<_MuyassarRecord>> _parseAndGroupMuyassarAsset(String jsonString) {
  final decoded = jsonDecode(jsonString);
  if (decoded is! List) {
    throw const FormatException(
      'Expected the Muyassar tafsir asset to be a JSON list.',
    );
  }

  final recordsByChapter = <int, List<_MuyassarRecord>>{};

  for (final entry in decoded) {
    if (entry is! Map<String, dynamic>) {
      throw const FormatException(
        'Expected each Muyassar tafsir entry to be a JSON object.',
      );
    }

    final chapterId = _readInt(entry, 'sura');
    final ayahNumber = _readInt(entry, 'aya');
    final text = _readString(entry, 'text');

    recordsByChapter.putIfAbsent(chapterId, () => <_MuyassarRecord>[]).add({
      'ayahNumber': ayahNumber,
      'text': text,
    });
  }

  for (final records in recordsByChapter.values) {
    records.sort((left, right) {
      final leftVerse = left['ayahNumber'] as int;
      final rightVerse = right['ayahNumber'] as int;
      final verseComparison = leftVerse.compareTo(rightVerse);
      if (verseComparison != 0) {
        return verseComparison;
      }

      return (left['text'] as String).compareTo(right['text'] as String);
    });
  }

  return recordsByChapter;
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.parse(value);
  }

  throw FormatException('Expected "$key" to be an integer.');
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  throw FormatException('Expected "$key" to be a string.');
}
