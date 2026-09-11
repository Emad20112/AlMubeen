import 'package:al_mubeen/core/data/hisn_content_shared_store.dart';
import 'package:al_mubeen/features/dua/domain/models/dua_category.dart';
import 'package:al_mubeen/features/dua/domain/models/dua_item.dart';

class DuaLocalDataSource {
  const DuaLocalDataSource(this._sharedStore);

  final HisnContentSharedStore _sharedStore;

  Future<List<DuaCategory>> getCategories() async {
    final categories = await _sharedStore.getCategories(HisnContentKind.dua);
    return categories
        .map(
          (category) => DuaCategory(
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

  Future<DuaCategory?> getCategoryById(String id) async {
    final category = await _sharedStore.getCategoryById(
      id,
      HisnContentKind.dua,
    );
    if (category == null) {
      return null;
    }

    return DuaCategory(
      id: category.id,
      title: category.title,
      subtitle: category.subtitle,
      iconKey: category.iconKey,
      count: category.count,
      arabicTitle: category.arabicTitle,
      priority: category.priority,
    );
  }

  Future<List<DuaItem>> getItemsByCategory(String categoryId) async {
    final items = await _sharedStore.getItemsByCategory(
      categoryId,
      HisnContentKind.dua,
    );

    return items
        .map(
          (item) => DuaItem(
            id: item.id,
            categoryId: item.categoryId,
            text: item.text,
            source: item.source,
            fadl: item.fadl,
            reference: item.reference,
            translation: item.translation,
          ),
        )
        .toList(growable: false);
  }
}
