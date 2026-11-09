import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran/qcf_quran.dart';

void main() {
  group('Adaptive Prefetch Window Architecture', () {
    AyahRef? nextAyahHelper(AyahRef current) {
      final verseCount = getVerseCount(current.surah);
      if (current.ayah < verseCount) {
        return AyahRef.fromSurahAyah(
          surah: current.surah,
          ayah: current.ayah + 1,
        );
      } else if (current.surah < totalSurahCount) {
        return AyahRef.fromSurahAyah(surah: current.surah + 1, ayah: 1);
      }
      return null;
    }

    test('Initial window creates exactly five ayahs starting from current ayah', () {
      final window = buildPrefetchWindow(
        start: AyahRef.fromSurahAyah(surah: 2, ayah: 1),
        count: QuranAudioController.prefetchBatchSize,
        nextAyah: nextAyahHelper,
      );

      expect(window.length, 5);
      expect(window[0].ayah, 1);
      expect(window[1].ayah, 2);
      expect(window[2].ayah, 3);
      expect(window[3].ayah, 4);
      expect(window[4].ayah, 5);
    });

    test('Subsequent batch continues from the last buffered ayah', () {
      // First batch: 1 to 5
      final firstBatch = buildPrefetchWindow(
        start: AyahRef.fromSurahAyah(surah: 2, ayah: 1),
        count: QuranAudioController.prefetchBatchSize,
        nextAyah: nextAyahHelper,
      );

      final nextStart = nextAyahHelper(firstBatch.last);
      expect(nextStart, isNotNull);
      expect(nextStart!.ayah, 6);

      // Triggered batch when nearing end of window
      final secondBatch = buildPrefetchWindow(
        start: nextStart,
        count: QuranAudioController.prefetchBatchSize,
        nextAyah: nextAyahHelper,
      );

      expect(secondBatch.length, 5);
      expect(secondBatch[0].ayah, 6);
      expect(secondBatch[4].ayah, 10);
    });

    test('Surah boundary transitions smoothly without exceeding total verses', () {
      // Al-Fatihah (Surah 1) has 7 ayahs. Starting from ayah 5 with count 5.
      final window = buildPrefetchWindow(
        start: AyahRef.fromSurahAyah(surah: 1, ayah: 5),
        count: 5,
        nextAyah: nextAyahHelper,
      );

      expect(window.length, 5);
      expect(window[0], AyahRef.fromSurahAyah(surah: 1, ayah: 5));
      expect(window[1], AyahRef.fromSurahAyah(surah: 1, ayah: 6));
      expect(window[2], AyahRef.fromSurahAyah(surah: 1, ayah: 7));
      expect(window[3], AyahRef.fromSurahAyah(surah: 2, ayah: 1)); // Transition to Al-Baqarah
      expect(window[4], AyahRef.fromSurahAyah(surah: 2, ayah: 2));
    });

    test('Final surah (An-Nas) gracefully stops when end of Quran reached', () {
      // An-Nas (Surah 114) has 6 ayahs.
      final window = buildPrefetchWindow(
        start: AyahRef.fromSurahAyah(surah: 114, ayah: 4),
        count: 5,
        nextAyah: nextAyahHelper,
      );

      // Only 4, 5, 6 exist. Next returns null.
      expect(window.length, 3);
      expect(window.last.ayah, 6);
    });
  });
}
