import 'package:flutter/foundation.dart';

@immutable
class HadithNawawiEntry {
  const HadithNawawiEntry({
    required this.id,
    required this.hadithNumber,
    required this.title,
    required this.preview,
    required this.fullText,
    required this.source,
    required this.description,
    required this.searchIndex,
  });

  final int id;
  final int hadithNumber;
  final String title;
  final String preview;
  final String fullText;
  final String source;
  final String description;
  final String searchIndex;

  factory HadithNawawiEntry.fromJson(Map<String, Object?> json) {
    final hadithText = json['hadith'] as String? ?? '';
    final description = json['description'] as String? ?? '';
    final index = json['id'] as int? ?? 0;

    final hadithNumber = _extractHadithNumber(hadithText);
    final title = _extractTitle(hadithText);
    final preview = _extractPreview(hadithText);
    final source = _extractSource(hadithText);

    return HadithNawawiEntry(
      id: index,
      hadithNumber: hadithNumber,
      title: title,
      preview: preview,
      fullText: hadithText,
      source: source,
      description: description,
      searchIndex: normalizeArabic('$hadithText $description'),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'hadith': fullText,
      'description': description,
    };
  }

  bool matchesQuery(String query) {
    final normalizedQuery = normalizeArabic(query);
    if (normalizedQuery.isEmpty) return true;
    return searchIndex.contains(normalizedQuery);
  }

  static int _extractHadithNumber(String text) {
    final arabicNumerals = {
      'الأول': 1, 'الثاني': 2, 'الثالث': 3, 'الرابع': 4,
      'الخامس': 5, 'السادس': 6, 'السابع': 7, 'الثامن': 8,
      'التاسع': 9, 'العاشر': 10, 'الحادي عشر': 11, 'الثاني عشر': 12,
      'الثالث عشر': 13, 'الرابع عشر': 14, 'الخامس عشر': 15,
      'السادس عشر': 16, 'السابع عشر': 17, 'الثامن عشر': 18,
      'التاسع عشر': 19, 'العشرون': 20, 'الحادي والعشرون': 21,
      'الثاني والعشرون': 22, 'الثالث والعشرون': 23, 'الرابع والعشرون': 24,
      'الخامس والعشرون': 25, 'السادس والعشرون': 26, 'السابع والعشرون': 27,
      'الثامن والعشرون': 28, 'التاسع والعشرون': 29, 'الثلاثون': 30,
      'الحادي والثلاثون': 31, 'الثاني والثلاثون': 32, 'الثالث والثلاثون': 33,
      'الرابع والثلاثون': 34, 'الخامس والثلاثون': 35, 'السادس والثلاثون': 36,
      'السابع والثلاثون': 37, 'الثامن والثلاثون': 38, 'التاسع والثلاثون': 39,
      'الأربعون': 40, 'الحادي والأربعون': 41, 'الثاني والأربعون': 42,
    };

    for (final entry in arabicNumerals.entries) {
      if (text.contains('الحديث ${entry.key}')) return entry.value;
    }
    return 0;
  }

  static String _extractTitle(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.length < 2) return lines.isNotEmpty ? lines.first : '';

    final quoteRegex = RegExp(r'"([^"]*)"|「([^」]*)」|‟([^"]*)"');
    final match = quoteRegex.firstMatch(lines.last);
    if (match != null) {
      return match.group(1) ?? match.group(2) ?? match.group(3) ?? '';
    }

    final cleaned = lines.last.replaceAll(RegExp(r'\(رواه.*'), '').trim();
    final words = cleaned.split(RegExp(r'\s+'));
    return words.take(8).join(' ');
  }

  static String _extractPreview(String text) {
    final quoteRegex = RegExp(r'"([^"]*)"|「([^」]*)」|‟([^"]*)"');
    final match = quoteRegex.firstMatch(text);
    if (match != null) {
      final content = match.group(1) ?? match.group(2) ?? match.group(3) ?? '';
      if (content.length > 120) {
        return '${content.substring(0, 120)}...';
      }
      return content;
    }

    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final hadithBody = lines.length >= 3 ? lines.sublist(2).join(' ') : text;
    if (hadithBody.length > 120) {
      return '${hadithBody.substring(0, 120)}...';
    }
    return hadithBody;
  }

  static String _extractSource(String text) {
    final sourcePatterns = [
      RegExp(r'\(رواه [^)]+\)'),
      RegExp(r'\((متفق عليه|رواه مسلم|رواه البخاري|رواه الترمذي|رواه النسائي|رواه أبو داود|رواه ابن ماجه)[^)]*\)'),
      RegExp(r'\(حديث (حسن|صحيح|ضعيف)[^)]*\)'),
    ];

    for (final pattern in sourcePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0)!.replaceAll(RegExp(r'^\(|\)$'), '');
      }
    }

    return '';
  }
}

String normalizeArabic(String input) {
  if (input.isEmpty) return '';
  final stripped = input.replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '');
  return stripped
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ٱ', 'ا')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .toLowerCase()
      .replaceAll(RegExp(r'[^ء-ي0-9a-z]+', unicode: true), '');
}
