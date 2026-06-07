import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_mubeen/features/adhkar/data/adhkar_providers.dart';
import 'package:al_mubeen/features/adhkar/data/data_sources/adhkar_db_data_source.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_user_progress.dart';

class AdhkarProgressController extends Notifier<Map<String, AdhkarUserProgress>> {
  late final AdhkarDbDataSource _dbDataSource;

  @override
  Map<String, AdhkarUserProgress> build() {
    _dbDataSource = ref.watch(adhkarDbDataSourceProvider);
    return const {};
  }

  // تحميل التقدم المسجل لفئة معينة
  Future<void> loadProgress(String categoryId) async {
    try {
      final progressList = await _dbDataSource.getProgressByCategory(categoryId);
      final updatedMap = Map<String, AdhkarUserProgress>.from(state);
      for (final p in progressList) {
        updatedMap[p.itemId] = p;
      }
      state = updatedMap;
    } catch (e) {
      debugPrint('Error loading progress for $categoryId: $e');
    }
  }

  // زيادة العداد للذكر الحالي
  Future<void> incrementProgress(String itemId, String categoryId, int maxCount) async {
    final today = DateTime.now();
    final current = state[itemId] ?? AdhkarUserProgress(
      itemId: itemId,
      categoryId: categoryId,
      completedCount: 0,
      isCompleted: false,
      lastUpdated: today,
    );

    if (current.completedCount < maxCount) {
      final newCount = current.completedCount + 1;
      final isCompleted = newCount >= maxCount;
      final updated = current.copyWith(
        completedCount: newCount,
        isCompleted: isCompleted,
        lastUpdated: today,
      );

      // تحديث الحالة محلياً فوراً للتجاوب السريع مع النقرات
      final updatedMap = Map<String, AdhkarUserProgress>.from(state);
      updatedMap[itemId] = updated;
      state = updatedMap;

      // حفظ التغيير في قاعدة البيانات في الخلفية
      unawaited(_dbDataSource.saveProgress(updated));
    }
  }

  // تصفير تقدم الفئة بالكامل
  Future<void> resetCategory(String categoryId) async {
    try {
      await _dbDataSource.resetCategoryProgress(categoryId);
      // إعادة تحميل التقدم بعد التصفير
      await loadProgress(categoryId);
    } catch (e) {
      debugPrint('Error resetting category $categoryId: $e');
    }
  }
}
