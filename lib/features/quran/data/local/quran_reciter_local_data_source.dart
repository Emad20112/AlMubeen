import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:drift/drift.dart';

final class QuranReciterLocalDataSource {
  const QuranReciterLocalDataSource({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  static String cacheKeyForLanguage(String language) {
    return 'quran_com_recitations_${_normalizeLanguage(language)}';
  }

  Future<DataResult<List<QuranRecitation>>> getRecitations({
    String language = 'en',
  }) async {
    return _guard(() async {
      final languageCode = _normalizeLanguage(language);
      final rows =
          await (_database.select(_database.quranRecitationCache)
                ..where((table) => table.languageCode.equals(languageCode))
                ..orderBy([
                  (table) => OrderingTerm(expression: table.reciterName),
                ]))
              .get();

      if (rows.isEmpty) {
        return _cacheMiss('No recitations are cached for "$languageCode".');
      }

      return DataSuccess(rows.map(_recitationFromRow).toList(growable: false));
    });
  }

  Future<DataResult<void>> saveRecitations(
    List<QuranRecitation> recitations, {
    String language = 'en',
  }) async {
    return _guard(() async {
      final languageCode = _normalizeLanguage(language);
      final now = DateTime.now().toUtc();

      await _database.transaction(() async {
        await (_database.delete(
          _database.quranRecitationCache,
        )..where((table) => table.languageCode.equals(languageCode))).go();

        if (recitations.isNotEmpty) {
          await _database.batch((batch) {
            batch.insertAllOnConflictUpdate(_database.quranRecitationCache, [
              for (final recitation in recitations)
                QuranRecitationCacheCompanion(
                  recitationId: Value(recitation.id),
                  languageCode: Value(languageCode),
                  reciterName: Value(recitation.reciterName),
                  style: Value(recitation.style),
                  translatedName: Value(recitation.translatedName),
                  languageName: Value(recitation.languageName),
                  updatedAt: Value(now),
                ),
            ]);
          });
        }

        await _upsertCacheMetadata(
          cacheKeyForLanguage(languageCode),
          fetchedAt: now,
          now: now,
        );
      });

      return const DataSuccess<void>(null);
    });
  }

  Future<DataResult<DateTime?>> getCacheLastFetchedAt({
    String language = 'en',
  }) async {
    return _guard(() async {
      final row =
          await (_database.select(_database.quranCacheMetadata)..where(
                (table) => table.cacheKey.equals(cacheKeyForLanguage(language)),
              ))
              .getSingleOrNull();

      return DataSuccess(row?.lastFetchedAt?.toUtc());
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

  QuranRecitation _recitationFromRow(QuranRecitationCacheEntry row) {
    return QuranRecitation(
      id: row.recitationId,
      reciterName: row.reciterName,
      style: row.style,
      translatedName: row.translatedName,
      languageName: row.languageName,
    );
  }

  Future<DataResult<T>> _guard<T>(
    Future<DataResult<T>> Function() action,
  ) async {
    try {
      return await action();
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.storage,
          message: 'Unable to read or write cached Quran reciter data.',
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

  static String _normalizeLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    return normalized.isEmpty ? 'en' : normalized;
  }
}
