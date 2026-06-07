import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/foundation.dart';

@immutable
final class QuranRecitationDto {
  const QuranRecitationDto({
    required this.id,
    required this.reciterName,
    this.style,
    this.translatedName,
    this.languageName,
  });

  factory QuranRecitationDto.fromJson(JsonMap json) {
    final translatedName = json['translated_name'];

    return QuranRecitationDto(
      id: _requiredInt(json, 'id'),
      reciterName: _requiredString(json, 'reciter_name'),
      style: _stringValue(json['style']),
      translatedName: translatedName is JsonMap
          ? _stringValue(translatedName['name'])
          : null,
      languageName: translatedName is JsonMap
          ? _stringValue(translatedName['language_name'])
          : null,
    );
  }

  final int id;
  final String reciterName;
  final String? style;
  final String? translatedName;
  final String? languageName;

  QuranRecitation toDomain() {
    return QuranRecitation(
      id: id,
      reciterName: reciterName,
      style: style,
      translatedName: translatedName,
      languageName: languageName,
    );
  }

  static int _requiredInt(JsonMap json, String key) {
    final value = _intValue(json[key]);
    if (value == null) {
      throw FormatException('Missing integer field "$key".', json);
    }
    return value;
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
