import 'package:al_mubeen/features/names_of_allah/domain/models/allah_name_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AllahNameEntry', () {
    test('normalizes Arabic text for search', () {
      expect(normalizeArabic('ٱللَّهُ'), 'الله');
      expect(normalizeArabic('الرَّحْمَنُ'), 'الرحمن');
    });

    test('matches by name and meaning', () {
      final entry = AllahNameEntry(
        id: 55,
        name: 'الرَّحْمَنُ',
        meaning: 'ذو الرحمة الواسعة',
        searchIndex: buildAllahNameSearchIndex(
          'الرَّحْمَنُ',
          'ذو الرحمة الواسعة',
        ),
      );

      expect(entry.matchesQuery('الرحمن'), isTrue);
      expect(entry.matchesQuery('الرحمة الواسعة'), isTrue);
      expect(entry.matchesQuery('القادر'), isFalse);
    });
  });
}
