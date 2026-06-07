import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/foundation.dart';

@immutable
final class QuranChapterDto {
  const QuranChapterDto({
    required this.id,
    required this.nameArabic,
    required this.nameSimple,
    required this.nameComplex,
    required this.versesCount,
    required this.pages,
    this.revelationPlace,
    this.revelationOrder,
    this.bismillahPre,
    this.translatedName,
  });

  factory QuranChapterDto.fromJson(JsonMap json) {
    return QuranChapterDto(
      id: _requiredInt(json, 'id'),
      nameArabic: _requiredString(json, 'name_arabic'),
      nameSimple: _requiredString(json, 'name_simple'),
      nameComplex: _stringValue(json['name_complex']) ?? '',
      versesCount: _requiredInt(json, 'verses_count'),
      pages: _intList(json['pages']),
      revelationPlace: _stringValue(json['revelation_place']),
      revelationOrder: _intValue(json['revelation_order']),
      bismillahPre: json['bismillah_pre'] as bool?,
      translatedName: _translatedName(json['translated_name']),
    );
  }

  final int id;
  final String nameArabic;
  final String nameSimple;
  final String nameComplex;
  final int versesCount;
  final List<int> pages;
  final String? revelationPlace;
  final int? revelationOrder;
  final bool? bismillahPre;
  final String? translatedName;

  QuranChapter toDomain() {
    return QuranChapter(
      id: id,
      nameArabic: nameArabic,
      nameSimple: nameSimple,
      nameComplex: nameComplex,
      versesCount: versesCount,
      pages: pages,
      revelationPlace: revelationPlace,
      revelationOrder: revelationOrder,
      bismillahPre: bismillahPre,
      translatedName: translatedName,
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

  static List<int> _intList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.map(_intValue).whereType<int>().toList(growable: false);
  }

  static String? _translatedName(Object? value) {
    if (value is! JsonMap) {
      return null;
    }

    return _stringValue(value['name']);
  }
}
