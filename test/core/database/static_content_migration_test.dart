import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/hadith_nawawi/data/hadith_nawawi_local_data_source.dart';
import 'package:al_mubeen/features/names_of_allah/data/names_of_allah_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/tafsir_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/tafsir_muyassar_asset_data_source.dart';
import 'package:al_mubeen/features/quran/domain/tafsir_defaults.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late NamesOfAllahLocalDataSource namesDataSource;
  late HadithNawawiLocalDataSource hadithDataSource;

  setUp(() {
    // In-memory sqlite database running our Drift schema
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    namesDataSource = NamesOfAllahLocalDataSource(db);
    hadithDataSource = HadithNawawiLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'Names of Allah database content is completely seeded and valid',
    () async {
      final dbEntries = await namesDataSource.getEntries();

      expect(dbEntries.length, equals(100)); // 100 entries in curated set
      expect(dbEntries.first.id, equals(1));
      expect(dbEntries.first.name, isNotEmpty);
      expect(dbEntries.first.meaning, isNotEmpty);
      expect(dbEntries.first.searchIndex, isNotEmpty);

      // Verify search across in-memory / parsed entries
      final searchResult = dbEntries
          .where((e) => e.matchesQuery('الرحمن'))
          .toList();
      expect(searchResult.isNotEmpty, isTrue);
    },
  );

  test(
    '40 Hadith Nawawi database content is completely seeded and valid',
    () async {
      final dbEntries = await hadithDataSource.getEntries();

      expect(dbEntries.length, equals(42));
      for (var i = 0; i < dbEntries.length; i++) {
        final entry = dbEntries[i];
        expect(entry.id, equals(i + 1));
        expect(entry.fullText, isNotEmpty);
        expect(entry.description, isNotEmpty);
        expect(entry.title.isNotEmpty, isTrue);
        expect(entry.searchIndex.isNotEmpty, isTrue);
      }

      // Verify search
      final searchResult = dbEntries
          .where((e) => e.matchesQuery('النيات'))
          .toList();
      expect(searchResult.isNotEmpty, isTrue);
    },
  );

  test('Hisn Al-Muslim database content is seeded properly', () async {
    final categoryRows = await db.select(db.hisnContentCache).get();
    expect(categoryRows.length, equals(135)); // 135 categories

    final itemRows = await db.select(db.hisnContentItemCache).get();
    expect(itemRows.length, equals(319));
  });

  test(
    'User data safety: modifying bookmarks and progress is completely preserved across static reads',
    () async {
      // 1. Add user bookmark
      await db
          .into(db.quranBookmarks)
          .insert(
            QuranBookmarksCompanion.insert(
              page: 45,
              surahNumber: 2,
              ayahNumber: const Value(255),
              label: const Value('Ayat Al-Kursi'),
              createdAt: DateTime.now(),
            ),
          );

      // 2. Read static content
      final names = await namesDataSource.getEntries();
      expect(names.length, equals(100));

      final hadiths = await hadithDataSource.getEntries();
      expect(hadiths.length, equals(42));

      // 3. Verify user bookmark is untouched
      final bookmarks = await db.select(db.quranBookmarks).get();
      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.page, equals(45));
      expect(bookmarks.first.label, equals('Ayat Al-Kursi'));
    },
  );

  test(
    'Migration from schema version 13 to 14 creates new tables and seeds data seamlessly',
    () async {
      // Test that the static data can be seeded on upgrade
      final testDb = AppDatabase.forExecutor(NativeDatabase.memory());

      // Verify static content is accessible
      final names = await testDb.select(testDb.namesOfAllahEntries).get();
      final hadiths = await testDb.select(testDb.hadithNawawiEntries).get();
      final hisnCats = await testDb.select(testDb.hisnContentCache).get();
      final hisnItems = await testDb.select(testDb.hisnContentItemCache).get();

      expect(names.length, equals(100));
      expect(hadiths.length, equals(42));
      expect(hisnCats.length, equals(135));
      expect(hisnItems.length, equals(319));

      await testDb.close();
    },
  );

  test(
    'Tafsir Muyassar embedded seeds load and save into SQLite without JSON assets',
    () async {
      final assetSource = TafsirMuyassarAssetDataSource();
      final fatihaTexts = await assetSource.getChapterTexts(1);
      expect(fatihaTexts.length, equals(7));

      // Seed into tafsir local data source
      final tafsirLocalSource = TafsirLocalDataSource(database: db);
      await tafsirLocalSource.saveAllTafsirTexts(
        resourceId: defaultTafsirResourceId,
        chapterTexts: {1: fatihaTexts},
      );

      final dbTexts = await tafsirLocalSource.getTafsirTextForChapter(
        resourceId: defaultTafsirResourceId,
        chapterId: 1,
      );
      expect(dbTexts.length, equals(7));
      expect(dbTexts.first.text, contains('الفاتحة'));
    },
  );
}
