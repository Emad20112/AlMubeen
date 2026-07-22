import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:al_mubeen/features/hadith_nawawi/domain/models/hadith_nawawi_entry.dart';
import 'package:flutter/services.dart';

final class HadithNawawiLocalDataSource {
  HadithNawawiLocalDataSource();

  static const String _assetPath = 'assets/data/40-hadith-nawawi.json';

  List<HadithNawawiEntry>? _cachedEntries;
  Future<List<HadithNawawiEntry>>? _loadingFuture;

  Future<List<HadithNawawiEntry>> getEntries({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cachedEntries;
      if (cached != null) return cached;

      final loading = _loadingFuture;
      if (loading != null) return loading;
    }

    final loadFuture = _loadEntries();
    _loadingFuture = loadFuture;

    try {
      final entries = await loadFuture;
      final immutable = List<HadithNawawiEntry>.unmodifiable(entries);
      _cachedEntries = immutable;
      return immutable;
    } finally {
      if (identical(_loadingFuture, loadFuture)) {
        _loadingFuture = null;
      }
    }
  }

  Future<void> warmUp() async {
    await getEntries();
  }

  Future<List<HadithNawawiEntry>> _loadEntries() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final entries = await Isolate.run(() {
      return _parseHadithNawawi(jsonString);
    });

    return entries.asMap().entries.map((e) {
      final raw = e.value;
      return HadithNawawiEntry.fromJson({
        'id': e.key + 1,
        'hadith': raw['hadith'],
        'description': raw['description'],
      });
    }).toList();
  }
}

List<Map<String, Object?>> _parseHadithNawawi(String jsonString) {
  final decoded = jsonDecode(jsonString);
  if (decoded is! List) {
    throw const FormatException('Expected the 40 Hadith asset to be a JSON list.');
  }

  return decoded.map<Map<String, Object?>>((entry) {
    if (entry is Map) {
      return entry.cast<String, Object?>();
    }
    throw const FormatException('Expected each hadith item to be a JSON object.');
  }).toList(growable: false);
}
