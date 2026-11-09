import 'package:al_mubeen/core/config/app_config.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/core/data/request_abort_handle.dart';
import 'package:al_mubeen/features/quran/data/models/chapter_audio_model.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_audio_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeChapterApiClient implements QuranComApiClient {
  _FakeChapterApiClient(this.responsePayload);

  final JsonMap responsePayload;

  @override
  Future<DataResult<JsonMap>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
    RequestAbortHandle? abortHandle,
  }) async {
    return DataSuccess(responsePayload);
  }

  @override
  Future<DataResult<JsonList>> getJsonList(
    String path, {
    Map<String, String> queryParameters = const {},
    RequestAbortHandle? abortHandle,
  }) async {
    return const DataSuccess([]);
  }
}

void main() {
  setUp(() {
    AppConfig.quranBackendUrl = Uri.parse('https://backend.example.com');
  });

  group('ChapterAudioData Validation Requirements', () {
    // Al-Fatihah (Chapter 1) has 7 ayahs.
    List<ChapterVerseTiming> generateFatihahTimestamps({
      int count = 7,
      int Function(int index)? startMsOverride,
      int Function(int index)? endMsOverride,
      int Function(int index)? ayahOverride,
      int Function(int index)? surahOverride,
    }) {
      final list = <ChapterVerseTiming>[];
      int currentStart = 0;
      for (int i = 0; i < count; i++) {
        final ayah = ayahOverride != null ? ayahOverride(i) : i + 1;
        final surah = surahOverride != null ? surahOverride(i) : 1;
        final start = startMsOverride != null ? startMsOverride(i) : currentStart;
        final end = endMsOverride != null ? endMsOverride(i) : start + 3000;
        currentStart = end;

        list.add(
          ChapterVerseTiming(
            verseKey: '$surah:$ayah',
            surah: surah,
            ayah: ayah,
            startMs: start,
            endMs: end,
          ),
        );
      }
      return list;
    }

    test('Valid complete timestamps passes validation', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(),
      );

      final result = data.validate();
      expect(result.isValid, isTrue);
      expect(result.reason, isNull);
    });

    test('Fails when audioUrl is empty', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse(''),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(),
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Audio URL is empty'));
    });

    test('Fails when timestamps list is empty', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: const [],
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Timestamps list is empty'));
    });

    test('Fails when timestamps count does not match chapter verse count', () {
      // 5 ayahs instead of 7 for Surah Al-Fatihah
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(count: 5),
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('does not match chapter verse count'));
    });

    test('Fails when surah number does not match requested chapter', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(
          surahOverride: (i) => i == 2 ? 2 : 1,
        ),
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('expected 1'));
    });

    test('Fails when verses are not sequential', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(
          ayahOverride: (i) => i == 1 ? 5 : i + 1,
        ),
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('expected sequential'));
    });

    test('Fails when timestamps have negative values', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(
          startMsOverride: (i) => i == 0 ? -100 : i * 3000,
        ),
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Negative timestamp'));
    });

    test('Fails when endMs is less than or equal to startMs', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(
          startMsOverride: (i) => i == 2 ? 6000 : i * 3000,
          endMsOverride: (i) => i == 2 ? 5500 : (i + 1) * 3000,
        ),
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('endMs (5500) <= startMs (6000)'));
    });

    test('Fails when timestamps are not in ascending order', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(
          startMsOverride: (i) => i == 3 ? 1000 : i * 3000,
          endMsOverride: (i) => i == 3 ? 2000 : (i + 1) * 3000,
        ),
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Timestamps not ascending'));
    });

    test('Fails when timestamps have unreasonable overlap', () {
      final data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 22000,
        timestamps: generateFatihahTimestamps(
          startMsOverride: (i) => i == 2 ? 3000 : i * 3000, // verse 2 starts 3s before verse 1 ends (6000)
          endMsOverride: (i) => (i + 1) * 3000,
        ),
      );

      final result = data.validate();
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Unreasonable timestamp overlap'));
    });
  });

  group('Binary Search on ChapterAudioData', () {
    late ChapterAudioData data;

    setUp(() {
      data = ChapterAudioData(
        chapterNumber: 1,
        reciterId: 7,
        audioUrl: Uri.parse('https://example.com/001.mp3'),
        format: 'mp3',
        durationMs: 21000,
        timestamps: [
          const ChapterVerseTiming(verseKey: '1:1', surah: 1, ayah: 1, startMs: 0, endMs: 3000),
          const ChapterVerseTiming(verseKey: '1:2', surah: 1, ayah: 2, startMs: 3000, endMs: 6000),
          const ChapterVerseTiming(verseKey: '1:3', surah: 1, ayah: 3, startMs: 6000, endMs: 9000),
          const ChapterVerseTiming(verseKey: '1:4', surah: 1, ayah: 4, startMs: 9000, endMs: 12000),
          const ChapterVerseTiming(verseKey: '1:5', surah: 1, ayah: 5, startMs: 12000, endMs: 15000),
          const ChapterVerseTiming(verseKey: '1:6', surah: 1, ayah: 6, startMs: 15000, endMs: 18000),
          const ChapterVerseTiming(verseKey: '1:7', surah: 1, ayah: 7, startMs: 18000, endMs: 21000),
        ],
      );
    });

    test('Accurately finds ayah for exact and intermediate positions', () {
      expect(data.findAyahAtPosition(0)?.ayah, 1);
      expect(data.findAyahAtPosition(1500)?.ayah, 1);
      expect(data.findAyahAtPosition(2999)?.ayah, 1);

      expect(data.findAyahAtPosition(3000)?.ayah, 2);
      expect(data.findAyahAtPosition(5999)?.ayah, 2);

      expect(data.findAyahAtPosition(6000)?.ayah, 3);
      expect(data.findAyahAtPosition(10500)?.ayah, 4);
      expect(data.findAyahAtPosition(19500)?.ayah, 7);
    });

    test('Boundary positions beyond end map to last ayah', () {
      expect(data.findAyahAtPosition(25000)?.ayah, 7);
    });

    test('getStartMsForAyah returns accurate start time for seeking', () {
      expect(data.getStartMsForAyah(1), 0);
      expect(data.getStartMsForAyah(4), 9000);
      expect(data.getStartMsForAyah(7), 18000);
      expect(data.getStartMsForAyah(8), isNull);
    });
  });

  group('QuranAudioRepositoryImpl getChapterAudioData', () {
    test('Successfully fetches and parses chapter audio and timestamps', () async {
      final mockClient = _FakeChapterApiClient({
        'audio_file': {
          'audio_url': 'https://download.quranicaudio.com/qdc/mishari/001.mp3',
          'duration': 21,
          'file_size': 500000,
          'format': 'mp3',
          'timestamps': [
            {'verse_key': '1:1', 'timestamp_from': 0, 'timestamp_to': 3000, 'duration': 3000},
            {'verse_key': '1:2', 'timestamp_from': 3000, 'timestamp_to': 6000, 'duration': 3000},
            {'verse_key': '1:3', 'timestamp_from': 6000, 'timestamp_to': 9000, 'duration': 3000},
            {'verse_key': '1:4', 'timestamp_from': 9000, 'timestamp_to': 12000, 'duration': 3000},
            {'verse_key': '1:5', 'timestamp_from': 12000, 'timestamp_to': 15000, 'duration': 3000},
            {'verse_key': '1:6', 'timestamp_from': 15000, 'timestamp_to': 18000, 'duration': 3000},
            {'verse_key': '1:7', 'timestamp_from': 18000, 'timestamp_to': 21000, 'duration': 3000},
          ],
        },
      });

      final remoteDataSource = QuranComRemoteDataSource(apiClient: mockClient);
      final repo = QuranAudioRepositoryImpl(remoteDataSource: remoteDataSource);

      final result = await repo.getChapterAudioData(reciterId: 7, surahNumber: 1);
      expect(result.isSuccess, isTrue);

      final chapterData = result.valueOrNull!;
      expect(chapterData.chapterNumber, 1);
      expect(chapterData.reciterId, 7);
      expect(chapterData.audioUrl.path, '/api/audio/stream');
      expect(chapterData.audioUrl.queryParameters['url'], contains('download.quranicaudio.com'));
      expect(chapterData.timestamps.length, 7);
      expect(chapterData.validate().isValid, isTrue);
    });
  });
}
