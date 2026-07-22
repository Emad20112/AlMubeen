import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/dua/data/data_sources/dua_local_data_source.dart';
import 'package:al_mubeen/features/dua/domain/models/dua_category.dart';
import 'package:al_mubeen/features/dua/domain/models/dua_item.dart';

final duaLocalDataSourceProvider = Provider<DuaLocalDataSource>((ref) {
  return DuaLocalDataSource(ref.watch(appDatabaseProvider));
});

final duaCategoriesProvider = FutureProvider<List<DuaCategory>>((ref) async {
  final localDataSource = ref.watch(duaLocalDataSourceProvider);
  return localDataSource.getCategories();
});

final duaCategoryProvider = FutureProvider.family<DuaCategory?, String>((ref, id) async {
  final localDataSource = ref.watch(duaLocalDataSourceProvider);
  return localDataSource.getCategoryById(id);
});

final duaItemsProvider = FutureProvider.family<List<DuaItem>, String>((ref, categoryId) async {
  final localDataSource = ref.watch(duaLocalDataSourceProvider);
  return localDataSource.getItemsByCategory(categoryId);
});
