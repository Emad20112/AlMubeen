import 'package:al_mubeen/features/quran/data/models/highlight_verse.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter/material.dart';

class QuranHighlightController extends ValueNotifier<List<HighlightVerse>> {
  QuranHighlightController() : super(const []);

  bool contains(AyahRef ref) {
    return value.any(
      (highlight) =>
          highlight.surah == ref.surah && highlight.verseNumber == ref.ayah,
    );
  }

  void toggleSingle(AyahRef ref, Color color) {
    if (contains(ref)) {
      clear();
      return;
    }

    highlightSingle(ref, color);
  }

  void highlightSingle(AyahRef ref, Color color) {
    value = [
      HighlightVerse(
        surah: ref.surah,
        verseNumber: ref.ayah,
        page: ref.page,
        color: color,
      ),
    ];
  }

  void clear() {
    if (value.isEmpty) {
      return;
    }

    value = const [];
  }
}
