import 'package:flutter/foundation.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

/// Helper functions for Quran page-related calculations that are not
/// directly available in the qcf_quran_plus package.

/// Returns the surah number for a given page number.
/// If the page contains multiple surahs, returns the first one.
int getSurahNumberFromPage(int pageNumber) {
  try {
    final pageData = getPageData(pageNumber);
    if (pageData.isEmpty) return 1;

    final first = pageData.first;

    // Common simple case: an integer surah number
    if (first is int) return first;
    if (first is double) return first.toInt();
    if (first is String) return int.tryParse(first) ?? 1;

    // If the element is a Map, try common keys
    if (first is Map) {
      for (final key in [
        'surah',
        'surahNumber',
        'surah_number',
        'chapter',
        'chapterNumber',
        'chapter_number',
        'sura',
      ]) {
        if (first.containsKey(key)) {
          final v = first[key];
          if (v is int) return v;
          if (v is double) return v.toInt();
          if (v is String) return int.tryParse(v) ?? 1;
        }
      }

      // If the map only has one value, and it's numeric, use it
      if (first.values.length == 1) {
        final v = first.values.first;
        if (v is int) return v;
        if (v is double) return v.toInt();
        if (v is String) return int.tryParse(v) ?? 1;
      }
    }

    // Try dynamic property access for potential library objects.
    // We avoid advanced reflection and instead try common patterns safely.
    try {
      final dyn = first as dynamic;
      for (final prop in [
        'surah',
        'chapter',
        'sura',
        'surahNumber',
        'chapterNumber',
      ]) {
        // If object provides toJson(), call it and inspect the map.
        try {
          final maybeMap = dyn.toJson();
          if (maybeMap is Map && maybeMap.containsKey(prop)) {
            final val = maybeMap[prop];
            if (val is int) return val;
            if (val is double) return val.toInt();
            if (val is String) return int.tryParse(val) ?? 1;
          }
        } catch (_) {}

        // If the dynamic object itself behaves like a Map, check directly.
        try {
          if (dyn is Map && dyn.containsKey(prop)) {
            final val = dyn[prop];
            if (val is int) return val;
            if (val is double) return val.toInt();
            if (val is String) return int.tryParse(val) ?? 1;
          }
        } catch (_) {}
      }
    } catch (_) {}

    // Last resort: attempt to parse the string representation
    final parsed = int.tryParse(first.toString());
    if (parsed != null) return parsed;
  } catch (e, st) {
    debugPrint('getSurahNumberFromPage failed for page=$pageNumber: $e\n$st');
  }

  return 1;
}

/// Returns the first ayah reference on [pageNumber].
AyahRef getFirstAyahOnPage(int pageNumber) {
  try {
    final data = getPageData(pageNumber);
    if (data.isNotEmpty && data.first is Map) {
      final first = data.first as Map;
      final surah = first['surah'];
      final start = first['start'];
      if (surah is int && start is int) {
        return AyahRef.fromSurahAyah(surah: surah, ayah: start);
      }
    }
  } catch (e, st) {
    debugPrint('getFirstAyahOnPage failed for page=$pageNumber: $e\n$st');
  }

  return AyahRef.fromSurahAyah(
    surah: getSurahNumberFromPage(pageNumber),
    ayah: 1,
  );
}
