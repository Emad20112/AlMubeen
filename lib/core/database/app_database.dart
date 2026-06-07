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
@TableIndex(
  name: 'quran_recitation_cache_language',
  columns: {#languageCode},
)
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

@DriftDatabase(
  tables: [
    QuranChapterCache,
    QuranVerseCache,
    QuranRecitationCache,
    QuranCacheMetadata,
    AdhkarProgressCache,
    AdhkarFavorites,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'al_mubeen'));

  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 3;

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
      },
    );
  }
}
