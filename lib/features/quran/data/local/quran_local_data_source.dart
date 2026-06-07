import 'dart:convert';

import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:drift/drift.dart';

final class QuranLocalDataSource {
  const QuranLocalDataSource({required AppDatabase database})
    : _database = database;

  static const String chaptersCacheKey = 'quran_com_chapters';

  final AppDatabase _database;

  Future<DataResult<List<QuranChapter>>> getChapters() async {
    return _guard(() async {
      final rows = await (_database.select(
        _database.quranChapterCache,
      )..orderBy([(table) => OrderingTerm(expression: table.chapterId)])).get();

      if (rows.isEmpty) {
        return _cacheMiss('No Quran chapters are cached yet.');
      }

      return DataSuccess(rows.map(_chapterFromRow).toList(growable: false));
    });
  }

  Future<DataResult<QuranChapter>> getChapter(int chapterNumber) async {
    return _guard(() async {
      final row =
          await (_database.select(_database.quranChapterCache)
                ..where((table) => table.chapterId.equals(chapterNumber)))
              .getSingleOrNull();

      if (row == null) {
        return _cacheMiss('Quran chapter $chapterNumber is not cached.');
      }

      return DataSuccess(_chapterFromRow(row));
    });
  }

  Future<DataResult<void>> saveChapters(List<QuranChapter> chapters) async {
    return _guard(() async {
      final now = DateTime.now().toUtc();

      await _database.transaction(() async {
        await _database.batch((batch) {
          batch.insertAllOnConflictUpdate(_database.quranChapterCache, [
            for (final chapter in chapters)
              QuranChapterCacheCompanion(
                chapterId: Value(chapter.id),
                nameArabic: Value(chapter.nameArabic),
                nameSimple: Value(chapter.nameSimple),
                nameComplex: Value(chapter.nameComplex),
                versesCount: Value(chapter.versesCount),
                pagesJson: Value(jsonEncode(chapter.pages)),
                revelationPlace: Value(chapter.revelationPlace),
                revelationOrder: Value(chapter.revelationOrder),
                bismillahPre: Value(chapter.bismillahPre),
                translatedName: Value(chapter.translatedName),
                updatedAt: Value(now),
              ),
          ]);
        });

        await _upsertCacheMetadata(chaptersCacheKey, fetchedAt: now, now: now);
      });

      return const DataSuccess<void>(null);
    });
  }

  Future<DataResult<QuranVerse>> getVerse(QuranVerseKey verseKey) async {
    return _guard(() async {
      final row =
          await (_database.select(_database.quranVerseCache)
                ..where((table) => table.verseKey.equals(verseKey.value)))
              .getSingleOrNull();

      if (row == null) {
        return _cacheMiss('Quran verse ${verseKey.value} is not cached.');
      }

      return DataSuccess(_verseFromRow(row));
    });
  }

  Future<DataResult<QuranVersesPage>> getVersesByChapter(
    int chapterNumber,
  ) async {
    return _guard(() async {
      final rows =
          await (_database.select(_database.quranVerseCache)
                ..where((table) => table.chapterId.equals(chapterNumber))
                ..orderBy([
                  (table) => OrderingTerm(expression: table.verseNumber),
                ]))
              .get();

      if (rows.isEmpty) {
        return _cacheMiss('No verses for chapter $chapterNumber are cached.');
      }

      return DataSuccess(
        QuranVersesPage(
          verses: rows.map(_verseFromRow).toList(growable: false),
        ),
      );
    });
  }

  Future<DataResult<void>> saveVerse(QuranVerse verse) {
    return saveVerses([verse]);
  }

  Future<DataResult<void>> saveVerses(List<QuranVerse> verses) async {
    return _guard(() async {
      final now = DateTime.now().toUtc();

      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(_database.quranVerseCache, [
          for (final verse in verses)
            QuranVerseCacheCompanion(
              verseKey: Value(verse.verseKey.value),
              quranComVerseId: Value(verse.id),
              chapterId: Value(verse.verseKey.surah),
              verseNumber: Value(verse.verseNumber ?? verse.verseKey.ayah),
              pageNumber: Value(verse.pageNumber),
              juzNumber: Value(verse.juzNumber),
              hizbNumber: Value(verse.hizbNumber),
              rubElHizbNumber: Value(verse.rubElHizbNumber),
              sajdahNumber: Value(verse.sajdahNumber),
              textUthmani: Value(verse.textUthmani),
              textUthmaniSimple: Value(verse.textUthmaniSimple),
              updatedAt: Value(now),
            ),
        ]);
      });

      return const DataSuccess<void>(null);
    });
  }

  Future<DataResult<DateTime?>> getCacheLastFetchedAt(String cacheKey) async {
    return _guard(() async {
      final row = await (_database.select(
        _database.quranCacheMetadata,
      )..where((table) => table.cacheKey.equals(cacheKey))).getSingleOrNull();

      return DataSuccess(row?.lastFetchedAt?.toUtc());
    });
  }

  Future<DataResult<void>> markCacheFetched(
    String cacheKey, {
    DateTime? fetchedAt,
  }) async {
    return _guard(() async {
      final now = DateTime.now().toUtc();
      await _upsertCacheMetadata(
        cacheKey,
        fetchedAt: fetchedAt ?? now,
        now: now,
      );

      return const DataSuccess<void>(null);
    });
  }

  Future<void> _upsertCacheMetadata(
    String cacheKey, {
    required DateTime fetchedAt,
    required DateTime now,
  }) {
    return _database
        .into(_database.quranCacheMetadata)
        .insertOnConflictUpdate(
          QuranCacheMetadataCompanion(
            cacheKey: Value(cacheKey),
            lastFetchedAt: Value(fetchedAt),
            updatedAt: Value(now),
          ),
        );
  }

  QuranChapter _chapterFromRow(QuranChapterCacheEntry row) {
    return QuranChapter(
      id: row.chapterId,
      nameArabic: row.nameArabic,
      nameSimple: row.nameSimple,
      nameComplex: row.nameComplex,
      versesCount: row.versesCount,
      pages: _decodePages(row.pagesJson),
      revelationPlace: row.revelationPlace,
      revelationOrder: row.revelationOrder,
      bismillahPre: row.bismillahPre,
      translatedName: row.translatedName,
    );
  }

  QuranVerse _verseFromRow(QuranVerseCacheEntry row) {
    return QuranVerse(
      verseKey: QuranVerseKey.parse(row.verseKey),
      id: row.quranComVerseId,
      verseNumber: row.verseNumber,
      pageNumber: row.pageNumber,
      juzNumber: row.juzNumber,
      hizbNumber: row.hizbNumber,
      rubElHizbNumber: row.rubElHizbNumber,
      sajdahNumber: row.sajdahNumber,
      textUthmani: row.textUthmani,
      textUthmaniSimple: row.textUthmaniSimple,
    );
  }

  List<int> _decodePages(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      throw const FormatException('Cached chapter pages must be a JSON list.');
    }

    return decoded
        .map((page) => page is num ? page.toInt() : int.parse(page.toString()))
        .toList(growable: false);
  }

  Future<DataResult<T>> _guard<T>(
    Future<DataResult<T>> Function() action,
  ) async {
    try {
      return await action();
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse cached Quran data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.storage,
          message: 'Unable to read or write cached Quran data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  DataError<T> _cacheMiss<T>(String message) {
    return DataError(
      DataFailure(kind: DataFailureKind.cacheMiss, message: message),
    );
  }
}
