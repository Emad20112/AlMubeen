import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/adhkar/data/data_sources/adhkar_db_data_source.dart';
import 'package:al_mubeen/features/adhkar/data/data_sources/adhkar_local_data_source.dart';
import 'package:al_mubeen/features/adhkar/data/islam_house_adhkar_repository.dart';
import 'package:al_mubeen/features/adhkar/data/mock_adhkar_repository.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/adhkar/domain/repositories/adhkar_repository.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_user_progress.dart';
import 'package:al_mubeen/features/adhkar/presentation/controllers/adhkar_progress_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adhkarLocalDataSourceProvider = Provider<AdhkarLocalDataSource>((ref) {
  return AdhkarLocalDataSource();
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
    fallback: const MockAdhkarRepository(),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final adhkarCategoriesProvider = Provider<List<AdhkarCategory>>((ref) {
  return ref.watch(adhkarRepositoryProvider).getCategories();
});

final adhkarCategoryProvider = Provider.family<AdhkarCategory?, String>((
  ref,
  categoryId,
) {
  return ref.watch(adhkarRepositoryProvider).getCategoryById(categoryId);
});

final adhkarItemsProvider = FutureProvider.family<List<AdhkarItem>, String>((
  ref,
  categoryId,
) {
  return ref.watch(adhkarRepositoryProvider).getItemsByCategory(categoryId);
});
