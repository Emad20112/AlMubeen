import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:drift/drift.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class TafsirLocalDataSource {
  const TafsirLocalDataSource({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;
  static const int _totalChapters = 114;

  /// Save a downloaded tafsir metadata
  Future<void> saveDownloadedTafsir(Tafsir tafsir) async {
    final now = DateTime.now();
    await _database.customStatement(
      '''
      INSERT OR REPLACE INTO downloaded_tafsirs (
        resource_id, name, author_name, slug, language_name, 
        resource_name, downloaded_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        tafsir.id,
        tafsir.name,
        tafsir.authorName,
        tafsir.slug,
        tafsir.languageName,
        tafsir.resourceName,
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );
  }

  /// Save a full chapter worth of tafsir verses.
  Future<void> saveTafsirTexts({
    required int resourceId,
    required int chapterId,
    required List<TafsirText> tafsirTexts,
  }) async {
    if (tafsirTexts.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(_database.tafsirTextCache, [
        for (final tafsirText in tafsirTexts)
          TafsirTextCacheCompanion(
            resourceId: Value(resourceId),
            chapterId: Value(chapterId),
            ayahNumber: Value(
              tafsirText.verseNumber ??
                  _ayahNumberFromVerseKey(tafsirText.verseKey),
            ),
            tafsirText: Value(tafsirText.text),
            resourceName: Value(tafsirText.resourceName),
            cachedAt: Value(now),
          ),
      ]);
    });
  }

  /// Get all downloaded tafsirs
  Future<List<Tafsir>> getDownloadedTafsirs() async {
    final results = await _database.customSelect('''
      SELECT resource_id, name, author_name, slug, language_name, resource_name
      FROM downloaded_tafsirs
      ORDER BY downloaded_at DESC
    ''').get();

    return results.map((row) {
      return Tafsir(
        id: row.read<int>('resource_id'),
        name: row.read<String>('name'),
        authorName: row.read<String?>('author_name'),
        slug: row.read<String?>('slug'),
        languageName: row.read<String?>('language_name'),
        resourceName: row.read<String?>('resource_name'),
      );
    }).toList();
  }

  /// Check if a tafsir is downloaded
  Future<bool> isTafsirDownloaded(int resourceId) async {
    final chapterIds = await getCachedTafsirChapterIds(resourceId);
    return chapterIds.length >= _totalChapters;
  }

  /// Delete a downloaded tafsir
  Future<void> deleteDownloadedTafsir(int resourceId) async {
    await _database.customStatement(
      '''
      DELETE FROM downloaded_tafsirs WHERE resource_id = ?
    ''',
      [resourceId],
    );

    // Also delete cached tafsir text for this resource
    await _database.customStatement(
      '''
      DELETE FROM tafsir_text_cache WHERE resource_id = ?
    ''',
      [resourceId],
    );
  }

  /// Delete only the downloaded tafsir metadata, keeping cached chapters.
  Future<void> deleteDownloadedTafsirMetadata(int resourceId) async {
    await _database.customStatement(
      '''
      DELETE FROM downloaded_tafsirs WHERE resource_id = ?
    ''',
      [resourceId],
    );
  }

  /// Delete cached tafsir text for a specific chapter.
  Future<void> deleteTafsirChapterCache({
    required int resourceId,
    required int chapterId,
  }) async {
    await _database.customStatement(
      '''
      DELETE FROM tafsir_text_cache
      WHERE resource_id = ? AND chapter_id = ?
    ''',
      [resourceId, chapterId],
    );
  }

  /// Save tafsir text for a specific ayah
  Future<void> saveTafsirText({
    required int resourceId,
    required int chapterId,
    required int ayahNumber,
    required String text,
    required String resourceName,
  }) async {
    final now = DateTime.now();
    await _database.customStatement(
      '''
      INSERT OR REPLACE INTO tafsir_text_cache (
        resource_id, chapter_id, ayah_number, tafsir_text, resource_name, cached_at
      ) VALUES (?, ?, ?, ?, ?, ?)
    ''',
      [
        resourceId,
        chapterId,
        ayahNumber,
        text,
        resourceName,
        now.toIso8601String(),
      ],
    );
  }

  /// Get tafsir text for a specific ayah
  Future<TafsirText?> getTafsirText({
    required int resourceId,
    required int chapterId,
    required int ayahNumber,
  }) async {
    final results = await _database.customSelect('''
      SELECT resource_id, resource_name, tafsir_text, chapter_id, ayah_number
      FROM tafsir_text_cache
      WHERE resource_id = $resourceId AND chapter_id = $chapterId AND ayah_number = $ayahNumber
    ''').get();

    if (results.isEmpty) return null;

    final row = results.first;
    return TafsirText(
      resourceId: row.read<int>('resource_id'),
      resourceName: row.read<String>('resource_name'),
      text: row.read<String>('tafsir_text'),
      chapterId: row.read<int>('chapter_id'),
      verseNumber: row.read<int>('ayah_number'),
    );
  }

  /// Get all tafsir text for a chapter
  Future<List<TafsirText>> getTafsirTextForChapter({
    required int resourceId,
    required int chapterId,
  }) async {
    final results = await _database.customSelect('''
      SELECT resource_id, resource_name, tafsir_text, chapter_id, ayah_number
      FROM tafsir_text_cache
      WHERE resource_id = $resourceId AND chapter_id = $chapterId
      ORDER BY ayah_number ASC
    ''').get();

    if (results.isEmpty) {
      return <TafsirText>[];
    }

    final expectedVerseCount = getVerseCount(chapterId);
    if (results.length < expectedVerseCount) {
      return <TafsirText>[];
    }

    return results.map((row) {
      return TafsirText(
        resourceId: row.read<int>('resource_id'),
        resourceName: row.read<String>('resource_name'),
        text: row.read<String>('tafsir_text'),
        chapterId: row.read<int>('chapter_id'),
        verseNumber: row.read<int>('ayah_number'),
      );
    }).toList();
  }

  /// Get the chapter IDs that are fully cached for this tafsir.
  Future<Set<int>> getCachedTafsirChapterIds(int resourceId) async {
    final results = await _database.customSelect('''
      SELECT chapter_id, COUNT(*) AS verse_count
      FROM tafsir_text_cache
      WHERE resource_id = $resourceId
      GROUP BY chapter_id
    ''').get();

    return results
        .where((row) {
          final chapterId = row.read<int>('chapter_id');
          final cachedVerseCount = row.read<int>('verse_count');
          return cachedVerseCount >= getVerseCount(chapterId);
        })
        .map((row) => row.read<int>('chapter_id'))
        .toSet();
  }

  /// Delete all cached tafsir text for a specific resource
  Future<void> clearTafsirCache(int resourceId) async {
    await _database.customStatement(
      '''
      DELETE FROM tafsir_text_cache WHERE resource_id = ?
    ''',
      [resourceId],
    );
  }

  int _ayahNumberFromVerseKey(String? verseKey) {
    if (verseKey == null || verseKey.trim().isEmpty) {
      throw const FormatException('Tafsir verse is missing an ayah number.');
    }

    final parts = verseKey.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid tafsir verse key: $verseKey');
    }

    return int.parse(parts[1]);
  }
}
