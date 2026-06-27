import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:drift/drift.dart';

class TranslationLocalDataSource {
  const TranslationLocalDataSource({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  Future<void> saveDownloadedTranslation(Translation translation) async {
    final now = DateTime.now();
    await _database.customStatement(
      '''
      INSERT OR REPLACE INTO downloaded_translations (
        resource_id, name, author_name, slug, language_name,
        resource_name, downloaded_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        translation.id,
        translation.name,
        translation.authorName,
        translation.slug,
        translation.languageName,
        translation.resourceName,
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );
  }

  Future<void> saveTranslationTexts({
    required int resourceId,
    required int chapterId,
    required List<TranslationText> translationTexts,
  }) async {
    if (translationTexts.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(_database.translationTextCache, [
        for (final translationText in translationTexts)
          TranslationTextCacheCompanion(
            resourceId: Value(resourceId),
            chapterId: Value(chapterId),
            ayahNumber: Value(
              translationText.verseNumber ??
                  _ayahNumberFromVerseKey(translationText.verseKey),
            ),
            translationText: Value(translationText.text),
            resourceName: Value(translationText.resourceName),
            cachedAt: Value(now),
          ),
      ]);
    });
  }

  Future<List<Translation>> getDownloadedTranslations() async {
    final results = await _database.customSelect('''
      SELECT resource_id, name, author_name, slug, language_name, resource_name
      FROM downloaded_translations
      ORDER BY downloaded_at DESC
    ''').get();

    return results.map((row) {
      return Translation(
        id: row.read<int>('resource_id'),
        name: row.read<String>('name'),
        authorName: row.read<String?>('author_name'),
        slug: row.read<String?>('slug'),
        languageName: row.read<String?>('language_name'),
        resourceName: row.read<String?>('resource_name'),
      );
    }).toList();
  }

  Future<bool> isTranslationDownloaded(int resourceId) async {
    final chapterIds = await getCachedTranslationChapterIds(resourceId);
    return chapterIds.length >= 114;
  }

  Future<void> deleteDownloadedTranslation(int resourceId) async {
    await _database.customStatement(
      '''
      DELETE FROM downloaded_translations WHERE resource_id = ?
    ''',
      [resourceId],
    );

    await _database.customStatement(
      '''
      DELETE FROM translation_text_cache WHERE resource_id = ?
    ''',
      [resourceId],
    );
  }

  Future<void> saveTranslationText({
    required int resourceId,
    required int chapterId,
    required int ayahNumber,
    required String text,
    required String resourceName,
  }) async {
    final now = DateTime.now();
    await _database.customStatement(
      '''
      INSERT OR REPLACE INTO translation_text_cache (
        resource_id, chapter_id, ayah_number, translation_text, resource_name, cached_at
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

  Future<TranslationText?> getTranslationText({
    required int resourceId,
    required int chapterId,
    required int ayahNumber,
  }) async {
    final results = await _database.customSelect('''
      SELECT resource_id, resource_name, translation_text, chapter_id, ayah_number
      FROM translation_text_cache
      WHERE resource_id = $resourceId AND chapter_id = $chapterId AND ayah_number = $ayahNumber
    ''').get();

    if (results.isEmpty) return null;

    final row = results.first;
    return TranslationText(
      resourceId: row.read<int>('resource_id'),
      resourceName: row.read<String>('resource_name'),
      text: row.read<String>('translation_text'),
      chapterId: row.read<int>('chapter_id'),
      verseNumber: row.read<int>('ayah_number'),
    );
  }

  Future<List<TranslationText>> getTranslationTextForChapter({
    required int resourceId,
    required int chapterId,
  }) async {
    final results = await _database.customSelect('''
      SELECT resource_id, resource_name, translation_text, chapter_id, ayah_number
      FROM translation_text_cache
      WHERE resource_id = $resourceId AND chapter_id = $chapterId
      ORDER BY ayah_number ASC
    ''').get();

    return results.map((row) {
      return TranslationText(
        resourceId: row.read<int>('resource_id'),
        resourceName: row.read<String>('resource_name'),
        text: row.read<String>('translation_text'),
        chapterId: row.read<int>('chapter_id'),
        verseNumber: row.read<int>('ayah_number'),
      );
    }).toList();
  }

  Future<Set<int>> getCachedTranslationChapterIds(int resourceId) async {
    final results = await _database.customSelect('''
      SELECT DISTINCT chapter_id
      FROM translation_text_cache
      WHERE resource_id = $resourceId
    ''').get();

    return results.map((row) => row.read<int>('chapter_id')).toSet();
  }

  Future<void> clearTranslationCache(int resourceId) async {
    await _database.customStatement(
      '''
      DELETE FROM translation_text_cache WHERE resource_id = ?
    ''',
      [resourceId],
    );
  }

  int _ayahNumberFromVerseKey(String? verseKey) {
    if (verseKey == null || verseKey.trim().isEmpty) {
      throw const FormatException(
        'Translation verse is missing an ayah number.',
      );
    }

    final parts = verseKey.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid translation verse key: $verseKey');
    }

    return int.parse(parts[1]);
  }
}
