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

  static const int defaultMushafId = 1;
  static const int maxVersesPerPage = 50;

  final QuranComApiClient _apiClient;

  /// Quranpedia reciters endpoint returns grouped reciters.
  /// This method flattens them into a single list for UI consumption.
  Future<DataResult<JsonList>> getRecitations({
    String language = 'ar',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJsonList(
      'reciters',
      queryParameters: {'language': language},
    );

    return result.when(
      success: (groups) => DataSuccess(_flattenReciterGroups(groups)),
      error: DataError.new,
    );
  }

  /// Optional helper if your UI wants the raw grouped response.
  Future<DataResult<JsonList>> getGroupedRecitations({
    String language = 'ar',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    return _apiClient.getJsonList(
      'reciters',
      queryParameters: {'language': language},
    );
  }

  /// Chapter/surah metadata from Quranpedia's Hafs mushaf.
  @override
  Future<DataResult<JsonList>> getChapters({
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson('mushafs/$defaultMushafId');
    return _readList(result, 'surahs');
  }

  /// Surah metadata for a single chapter.
  @override
  Future<DataResult<JsonMap>> getChapter({
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    return _apiClient.getJson('surah/information/$chapterNumber');
  }

  /// Single ayah from the Hafs mushaf.
  @override
  Future<DataResult<JsonMap>> getVerse({
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
      'mushafs/$defaultMushafId/${parsed.$1}/${parsed.$2}',
    );
    return result;
  }

  /// All ayahs for a surah.
  @override
  Future<DataResult<JsonList>> getVersesByChapter({
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    return _apiClient.getJsonList('mushafs/$defaultMushafId/$chapterNumber');
  }

  /// Quranpedia does not page ayahs in this endpoint, so we page locally.
  Future<DataResult<JsonMap>> getVersesPageByChapter({
    required int chapterNumber,
    int page = 1,
    int perPage = maxVersesPerPage,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final versesResult = await getVersesByChapter(
      chapterNumber: chapterNumber,
      fetchPolicy: fetchPolicy,
    );

    return versesResult.when(
      success: (verses) {
        final boundedPerPage = perPage.clamp(1, maxVersesPerPage);
        final boundedPage = page < 1 ? 1 : page;
        final start = (boundedPage - 1) * boundedPerPage;
        final end = (start + boundedPerPage).clamp(0, verses.length);
        final pageItems = start >= verses.length
            ? <dynamic>[]
            : verses.sublist(start, end);

        final totalRecords = verses.length;
        final totalPages = (totalRecords / boundedPerPage).ceil();
        final nextPage = boundedPage < totalPages ? boundedPage + 1 : null;

        return DataSuccess(<String, dynamic>{
          'verses': pageItems,
          'pagination': {
            'current_page': boundedPage,
            'per_page': boundedPerPage,
            'next_page': nextPage,
            'total_pages': totalPages,
            'total_records': totalRecords,
          },
        });
      },
      error: DataError.new,
    );
  }

  /// Tafsir books available for a given surah.
  Future<DataResult<JsonList>> getTafsirsByChapter({
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    return _apiClient.getJsonList('surah/tafsirs/$chapterNumber');
  }

  /// Tafsir content for a single ayah from a specific tafsir book.
  Future<DataResult<JsonMap>> getTafsirForAyah({
    required int chapterNumber,
    required int ayahNumber,
    required int bookId,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    return _apiClient.getJson('ayah/$chapterNumber/$ayahNumber/book/$bookId');
  }

  /// Audio files for a single ayah from a recitation.
  /// Quranpedia exposes recitation resources under `resources/recitations`.
  Future<DataResult<JsonList>> getAyahAudioFiles({
    required int recitationId,
    required QuranVerseKey verseKey,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    if (!fetchPolicy.canReadNetwork) {
      return _cacheMiss();
    }

    final result = await _apiClient.getJson(
      'resources/recitations/$recitationId/by_ayah/${verseKey.value}',
      queryParameters: const {
        'fields': 'id,verse_key,url,format,duration',
        'per_page': '1',
      },
    );

    return _readList(result, 'audio_files');
  }

  DataResult<JsonMap> _readMap(DataResult<JsonMap> result, String key) {
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

  List<dynamic> _flattenReciterGroups(JsonList groups) {
    final reciters = <dynamic>[];

    for (final group in groups) {
      if (group is JsonList) {
        reciters.addAll(group);
      } else if (group is JsonMap) {
        reciters.add(group);
      }
    }

    return reciters;
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
            'Remote Quranpedia data source cannot satisfy cache-only reads.',
      ),
    );
  }
}
