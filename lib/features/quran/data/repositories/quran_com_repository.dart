import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/models/quran_chapter_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_pagination_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';

final class QuranComRepository implements QuranRepository {
  const QuranComRepository({required QuranComRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final QuranComRemoteDataSource _remoteDataSource;

  @override
  Future<DataResult<List<QuranChapter>>> getChapters({
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getChapters(
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (chapters) {
        return _parse(() {
          return chapters.map(_chapterFromJson).toList(growable: false);
        });
      },
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<QuranChapter>> getChapter({
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getChapter(
      chapterNumber: chapterNumber,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (chapter) =>
          _parse(() => QuranChapterDto.fromJson(chapter).toDomain()),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<QuranVerse>> getVerse({
    required QuranVerseKey verseKey,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getVerse(
      verseKey: verseKey,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (verse) =>
          _parse(() => QuranVerseDto.fromJson(verse).toDomain()),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<QuranVersesPage>> getVersesByChapter({
    required int chapterNumber,
    int page = 1,
    int perPage = QuranComRemoteDataSource.maxVersesPerPage,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getVersesPageByChapter(
      chapterNumber: chapterNumber,
      page: page,
      perPage: perPage,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (json) => _parse(() => _versesPageFromJson(json).toDomain()),
      error: DataError.new,
    );
  }

  QuranChapter _chapterFromJson(Object? value) {
    if (value is! JsonMap) {
      throw FormatException(
        'Expected chapter item to be a JSON object.',
        value,
      );
    }

    return QuranChapterDto.fromJson(value).toDomain();
  }

  QuranVersesPageDto _versesPageFromJson(JsonMap json) {
    final versesJson = json['verses'];
    if (versesJson is! JsonList) {
      throw FormatException('Expected "verses" to be a JSON list.', json);
    }

    final verses = versesJson
        .map((value) {
          if (value is! JsonMap) {
            throw FormatException(
              'Expected verse item to be a JSON object.',
              value,
            );
          }

          return QuranVerseDto.fromJson(value);
        })
        .toList(growable: false);

    final paginationJson = json['pagination'];
    final pagination = paginationJson is JsonMap
        ? QuranPaginationDto.fromJson(paginationJson)
        : null;

    return QuranVersesPageDto(verses: verses, pagination: pagination);
  }

  DataResult<T> _parse<T>(T Function() parser) {
    try {
      return DataSuccess(parser());
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse Quran.com data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unexpected Quran.com parsing error.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
