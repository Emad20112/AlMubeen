import 'package:al_mubeen/core/data/hisn_content_shared_store.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';

class AdhkarLocalDataSource {
  const AdhkarLocalDataSource(this._sharedStore);

  final HisnContentSharedStore _sharedStore;

  Future<List<AdhkarCategory>> getCategories() async {
    final categories = await _sharedStore.getCategories(HisnContentKind.adhkar);
    return categories
        .map(
          (category) => AdhkarCategory(
            id: category.id,
            title: category.title,
            subtitle: category.subtitle,
            iconKey: category.iconKey,
            count: category.count,
            arabicTitle: category.arabicTitle,
            priority: category.priority,
          ),
        )
        .toList(growable: false);
  }

  Future<AdhkarCategory?> getCategoryById(String id) async {
    final category = await _sharedStore.getCategoryById(
      id,
      HisnContentKind.adhkar,
    );
    if (category == null) {
      return null;
    }

    return AdhkarCategory(
      id: category.id,
      title: category.title,
      subtitle: category.subtitle,
      iconKey: category.iconKey,
      count: category.count,
      arabicTitle: category.arabicTitle,
      priority: category.priority,
    );
  }

  Future<List<AdhkarItem>> getItemsByCategory(String categoryId) async {
    final items = await _sharedStore.getItemsByCategory(
      categoryId,
      HisnContentKind.adhkar,
    );

    return items
        .map(
          (item) => AdhkarItem(
            id: item.id,
            categoryId: item.categoryId,
            text: item.text,
            source: item.source,
            repeatCount: item.repeatCount,
            fadl: item.fadl,
            reference: item.reference,
            translation: item.translation,
          ),
        )
        .toList(growable: false);
  }
}
