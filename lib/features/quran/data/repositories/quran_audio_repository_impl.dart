import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/models/quran_audio_file_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';

final class QuranAudioRepositoryImpl implements QuranAudioRepository {
  const QuranAudioRepositoryImpl({
    required QuranComRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final QuranComRemoteDataSource _remoteDataSource;

  @override
  Future<DataResult<QuranAudioFile>> getAyahAudio({
    required QuranVerseKey verseKey,
    required int recitationId,
  }) async {
    final result = await _remoteDataSource.getAyahAudioFiles(
      recitationId: recitationId,
      verseKey: verseKey,
      fetchPolicy: DataFetchPolicy.networkOnly,
    );

    return result.when(
      success: (audioFiles) => _parseAudioFile(audioFiles, verseKey),
      error: DataError.new,
    );
  }

  DataResult<QuranAudioFile> _parseAudioFile(
    JsonList audioFiles,
    QuranVerseKey verseKey,
  ) {
    try {
      for (final value in audioFiles) {
        if (value is! JsonMap) {
          throw FormatException(
            'Expected audio file item to be a JSON object.',
            value,
          );
        }

        final audioFile = QuranAudioFileDto.fromJson(value).toDomain();
        if (audioFile.verseKey == verseKey) {
          return DataSuccess(audioFile);
        }
      }

      return DataError(
        DataFailure(
          kind: DataFailureKind.notFound,
          message: 'No Quran audio file was returned for ${verseKey.value}.',
        ),
      );
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse Quran audio file data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unexpected Quran audio parsing error.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
