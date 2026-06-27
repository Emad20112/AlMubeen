import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('QuranChapterCacheEntry')
@TableIndex(name: 'quran_chapter_cache_updated_at', columns: {#updatedAt})
class QuranChapterCache extends Table {
  IntColumn get chapterId => integer()();

  TextColumn get nameArabic => text()();

  TextColumn get nameSimple => text()();

  TextColumn get nameComplex => text()();

  IntColumn get versesCount => integer()();

  TextColumn get pagesJson => text()();

  TextColumn get revelationPlace => text().nullable()();

  IntColumn get revelationOrder => integer().nullable()();

  BoolColumn get bismillahPre => boolean().nullable()();

  TextColumn get translatedName => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {chapterId};
}

@DataClassName('QuranVerseCacheEntry')
@TableIndex(
  name: 'quran_verse_cache_chapter_verse',
  columns: {#chapterId, #verseNumber},
)
@TableIndex(name: 'quran_verse_cache_page_number', columns: {#pageNumber})
@TableIndex(name: 'quran_verse_cache_updated_at', columns: {#updatedAt})
class QuranVerseCache extends Table {
  TextColumn get verseKey => text()();

  IntColumn get quranComVerseId => integer().nullable()();

  IntColumn get chapterId => integer()();

  IntColumn get verseNumber => integer()();

  IntColumn get pageNumber => integer().nullable()();

  IntColumn get juzNumber => integer().nullable()();

  IntColumn get hizbNumber => integer().nullable()();

  IntColumn get rubElHizbNumber => integer().nullable()();

  IntColumn get sajdahNumber => integer().nullable()();

  TextColumn get textUthmani => text().nullable()();

  TextColumn get textUthmaniSimple => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {verseKey};
}

@DataClassName('QuranRecitationCacheEntry')
@TableIndex(name: 'quran_recitation_cache_language', columns: {#languageCode})
@TableIndex(name: 'quran_recitation_cache_updated_at', columns: {#updatedAt})
class QuranRecitationCache extends Table {
  IntColumn get recitationId => integer()();

  TextColumn get languageCode => text()();

  TextColumn get reciterName => text()();

  TextColumn get style => text().nullable()();

  TextColumn get translatedName => text().nullable()();

  TextColumn get languageName => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {recitationId, languageCode};
}

@DataClassName('QuranCacheMetadataEntry')
class QuranCacheMetadata extends Table {
  TextColumn get cacheKey => text()();

  DateTimeColumn get lastFetchedAt => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}

@DataClassName('AdhkarProgressCacheEntry')
class AdhkarProgressCache extends Table {
  TextColumn get itemId => text()();
  TextColumn get categoryId => text()();
  IntColumn get completedCount => integer()();
  BoolColumn get isCompleted => boolean()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

@DataClassName('AdhkarFavoritesEntry')
class AdhkarFavorites extends Table {
  TextColumn get itemId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

@DataClassName('QuranReadingProgressEntry')
class QuranReadingProgressCache extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get lastPage => integer()();
  IntColumn get lastSurahNumber => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('QuranBookmarkEntry')
class QuranBookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get page => integer()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer().nullable()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {page, surahNumber, ayahNumber},
  ];
}

@DataClassName('DownloadedTafsirEntry')
@TableIndex(name: 'downloaded_tafsirs_resource_id', columns: {#resourceId})
@TableIndex(name: 'downloaded_tafsirs_updated_at', columns: {#updatedAt})
class DownloadedTafsirs extends Table {
  IntColumn get resourceId => integer()();

  TextColumn get name => text()();

  TextColumn get authorName => text().nullable()();

  TextColumn get slug => text().nullable()();

  TextColumn get languageName => text().nullable()();

  TextColumn get resourceName => text().nullable()();

  DateTimeColumn get downloadedAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {resourceId};
}

@DataClassName('DownloadedTranslationEntry')
@TableIndex(name: 'downloaded_translations_resource_id', columns: {#resourceId})
@TableIndex(name: 'downloaded_translations_updated_at', columns: {#updatedAt})
class DownloadedTranslations extends Table {
  IntColumn get resourceId => integer()();

  TextColumn get name => text()();

  TextColumn get authorName => text().nullable()();

  TextColumn get slug => text().nullable()();

  TextColumn get languageName => text().nullable()();

  TextColumn get resourceName => text().nullable()();

  DateTimeColumn get downloadedAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {resourceId};
}

@DataClassName('TafsirTextCacheEntry')
@TableIndex(
  name: 'tafsir_text_cache_resource_chapter_ayah',
  columns: {#resourceId, #chapterId, #ayahNumber},
)
@TableIndex(name: 'tafsir_text_cache_updated_at', columns: {#cachedAt})
class TafsirTextCache extends Table {
  IntColumn get resourceId => integer()();

  IntColumn get chapterId => integer()();

  IntColumn get ayahNumber => integer()();

  TextColumn get tafsirText => text()();

  TextColumn get resourceName => text()();

  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {resourceId, chapterId, ayahNumber};
}

@DataClassName('TranslationTextCacheEntry')
@TableIndex(
  name: 'translation_text_cache_resource_chapter_ayah',
  columns: {#resourceId, #chapterId, #ayahNumber},
)
@TableIndex(name: 'translation_text_cache_updated_at', columns: {#cachedAt})
class TranslationTextCache extends Table {
  IntColumn get resourceId => integer()();

  IntColumn get chapterId => integer()();

  IntColumn get ayahNumber => integer()();

  TextColumn get translationText => text()();

  TextColumn get resourceName => text()();

  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {resourceId, chapterId, ayahNumber};
}

@DriftDatabase(
  tables: [
    QuranChapterCache,
    QuranVerseCache,
    QuranRecitationCache,
    QuranCacheMetadata,
    AdhkarProgressCache,
    AdhkarFavorites,
    QuranReadingProgressCache,
    QuranBookmarks,
    DownloadedTafsirs,
    DownloadedTranslations,
    TafsirTextCache,
    TranslationTextCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'al_mubeen'));

  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(quranRecitationCache);
        }
        if (from < 3) {
          await migrator.createTable(adhkarProgressCache);
          await migrator.createTable(adhkarFavorites);
        }
        if (from < 4) {
          await migrator.createTable(quranReadingProgressCache);
        }
        if (from < 5) {
          // Delete all data from the table to fix schema issues
          await (migrator.database as AppDatabase).customStatement(
            'DELETE FROM quran_reading_progress_cache',
          );
        }
        if (from < 6) {
          await migrator.createTable(quranBookmarks);
        }
        if (from < 7) {
          await (migrator.database as AppDatabase).customStatement('''
            CREATE TABLE IF NOT EXISTS downloaded_tafsirs (
              resource_id INTEGER NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              author_name TEXT,
              slug TEXT,
              language_name TEXT,
              resource_name TEXT,
              downloaded_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE TABLE IF NOT EXISTS tafsir_text_cache (
              resource_id INTEGER NOT NULL,
              chapter_id INTEGER NOT NULL,
              ayah_number INTEGER NOT NULL,
              tafsir_text TEXT NOT NULL,
              resource_name TEXT NOT NULL,
              cached_at INTEGER NOT NULL,
              PRIMARY KEY (resource_id, chapter_id, ayah_number)
            )
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE INDEX IF NOT EXISTS downloaded_tafsirs_resource_id 
            ON downloaded_tafsirs (resource_id)
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE INDEX IF NOT EXISTS downloaded_tafsirs_updated_at 
            ON downloaded_tafsirs (updated_at)
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE INDEX IF NOT EXISTS tafsir_text_cache_resource_chapter_ayah 
            ON tafsir_text_cache (resource_id, chapter_id, ayah_number)
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE INDEX IF NOT EXISTS tafsir_text_cache_updated_at 
            ON tafsir_text_cache (cached_at)
          ''');
        }
        if (from < 8) {
          await (migrator.database as AppDatabase).customStatement('''
            CREATE TABLE IF NOT EXISTS downloaded_translations (
              resource_id INTEGER NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              author_name TEXT,
              slug TEXT,
              language_name TEXT,
              resource_name TEXT,
              downloaded_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE TABLE IF NOT EXISTS translation_text_cache (
              resource_id INTEGER NOT NULL,
              chapter_id INTEGER NOT NULL,
              ayah_number INTEGER NOT NULL,
              translation_text TEXT NOT NULL,
              resource_name TEXT NOT NULL,
              cached_at INTEGER NOT NULL,
              PRIMARY KEY (resource_id, chapter_id, ayah_number)
            )
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE INDEX IF NOT EXISTS downloaded_translations_resource_id 
            ON downloaded_translations (resource_id)
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE INDEX IF NOT EXISTS downloaded_translations_updated_at 
            ON downloaded_translations (updated_at)
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE INDEX IF NOT EXISTS translation_text_cache_resource_chapter_ayah 
            ON translation_text_cache (resource_id, chapter_id, ayah_number)
          ''');
          await (migrator.database as AppDatabase).customStatement('''
            CREATE INDEX IF NOT EXISTS translation_text_cache_updated_at 
            ON translation_text_cache (cached_at)
          ''');
        }
      },
    );
  }
}
