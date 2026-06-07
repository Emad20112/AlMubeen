import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/adhkar/domain/repositories/adhkar_repository.dart';

class MockAdhkarRepository implements AdhkarRepository {
  const MockAdhkarRepository();

  static const List<AdhkarCategory> _categories = [
    AdhkarCategory(
      id: 'morning',
      title: 'أذكار الصباح',
      subtitle: 'أحصنك الله طوال يومك',
      iconKey: 'sun',
      count: 8,
    ),
    AdhkarCategory(
      id: 'evening',
      title: 'أذكار المساء',
      subtitle: 'أحصنك الله طوال ليلك',
      iconKey: 'moon',
      count: 8,
    ),
    AdhkarCategory(
      id: 'sleep',
      title: 'أذكار النوم',
      subtitle: 'لنوم هادئ وراحة البال',
      iconKey: 'sleep',
      count: 8,
    ),
    AdhkarCategory(
      id: 'after_prayer',
      title: 'أذكار بعد الصلاة',
      subtitle: 'أذكار مأثورة بعد كل صلاة',
      iconKey: 'mosque',
      count: 10,
    ),
    AdhkarCategory(
      id: 'wake_up',
      title: 'أذكار الاستيقاظ',
      subtitle: 'بداية يومك بذكر الله',
      iconKey: 'alarm',
      count: 5,
    ),
    AdhkarCategory(
      id: 'restroom',
      title: 'أذكار دخول الخلاء',
      subtitle: 'احفظ نفسك بذكر الله',
      iconKey: 'door',
      count: 4,
    ),
    AdhkarCategory(
      id: 'leaving_home',
      title: 'أذكار الخروج من المنزل',
      subtitle: 'توكل على الله وحفظه',
      iconKey: 'home_exit',
      count: 6,
    ),
    AdhkarCategory(
      id: 'duas',
      title: 'أدعية متنوعة',
      subtitle: 'أدعية من القرآن والسنة',
      iconKey: 'dua',
      count: 12,
    ),
    AdhkarCategory(
      id: 'tasbih',
      title: 'التسبيح',
      subtitle: 'سبحان الله، الحمد لله، الله أكبر',
      iconKey: 'tasbih',
      count: 6,
    ),
    AdhkarCategory(
      id: 'quran_sunnah',
      title: 'أذكار من القرآن والسنة',
      subtitle: 'أذكار مأثورة من الكتاب والسنة',
      iconKey: 'quran',
      count: 10,
    ),
  ];

  static const List<AdhkarItem> _fallbackItems = [
    AdhkarItem(
      id: 'item_1',
      categoryId: 'any',
      text: 'بِسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    AdhkarItem(
      id: 'item_2',
      categoryId: 'any',
      text:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَكَفَانَا وَآوَانَا',
      source: 'رواه مسلم',
      repeatCount: 1,
    ),
    AdhkarItem(
      id: 'item_3',
      categoryId: 'any',
      text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      source: 'رواه أبو داود',
      repeatCount: 3,
    ),
    AdhkarItem(
      id: 'item_4',
      categoryId: 'any',
      text:
          'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      source: 'ذكر مأثور',
      repeatCount: 33,
    ),
  ];

  @override
  List<AdhkarCategory> getCategories() => _categories;

  @override
  AdhkarCategory? getCategoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) {
        return category;
      }
    }

    return null;
  }

  @override
  Future<List<AdhkarItem>> getItemsByCategory(String categoryId) async {
    return List<AdhkarItem>.generate(_fallbackItems.length, (index) {
      final item = _fallbackItems[index];

      return AdhkarItem(
        id: '${categoryId}_${index + 1}',
        categoryId: categoryId,
        text: item.text,
        source: item.source,
        repeatCount: item.repeatCount,
      );
    });
  }
}
