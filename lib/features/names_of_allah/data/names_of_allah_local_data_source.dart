import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:al_mubeen/features/names_of_allah/domain/models/allah_name_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class NamesOfAllahLocalDataSource {
  NamesOfAllahLocalDataSource();

  static const String _assetPath = 'assets/data/Names_Of_Allah.json';
  static const String _cacheDirectoryName = 'names_of_allah';
  static const String _cacheFileName = 'names_of_allah_v1.json';
  static const int _expectedEntryCount = 99;

  List<AllahNameEntry>? _cachedEntries;
  Future<List<AllahNameEntry>>? _loadingFuture;

  Future<List<AllahNameEntry>> getEntries({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedEntries = _cachedEntries;
      if (cachedEntries != null) {
        return cachedEntries;
      }

      final loadingFuture = _loadingFuture;
      if (loadingFuture != null) {
        return loadingFuture;
      }
    }

    final loadFuture = _loadEntries(forceRefresh: forceRefresh);
    _loadingFuture = loadFuture;

    try {
      final entries = await loadFuture;
      final immutableEntries = List<AllahNameEntry>.unmodifiable(entries);
      _cachedEntries = immutableEntries;
      return immutableEntries;
    } finally {
      if (identical(_loadingFuture, loadFuture)) {
        _loadingFuture = null;
      }
    }
  }

  Future<void> warmUp() async {
    await getEntries();
  }

  Future<List<AllahNameEntry>> _loadEntries({
    required bool forceRefresh,
  }) async {
    if (!forceRefresh) {
      final cachedEntries = await _readCachedEntries();
      if (cachedEntries.length == _expectedEntryCount) {
        return cachedEntries;
      }
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final rawEntries = await Isolate.run(() {
      return _parseAllahNamesAsset(jsonString);
    });
    final entries = rawEntries
        .map(AllahNameEntry.fromJson)
        .toList(growable: true)
      ..sort((left, right) => left.id.compareTo(right.id));

    await _writeCache(entries);
    return entries;
  }

  Future<List<AllahNameEntry>> _readCachedEntries() async {
    try {
      final file = await _resolveCacheFile();
      if (!await file.exists()) {
        return const <AllahNameEntry>[];
      }

      final encoded = await file.readAsString();
      if (encoded.trim().isEmpty) {
        return const <AllahNameEntry>[];
      }

      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        return const <AllahNameEntry>[];
      }

      final entries = decoded
          .map((value) {
            if (value is Map) {
              return AllahNameEntry.fromJson(
                value.cast<String, Object?>(),
              );
            }

            throw const FormatException('Expected a JSON object.');
          })
          .toList(growable: true)
        ..sort((left, right) => left.id.compareTo(right.id));

      if (entries.length != _expectedEntryCount) {
        return const <AllahNameEntry>[];
      }

      return entries;
    } on Object catch (error, stackTrace) {
      debugPrint(
        'NamesOfAllahLocalDataSource._readCachedEntries failed: $error',
      );
      debugPrint('$stackTrace');
      return const <AllahNameEntry>[];
    }
  }

  Future<void> _writeCache(List<AllahNameEntry> entries) async {
    try {
      final file = await _resolveCacheFile();
      await file.parent.create(recursive: true);

      final encoded = jsonEncode(
        entries.map((entry) => entry.toJson()).toList(growable: false),
      );

      final tempFile = File('${file.path}.tmp');
      await tempFile.writeAsString(encoded, flush: true);
      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);
    } on Object catch (error, stackTrace) {
      debugPrint('NamesOfAllahLocalDataSource._writeCache failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<File> _resolveCacheFile() async {
    Directory baseDirectory;
    try {
      baseDirectory = await getApplicationSupportDirectory();
    } on Object catch (error, stackTrace) {
      debugPrint(
        'NamesOfAllahLocalDataSource._resolveCacheFile fallback: $error',
      );
      debugPrint('$stackTrace');
      baseDirectory = Directory.systemTemp;
    }

    final cacheDirectory = Directory(
      p.join(baseDirectory.path, _cacheDirectoryName),
    );
    await cacheDirectory.create(recursive: true);
    return File(p.join(cacheDirectory.path, _cacheFileName));
  }
}

typedef _AllahNamesRecord = Map<String, Object?>;

List<_AllahNamesRecord> _parseAllahNamesAsset(String jsonString) {
  final decoded = jsonDecode(jsonString);
  if (decoded is! List) {
    throw const FormatException(
      'Expected the Names of Allah asset to be a JSON list.',
    );
  }

  return decoded
      .map((entry) {
        if (entry is Map) {
          return _parseAllahNameRecord(entry.cast<String, Object?>());
        }

        throw const FormatException(
          'Expected each Names of Allah item to be a JSON object.',
        );
      })
      .toList(growable: false);
}

_AllahNamesRecord _parseAllahNameRecord(Map<String, Object?> json) {
  final id = _readInt(json, 'id');
  final name = _readString(json, 'name');
  final meaning = _readString(json, 'text');

  return <String, Object?>{
    'id': id,
    'name': name,
    'meaning': meaning,
    'searchIndex': buildAllahNameSearchIndex(name, meaning),
  };
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

String _readString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  throw FormatException('Expected "$key" to be a string.');
}
