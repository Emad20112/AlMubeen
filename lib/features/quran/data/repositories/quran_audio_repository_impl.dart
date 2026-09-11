import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/models/quran_audio_file_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:qcf_quran/qcf_quran.dart';

final class QuranAudioRepositoryImpl implements QuranAudioRepository {
  const QuranAudioRepositoryImpl({
    required QuranComRemoteDataSource remoteDataSource,
    Future<List<QuranRecitation>> Function()? islamicAppRecitationsFuture,
  }) : _remoteDataSource = remoteDataSource,
       _islamicAppRecitationsFuture = islamicAppRecitationsFuture;

  final QuranComRemoteDataSource _remoteDataSource;
  final Future<List<QuranRecitation>> Function()? _islamicAppRecitationsFuture;

  Future<(String? identifier, QuranRecitation? recitation)>
  _getIslamicAppRecitation(int recitationId) async {
    final islamicAppRecitationsFuture = _islamicAppRecitationsFuture;
    if (recitationId >= 0 || islamicAppRecitationsFuture == null) {
      return (null, null);
    }
    try {
      final list = await islamicAppRecitationsFuture();
      final match = list.where((r) => r.id == recitationId).firstOrNull;
      return (match?.identifier, match);
    } catch (_) {
      return (null, null);
    }
  }

  int _getGlobalAyahNumber(int surah, int ayah) {
    int global = 0;
    for (int i = 1; i < surah; i++) {
      global += getVerseCount(i);
    }
    return global + ayah;
  }

  @override
  Future<DataResult<QuranAudioFile>> getAyahAudio({
    required QuranVerseKey verseKey,
    required int recitationId,
  }) async {
    final (identifier, recitation) = await _getIslamicAppRecitation(
      recitationId,
    );
    if (identifier != null) {
      // Check if this reciter supports per-ayah audio
      if (recitation != null && !recitation.hasAyahAudio) {
        return const DataError(
          DataFailure(
            kind: DataFailureKind.notFound,
            message:
                'هذا القارئ لا يدعم تشغيل الآيات المفردة، جرّب تشغيل السورة كاملة.',
          ),
        );
      }
      final globalAyah = _getGlobalAyahNumber(verseKey.surah, verseKey.ayah);
      // Use direct CDN URL to avoid 302 redirects that cause just_audio issues
      final url = Uri.parse(
        'https://cdn.islamic.app/quran/audio/$identifier/$globalAyah.mp3',
      );
      return DataSuccess(QuranAudioFile(verseKey: verseKey, url: url));
    }

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

  @override
  Future<DataResult<List<QuranAudioFile>>> getSurahAudioFiles({
    required int chapterNumber,
    required int recitationId,
  }) async {
    final (identifier, recitation) = await _getIslamicAppRecitation(
      recitationId,
    );
    if (identifier != null) {
      if (recitation != null && !recitation.hasAyahAudio) {
        return const DataError(
          DataFailure(
            kind: DataFailureKind.notFound,
            message: 'هذا القارئ لا يدعم تشغيل الآيات المفردة.',
          ),
        );
      }
      // islamic.app serves one MP3 per ayah on a predictable CDN path —
      // build the full list without any API call.
      final verseCount = getVerseCount(chapterNumber);
      final files = <QuranAudioFile>[];
      for (var ayah = 1; ayah <= verseCount; ayah++) {
        final globalAyah = _getGlobalAyahNumber(chapterNumber, ayah);
        files.add(
          QuranAudioFile(
            verseKey: QuranVerseKey(surah: chapterNumber, ayah: ayah),
            url: Uri.parse(
              'https://cdn.islamic.app/quran/audio/$identifier/$globalAyah.mp3',
            ),
          ),
        );
      }
      return DataSuccess(files);
    }

    final result = await _remoteDataSource.getSurahAudioFiles(
      recitationId: recitationId,
      chapterNumber: chapterNumber,
      fetchPolicy: DataFetchPolicy.networkOnly,
    );

    return result.when(
      success: (audioFiles) => _parseSurahAudioFiles(audioFiles, chapterNumber),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<Uri>> getChapterAudioUrl({
    required int reciterId,
    required int surahNumber,
  }) async {
    final (identifier, recitation) = await _getIslamicAppRecitation(reciterId);
    if (identifier != null) {
      // Check if this reciter supports full surah audio
      if (recitation != null && !recitation.hasSurahAudio) {
        return const DataError(
          DataFailure(
            kind: DataFailureKind.notFound,
            message:
                'هذا القارئ لا يدعم تشغيل السور كاملة، جرّب تشغيل الآيات منفردة.',
          ),
        );
      }
      // Use direct CDN URL to avoid 302 redirects.
      // NOTE: islamic.app expects the surah number WITHOUT zero-padding;
      // padded URLs like 001.mp3 return 404.
      return DataSuccess(
        Uri.parse(
          'https://cdn.islamic.app/quran/audio-surah/$identifier/$surahNumber.mp3',
        ),
      );
    }

    final result = await _remoteDataSource.getChapterRecitation(
      reciterId: reciterId,
      surahNumber: surahNumber,
    );

    return result.when(
      success: (json) {
        try {
          final audioFile = json['audio_file'];
          if (audioFile is! JsonMap) {
            return DataError(
              const DataFailure(
                kind: DataFailureKind.invalidResponse,
                message: 'Expected "audio_file" to be a JSON object.',
              ),
            );
          }

          final audioUrlValue =
              audioFile['audio_url']?.toString().trim() ??
              audioFile['url']?.toString().trim();

          if (audioUrlValue == null || audioUrlValue.isEmpty) {
            return DataError(
              const DataFailure(
                kind: DataFailureKind.notFound,
                message: 'No audio_url found in chapter recitation response.',
              ),
            );
          }

          final url = _resolveAudioUrl(audioUrlValue);
          return DataSuccess(url);
        } on Object catch (error, stackTrace) {
          return DataError(
            DataFailure(
              kind: DataFailureKind.parsing,
              message: 'Failed to parse chapter recitation response.',
              cause: error,
              stackTrace: stackTrace,
            ),
          );
        }
      },
      error: DataError.new,
    );
  }

  static Uri _resolveAudioUrl(String value) {
    if (value.startsWith('//')) {
      return Uri.parse('https:$value');
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Uri.parse(value);
    }
    if (value.startsWith('mirrors.quranicaudio.com') ||
        value.startsWith('audio.qurancdn.com')) {
      return Uri.parse('https://$value');
    }
    final path = value.startsWith('/') ? value.substring(1) : value;
    return Uri.parse('https://mirrors.quranicaudio.com/$path');
  }

  DataResult<List<QuranAudioFile>> _parseSurahAudioFiles(
    JsonList audioFiles,
    int chapterNumber,
  ) {
    try {
      final List<QuranAudioFile> files = [];
      for (final value in audioFiles) {
        if (value is! JsonMap) {
          throw FormatException(
            'Expected audio file item to be a JSON object.',
            value,
          );
        }
        files.add(
          QuranAudioFileDto.fromJson(
            value,
            fallbackVerseKey: QuranVerseKey(surah: chapterNumber, ayah: 1),
          ).toDomain(),
        );
      }
      return DataSuccess(files);
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse Quran surah audio files data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unexpected Quran surah audio parsing error.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
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
