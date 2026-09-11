import 'package:al_mubeen/core/database/app_database.dart';
import 'package:drift/drift.dart';

class CategoryFavoritesDataSource {
  final AppDatabase _db;

  CategoryFavoritesDataSource(this._db);

  Future<void> addFavorite(String categoryId, String type) async {
    await _db
        .into(_db.categoryFavorites)
        .insertOnConflictUpdate(
          CategoryFavoritesEntry(
            categoryId: categoryId,
            type: type,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> removeFavorite(String categoryId, String type) async {
    final query = _db.delete(_db.categoryFavorites)
      ..where(
        (tbl) => tbl.categoryId.equals(categoryId) & tbl.type.equals(type),
      );
    await query.go();
  }

  Future<bool> isFavorited(String categoryId, String type) async {
    final query = _db.select(_db.categoryFavorites)
      ..where(
        (tbl) => tbl.categoryId.equals(categoryId) & tbl.type.equals(type),
      );
    final row = await query.getSingleOrNull();
    return row != null;
  }

  Future<Set<String>> getAllFavoriteIds(String type) async {
    final query = _db.select(_db.categoryFavorites)
      ..where((tbl) => tbl.type.equals(type));
    final rows = await query.get();
    return rows.map((row) => row.categoryId).toSet();
  }
}
