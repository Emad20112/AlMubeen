import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wirdDaoProvider = Provider<WirdDao>((ref) {
  return WirdDao(ref.watch(appDatabaseProvider));
});

class WirdDao {
  WirdDao(this._database);

  final AppDatabase _database;

  Future<WirdEntry?> getWird() async {
    final query = _database.select(_database.wirdsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(1);

    return query.getSingleOrNull();
  }

  Future<int> insertWird(WirdsTableCompanion entry) {
    return _database.into(_database.wirdsTable).insert(entry);
  }

  Future<void> updateWird(WirdEntry entry) async {
    await _database.update(_database.wirdsTable).replace(entry);
  }

  Future<void> markWirdCompletedToday({
    required int wirdId,
    required int plannedStartPage,
    required int plannedEndPage,
    required int targetPages,
    DateTime? at,
  }) async {
    final now = at ?? DateTime.now();
    final dateKey = now.toIso8601String().split('T').first;

    final existing =
        await (_database.select(_database.wirdDailyProgressTable)
              ..where(
                (tbl) =>
                    tbl.wirdId.equals(wirdId) & tbl.dateKey.equals(dateKey),
              )
              ..limit(1))
            .getSingleOrNull();

    final data = WirdDailyProgressTableCompanion(
      wirdId: Value(wirdId),
      dateKey: Value(dateKey),
      plannedStartPage: Value(plannedStartPage),
      plannedEndPage: Value(plannedEndPage),
      actualStartPage: Value(plannedStartPage),
      actualEndPage: Value(plannedEndPage),
      targetPages: Value(targetPages),
      completedPages: Value(targetPages),
      status: const Value('completed'),
      completedAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    if (existing != null) {
      await (_database.update(
        _database.wirdDailyProgressTable,
      )..where((tbl) => tbl.id.equals(existing.id))).write(data);
      return;
    }

    await _database.into(_database.wirdDailyProgressTable).insert(data);
  }
}
