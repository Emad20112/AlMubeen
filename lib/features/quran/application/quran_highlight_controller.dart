import 'package:al_mubeen/features/quran/data/models/highlight_verse.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:flutter/material.dart';

/// يدير التظليلات في المصحف مع فصل صريح ودقيق بين التظليل الصوتي والتظليلات اليدوية.
///
/// هذا الفصل يضمن:
/// 1. عدم مسح التظليلات اليدوية عند توقف التلاوة الصوتية أو تغيير الآيات.
/// 2. بقاء تظليل الآية الصوتية عند الإيقاف المؤقت (Pause) دون مسحه.
/// 3. استبدال آية التلاوة الحالية تلقائياً عند تقدم القارئ دون لمس التظليلات اليدوية.
class QuranHighlightController extends ValueNotifier<List<HighlightVerse>> {
  QuranHighlightController() : super(const []);

  HighlightVerse? _audioHighlight;
  final List<HighlightVerse> _manualHighlights = <HighlightVerse>[];

  HighlightVerse? get audioHighlight => _audioHighlight;
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
    if (_audioHighlight != null &&
        _audioHighlight!.surah == ref.surah &&
        _audioHighlight!.verseNumber == ref.ayah &&
        _audioHighlight!.color == color) {
      return;
    }

    _audioHighlight = HighlightVerse(
      surah: ref.surah,
      verseNumber: ref.ayah,
      page: ref.page,
      color: color,
    );
    _recomputeValue();
  }

  /// مسح التظليل الصوتي فقط (عند التوقف النهائي للتلاوة Stop أو انتهاء السورة)
  void clearAudioHighlight() {
    if (_audioHighlight == null) return;
    _audioHighlight = null;
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
