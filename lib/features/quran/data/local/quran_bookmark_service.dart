import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:drift/drift.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class QuranBookmarkService {
  QuranBookmarkService({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Stream<List<QuranBookmarkEntry>> watchAll() {
    return (_db.select(_db.quranBookmarks)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<QuranBookmarkEntry>> getAll() {
    return (_db.select(_db.quranBookmarks)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<bool> isBookmarked({
    required int page,
    int? ayahNumber,
  }) async {
    final bookmark = await findBookmark(page: page, ayahNumber: ayahNumber);
    return bookmark != null;
  }

  Future<QuranBookmarkEntry?> findBookmark({
    required int page,
    int? ayahNumber,
  }) async {
    if (ayahNumber == null) {
      return (_db.select(_db.quranBookmarks)
            ..where((t) => t.page.equals(page) & t.ayahNumber.isNull()))
          .getSingleOrNull();
    }

    return (_db.select(_db.quranBookmarks)
          ..where(
            (t) =>
                t.page.equals(page) & t.ayahNumber.equals(ayahNumber),
          ))
        .getSingleOrNull();
  }

  Future<void> addPageBookmark({required int page}) async {
    final surahNumber = getSurahNumberFromPage(page);
    final label = 'صفحة $page • ${getSurahNameArabic(surahNumber)}';
    await _insertBookmark(
      page: page,
      surahNumber: surahNumber,
      ayahNumber: null,
      label: label,
    );
  }

  Future<void> addAyahBookmark({required AyahRef ayahRef}) async {
    final label =
        '${getSurahNameArabic(ayahRef.surah)} - الآية ${ayahRef.ayah}';
    await _insertBookmark(
      page: ayahRef.page,
      surahNumber: ayahRef.surah,
      ayahNumber: ayahRef.ayah,
      label: label,
    );
  }

  Future<void> removeBookmark(int id) async {
    await (_db.delete(_db.quranBookmarks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> togglePageBookmark({required int page}) async {
    final existing = await findBookmark(page: page, ayahNumber: null);
    if (existing != null) {
      await removeBookmark(existing.id);
      return;
    }
    await addPageBookmark(page: page);
  }

  Future<void> toggleAyahBookmark({required AyahRef ayahRef}) async {
    final existing = await findBookmark(
      page: ayahRef.page,
      ayahNumber: ayahRef.ayah,
    );
    if (existing != null) {
      await removeBookmark(existing.id);
      return;
    }
    await addAyahBookmark(ayahRef: ayahRef);
  }

  Future<void> _insertBookmark({
    required int page,
    required int surahNumber,
    required int? ayahNumber,
    required String label,
  }) async {
    await _db.into(_db.quranBookmarks).insert(
      QuranBookmarksCompanion.insert(
        page: page,
        surahNumber: surahNumber,
        ayahNumber: Value(ayahNumber),
        label: Value(label),
        createdAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}
