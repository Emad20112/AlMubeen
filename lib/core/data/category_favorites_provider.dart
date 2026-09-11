import 'package:al_mubeen/core/data/category_favorites_data_source.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/adhkar/data/adhkar_providers.dart';
import 'package:al_mubeen/features/dua/data/dua_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Map<String, int> _defaultAdhkarFavorites = {
  'أذكار الصباح': 1,
  'أذكار المساء': 2,
  'أذكار النوم': 3,
  'أذكار الاستيقاظ من النوم': 4,
};

const Map<String, int> _defaultDuaFavorites = {
  'دعاء السفر': 1,
  'دعاء الاستخارة': 2,
  'دعاء الهم والحزن': 3,
  'دعاء الكرب': 4,
};

class CategoryFavoritesController extends Notifier<Set<String>> {
  late CategoryFavoritesDataSource _dataSource;
  String _type = 'adhkar';

  @override
  Set<String> build() {
    return const {};
  }

  void init(String type, {CategoryFavoritesDataSource? dataSource}) {
    _type = type;
    _dataSource =
        dataSource ??
        CategoryFavoritesDataSource(ref.read(appDatabaseProvider));
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _dataSource.getAllFavoriteIds(_type);
    if (ids.isEmpty) {
      await _insertDefaults();
      state = await _dataSource.getAllFavoriteIds(_type);
    } else {
      state = ids;
    }
  }

  Future<void> _insertDefaults() async {
    final defaults = _type == 'adhkar'
        ? _defaultAdhkarFavorites
        : _defaultDuaFavorites;

    List<dynamic> categories;
    if (_type == 'adhkar') {
      final ds = ref.read(adhkarLocalDataSourceProvider);
      categories = await ds.getCategories();
    } else {
      final ds = ref.read(duaLocalDataSourceProvider);
      categories = await ds.getCategories();
    }

    for (final cat in categories) {
      final arabicTitle = cat.arabicTitle;
      if (arabicTitle != null && defaults.containsKey(arabicTitle)) {
        await _dataSource.addFavorite(cat.id, _type);
      }
    }
  }

  Future<void> toggleFavorite(String categoryId) async {
    if (state.contains(categoryId)) {
      await _dataSource.removeFavorite(categoryId, _type);
      state = {...state}..remove(categoryId);
    } else {
      await _dataSource.addFavorite(categoryId, _type);
      state = {...state, categoryId};
    }
  }

  bool isFavorited(String categoryId) => state.contains(categoryId);
}

final categoryFavoritesProvider =
    NotifierProvider<CategoryFavoritesController, Set<String>>(
      CategoryFavoritesController.new,
    );
