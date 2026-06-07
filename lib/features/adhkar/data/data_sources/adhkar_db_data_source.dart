import 'package:drift/drift.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_user_progress.dart';

class AdhkarDbDataSource {
  final AppDatabase _db;

  AdhkarDbDataSource(this._db);

  // حفظ أو تحديث تقدم المستخدم في ذكر معين
  Future<void> saveProgress(AdhkarUserProgress progress) async {
    await _db.into(_db.adhkarProgressCache).insertOnConflictUpdate(
      AdhkarProgressCacheEntry(
        itemId: progress.itemId,
        categoryId: progress.categoryId,
        completedCount: progress.completedCount,
        isCompleted: progress.isCompleted,
        lastUpdated: progress.lastUpdated,
      ),
    );
  }

  // جلب تقدم الأذكار لفئة معينة لليوم الحالي
  Future<List<AdhkarUserProgress>> getProgressByCategory(String categoryId) async {
    final query = _db.select(_db.adhkarProgressCache)
      ..where((tbl) => tbl.categoryId.equals(categoryId));
    final rows = await query.get();
    
    final today = DateTime.now();
    final List<AdhkarUserProgress> results = [];
    
    for (final row in rows) {
      // التحقق مما إذا كان التقدم المحفوظ ينتمي لليوم الحالي
      final isSameDay = row.lastUpdated.year == today.year &&
          row.lastUpdated.month == today.month &&
          row.lastUpdated.day == today.day;
          
      if (!isSameDay) {
        final resetRow = row.copyWith(
          completedCount: 0,
          isCompleted: false,
          lastUpdated: today,
        );
        // تحديث في قاعدة البيانات للتصفير اليومي
        await _db.into(_db.adhkarProgressCache).insertOnConflictUpdate(resetRow);
        results.add(AdhkarUserProgress(
          itemId: resetRow.itemId,
          categoryId: resetRow.categoryId,
          completedCount: 0,
          isCompleted: false,
          lastUpdated: today,
        ));
      } else {
        results.add(AdhkarUserProgress(
          itemId: row.itemId,
          categoryId: row.categoryId,
          completedCount: row.completedCount,
          isCompleted: row.isCompleted,
          lastUpdated: row.lastUpdated,
        ));
      }
    }
    
    return results;
  }

  // جلب تقدم ذكر فردي
  Future<AdhkarUserProgress?> getProgressByItem(String itemId) async {
    final query = _db.select(_db.adhkarProgressCache)
      ..where((tbl) => tbl.itemId.equals(itemId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final today = DateTime.now();
    final isSameDay = row.lastUpdated.year == today.year &&
        row.lastUpdated.month == today.month &&
        row.lastUpdated.day == today.day;

    if (!isSameDay) {
      final resetRow = row.copyWith(
        completedCount: 0,
        isCompleted: false,
        lastUpdated: today,
      );
      await _db.into(_db.adhkarProgressCache).insertOnConflictUpdate(resetRow);
      return AdhkarUserProgress(
        itemId: resetRow.itemId,
        categoryId: resetRow.categoryId,
        completedCount: 0,
        isCompleted: false,
        lastUpdated: today,
      );
    }

    return AdhkarUserProgress(
      itemId: row.itemId,
      categoryId: row.categoryId,
      completedCount: row.completedCount,
      isCompleted: row.isCompleted,
      lastUpdated: row.lastUpdated,
    );
  }

  // تصفير تقدم الأذكار لفئة معينة يدوياً
  Future<void> resetCategoryProgress(String categoryId) async {
    final today = DateTime.now();
    final query = _db.update(_db.adhkarProgressCache)
      ..where((tbl) => tbl.categoryId.equals(categoryId));
    await query.write(
      AdhkarProgressCacheCompanion(
        completedCount: const Value(0),
        isCompleted: const Value(false),
        lastUpdated: Value(today),
      ),
    );
  }

  // إضافة الذكر للمفضلة
  Future<void> addToFavorites(String itemId) async {
    await _db.into(_db.adhkarFavorites).insertOnConflictUpdate(
      AdhkarFavoritesEntry(
        itemId: itemId,
        createdAt: DateTime.now(),
      ),
    );
  }

  // إزالة الذكر من المفضلة
  Future<void> removeFromFavorites(String itemId) async {
    final query = _db.delete(_db.adhkarFavorites)
      ..where((tbl) => tbl.itemId.equals(itemId));
    await query.go();
  }

  // جلب كافة معرفات الأذكار المفضلة
  Future<List<String>> getFavorites() async {
    final query = _db.select(_db.adhkarFavorites);
    final rows = await query.get();
    return rows.map((row) => row.itemId).toList();
  }

  // التحقق مما إذا كان الذكر مفضلاً
  Future<bool> isFavorited(String itemId) async {
    final query = _db.select(_db.adhkarFavorites)
      ..where((tbl) => tbl.itemId.equals(itemId));
    final row = await query.getSingleOrNull();
    return row != null;
  }
}
