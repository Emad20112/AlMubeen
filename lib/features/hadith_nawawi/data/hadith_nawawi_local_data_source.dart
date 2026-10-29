import 'dart:async';

import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/database/static_data_seeds.dart';
import 'package:al_mubeen/features/hadith_nawawi/domain/models/hadith_nawawi_entry.dart';
import 'package:drift/drift.dart';

final class HadithNawawiLocalDataSource {
  HadithNawawiLocalDataSource(this._db);

  final AppDatabase _db;

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
    final query = _db.select(_db.hadithNawawiEntries)
      ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]);

    var rows = await query.get();

    if (rows.isEmpty) {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.hadithNawawiEntries,
          staticHadithNawawiSeeds,
        );
      });
      rows = await query.get();
    }

    return rows
        .map(
          (row) => HadithNawawiEntry(
            id: row.id,
            hadithNumber: row.hadithNumber,
            title: row.title,
            preview: row.preview,
            fullText: row.fullText,
            source: row.source,
            description: row.description,
            searchIndex: row.searchIndex,
          ),
        )
        .toList(growable: true);
  }
}
