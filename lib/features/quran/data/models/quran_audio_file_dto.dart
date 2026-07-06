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

  factory QuranAudioFileDto.fromJson(
    JsonMap json, {
    QuranVerseKey? fallbackVerseKey,
  }) {
    final verseKeyValue = _stringValue(json['verse_key']);
    final resolvedVerseKey = verseKeyValue != null
        ? QuranVerseKey.parse(verseKeyValue)
        : fallbackVerseKey;

    if (resolvedVerseKey == null) {
      throw FormatException('Missing verse_key for audio entry.', json);
    }

    final audioUrlValue =
        _stringValue(json['url']) ?? _stringValue(json['audio_url']);
    if (audioUrlValue == null || audioUrlValue.isEmpty) {
      throw FormatException('Missing audio url for audio entry.', json);
    }

    return QuranAudioFileDto(
      verseKey: resolvedVerseKey,
      url: _audioUrl(audioUrlValue),
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
      final uri = Uri.parse('https:$value');
      debugPrint('QuranAudioFileDto: protocol-relative URL -> $uri');
      return uri;
    }
    if (value.startsWith('mirrors.quranicaudio.com') ||
        value.startsWith('audio.qurancdn.com')) {
      final uri = Uri.parse('https://$value');
      debugPrint('QuranAudioFileDto: host-only URL -> $uri');
      return uri;
    }

    final uri = Uri.parse(value);
    if (uri.hasScheme) {
      debugPrint('QuranAudioFileDto: absolute URL -> $uri');
      return uri;
    }

    final path = value.startsWith('/') ? value.substring(1) : value;
    final resolved = _audioBaseUri.resolve(path);
    debugPrint('QuranAudioFileDto: relative path "$value" resolved to $resolved');
    return resolved;
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
