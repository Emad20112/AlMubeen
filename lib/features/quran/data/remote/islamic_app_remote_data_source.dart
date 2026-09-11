import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/helpers/reciter_normalizer.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';

final class IslamicAppRemoteDataSource {
  const IslamicAppRemoteDataSource({required QuranComApiClient apiClient})
    : _apiClient = apiClient;

  final QuranComApiClient _apiClient;

  Future<DataResult<List<QuranRecitation>>> fetchReciters() async {
    final result = await _apiClient.getJsonList('reciters');
    return result.when(success: _parseReciters, error: DataError.new);
  }

  DataResult<List<QuranRecitation>> _parseReciters(JsonList jsonList) {
    try {
      final recitations = jsonList
          .map((value) {
            if (value is! JsonMap) {
              throw FormatException(
                'Expected Islamic.app reciter item to be a JSON object.',
                value,
              );
            }

            final identifier = value['identifier']?.toString();
            if (identifier == null || identifier.isEmpty) {
              throw FormatException(
                'Expected Islamic.app reciter identifier to be a non-empty string.',
                value,
              );
            }

            final audioLevelsRaw = value['audioLevels'];
            final audioLevels = audioLevelsRaw is List
                ? audioLevelsRaw
                      .map((item) => item.toString().toLowerCase())
                      .toList()
                : const <String>[];

            final hasAyah = audioLevels.isEmpty || audioLevels.contains('ayah');
            final hasSurah =
                audioLevels.isEmpty || audioLevels.contains('surah');

            return QuranRecitation(
              id: stableNegativeReciterId(identifier),
              reciterName: value['name']?.toString() ?? 'Unknown',
              translatedName: value['englishName']?.toString(),
              languageName: value['language']?.toString(),
              style: value['format'] == 'audio' ? 'Islamic.app' : null,
              identifier: identifier,
              hasAyahAudio: hasAyah,
              hasSurahAudio: hasSurah,
            );
          })
          .toList(growable: false);

      return DataSuccess(recitations);
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse Islamic.app reciter data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unexpected Islamic.app reciter parsing error.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
