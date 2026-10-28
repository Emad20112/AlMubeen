import 'dart:async';
import 'dart:isolate';

import 'package:al_mubeen/features/quran/data/local/muyassar_embedded_seed.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/domain/tafsir_defaults.dart';
import 'package:flutter/foundation.dart';

class TafsirMuyassarAssetDataSource {
  TafsirMuyassarAssetDataSource();

  Map<int, List<TafsirText>>? _cachedChapterTexts;
  Future<Map<int, List<TafsirText>>>? _loadingFuture;

  Future<Map<int, List<TafsirText>>> loadChapterTextsMap() async {
    return getAllChapterTextsMap();
  }

  Future<Map<int, List<TafsirText>>> getAllChapterTextsMap() async {
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
      final decodedMap = await Isolate.run(() {
        return decodeEmbeddedMuyassarTafsir();
      });

      final chapterTexts = <int, List<TafsirText>>{};
      for (final chapterEntry in decodedMap.entries) {
        final chapterId = chapterEntry.key;
        final verses = chapterEntry.value;
        final list = <TafsirText>[];

        final sortedAyahKeys = verses.keys.toList()..sort();
        for (final ayahNumber in sortedAyahKeys) {
          list.add(
            TafsirText(
              resourceId: defaultTafsirResourceId,
              resourceName: defaultBuiltInTafsir.name,
              text: verses[ayahNumber]!,
              verseKey: '$chapterId:$ayahNumber',
              verseNumber: ayahNumber,
              chapterId: chapterId,
            ),
          );
        }
        chapterTexts[chapterId] = List<TafsirText>.unmodifiable(list);
      }

      _cachedChapterTexts = chapterTexts;
      completer.complete(chapterTexts);
    } catch (error, stackTrace) {
      debugPrint(
        'TafsirMuyassarAssetDataSource.getAllChapterTextsMap failed: $error',
      );
      debugPrint('$stackTrace');
      completer.completeError(error, stackTrace);
    } finally {
      _loadingFuture = null;
    }

    return completer.future;
  }

  Future<List<int>> getAvailableChapterNumbers() async {
    final allChapters = await getAllChapterTextsMap();
    return allChapters.keys.toList()..sort();
  }

  Future<List<TafsirText>> getChapterTexts(int chapterNumber) async {
    final allChapters = await getAllChapterTextsMap();
    return allChapters[chapterNumber] ?? const <TafsirText>[];
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
}

