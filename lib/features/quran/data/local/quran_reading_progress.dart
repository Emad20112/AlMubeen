import 'package:al_mubeen/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Provides read/write access to the user's Quran reading progress.
///
/// Stores the last page and surah number the user was reading so the app
/// can resume from the same position on subsequent launches.
class QuranReadingProgressService {
  QuranReadingProgressService({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  /// Retrieves the last saved reading position, or `null` if none exists.
  Future<QuranReadingProgressEntry?> getLastPosition() async {
    try {
      final query = _db.select(_db.quranReadingProgressCache)
        ..where((t) => t.id.equals(1));
      return query.getSingleOrNull();
    } catch (e) {
      // If there's an error (e.g., schema mismatch), delete all data and return null
      try {
        await _db.delete(_db.quranReadingProgressCache).go();
      } catch (_) {
        // Ignore delete errors
      }
      return null;
    }
  }

  /// Saves the current reading position (page + surah number).
  Future<void> savePosition({
    required int page,
    required int surahNumber,
  }) async {
    await _db
        .into(_db.quranReadingProgressCache)
        .insertOnConflictUpdate(
          QuranReadingProgressCacheCompanion.insert(
            id: const Value(1),
            lastPage: page,
            lastSurahNumber: surahNumber,
            updatedAt: DateTime.now(),
          ),
        );
  }
}
