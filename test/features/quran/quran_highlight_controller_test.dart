import 'package:al_mubeen/features/quran/application/quran_highlight_controller.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuranHighlightController - Architecture & Lifetime Tests', () {
    late QuranHighlightController controller;
    const testColor = Color(0xFFD8B457);
    const manualColor = Color(0xFF800020);

    setUp(() {
      controller = QuranHighlightController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state is empty', () {
      expect(controller.value, isEmpty);
      expect(controller.audioHighlight, isNull);
      expect(controller.manualHighlights, isEmpty);
    });

    test('Separates audio highlight from manual highlights', () {
      final ayah1 = AyahRef.fromSurahAyah(surah: 1, ayah: 1);
      final ayah2 = AyahRef.fromSurahAyah(surah: 1, ayah: 2);

      // 1. User manually highlights ayah 1
      controller.toggleSingle(ayah1, manualColor);
      expect(controller.containsManual(ayah1), isTrue);
      expect(controller.manualHighlights.length, 1);
      expect(controller.value.length, 1);

      // 2. Audio starts playing on ayah 2
      controller.setAudioHighlight(ayah2, testColor);
      expect(controller.audioHighlight, isNotNull);
      expect(controller.audioHighlight!.verseNumber, 2);
      expect(controller.value.length, 2);

      // 3. Audio moves to ayah 3
      final ayah3 = AyahRef.fromSurahAyah(surah: 1, ayah: 3);
      controller.setAudioHighlight(ayah3, testColor);
      expect(controller.audioHighlight!.verseNumber, 3);
      expect(controller.value.length, 2); // manual ayah1 + audio ayah3

      // 4. Audio stops (e.g. Stop pressed or session ended)
      controller.clearAudioHighlight();
      expect(controller.audioHighlight, isNull);
      // Manual highlight is strictly preserved!
      expect(controller.containsManual(ayah1), isTrue);
      expect(controller.value.length, 1);
      expect(controller.value.first.verseNumber, 1);
    });

    test('Pause retains audio highlight without clearing', () {
      final ayah = AyahRef.fromSurahAyah(surah: 2, ayah: 255);
      controller.setAudioHighlight(ayah, testColor);

      expect(controller.contains(ayah), isTrue);
      expect(controller.audioHighlight, isNotNull);

      // Simulating what happens during pause: NO clearAudioHighlight is called
      // Controller keeps the state intact for seamless resume
      expect(controller.audioHighlight!.surah, 2);
      expect(controller.audioHighlight!.verseNumber, 255);
      expect(controller.value.isNotEmpty, isTrue);
    });

    test('Manual clear only clears manual highlights', () {
      final manualAyah = AyahRef.fromSurahAyah(surah: 1, ayah: 5);
      final audioAyah = AyahRef.fromSurahAyah(surah: 1, ayah: 6);

      controller.toggleSingle(manualAyah, manualColor);
      controller.setAudioHighlight(audioAyah, testColor);
      expect(controller.value.length, 2);

      // User clears manual selection from bottom sheet or long-press overlay
      controller.clear();
      expect(controller.manualHighlights, isEmpty);
      // Audio highlight remains intact
      expect(controller.audioHighlight, isNotNull);
      expect(controller.value.length, 1);
      expect(controller.value.first.verseNumber, 6);
    });

    test('HighlightSingle overrides manual highlights but preserves audio', () {
      final manual1 = AyahRef.fromSurahAyah(surah: 1, ayah: 1);
      final manual2 = AyahRef.fromSurahAyah(surah: 1, ayah: 2);
      final audio = AyahRef.fromSurahAyah(surah: 1, ayah: 7);

      controller.toggleSingle(manual1, manualColor);
      controller.setAudioHighlight(audio, testColor);

      // User jumps to ayah 2 from search
      controller.highlightSingle(manual2, manualColor);

      expect(controller.containsManual(manual1), isFalse);
      expect(controller.containsManual(manual2), isTrue);
      expect(controller.audioHighlight, isNotNull);
      expect(controller.value.length, 2);
    });
  });
}
