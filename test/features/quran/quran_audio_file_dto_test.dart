import 'package:al_mubeen/features/quran/data/models/quran_audio_file_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuranAudioFileDto', () {
    test(
      'parses audio_url when backend returns a single audio_file object',
      () {
        final dto = QuranAudioFileDto.fromJson({
          'audio_url': 'https://example.com/1.mp3',
          'format': 'mp3',
          'duration': 123,
        }, fallbackVerseKey: const QuranVerseKey(surah: 1, ayah: 1));

        expect(dto.url.toString(), 'https://example.com/1.mp3');
        expect(dto.verseKey.surah, 1);
        expect(dto.verseKey.ayah, 1);
      },
    );
  });
}
