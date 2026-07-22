import 'package:flutter/foundation.dart';

@immutable
class AllahNameEntry {
  const AllahNameEntry({
    required this.id,
    required this.name,
    required this.meaning,
    required this.searchIndex,
  });

  final int id;
  final String name;
  final String meaning;
  final String searchIndex;

  factory AllahNameEntry.fromJson(Map<String, Object?> json) {
    final id = _readInt(json, 'id');
    final name = _readString(json, 'name');
    final meaning = _readString(json, 'meaning', fallbackKey: 'text');
    final searchIndex = json['searchIndex'] as String? ??
        buildAllahNameSearchIndex(name, meaning);

    return AllahNameEntry(
      id: id,
      name: name,
      meaning: meaning,
      searchIndex: searchIndex,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'meaning': meaning,
      'searchIndex': searchIndex,
    };
  }

  bool matchesQuery(String query) {
    final normalizedQuery = normalizeArabic(query);
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return searchIndex.contains(normalizedQuery);
  }
}

String buildAllahNameSearchIndex(String name, String meaning) {
  return normalizeArabic('$name $meaning');
}

String normalizeArabic(String input) {
  if (input.isEmpty) {
    return '';
  }

  final strippedDiacritics =
      input.replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '');
  final normalizedLetters = strippedDiacritics
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ٱ', 'ا')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .toLowerCase();

  return normalizedLetters.replaceAll(
    RegExp(r'[^ء-ي0-9a-z]+', unicode: true),
    '',
  );
}

int _readInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.parse(value);
  }

  throw FormatException('Expected "$key" to be an integer.');
}

String _readString(
  Map<String, Object?> json,
  String key, {
  String? fallbackKey,
}) {
  final value = json[key] ?? (fallbackKey == null ? null : json[fallbackKey]);
  if (value is String) {
    return value;
  }

  throw FormatException('Expected "$key" to be a string.');
}
