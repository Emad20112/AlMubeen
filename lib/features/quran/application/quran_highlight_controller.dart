import 'package:al_mubeen/features/quran/data/models/highlight_verse.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter/material.dart';

/// يدير التظليلات في المصحف مع فصل صريح ودقيق بين التظليل الصوتي والتظليلات اليدوية.
///
/// القواعد المعمارية الصارمة:
/// 1. التظليل اليدوي: دائم وثابت ولا يتأثر بحالة تشغيل الصوت (Play/Pause/Stop).
/// 2. التظليل الصوتي: يظهر أثناء التلاوة النشطة فقط، ويختفي فوراً عند الإيقاف المؤقت (Pause)
///    أو التوقف النهائي (Stop)، ويعود للظهور عند الاستئناف (Resume) على نفس الآية.
/// 3. التظليل الصوتي واليدوي لا يختلطان في الحالة الداخلية.
class QuranHighlightController extends ValueNotifier<List<HighlightVerse>> {
  QuranHighlightController() : super(const []);

  HighlightVerse? _audioHighlight;
  HighlightVerse? _pausedAudioHighlight;
  final List<HighlightVerse> _manualHighlights = <HighlightVerse>[];

  HighlightVerse? get audioHighlight => _audioHighlight;
  HighlightVerse? get pausedAudioHighlight => _pausedAudioHighlight;
  List<HighlightVerse> get manualHighlights => List.unmodifiable(_manualHighlights);

  void _recomputeValue() {
    final combined = <HighlightVerse>[];
    if (_audioHighlight != null) {
      combined.add(_audioHighlight!);
    }
    for (final manual in _manualHighlights) {
      if (_audioHighlight != null &&
          _audioHighlight!.surah == manual.surah &&
          _audioHighlight!.verseNumber == manual.verseNumber) {
        continue;
      }
      combined.add(manual);
    }
    value = List<HighlightVerse>.unmodifiable(combined);
  }

  bool contains(AyahRef ref) {
    return value.any(
      (highlight) =>
          highlight.surah == ref.surah && highlight.verseNumber == ref.ayah,
    );
  }

  bool containsManual(AyahRef ref) {
    return _manualHighlights.any(
      (highlight) =>
          highlight.surah == ref.surah && highlight.verseNumber == ref.ayah,
    );
  }

  /// تبديل التظليل اليدوي (تحديد أو إلغاء تحديد آية يدوياً بالضغط المطول)
  void toggleSingle(AyahRef ref, Color color) {
    final existingIndex = _manualHighlights.indexWhere(
      (h) => h.surah == ref.surah && h.verseNumber == ref.ayah,
    );

    if (existingIndex != -1) {
      _manualHighlights.removeAt(existingIndex);
    } else {
      _manualHighlights.add(
        HighlightVerse(
          surah: ref.surah,
          verseNumber: ref.ayah,
          page: ref.page,
          color: color,
        ),
      );
    }
    _recomputeValue();
  }

  /// تعيين تظليل صوتي حصري للآية التي يتلوها القارئ حالياً
  void setAudioHighlight(AyahRef ref, Color color) {
    final newHighlight = HighlightVerse(
      surah: ref.surah,
      verseNumber: ref.ayah,
      page: ref.page,
      color: color,
    );

    if (_audioHighlight != null &&
        _audioHighlight!.surah == ref.surah &&
        _audioHighlight!.verseNumber == ref.ayah &&
        _audioHighlight!.color == color) {
      return;
    }

    _audioHighlight = newHighlight;
    _pausedAudioHighlight = newHighlight;
    _recomputeValue();
  }

  /// إخفاء التظليل الصوتي عند الإيقاف المؤقت (Pause) مع الاحتفاظ بالآية داخلياً للاستئناف
  void pauseAudioHighlight() {
    if (_audioHighlight == null) return;
    _pausedAudioHighlight = _audioHighlight;
    _audioHighlight = null;
    _recomputeValue();
  }

  /// استئناف إظهار التظليل الصوتي عند العودة للتشغيل (Resume)
  void resumeAudioHighlight([Color? fallbackColor]) {
    if (_audioHighlight != null) return;
    if (_pausedAudioHighlight != null) {
      _audioHighlight = _pausedAudioHighlight;
      _recomputeValue();
    }
  }

  /// مسح التظليل الصوتي نهائياً (عند التوقف Stop أو انتهاء السورة)
  void clearAudioHighlight() {
    if (_audioHighlight == null && _pausedAudioHighlight == null) return;
    _audioHighlight = null;
    _pausedAudioHighlight = null;
    _recomputeValue();
  }

  /// مسح التظليلات اليدوية فقط
  void clearManualHighlights() {
    if (_manualHighlights.isEmpty) return;
    _manualHighlights.clear();
    _recomputeValue();
  }

  /// مسح عام للتظليل اليدوي (متوافق مع زر إلغاء التظليل في الـ Overlay)
  void clear() {
    clearManualHighlights();
  }

  /// تظليل يدوي لآية واحدة (متوافق مع التنقل السريع للفهرس أو الورد)
  void highlightSingle(AyahRef ref, Color color) {
    _manualHighlights.clear();
    _manualHighlights.add(
      HighlightVerse(
        surah: ref.surah,
        verseNumber: ref.ayah,
        page: ref.page,
        color: color,
      ),
    );
    _recomputeValue();
  }
}
