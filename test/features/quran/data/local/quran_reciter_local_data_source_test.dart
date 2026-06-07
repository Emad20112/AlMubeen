import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/data/local/quran_reciter_local_data_source.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late QuranReciterLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    dataSource = QuranReciterLocalDataSource(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('QuranReciterLocalDataSource', () {
    test('returns cache miss when recitations are not cached', () async {
      final result = await dataSource.getRecitations();

      expect(result, isA<DataError<List<QuranRecitation>>>());
      expect(
        (result as DataError<List<QuranRecitation>>).failure.kind,
        DataFailureKind.cacheMiss,
      );
    });

    test('saves and reads recitations sorted by reciter name', () async {
      final recitations = [
        const QuranRecitation(
          id: 2,
          reciterName: 'Zaki Daghistani',
          style: 'Murattal',
          translatedName: 'Zaki Daghistani',
          languageName: 'english',
        ),
        const QuranRecitation(
          id: 1,
          reciterName: 'Abdul Basit',
          style: 'Mujawwad',
          translatedName: 'Abdul Basit',
          languageName: 'english',
        ),
      ];

      final saveResult = await dataSource.saveRecitations(recitations);
      final readResult = await dataSource.getRecitations();
      final metadataResult = await dataSource.getCacheLastFetchedAt();

      expect(saveResult, isA<DataSuccess<void>>());
      expect(readResult, isA<DataSuccess<List<QuranRecitation>>>());
      final cached = (readResult as DataSuccess<List<QuranRecitation>>).value;
      expect(cached.map((recitation) => recitation.id), [1, 2]);
      expect(cached.first.style, 'Mujawwad');
      expect(cached.first.translatedName, 'Abdul Basit');
      expect(metadataResult, isA<DataSuccess<DateTime?>>());
      expect((metadataResult as DataSuccess<DateTime?>).value, isNotNull);
    });

    test(
      'keeps language caches separate and normalizes language keys',
      () async {
        await dataSource.saveRecitations(const [
          QuranRecitation(id: 1, reciterName: 'English reciter'),
          QuranRecitation(id: 2, reciterName: 'Stale English reciter'),
        ], language: ' EN ');
        await dataSource.saveRecitations(const [
          QuranRecitation(id: 3, reciterName: 'Arabic reciter'),
        ], language: 'ar');

        await dataSource.saveRecitations(const [
          QuranRecitation(id: 1, reciterName: 'Updated English reciter'),
        ], language: 'en');

        final englishResult = await dataSource.getRecitations(language: 'en');
        final arabicResult = await dataSource.getRecitations(language: 'AR');
        final englishMetadata = await dataSource.getCacheLastFetchedAt(
          language: ' en ',
        );

        expect(englishResult, isA<DataSuccess<List<QuranRecitation>>>());
        expect(arabicResult, isA<DataSuccess<List<QuranRecitation>>>());

        final english =
            (englishResult as DataSuccess<List<QuranRecitation>>).value;
        final arabic =
            (arabicResult as DataSuccess<List<QuranRecitation>>).value;

        expect(english.map((recitation) => recitation.id), [1]);
        expect(english.single.reciterName, 'Updated English reciter');
        expect(arabic.map((recitation) => recitation.id), [3]);
        expect((englishMetadata as DataSuccess<DateTime?>).value, isNotNull);
      },
    );
  });
}
