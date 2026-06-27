import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/contracts/quran_data_source.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';

final class QuranComRemoteDataSource implements QuranDataSource {
  QuranComRemoteDataSource({required QuranComApiClient apiClient})
    : _apiClient = apiClient;

  static const int maxVersesPerPage = 50;

  static const _verseFields =
      'text_uthmani,text_uthmani_simple,verse_key,verse_number,'
      'page_number,juz_number,hizb_number,rub_el_hizb_number,sajdah_number,id';

  final QuranComApiClient _apiClient;

  Future<DataResult<JsonList>> getRecitations({
    String language = 'ar',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson(
      'api/recitations',
      queryParameters: {'language': language},
    );

    return result.when(
      success: (json) => _readList(DataSuccess(json), 'recitations'),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<JsonList>> getChapters({
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson('api/chapters');
    return _readList(result, 'chapters');
  }

  @override
  Future<DataResult<JsonMap>> getChapter({
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson('api/chapters/$chapterNumber');
    return _readObject(result, 'chapter');
  }

  @override
  Future<DataResult<JsonMap>> getVerse({
    required QuranVerseKey verseKey,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson(
      'api/verses/${verseKey.value}',
      queryParameters: const {'fields': _verseFields},
    );
    return _readObject(result, 'verse');
  }

  @override
  Future<DataResult<JsonList>> getVersesByChapter({
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson(
      'api/chapters/$chapterNumber/verses',
      queryParameters: const {
        'fields': _verseFields,
        'per_page': '$maxVersesPerPage',
      },
    );

    return _readList(result, 'verses');
  }

  Future<DataResult<JsonMap>> getVersesPageByChapter({
    required int chapterNumber,
    int page = 1,
    int perPage = maxVersesPerPage,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final boundedPerPage = perPage.clamp(1, maxVersesPerPage);
    final boundedPage = page < 1 ? 1 : page;

    return _apiClient.getJson(
      'api/chapters/$chapterNumber/verses',
      queryParameters: {
        'fields': _verseFields,
        'page': '$boundedPage',
        'per_page': '$boundedPerPage',
      },
    );
  }

  Future<DataResult<JsonList>> getTafsirsByChapter({
    required int chapterNumber,
    String language = 'en',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson(
      'api/tafsirs',
      queryParameters: {'language': language},
    );
    return _readList(result, 'tafsirs');
  }

  Future<DataResult<JsonList>> getTranslationsByChapter({
    required int chapterNumber,
    String language = 'en',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson(
      'api/translations',
      queryParameters: {'language': language},
    );
    return _readList(result, 'translations');
  }

  Future<DataResult<JsonMap>> getTafsirForAyah({
    required int chapterNumber,
    required int ayahNumber,
    required int bookId,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    return _apiClient.getJson(
      'api/tafsirs/$bookId/chapter/$chapterNumber',
      queryParameters: {'verse_key': '$chapterNumber:$ayahNumber'},
    );
  }

  Future<DataResult<JsonMap>> getTafsirChapter({
    required int chapterNumber,
    required int bookId,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    return _apiClient.getJson('api/tafsirs/$bookId/chapter/$chapterNumber');
  }

  Future<DataResult<JsonMap>> getTranslationChapter({
    required int chapterNumber,
    required int bookId,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    return _apiClient.getJson(
      'api/translations',
      queryParameters: {
        'resourceId': '$bookId',
        'chapterNumber': '$chapterNumber',
        'translation_fields':
            'text,resource_name,verse_key,verse_number,chapter_id,resource_id',
      },
    );
  }

  Future<DataResult<JsonList>> getAyahAudioFiles({
    required int recitationId,
    required QuranVerseKey verseKey,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final parsed = _parseVerseKey(verseKey.value);
    if (parsed == null) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.invalidResponse,
          message: 'Unable to parse verse key: ${verseKey.value}',
        ),
      );
    }

    final result = await _apiClient.getJson(
      'api/recitations/$recitationId/by_ayah/${parsed.$1}/${parsed.$2}',
      queryParameters: const {
        'fields': 'id,verse_key,url,format,duration',
        'per_page': '1',
      },
    );

    return _readList(result, 'audio_files');
  }

  DataResult<JsonMap> _readObject(DataResult<JsonMap> result, String key) {
    return result.when(
      success: (json) {
        final value = json[key];
        if (value is JsonMap) {
          return DataSuccess(value);
        }

        return DataError(
          DataFailure(
            kind: DataFailureKind.invalidResponse,
            message: 'Expected "$key" to be a JSON object.',
          ),
        );
      },
      error: DataError.new,
    );
  }

  DataResult<JsonList> _readList(DataResult<JsonMap> result, String key) {
    return result.when(
      success: (json) {
        final value = json[key];
        if (value is JsonList) {
          return DataSuccess(value);
        }

        return DataError(
          DataFailure(
            kind: DataFailureKind.invalidResponse,
            message: 'Expected "$key" to be a JSON list.',
          ),
        );
      },
      error: DataError.new,
    );
  }

  (int, int)? _parseVerseKey(String value) {
    final normalized = value.trim();
    final parts = normalized.split(RegExp(r'[:\-/]'));
    if (parts.length < 2) {
      return null;
    }

    final chapter = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (chapter == null || ayah == null) {
      return null;
    }

    return (chapter, ayah);
  }

  DataError<T> _cacheMiss<T>() {
    return const DataError(
      DataFailure(
        kind: DataFailureKind.cacheMiss,
        message:
            'Remote Quran backend data source cannot satisfy cache-only reads.',
      ),
    );
  }
}
