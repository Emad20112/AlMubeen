import 'package:al_mubeen/features/quran/data/local/tafsir_muyassar_asset_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads built-in Muyassar tafsir chapters from the asset', () async {
    final dataSource = TafsirMuyassarAssetDataSource();

    final chapterNumbers = await dataSource.getAvailableChapterNumbers();
    final firstChapterTexts = await dataSource.getChapterTexts(1);

    expect(chapterNumbers.first, 1);
    expect(chapterNumbers.last, 114);
    expect(firstChapterTexts, isNotEmpty);
    expect(firstChapterTexts.first.chapterId, 1);
    expect(firstChapterTexts.first.verseNumber, 1);
  });
}
