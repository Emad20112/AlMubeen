import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';

abstract interface class AdhkarRepository {
  List<AdhkarCategory> getCategories();

  AdhkarCategory? getCategoryById(String id);

  Future<List<AdhkarItem>> getItemsByCategory(String categoryId);
}
