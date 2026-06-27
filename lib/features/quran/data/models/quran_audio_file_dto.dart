import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:flutter/foundation.dart';

@immutable
final class QuranAudioFileDto {
  const QuranAudioFileDto({
    required this.verseKey,
    required this.url,
    this.duration,
    this.format,
    this.id,
  });

  factory QuranAudioFileDto.fromJson(JsonMap json) {
    return QuranAudioFileDto(
      verseKey: QuranVerseKey.parse(_requiredString(json, 'verse_key')),
      url: _audioUrl(_requiredString(json, 'url')),
      duration: _intValue(json['duration']),
      format: _stringValue(json['format']),
      id: _intValue(json['id']),
    );
  }

  static final Uri _audioBaseUri = Uri.parse(
    'https://verses.quran.foundation/',
  );

  final QuranVerseKey verseKey;
  final Uri url;
  final int? duration;
  final String? format;
  final int? id;

  QuranAudioFile toDomain() {
    return QuranAudioFile(
      verseKey: verseKey,
      url: url,
      duration: duration,
      format: format,
      id: id,
    );
  }

  static Uri _audioUrl(String value) {
    if (value.startsWith('//')) {
      return Uri.parse('https:$value');
    }
    if (value.startsWith('mirrors.quranicaudio.com') || 
        value.startsWith('audio.qurancdn.com')) {
      return Uri.parse('https://$value');
    }

    final uri = Uri.parse(value);
    if (uri.hasScheme) {
      return uri;
    }

    final path = value.startsWith('/') ? value.substring(1) : value;
    return _audioBaseUri.resolve(path);
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
