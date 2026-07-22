import 'dart:async';
import 'package:al_mubeen/features/adhkar/data/data_sources/adhkar_local_data_source.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/adhkar/domain/repositories/adhkar_repository.dart';

class IslamHouseAdhkarRepository implements AdhkarRepository {
  IslamHouseAdhkarRepository({
    required AdhkarLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final AdhkarLocalDataSource _localDataSource;

  @override
  Future<List<AdhkarCategory>> getCategories() async {
    return await _localDataSource.getCategories();
  }

  @override
  Future<AdhkarCategory?> getCategoryById(String id) async {
    return await _localDataSource.getCategoryById(id);
  }

  @override
  Future<List<AdhkarItem>> getItemsByCategory(String categoryId) {
    return _localDataSource.getItemsByCategory(categoryId);
  }

  void dispose() {}
}
