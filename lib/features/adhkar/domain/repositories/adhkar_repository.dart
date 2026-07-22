import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';

abstract interface class AdhkarRepository {
  Future<List<AdhkarCategory>> getCategories();

  Future<AdhkarCategory?> getCategoryById(String id);

  Future<List<AdhkarItem>> getItemsByCategory(String categoryId);
}
