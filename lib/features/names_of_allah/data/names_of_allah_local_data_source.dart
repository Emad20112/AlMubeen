import 'dart:async';

import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/database/static_data_seeds.dart';
import 'package:al_mubeen/features/names_of_allah/domain/models/allah_name_entry.dart';
import 'package:drift/drift.dart';

final class NamesOfAllahLocalDataSource {
  NamesOfAllahLocalDataSource(this._db);

  final AppDatabase _db;

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
    final query = _db.select(_db.namesOfAllahEntries)
      ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]);

    var rows = await query.get();

    if (rows.isEmpty) {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.namesOfAllahEntries,
          staticNamesOfAllahSeeds,
        );
      });
      rows = await query.get();
    }

    return rows
        .map(
          (row) => AllahNameEntry(
            id: row.id,
            name: row.name,
            meaning: row.meaning,
            searchIndex: row.searchIndex,
          ),
        )
        .toList(growable: true);
  }
}
