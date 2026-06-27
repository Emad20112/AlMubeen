import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:flutter/foundation.dart';

abstract interface class QuranRepository {
  Future<DataResult<List<QuranChapter>>> getChapters({
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<QuranChapter>> getChapter({
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<QuranVerse>> getVerse({
    required QuranVerseKey verseKey,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<QuranVersesPage>> getVersesByChapter({
    required int chapterNumber,
    int page = 1,
    int perPage = 50,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<List<Tafsir>>> getTafsirs({
    String language = 'en',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<List<TafsirText>>> getTafsirChapterTexts({
    required int resourceId,
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<TafsirText>> getTafsirForChapter({
    required int resourceId,
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<TafsirText>> getTafsirForAyah({
    required int resourceId,
    required int chapterNumber,
    required int ayahNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<List<Translation>>> getTranslations({
    String language = 'en',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<List<TranslationText>>> getTranslationChapterTexts({
    required int resourceId,
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<TranslationText>> getTranslationForChapter({
    required int resourceId,
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });

  Future<DataResult<TranslationText>> getTranslationForAyah({
    required int resourceId,
    required int chapterNumber,
    required int ayahNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });
}

@immutable
final class QuranChapter {
  const QuranChapter({
    required this.id,
    required this.nameArabic,
    required this.nameSimple,
    required this.nameComplex,
    required this.versesCount,
    required this.pages,
    this.revelationPlace,
    this.revelationOrder,
    this.bismillahPre,
    this.translatedName,
  });

  final int id;
  final String nameArabic;
  final String nameSimple;
  final String nameComplex;
  final int versesCount;
  final List<int> pages;
  final String? revelationPlace;
  final int? revelationOrder;
  final bool? bismillahPre;
  final String? translatedName;
}

@immutable
final class QuranVerse {
  const QuranVerse({
    required this.verseKey,
    this.id,
    this.verseNumber,
    this.pageNumber,
    this.juzNumber,
    this.hizbNumber,
    this.rubElHizbNumber,
    this.sajdahNumber,
    this.textUthmani,
    this.textUthmaniSimple,
  });

  final QuranVerseKey verseKey;
  final int? id;
  final int? verseNumber;
  final int? pageNumber;
  final int? juzNumber;
  final int? hizbNumber;
  final int? rubElHizbNumber;
  final int? sajdahNumber;
  final String? textUthmani;
  final String? textUthmaniSimple;
}

@immutable
final class QuranVersesPage {
  const QuranVersesPage({required this.verses, this.pagination});

  final List<QuranVerse> verses;
  final QuranPagination? pagination;
}

@immutable
final class QuranPagination {
  const QuranPagination({
    required this.currentPage,
    required this.perPage,
    this.nextPage,
    this.totalPages,
    this.totalRecords,
  });

  final int currentPage;
  final int perPage;
  final int? nextPage;
  final int? totalPages;
  final int? totalRecords;
}

@immutable
final class Tafsir {
  const Tafsir({
    required this.id,
    required this.name,
    this.authorName,
    this.translatedAuthorName,
    this.slug,
    this.languageName,
    this.resourceName,
  });

  final int id;
  final String name;
  final String? authorName;
  final String? translatedAuthorName;
  final String? slug;
  final String? languageName;
  final String? resourceName;
}

@immutable
final class TafsirText {
  const TafsirText({
    required this.resourceId,
    required this.resourceName,
    required this.text,
    this.verseKey,
    this.verseNumber,
    this.chapterId,
  });

  final int resourceId;
  final String resourceName;
  final String text;
  final String? verseKey;
  final int? verseNumber;
  final int? chapterId;
}

@immutable
final class Translation {
  const Translation({
    required this.id,
    required this.name,
    this.authorName,
    this.translatedAuthorName,
    this.slug,
    this.languageName,
    this.resourceName,
  });

  final int id;
  final String name;
  final String? authorName;
  final String? translatedAuthorName;
  final String? slug;
  final String? languageName;
  final String? resourceName;
}

@immutable
final class TranslationText {
  const TranslationText({
    required this.resourceId,
    required this.resourceName,
    required this.text,
    this.verseKey,
    this.verseNumber,
    this.chapterId,
  });

  final int resourceId;
  final String resourceName;
  final String text;
  final String? verseKey;
  final int? verseNumber;
  final int? chapterId;
}
