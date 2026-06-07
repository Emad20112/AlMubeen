import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/data/local/quran_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late QuranLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    dataSource = QuranLocalDataSource(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('QuranLocalDataSource', () {
    test('returns cache miss when chapters are not cached', () async {
      final result = await dataSource.getChapters();

      expect(result, isA<DataError<List<QuranChapter>>>());
      expect(
        (result as DataError<List<QuranChapter>>).failure.kind,
        DataFailureKind.cacheMiss,
      );
    });

    test('saves and reads chapters in chapter order', () async {
      final chapters = [
        const QuranChapter(
          id: 2,
          nameArabic: 'البقرة',
          nameSimple: 'Al-Baqarah',
          nameComplex: 'Al-Baqarah',
          versesCount: 286,
          pages: [2, 49],
          revelationPlace: 'madinah',
          translatedName: 'The Cow',
        ),
        const QuranChapter(
          id: 1,
          nameArabic: 'الفاتحة',
          nameSimple: 'Al-Fatihah',
          nameComplex: 'Al-Fatihah',
          versesCount: 7,
          pages: [1, 1],
          revelationPlace: 'makkah',
          translatedName: 'The Opener',
        ),
      ];

      final saveResult = await dataSource.saveChapters(chapters);
      final readResult = await dataSource.getChapters();
      final metadataResult = await dataSource.getCacheLastFetchedAt(
        QuranLocalDataSource.chaptersCacheKey,
      );

      expect(saveResult, isA<DataSuccess<void>>());
      expect(readResult, isA<DataSuccess<List<QuranChapter>>>());
      final cachedChapters =
          (readResult as DataSuccess<List<QuranChapter>>).value;
      expect(cachedChapters.map((chapter) => chapter.id), [1, 2]);
      expect(cachedChapters.first.pages, [1, 1]);
      expect(cachedChapters.first.translatedName, 'The Opener');
      expect(metadataResult, isA<DataSuccess<DateTime?>>());
      expect((metadataResult as DataSuccess<DateTime?>).value, isNotNull);
    });

    test('saves and reads a single verse by key', () async {
      const verse = QuranVerse(
        id: 262,
        verseKey: QuranVerseKey(surah: 2, ayah: 255),
        verseNumber: 255,
        pageNumber: 42,
        juzNumber: 3,
        textUthmani: 'اللَّهُ لَا إِلَـٰهَ إِلَّا هُوَ',
      );

      await dataSource.saveVerse(verse);
      final result = await dataSource.getVerse(verse.verseKey);

      expect(result, isA<DataSuccess<QuranVerse>>());
      final cachedVerse = (result as DataSuccess<QuranVerse>).value;
      expect(cachedVerse.id, 262);
      expect(cachedVerse.verseKey.value, '2:255');
      expect(cachedVerse.pageNumber, 42);
      expect(cachedVerse.textUthmani, contains('اللَّهُ'));
    });

    test('saves and reads verses by chapter sorted by verse number', () async {
      await dataSource.saveVerses([
        const QuranVerse(
          verseKey: QuranVerseKey(surah: 2, ayah: 3),
          verseNumber: 3,
          pageNumber: 2,
          textUthmani: 'الذين يؤمنون بالغيب',
        ),
        const QuranVerse(
          verseKey: QuranVerseKey(surah: 2, ayah: 1),
          verseNumber: 1,
          pageNumber: 2,
          textUthmani: 'الم',
        ),
      ]);

      final result = await dataSource.getVersesByChapter(2);

      expect(result, isA<DataSuccess<QuranVersesPage>>());
      final verses = (result as DataSuccess<QuranVersesPage>).value.verses;
      expect(verses.map((verse) => verse.verseKey.value), ['2:1', '2:3']);
    });

    test('marks arbitrary cache metadata as fetched', () async {
      final fetchedAt = DateTime.utc(2026, 1, 1, 12);

      await dataSource.markCacheFetched('reciters', fetchedAt: fetchedAt);
      final result = await dataSource.getCacheLastFetchedAt('reciters');

      expect(result, isA<DataSuccess<DateTime?>>());
      expect((result as DataSuccess<DateTime?>).value, fetchedAt);
    });
  });
}
