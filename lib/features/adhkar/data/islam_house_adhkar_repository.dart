import 'dart:async';
import 'package:al_mubeen/features/adhkar/data/data_sources/adhkar_local_data_source.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/adhkar/domain/repositories/adhkar_repository.dart';

class IslamHouseAdhkarRepository implements AdhkarRepository {
  IslamHouseAdhkarRepository({
    required AdhkarLocalDataSource localDataSource,
    required AdhkarRepository fallback,
  }) : _localDataSource = localDataSource,
       _fallback = fallback;

  final AdhkarLocalDataSource _localDataSource;
  final AdhkarRepository _fallback;
  final Map<String, List<AdhkarItem>> _itemsCache = {};

  @override
  List<AdhkarCategory> getCategories() => _fallback.getCategories();

  @override
  AdhkarCategory? getCategoryById(String id) => _fallback.getCategoryById(id);

  @override
  Future<List<AdhkarItem>> getItemsByCategory(String categoryId) async {
    final cachedItems = _itemsCache[categoryId];
    if (cachedItems != null) {
      return cachedItems;
    }

    try {
      final localItems = await _localDataSource.getItemsByCategory(categoryId);
      if (localItems.isNotEmpty) {
        _itemsCache[categoryId] = localItems;
        return localItems;
      }
    } catch (e) {
      // تجاهل الخطأ في جلب البيانات المحلية والعودة للمستودع الاحتياطي
    }

    final fallbackItems = await _fallback.getItemsByCategory(categoryId);
    _itemsCache[categoryId] = fallbackItems;
    return fallbackItems;
  }

  void dispose() {
    // لا حاجة لعمليات إغلاق حالياً
  }
}
