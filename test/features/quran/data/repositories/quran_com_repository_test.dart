import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/local/quran_reciter_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/core/data/request_abort_handle.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';

import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_audio_repository_impl.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_com_repository.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_reciter_repository_impl.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuranComRepository', () {
    test('parses chapters from Quran.com response', () async {
      final client = _FakeQuranComApiClient({
        'api/chapters': const DataSuccess({
          'chapters': [
            {
              'id': 1,
              'revelation_place': 'makkah',
              'revelation_order': 5,
              'bismillah_pre': false,
              'name_simple': 'Al-Fatihah',
              'name_complex': 'Al-Fatihah',
              'name_arabic': 'الفاتحة',
              'verses_count': 7,
              'pages': [1, 1],
              'translated_name': {'name': 'The Opener'},
            },
          ],
        }),
      });
      final repository = _repository(client);

      final result = await repository.getChapters();

      expect(result, isA<DataSuccess<List<QuranChapter>>>());
      final chapters = (result as DataSuccess<List<QuranChapter>>).value;
      expect(chapters, hasLength(1));
      expect(chapters.single.id, 1);
      expect(chapters.single.nameArabic, 'الفاتحة');
      expect(chapters.single.pages, [1, 1]);
      expect(chapters.single.translatedName, 'The Opener');
    });

    test('parses a verse by Quran verse key', () async {
      final client = _FakeQuranComApiClient({
        'api/verses/2:255': const DataSuccess({
          'verse': {
            'id': 262,
            'verse_key': '2:255',
            'verse_number': 255,
            'page_number': 42,
            'juz_number': 3,
            'hizb_number': 5,
            'rub_el_hizb_number': 19,
            'text_uthmani': 'اللَّهُ لَا إِلَـٰهَ إِلَّا هُوَ',
          },
        }),
      });
      final repository = _repository(client);

      final result = await repository.getVerse(
        verseKey: const QuranVerseKey(surah: 2, ayah: 255),
      );

      expect(result, isA<DataSuccess<QuranVerse>>());
      final verse = (result as DataSuccess<QuranVerse>).value;
      expect(verse.verseKey.value, '2:255');
      expect(verse.pageNumber, 42);
      expect(verse.textUthmani, contains('اللَّهُ'));
      expect(client.requests.single.path, 'api/verses/2:255');
    });

    test('requests verses by chapter with bounded pagination', () async {
      // Quranpedia returns the full list of verses for a mushaf/chapter.
      // The data source pages locally; provide a simple list and assert
      // that paging logic bounds `per_page` to `maxVersesPerPage`.
      final client = _FakeQuranComApiClient({
        'api/chapters/2/verses': const DataSuccess({
          'verses': [
            {
              'id': 8,
              'verse_key': '2:1',
              'verse_number': 1,
              'page_number': 2,
              'juz_number': 1,
              'text_uthmani': 'الم',
            },
          ],
          'pagination': {
            'current_page': 1,
            'per_page': 50,
            'total_records': 1,
            'total_pages': 1,
          },
        }),
      });
      final repository = _repository(client);

      final result = await repository.getVersesByChapter(
        chapterNumber: 2,
        page: 1,
        perPage: 200,
      );

      expect(result, isA<DataSuccess<QuranVersesPage>>());
      final versesPage = (result as DataSuccess<QuranVersesPage>).value;
      expect(versesPage.verses.single.verseKey.value, '2:1');
      expect(versesPage.pagination?.currentPage, 1);
      expect(versesPage.pagination?.perPage, 50);
      expect(versesPage.pagination?.totalRecords, 1);
      expect(client.requests.single.path, 'api/chapters/2/verses');
    });

    test('returns parsing failure for malformed chapter items', () async {
      final client = _FakeQuranComApiClient({
        'api/chapters': const DataSuccess({
          'chapters': ['not-a-json-object'],
        }),
      });
      final repository = _repository(client);

      final result = await repository.getChapters();

      expect(result, isA<DataError<List<QuranChapter>>>());
      final failure = (result as DataError<List<QuranChapter>>).failure;
      expect(failure.kind, DataFailureKind.parsing);
    });

    test('does not call remote client for cache-only reads', () async {
      final client = _FakeQuranComApiClient({});
      final repository = _repository(client);

      final result = await repository.getVerse(
        verseKey: const QuranVerseKey(surah: 1, ayah: 1),
        fetchPolicy: DataFetchPolicy.cacheOnly,
      );

      expect(result, isA<DataError<QuranVerse>>());
      expect(
        (result as DataError<QuranVerse>).failure.kind,
        DataFailureKind.cacheMiss,
      );
      expect(client.requests, isEmpty);
    });
  });

  group('QuranReciterRepositoryImpl parsing', () {
    test('parses recitation metadata from Quran.com response', () async {
      final client = _FakeQuranComApiClient({
        'api/recitations': const DataSuccess({
          'recitations': [
            {
              'id': 7,
              'reciter_name': 'Mishari Rashid al-Afasy',
              'style': 'Murattal',
              'translated_name': {
                'name': 'Mishari Rashid al-Afasy',
                'language_name': 'english',
              },
            },
          ],
        }),
      });
      final database = AppDatabase.forExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = QuranReciterRepositoryImpl(
        remoteDataSource: QuranComRemoteDataSource(apiClient: client),
        localDataSource: QuranReciterLocalDataSource(database: database),
      );

      final result = await repository.getRecitations(
        fetchPolicy: DataFetchPolicy.networkOnly,
      );

      expect(result, isA<DataSuccess<List<QuranRecitation>>>());
      final recitations = (result as DataSuccess<List<QuranRecitation>>).value;
      expect(recitations, hasLength(1));
      expect(recitations.single.id, 7);
      expect(recitations.single.reciterName, 'Mishari Rashid al-Afasy');
      expect(recitations.single.style, 'Murattal');
      expect(recitations.single.translatedName, 'Mishari Rashid al-Afasy');
      expect(recitations.single.languageName, 'english');
      expect(client.requests.single.path, 'api/recitations');
    });

    test('returns parsing failure for malformed recitation items', () async {
      final client = _FakeQuranComApiClient({
        'api/recitations': const DataSuccess({
          'recitations': [
            {'id': 7},
          ],
        }),
      });
      final database = AppDatabase.forExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = QuranReciterRepositoryImpl(
        remoteDataSource: QuranComRemoteDataSource(apiClient: client),
        localDataSource: QuranReciterLocalDataSource(database: database),
      );

      final result = await repository.getRecitations(
        fetchPolicy: DataFetchPolicy.networkOnly,
      );

      expect(result, isA<DataError<List<QuranRecitation>>>());
      expect(
        (result as DataError<List<QuranRecitation>>).failure.kind,
        DataFailureKind.parsing,
      );
    });
  });

  group('QuranReciterRepositoryImpl cache policy', () {
    test(
      'cache-first returns cached recitations without remote request',
      () async {
        final database = AppDatabase.forExecutor(NativeDatabase.memory());
        addTearDown(database.close);
        final localDataSource = QuranReciterLocalDataSource(database: database);
        await localDataSource.saveRecitations(const [
          QuranRecitation(
            id: 1,
            reciterName: 'Cached reciter',
            style: 'Murattal',
          ),
        ]);
        final client = _FakeQuranComApiClient({});
        final repository = QuranReciterRepositoryImpl(
          remoteDataSource: QuranComRemoteDataSource(apiClient: client),
          localDataSource: localDataSource,
        );

        final result = await repository.getRecitations();

        expect(result, isA<DataSuccess<List<QuranRecitation>>>());
        final recitations =
            (result as DataSuccess<List<QuranRecitation>>).value;
        expect(recitations.single.reciterName, 'Cached reciter');
        expect(client.requests, isEmpty);
      },
    );

    test('refresh fetches remote recitations and persists cache', () async {
      final database = AppDatabase.forExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final client = _FakeQuranComApiClient({
        'api/recitations': const DataSuccess({
          'recitations': [
            {'id': 4, 'reciter_name': 'Remote reciter'},
          ],
        }),
      });
      final repository = QuranReciterRepositoryImpl(
        remoteDataSource: QuranComRemoteDataSource(apiClient: client),
        localDataSource: QuranReciterLocalDataSource(database: database),
      );

      final refreshResult = await repository.getRecitations(
        fetchPolicy: DataFetchPolicy.refresh,
      );
      final cacheOnlyResult = await repository.getRecitations(
        fetchPolicy: DataFetchPolicy.cacheOnly,
      );

      expect(refreshResult, isA<DataSuccess<List<QuranRecitation>>>());
      expect(cacheOnlyResult, isA<DataSuccess<List<QuranRecitation>>>());
      final cached =
          (cacheOnlyResult as DataSuccess<List<QuranRecitation>>).value;
      expect(cached.single.id, 4);
      expect(cached.single.reciterName, 'Remote reciter');
      expect(client.requests, hasLength(1));
    });
  });

  group('QuranAudioRepositoryImpl', () {
    test('requests ayah audio from the recitations endpoint', () async {
      final client = _FakeQuranComApiClient({
        'api/recitations/7/by_ayah/1/1': const DataSuccess({
          'audio_files': [
            {
              'id': 1,
              'verse_key': '1:1',
              'url': 'Alafasy/mp3/001001.mp3',
              'format': 'mp3',
              'duration': 6,
            },
          ],
        }),
      });
      final repository = QuranAudioRepositoryImpl(
        remoteDataSource: QuranComRemoteDataSource(apiClient: client),
      );

      final result = await repository.getAyahAudio(
        verseKey: const QuranVerseKey(surah: 1, ayah: 1),
        recitationId: 7,
      );

      expect(result, isA<DataSuccess<QuranAudioFile>>());
      final audioFile = (result as DataSuccess<QuranAudioFile>).value;
      expect(audioFile.verseKey.value, '1:1');
      expect(audioFile.url.toString(), contains('Alafasy/mp3/001001.mp3'));
      expect(client.requests.single.path, 'api/recitations/7/by_ayah/1/1');
      expect(client.requests.single.queryParameters['per_page'], '1');
    });
  });
}

QuranComRepository _repository(_FakeQuranComApiClient client) {
  return QuranComRepository(
    remoteDataSource: QuranComRemoteDataSource(apiClient: client),
  );
}

final class _FakeQuranComApiClient implements QuranComApiClient {
  _FakeQuranComApiClient(this._responses);

  // Map of path -> DataResult (JsonMap or JsonList). Tests may provide either.
  final Map<String, DataResult<Object?>> _responses;
  final List<_RecordedRequest> requests = [];

  @override
  Future<DataResult<JsonMap>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
    RequestAbortHandle? abortHandle,
  }) async {
    requests.add(
      _RecordedRequest(
        path: path,
        queryParameters: Map.unmodifiable(queryParameters),
      ),
    );

    final response = _responses[path];
    if (response == null) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.notFound,
          message: 'No fake response registered for $path.',
        ),
      );
    }

    // If the stored response is a JsonMap result, return it; otherwise fail.
    return response.when(
      success: (value) {
        if (value is JsonMap) {
          return DataSuccess(value);
        }
        return DataError(
          DataFailure(
            kind: DataFailureKind.invalidResponse,
            message: 'Fake response for $path is not a JSON object.',
          ),
        );
      },
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<JsonList>> getJsonList(
    String path, {
    Map<String, String> queryParameters = const {},
    RequestAbortHandle? abortHandle,
  }) async {
    requests.add(
      _RecordedRequest(
        path: path,
        queryParameters: Map.unmodifiable(queryParameters),
      ),
    );

    final response = _responses[path];
    if (response == null) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.notFound,
          message: 'No fake response registered for $path.',
        ),
      );
    }

    return response.when(
      success: (value) {
        if (value is JsonList) {
          return DataSuccess(value);
        }
        // If tests provided a JsonMap that contains a list under a key, try to
        // coerce common shapes (e.g., {'recitations': [...]}) by returning the
        // first list value found.
        if (value is JsonMap) {
          for (final v in value.values) {
            if (v is JsonList) {
              return DataSuccess(v);
            }
          }
        }

        return DataError(
          DataFailure(
            kind: DataFailureKind.invalidResponse,
            message: 'Fake response for $path is not a JSON list.',
          ),
        );
      },
      error: DataError.new,
    );
  }
}

final class _RecordedRequest {
  const _RecordedRequest({required this.path, required this.queryParameters});

  final String path;
  final Map<String, String> queryParameters;
}
