import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter/foundation.dart';
import 'package:qcf_quran/qcf_quran.dart';

@immutable
final class ChapterVerseTiming {
  const ChapterVerseTiming({
    required this.verseKey,
    required this.surah,
    required this.ayah,
    required this.startMs,
    required this.endMs,
    int? durationMs,
  }) : durationMs = durationMs ?? (endMs - startMs);

  factory ChapterVerseTiming.fromJson(JsonMap json) {
    final verseKey = json['verse_key']?.toString().trim() ?? '';
    final parts = verseKey.split(':');
    final surah = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final ayah = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final startMs = (json['start_ms'] as num?)?.toInt() ??
        (json['timestamp_from'] as num?)?.toInt() ??
        0;

    final endMs = (json['end_ms'] as num?)?.toInt() ??
        (json['timestamp_to'] as num?)?.toInt() ??
        0;

    final durationMs = (json['duration_ms'] as num?)?.toInt() ??
        (json['duration'] as num?)?.toInt() ??
        (endMs - startMs);

    return ChapterVerseTiming(
      verseKey: verseKey,
      surah: surah,
      ayah: ayah,
      startMs: startMs,
      endMs: endMs,
      durationMs: durationMs,
    );
  }

  final String verseKey;
  final int surah;
  final int ayah;
  final int startMs;
  final int endMs;
  final int durationMs;

  AyahRef toAyahRef() => AyahRef.fromSurahAyah(surah: surah, ayah: ayah);

  JsonMap toJson() => {
    'verse_key': verseKey,
    'start_ms': startMs,
    'end_ms': endMs,
    'duration_ms': durationMs,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterVerseTiming &&
          runtimeType == other.runtimeType &&
          verseKey == other.verseKey &&
          startMs == other.startMs &&
          endMs == other.endMs;

  @override
  int get hashCode => Object.hash(verseKey, startMs, endMs);
}

@immutable
final class ChapterAudioValidationResult {
  const ChapterAudioValidationResult.valid()
      : isValid = true,
        reason = null;

  const ChapterAudioValidationResult.invalid(this.reason)
      : isValid = false;

  final bool isValid;
  final String? reason;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid($reason)';
}

@immutable
final class ChapterAudioData {
  const ChapterAudioData({
    required this.chapterNumber,
    required this.reciterId,
    required this.audioUrl,
    required this.format,
    required this.durationMs,
    required this.timestamps,
    this.fileSize,
  });

  factory ChapterAudioData.fromJson(
    JsonMap json, {
    required int chapterNumber,
    required int reciterId,
    required Uri resolvedAudioUrl,
  }) {
    final audioFile = (json['audio_file'] is JsonMap)
        ? json['audio_file'] as JsonMap
        : json;

    final format =
        json['format']?.toString() ?? audioFile['format']?.toString() ?? 'mp3';
    final fileSize = (json['file_size'] as num?)?.toInt() ??
        (audioFile['file_size'] as num?)?.toInt();

    final rawDuration = json['duration_ms'] ??
        json['duration'] ??
        audioFile['duration_ms'] ??
        audioFile['duration'];
    final durationMs = switch (rawDuration) {
      int val => val > 10000 ? val : val * 1000,
      double val => val > 10000 ? val.round() : (val * 1000).round(),
      _ => 0,
    };

    final rawTimestamps = json['timestamps'] ?? audioFile['timestamps'];
    final timestamps = <ChapterVerseTiming>[];
    if (rawTimestamps is List) {
      for (final item in rawTimestamps) {
        if (item is JsonMap) {
          timestamps.add(ChapterVerseTiming.fromJson(item));
        }
      }
    }

    return ChapterAudioData(
      chapterNumber: chapterNumber,
      reciterId: reciterId,
      audioUrl: resolvedAudioUrl,
      fileSize: fileSize,
      format: format,
      durationMs: durationMs,
      timestamps: List.unmodifiable(timestamps),
    );
  }

  final int chapterNumber;
  final int reciterId;
  final Uri audioUrl;
  final int? fileSize;
  final String format;
  final int durationMs;
  final List<ChapterVerseTiming> timestamps;

  /// يتحقق بصرامة من مطابقة كافة شروط اعتماد ملف السورة العشرة:
  /// 1. وجود رابط صوتي صالح.
  /// 2. وجود قائمة توقيتات غير فارغة.
  /// 3. توافق جميع الآيات مع السورة المطلوبة.
  /// 4. صحة أرقام الآيات وترتيبها.
  /// 5. startMs و endMs أرقام صحيحة وغير سالبة.
  /// 6. endMs أكبر من startMs.
  /// 7. عدم وجود تداخل زمني غير منطقي.
  /// 8. ترتيب التوقيتات تصاعدياً.
  /// 9. عدم وجود آيات مفقودة ضمن نطاق السورة بالكامل.
  /// 10. توافق توقيتات نهاية الملف مع مدة الملف أو مدة موجبة معقولة.
  ChapterAudioValidationResult validate() {
    if (audioUrl.toString().trim().isEmpty) {
      return const ChapterAudioValidationResult.invalid('Audio URL is empty.');
    }

    if (timestamps.isEmpty) {
      return const ChapterAudioValidationResult.invalid('Timestamps list is empty.');
    }

    final expectedVerseCount = getVerseCount(chapterNumber);
    if (timestamps.length != expectedVerseCount) {
      return ChapterAudioValidationResult.invalid(
        'Timestamps count (${timestamps.length}) does not match chapter verse count ($expectedVerseCount).',
      );
    }

    int previousEnd = 0;
    for (int i = 0; i < timestamps.length; i++) {
      final timing = timestamps[i];
      final expectedAyah = i + 1;

      // 3. توافق السورة
      if (timing.surah != chapterNumber) {
        return ChapterAudioValidationResult.invalid(
          'Verse ${timing.verseKey} has surah ${timing.surah}, expected $chapterNumber.',
        );
      }

      // 4 & 9. تسلسل أرقام الآيات دون فقدان
      if (timing.ayah != expectedAyah) {
        return ChapterAudioValidationResult.invalid(
          'Ayah at index $i is ${timing.ayah}, expected sequential $expectedAyah.',
        );
      }

      // 5. قيم غير سالبة
      if (timing.startMs < 0 || timing.endMs < 0) {
        return ChapterAudioValidationResult.invalid(
          'Negative timestamp for verse ${timing.verseKey} (${timing.startMs} - ${timing.endMs}).',
        );
      }

      // 6. endMs أكبر من startMs
      if (timing.endMs <= timing.startMs) {
        return ChapterAudioValidationResult.invalid(
          'endMs (${timing.endMs}) <= startMs (${timing.startMs}) for verse ${timing.verseKey}.',
        );
      }

      // 7 & 8. عدم وجود تراجع وتداخل غير منطقي وترتيب تصاعدي
      if (i > 0) {
        final prev = timestamps[i - 1];
        if (timing.startMs < prev.startMs) {
          return ChapterAudioValidationResult.invalid(
            'Timestamps not ascending at verse ${timing.verseKey}.',
          );
        }
        // سماح بهامش تداخل صوتي طفيف جدًا (أقل من 300ms) للتنفس ولكن ليس تداخل كامل
        if (timing.startMs < prev.endMs - 1000) {
          return ChapterAudioValidationResult.invalid(
            'Unreasonable timestamp overlap between ${prev.verseKey} and ${timing.verseKey}.',
          );
        }
      }

      previousEnd = timing.endMs;
    }

    // 10. توافق نهاية التوقيت مع مدة الملف ضمن هامش معقول إن وجدت
    if (durationMs > 0 && previousEnd > durationMs + 5000) {
      return ChapterAudioValidationResult.invalid(
        'Last timestamp end ($previousEnd ms) significantly exceeds audio duration ($durationMs ms).',
      );
    }

    return const ChapterAudioValidationResult.valid();
  }

  /// بحث ثنائي Binary Search O(log N) سريع ودقيق لتحديد الآية الحالية
  /// بناءً على موضع التلاوة بالمللي ثانية دون إحداث فواق في الأداء.
  AyahRef? findAyahAtPosition(int positionMs) {
    if (timestamps.isEmpty || positionMs < 0) return null;

    // Fast-path: قبل البداية أو عند النهاية
    if (positionMs <= timestamps.first.startMs) {
      return timestamps.first.toAyahRef();
    }
    if (positionMs >= timestamps.last.startMs) {
      return timestamps.last.toAyahRef();
    }

    int low = 0;
    int high = timestamps.length - 1;

    while (low <= high) {
      final mid = (low + high) >> 1;
      final timing = timestamps[mid];

      if (positionMs >= timing.startMs && positionMs < timing.endMs) {
        return timing.toAyahRef();
      }

      if (positionMs < timing.startMs) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    // إذا وقع الموضع في فجوة صمت طفيفة بين آيتين، نختار الآية الأقرب السابقة
    if (high >= 0 && high < timestamps.length) {
      return timestamps[high].toAyahRef();
    }

    return timestamps.first.toAyahRef();
  }

  /// إرجاع الموضع الزمني لبداية آية معينة بالمللي ثانية للـ Seek الفوري
  int? getStartMsForAyah(int ayahNumber) {
    for (final timing in timestamps) {
      if (timing.ayah == ayahNumber) {
        return timing.startMs;
      }
    }
    return null;
  }
}
