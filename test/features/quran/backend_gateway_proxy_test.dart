import 'package:al_mubeen/core/config/app_config.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/core/data/request_abort_handle.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/remote/islamic_app_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_audio_repository_impl.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRecordingApiClient implements QuranComApiClient {
  final List<String> requestedPaths = [];

  @override
  Future<DataResult<JsonMap>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
    RequestAbortHandle? abortHandle,
  }) async {
    requestedPaths.add(path);
    if (path.contains('chapter-reciters')) {
      return const DataSuccess({
        'audio_file': {
          'id': 1,
          'chapter_id': 1,
          'file_size': 1000,
          'format': 'mp3',
          'audio_url':
              'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/001.mp3',
        },
      });
    }
    return const DataSuccess({'ok': true});
  }

  @override
  Future<DataResult<JsonList>> getJsonList(
    String path, {
    Map<String, String> queryParameters = const {},
    RequestAbortHandle? abortHandle,
  }) async {
    requestedPaths.add(path);
    if (path == 'api/islamic/reciters') {
      return const DataSuccess([
        {
          'identifier': 'ar.alafasy',
          'name': 'مشاري العفاسي',
          'englishName': 'Mishari Rashid al-`Afasy',
          'language': 'ar',
          'format': 'audio',
          'audioLevels': ['ayah', 'surah'],
        },
      ]);
    }
    return const DataSuccess([]);
  }
}

void main() {
  setUp(() {
    AppConfig.quranBackendUrl = Uri.parse('https://quan-packend.vercel.app');
  });

  test('IslamicAppRemoteDataSource routes through backend gateway', () async {
    final mockClient = MockRecordingApiClient();
    final dataSource = IslamicAppRemoteDataSource(apiClient: mockClient);

    final result = await dataSource.fetchReciters();
    expect(result.isSuccess, isTrue);
    expect(mockClient.requestedPaths, contains('api/islamic/reciters'));
    expect(result.valueOrNull!.first.reciterName, 'مشاري العفاسي');
  });

  test(
    'QuranComRemoteDataSource routes getChapterRecitation through backend gateway',
    () async {
      final mockClient = MockRecordingApiClient();
      final dataSource = QuranComRemoteDataSource(apiClient: mockClient);

      final result = await dataSource.getChapterRecitation(
        reciterId: 7,
        surahNumber: 1,
      );
      expect(result.isSuccess, isTrue);
      expect(
        mockClient.requestedPaths,
        contains('api/chapter-reciters/7/chapter/1'),
      );
    },
  );

  test(
    'QuranAudioRepository routes Islamic and Quran.com audio through backend audio stream proxy',
    () async {
      final mockClient = MockRecordingApiClient();
      final remoteDataSource = QuranComRemoteDataSource(apiClient: mockClient);

      final repo = QuranAudioRepositoryImpl(
        remoteDataSource: remoteDataSource,
        islamicAppRecitationsFuture: () async => [
          const QuranRecitation(
            id: -100001,
            reciterName: 'مشاري العفاسي',
            identifier: 'ar.alafasy',
            hasAyahAudio: true,
            hasSurahAudio: true,
          ),
        ],
      );

      // 1. Test Islamic.app ayah audio url
      final ayahAudioResult = await repo.getAyahAudio(
        verseKey: const QuranVerseKey(surah: 1, ayah: 1),
        recitationId: -100001,
      );
      expect(ayahAudioResult.isSuccess, isTrue);
      final ayahUrl = ayahAudioResult.valueOrNull!.url;
      expect(ayahUrl.path, '/api/audio/stream');
      expect(
        ayahUrl.queryParameters['url'],
        contains('cdn.islamic.app/quran/audio/ar.alafasy/1.mp3'),
      );

      // 2. Test Islamic.app surah audio url
      final surahAudioResult = await repo.getChapterAudioUrl(
        reciterId: -100001,
        surahNumber: 1,
      );
      expect(surahAudioResult.isSuccess, isTrue);
      final surahUrl = surahAudioResult.valueOrNull!;
      expect(surahUrl.path, '/api/audio/stream');
      expect(
        surahUrl.queryParameters['url'],
        contains('cdn.islamic.app/quran/audio-surah/ar.alafasy/1.mp3'),
      );

      // 3. Test Quran.com full surah audio url
      final qfSurahResult = await repo.getChapterAudioUrl(
        reciterId: 7,
        surahNumber: 1,
      );
      expect(qfSurahResult.isSuccess, isTrue);
      final qfUrl = qfSurahResult.valueOrNull!;
      expect(qfUrl.path, '/api/audio/stream');
      expect(
        qfUrl.queryParameters['url'],
        contains('download.quranicaudio.com'),
      );
    },
  );
}
