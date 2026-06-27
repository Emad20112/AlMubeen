import 'package:al_mubeen/core/data/json_map.dart';
import 'package:flutter/foundation.dart';

@immutable
final class TafsirDto {
  const TafsirDto({
    required this.id,
    required this.name,
    this.authorName,
    this.slug,
    this.languageName,
    this.translatedName,
  });

  factory TafsirDto.fromJson(JsonMap json) {
    return TafsirDto(
      id: _requiredInt(json, 'id'),
      name: _requiredString(json, 'name'),
      authorName: _stringValue(json['author_name']),
      slug: _stringValue(json['slug']),
      languageName: _stringValue(json['language_name']),
      translatedName: _translatedName(json['translated_name']),
    );
  }

  final int id;
  final String name;
  final String? authorName;
  final String? slug;
  final String? languageName;
  final TafsirTranslatedNameDto? translatedName;

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

  static TafsirTranslatedNameDto? _translatedName(Object? value) {
    if (value is! JsonMap) {
      return null;
    }

    final name = _stringValue(value['name']);
    if (name == null) {
      return null;
    }

    return TafsirTranslatedNameDto(
      name: name,
      languageName: _stringValue(value['language_name']),
    );
  }
}

@immutable
final class TafsirTranslatedNameDto {
  const TafsirTranslatedNameDto({required this.name, this.languageName});

  final String name;
  final String? languageName;
}

@immutable
final class TafsirTextDto {
  const TafsirTextDto({
    required this.resourceId,
    required this.resourceName,
    required this.text,
    this.verseKey,
    this.verseNumber,
    this.chapterId,
  });

  factory TafsirTextDto.fromJson(JsonMap json) {
    return TafsirTextDto(
      resourceId: _requiredInt(json, 'resource_id'),
      resourceName: _requiredString(json, 'resource_name'),
      text: _stringValue(json['text']) ?? '',
      verseKey: _stringValue(json['verse_key']),
      verseNumber: _intValue(json['verse_number']),
      chapterId: _intValue(json['chapter_id']),
    );
  }

  final int resourceId;
  final String resourceName;
  final String text;
  final String? verseKey;
  final int? verseNumber;
  final int? chapterId;

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
