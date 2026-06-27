import 'dart:convert';
import 'dart:io';

import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final class QuranResourceCatalogStorage {
  QuranResourceCatalogStorage();

  final Map<String, List<Tafsir>> _tafsirCache = {};
  final Map<String, List<Translation>> _translationCache = {};
  final Map<String, List<QuranRecitation>> _recitationCache = {};

  Future<List<Tafsir>> getTafsirs({String language = 'en'}) async {
    final normalizedLanguage = _normalizeLanguage(language);
    final cached = _tafsirCache[normalizedLanguage];
    if (cached != null) {
      return cached;
    }

    final items = await _readList(
      fileName: _fileName(prefix: 'tafsirs', language: normalizedLanguage),
      fromJson: _tafsirFromJson,
    );
    final immutableItems = List<Tafsir>.unmodifiable(items);
    _tafsirCache[normalizedLanguage] = immutableItems;
    return immutableItems;
  }

  Future<void> saveTafsirs(
    List<Tafsir> tafsirs, {
    required String language,
  }) async {
    final normalizedLanguage = _normalizeLanguage(language);
    final immutableItems = List<Tafsir>.unmodifiable(tafsirs);

    await _writeList(
      fileName: _fileName(prefix: 'tafsirs', language: normalizedLanguage),
      items: immutableItems,
      toJson: _tafsirToJson,
    );

    _tafsirCache[normalizedLanguage] = immutableItems;
  }

  Future<List<Translation>> getTranslations({String language = 'en'}) async {
    final normalizedLanguage = _normalizeLanguage(language);
    final cached = _translationCache[normalizedLanguage];
    if (cached != null) {
      return cached;
    }

    final items = await _readList(
      fileName: _fileName(prefix: 'translations', language: normalizedLanguage),
      fromJson: _translationFromJson,
    );
    final immutableItems = List<Translation>.unmodifiable(items);
    _translationCache[normalizedLanguage] = immutableItems;
    return immutableItems;
  }

  Future<void> saveTranslations(
    List<Translation> translations, {
    required String language,
  }) async {
    final normalizedLanguage = _normalizeLanguage(language);
    final immutableItems = List<Translation>.unmodifiable(translations);

    await _writeList(
      fileName: _fileName(prefix: 'translations', language: normalizedLanguage),
      items: immutableItems,
      toJson: _translationToJson,
    );

    _translationCache[normalizedLanguage] = immutableItems;
  }

  Future<List<QuranRecitation>> getRecitations({String language = 'ar'}) async {
    final normalizedLanguage = _normalizeLanguage(language);
    final cached = _recitationCache[normalizedLanguage];
    if (cached != null) {
      return cached;
    }

    final items = await _readList(
      fileName: _fileName(prefix: 'recitations', language: normalizedLanguage),
      fromJson: _recitationFromJson,
    );
    final immutableItems = List<QuranRecitation>.unmodifiable(items);
    _recitationCache[normalizedLanguage] = immutableItems;
    return immutableItems;
  }

  Future<void> saveRecitations(
    List<QuranRecitation> recitations, {
    required String language,
  }) async {
    final normalizedLanguage = _normalizeLanguage(language);
    final immutableItems = List<QuranRecitation>.unmodifiable(recitations);

    await _writeList(
      fileName: _fileName(prefix: 'recitations', language: normalizedLanguage),
      items: immutableItems,
      toJson: _recitationToJson,
    );

    _recitationCache[normalizedLanguage] = immutableItems;
  }

  Future<List<T>> _readList<T>({
    required String fileName,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final file = await _resolveFile(fileName);
      if (!await file.exists()) {
        return <T>[];
      }

      final encoded = await file.readAsString();
      if (encoded.trim().isEmpty) {
        return <T>[];
      }

      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        throw const FormatException('Expected a JSON list.');
      }

      return decoded
          .map((value) {
            if (value is! Map<String, dynamic>) {
              throw const FormatException('Expected a JSON object.');
            }

            return fromJson(value);
          })
          .toList(growable: false);
    } on Object catch (error, stackTrace) {
      debugPrint('Quran catalog cache read failed for $fileName: $error');
      debugPrint('$stackTrace');
      return <T>[];
    }
  }

  Future<void> _writeList<T>({
    required String fileName,
    required List<T> items,
    required Map<String, Object?> Function(T item) toJson,
  }) async {
    try {
      final file = await _resolveFile(fileName);
      final encoded = jsonEncode(items.map(toJson).toList(growable: false));
      await file.writeAsString(encoded, flush: true);
    } on Object catch (error, stackTrace) {
      debugPrint('Quran catalog cache write failed for $fileName: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<File> _resolveFile(String fileName) async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final catalogDirectory = Directory(
      path.join(baseDirectory.path, 'quran_catalog'),
    );
    await catalogDirectory.create(recursive: true);
    return File(path.join(catalogDirectory.path, fileName));
  }

  Map<String, Object?> _tafsirToJson(Tafsir tafsir) {
    return {
      'id': tafsir.id,
      'name': tafsir.name,
      'authorName': tafsir.authorName,
      'translatedAuthorName': tafsir.translatedAuthorName,
      'slug': tafsir.slug,
      'languageName': tafsir.languageName,
      'resourceName': tafsir.resourceName,
    };
  }

  Tafsir _tafsirFromJson(Map<String, dynamic> json) {
    return Tafsir(
      id: _readInt(json, 'id'),
      name: _readString(json, 'name'),
      authorName: _readNullableString(json, 'authorName'),
      translatedAuthorName: _readNullableString(json, 'translatedAuthorName'),
      slug: _readNullableString(json, 'slug'),
      languageName: _readNullableString(json, 'languageName'),
      resourceName: _readNullableString(json, 'resourceName'),
    );
  }

  Map<String, Object?> _translationToJson(Translation translation) {
    return {
      'id': translation.id,
      'name': translation.name,
      'authorName': translation.authorName,
      'translatedAuthorName': translation.translatedAuthorName,
      'slug': translation.slug,
      'languageName': translation.languageName,
      'resourceName': translation.resourceName,
    };
  }

  Translation _translationFromJson(Map<String, dynamic> json) {
    return Translation(
      id: _readInt(json, 'id'),
      name: _readString(json, 'name'),
      authorName: _readNullableString(json, 'authorName'),
      translatedAuthorName: _readNullableString(json, 'translatedAuthorName'),
      slug: _readNullableString(json, 'slug'),
      languageName: _readNullableString(json, 'languageName'),
      resourceName: _readNullableString(json, 'resourceName'),
    );
  }

  Map<String, Object?> _recitationToJson(QuranRecitation recitation) {
    return {
      'id': recitation.id,
      'reciterName': recitation.reciterName,
      'style': recitation.style,
      'translatedName': recitation.translatedName,
      'languageName': recitation.languageName,
    };
  }

  QuranRecitation _recitationFromJson(Map<String, dynamic> json) {
    return QuranRecitation(
      id: _readInt(json, 'id'),
      reciterName: _readString(json, 'reciterName'),
      style: _readNullableString(json, 'style'),
      translatedName: _readNullableString(json, 'translatedName'),
      languageName: _readNullableString(json, 'languageName'),
    );
  }

  static String _fileName({required String prefix, required String language}) {
    return '${prefix}_${_normalizeLanguage(language)}.json';
  }

  static String _normalizeLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    return normalized.isEmpty ? 'en' : normalized;
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.parse(value);
    }

    throw FormatException('Expected "$key" to be an integer.');
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }

    throw FormatException('Expected "$key" to be a string.');
  }

  static String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }

    if (value is String) {
      return value;
    }

    return value.toString();
  }
}
