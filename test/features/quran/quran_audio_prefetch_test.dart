import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildPrefetchWindow', () {
    test('returns the next five ayahs from the current ayah', () {
      final window = buildPrefetchWindow(
        start: AyahRef.fromSurahAyah(surah: 1, ayah: 1),
        count: 5,
        nextAyah: (current) {
          return AyahRef.fromSurahAyah(
            surah: current.surah,
            ayah: current.ayah + 1,
          );
        },
      );

      expect(window.length, 5);
      expect(window.first.ayah, 2);
      expect(window.last.ayah, 6);
    });
  });
}
