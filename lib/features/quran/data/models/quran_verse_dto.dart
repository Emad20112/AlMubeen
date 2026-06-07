import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/foundation.dart';

@immutable
final class QuranVerseDto {
  const QuranVerseDto({
    required this.verseKey,
    this.id,
    this.verseNumber,
    this.pageNumber,
    this.juzNumber,
    this.hizbNumber,
    this.rubElHizbNumber,
    this.sajdahNumber,
    this.textUthmani,
    this.textUthmaniSimple,
  });

  factory QuranVerseDto.fromJson(JsonMap json) {
    return QuranVerseDto(
      id: _intValue(json['id']),
      verseKey: QuranVerseKey.parse(_requiredString(json, 'verse_key')),
      verseNumber: _intValue(json['verse_number']),
      pageNumber: _intValue(json['page_number']),
      juzNumber: _intValue(json['juz_number']),
      hizbNumber: _intValue(json['hizb_number']),
      rubElHizbNumber: _intValue(json['rub_el_hizb_number']),
      sajdahNumber: _intValue(json['sajdah_number']),
      textUthmani: _stringValue(json['text_uthmani']),
      textUthmaniSimple: _stringValue(json['text_uthmani_simple']),
    );
  }

  final QuranVerseKey verseKey;
  final int? id;
  final int? verseNumber;
  final int? pageNumber;
  final int? juzNumber;
  final int? hizbNumber;
  final int? rubElHizbNumber;
  final int? sajdahNumber;
  final String? textUthmani;
  final String? textUthmaniSimple;

  QuranVerse toDomain() {
    return QuranVerse(
      verseKey: verseKey,
      id: id,
      verseNumber: verseNumber,
      pageNumber: pageNumber,
      juzNumber: juzNumber,
      hizbNumber: hizbNumber,
      rubElHizbNumber: rubElHizbNumber,
      sajdahNumber: sajdahNumber,
      textUthmani: textUthmani,
      textUthmaniSimple: textUthmaniSimple,
    );
  }

  static String _requiredString(JsonMap json, String key) {
    final value = _stringValue(json[key]);
    if (value == null || value.isEmpty) {
      throw FormatException('Missing string field "$key".', json);
    }
    return value;
  }

  static int? _intValue(Object? value) {
    return switch (value) {
      int() => value,
      num() => value.toInt(),
      String() => int.tryParse(value),
      _ => null,
    };
  }

  static String? _stringValue(Object? value) {
    final string = value?.toString().trim();
    return string == null || string.isEmpty ? null : string;
  }
}
