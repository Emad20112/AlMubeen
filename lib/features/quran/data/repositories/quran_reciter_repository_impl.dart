import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/local/quran_reciter_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/models/quran_reciter_dto.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';

final class QuranReciterRepositoryImpl implements QuranReciterRepository {
  const QuranReciterRepositoryImpl({
    required QuranComRemoteDataSource remoteDataSource,
    required QuranReciterLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final QuranComRemoteDataSource _remoteDataSource;
  final QuranReciterLocalDataSource _localDataSource;

  @override
  Future<DataResult<List<QuranRecitation>>> getRecitations({
    String language = 'en',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    return switch (fetchPolicy) {
      DataFetchPolicy.cacheOnly => _localDataSource.getRecitations(
        language: language,
      ),
      DataFetchPolicy.networkOnly || DataFetchPolicy.refresh =>
        _fetchRemoteAndCache(language: language),
      DataFetchPolicy.networkFirst => _networkFirst(language),
      DataFetchPolicy.cacheFirst => _cacheFirst(language),
    };
  }

  Future<DataResult<List<QuranRecitation>>> _cacheFirst(String language) async {
    final cached = await _localDataSource.getRecitations(language: language);
    if (cached is DataSuccess<List<QuranRecitation>>) {
      return cached;
    }

    return _fetchRemoteAndCache(language: language);
  }

  Future<DataResult<List<QuranRecitation>>> _networkFirst(
    String language,
  ) async {
    final remote = await _fetchRemoteAndCache(language: language);
    if (remote is DataSuccess<List<QuranRecitation>>) {
      return remote;
    }

    final cached = await _localDataSource.getRecitations(language: language);
    if (cached is DataSuccess<List<QuranRecitation>>) {
      return cached;
    }

    return remote;
  }

  Future<DataResult<List<QuranRecitation>>> _fetchRemoteAndCache({
    required String language,
  }) async {
    final result = await _remoteDataSource.getRecitations(
      language: language,
      fetchPolicy: DataFetchPolicy.networkOnly,
    );

    if (result is DataError<JsonList>) {
      return DataError(result.failure);
    }

    final parsedResult = _parseRecitations(
      (result as DataSuccess<JsonList>).value,
    );
    final parsed = parsedResult.valueOrNull;
    if (parsed != null) {
      await _localDataSource.saveRecitations(parsed, language: language);
    }

    return parsedResult;
  }

  DataResult<List<QuranRecitation>> _parseRecitations(JsonList jsonList) {
    try {
      final recitations = jsonList.map((value) {
        if (value is! JsonMap) {
          throw FormatException(
            'Expected recitation item to be a JSON object.',
            value,
          );
        }

        return QuranRecitationDto.fromJson(value).toDomain();
      }).toList(growable: false);

      return DataSuccess(recitations);
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse Quran.com recitation data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unexpected Quran.com recitation parsing error.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
