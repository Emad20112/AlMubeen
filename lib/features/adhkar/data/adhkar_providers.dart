import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/adhkar/data/data_sources/adhkar_db_data_source.dart';
import 'package:al_mubeen/features/adhkar/data/data_sources/adhkar_local_data_source.dart';
import 'package:al_mubeen/features/adhkar/data/islam_house_adhkar_repository.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/adhkar/domain/repositories/adhkar_repository.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_user_progress.dart';
import 'package:al_mubeen/features/adhkar/presentation/controllers/adhkar_progress_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adhkarLocalDataSourceProvider = Provider<AdhkarLocalDataSource>((ref) {
  return AdhkarLocalDataSource(ref.watch(appDatabaseProvider));
});

final adhkarDbDataSourceProvider = Provider<AdhkarDbDataSource>((ref) {
  return AdhkarDbDataSource(ref.watch(appDatabaseProvider));
});

final adhkarProgressProvider =
    NotifierProvider<AdhkarProgressController, Map<String, AdhkarUserProgress>>(
      AdhkarProgressController.new,
    );

final adhkarRepositoryProvider = Provider<AdhkarRepository>((ref) {
  final repository = IslamHouseAdhkarRepository(
    localDataSource: ref.watch(adhkarLocalDataSourceProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final adhkarCategoriesProvider = FutureProvider<List<AdhkarCategory>>((ref) async {
  final repository = ref.watch(adhkarRepositoryProvider);
  return repository.getCategories();
});

final adhkarCategoryProvider = FutureProvider.family<AdhkarCategory?, String>((
  ref,
  categoryId,
) async {
  return await ref.watch(adhkarRepositoryProvider).getCategoryById(categoryId);
});

final adhkarItemsProvider = FutureProvider.family<List<AdhkarItem>, String>((
  ref,
  categoryId,
) {
  return ref.watch(adhkarRepositoryProvider).getItemsByCategory(categoryId);
});

final adhkarProgressSummaryProvider = Provider<({int total, int completed})>((ref) {
  final progressMap = ref.watch(adhkarProgressProvider);
  final categoriesAsync = ref.watch(adhkarCategoriesProvider);

  return categoriesAsync.when(
    data: (categories) {
      int total = 0;
      int completed = 0;
      for (final category in categories) {
        total += category.count;
      }
      for (final entry in progressMap.entries) {
        if (entry.value.isCompleted) {
          completed++;
        }
      }
      return (total: total, completed: completed);
    },
    loading: () => (total: 0, completed: 0),
    error: (_, _) => (total: 0, completed: 0),
  );
});
