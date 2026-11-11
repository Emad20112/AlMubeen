import 'package:al_mubeen/core/config/app_config.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/core/data/request_abort_handle.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_highlight_controller.dart';
import 'package:al_mubeen/features/quran/data/models/chapter_audio_model.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_audio_repository_impl.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTestApiClient implements QuranComApiClient {
  _FakeTestApiClient({required this.chapterResponse});

  final JsonMap chapterResponse;

  @override
  Future<DataResult<JsonMap>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
    RequestAbortHandle? abortHandle,
  }) async {
    return DataSuccess(chapterResponse);
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

  group('Hybrid Audio Engine & Highlighting Integration Tests', () {
    test('Automatic selection: Chapter mode when valid timestamps are returned', () async {
      final validPayload = {
        'audio_file': {
          'audio_url': 'https://download.quranicaudio.com/qdc/mishari/001.mp3',
          'duration': 21,
          'file_size': 450000,
          'format': 'mp3',
          'timestamps': [
            {'verse_key': '1:1', 'timestamp_from': 0, 'timestamp_to': 3000},
            {'verse_key': '1:2', 'timestamp_from': 3000, 'timestamp_to': 6000},
            {'verse_key': '1:3', 'timestamp_from': 6000, 'timestamp_to': 9000},
            {'verse_key': '1:4', 'timestamp_from': 9000, 'timestamp_to': 12000},
            {'verse_key': '1:5', 'timestamp_from': 12000, 'timestamp_to': 15000},
            {'verse_key': '1:6', 'timestamp_from': 15000, 'timestamp_to': 18000},
            {'verse_key': '1:7', 'timestamp_from': 18000, 'timestamp_to': 21000},
          ],
        },
      };

      final client = _FakeTestApiClient(chapterResponse: validPayload);
      final remoteSource = QuranComRemoteDataSource(apiClient: client);
      final repo = QuranAudioRepositoryImpl(remoteDataSource: remoteSource);

      final result = await repo.getChapterAudioData(reciterId: 7, surahNumber: 1);
      expect(result.isSuccess, isTrue);

      final chapterData = result.valueOrNull!;
      final validation = chapterData.validate();
      expect(validation.isValid, isTrue);
      expect(chapterData.timestamps.length, 7);
    });

    test('Automatic selection: Fallback to Ayah mode when timestamps are incomplete or invalid', () async {
      // Incomplete timestamps (only 3 out of 7 ayahs for Al-Fatihah)
      final invalidPayload = {
        'audio_file': {
          'audio_url': 'https://download.quranicaudio.com/qdc/mishari/001.mp3',
          'duration': 21,
          'timestamps': [
            {'verse_key': '1:1', 'timestamp_from': 0, 'timestamp_to': 3000},
            {'verse_key': '1:2', 'timestamp_from': 3000, 'timestamp_to': 6000},
            {'verse_key': '1:3', 'timestamp_from': 6000, 'timestamp_to': 9000},
          ],
        },
      };

      final client = _FakeTestApiClient(chapterResponse: invalidPayload);
      final remoteSource = QuranComRemoteDataSource(apiClient: client);
      final repo = QuranAudioRepositoryImpl(remoteDataSource: remoteSource);

      final result = await repo.getChapterAudioData(reciterId: 7, surahNumber: 1);
      expect(result.isSuccess, isTrue);

      final chapterData = result.valueOrNull!;
      final validation = chapterData.validate();
      // Must be rejected so controller falls back to Ayah mode!
      expect(validation.isValid, isFalse);
      expect(validation.reason, contains('does not match chapter verse count'));
    });

    test('Highlighting behavior: Audio highlight hides on Pause and reappears on Resume', () {
      final controller = QuranHighlightController();
      const audioColor = Color(0xFFD8B457);
      const manualColor = Color(0xFF800020);

      final manualAyah = AyahRef.fromSurahAyah(surah: 1, ayah: 2);
      final playingAyah = AyahRef.fromSurahAyah(surah: 1, ayah: 5);

      // User has manually highlighted ayah 2
      controller.toggleSingle(manualAyah, manualColor);
      expect(controller.containsManual(manualAyah), isTrue);
      expect(controller.value.length, 1);

      // 1. Play starts
      controller.setAudioHighlight(playingAyah, audioColor);
      expect(controller.audioHighlight, isNotNull);
      expect(controller.contains(playingAyah), isTrue);
      expect(controller.value.length, 2);

      // 2. Pause: audio highlight disappears immediately
      controller.pauseAudioHighlight();
      expect(controller.audioHighlight, isNull);
      expect(controller.contains(playingAyah), isFalse);
      // Manual highlight remains strictly intact
      expect(controller.containsManual(manualAyah), isTrue);
      expect(controller.value.length, 1);

      // 3. Resume: audio highlight reappears on the same ayah
      controller.resumeAudioHighlight();
      expect(controller.audioHighlight, isNotNull);
      expect(controller.audioHighlight!.verseNumber, 5);
      expect(controller.contains(playingAyah), isTrue);
      expect(controller.value.length, 2);

      // 4. Stop: audio highlight cleared completely
      controller.clearAudioHighlight();
      expect(controller.audioHighlight, isNull);
      expect(controller.pausedAudioHighlight, isNull);
      expect(controller.containsManual(manualAyah), isTrue);
      expect(controller.value.length, 1);

      controller.dispose();
    });

    test('Manual highlighting: Multiple ayahs stay highlighted across navigation', () {
      final controller = QuranHighlightController();
      const manualColor = Color(0xFF800020);

      final ayah1 = AyahRef.fromSurahAyah(surah: 1, ayah: 1);
      final ayah3 = AyahRef.fromSurahAyah(surah: 1, ayah: 3);
      final ayah7 = AyahRef.fromSurahAyah(surah: 1, ayah: 7);

      controller.toggleSingle(ayah1, manualColor);
      controller.toggleSingle(ayah3, manualColor);
      controller.toggleSingle(ayah7, manualColor);

      expect(controller.manualHighlights.length, 3);
      expect(controller.containsManual(ayah1), isTrue);
      expect(controller.containsManual(ayah3), isTrue);
      expect(controller.containsManual(ayah7), isTrue);

      controller.dispose();
    });
  });
}
