import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/models/quran_chapter_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_pagination_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_dto.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/models/translation_dto.dart';
import 'package:al_mubeen/features/quran/data/models/tafsir_dto.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';

final class QuranComRepository implements QuranRepository {
  const QuranComRepository({required QuranComRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final QuranComRemoteDataSource _remoteDataSource;

  @override
  Future<DataResult<List<QuranChapter>>> getChapters({
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getChapters(
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (chapters) {
        return _parse(() {
          return chapters.map(_chapterFromJson).toList(growable: false);
        });
      },
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<QuranChapter>> getChapter({
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getChapter(
      chapterNumber: chapterNumber,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (chapter) =>
          _parse(() => QuranChapterDto.fromJson(chapter).toDomain()),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<QuranVerse>> getVerse({
    required QuranVerseKey verseKey,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getVerse(
      verseKey: verseKey,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (verse) =>
          _parse(() => QuranVerseDto.fromJson(verse).toDomain()),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<QuranVersesPage>> getVersesByChapter({
    required int chapterNumber,
    int page = 1,
    int perPage = QuranComRemoteDataSource.maxVersesPerPage,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getVersesPageByChapter(
      chapterNumber: chapterNumber,
      page: page,
      perPage: perPage,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (json) => _parse(() => _versesPageFromJson(json).toDomain()),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<List<Tafsir>>> getTafsirs({
    String language = 'en',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getTafsirsByChapter(
      chapterNumber: 1, // This is ignored by the API, just needed for the call
      language: language,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (tafsirs) {
        return _parse(() {
          return tafsirs.map(_tafsirFromJson).toList(growable: false);
        });
      },
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<List<TafsirText>>> getTafsirChapterTexts({
    required int resourceId,
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getTafsirChapter(
      chapterNumber: chapterNumber,
      bookId: resourceId,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (json) => _parse(() => _tafsirTextsFromJson(json)),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<List<Translation>>> getTranslations({
    String language = 'en',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getTranslationsByChapter(
      chapterNumber: 1,
      language: language,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (translations) {
        return _parse(() {
          return translations.map(_translationFromJson).toList(growable: false);
        });
      },
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<List<TranslationText>>> getTranslationChapterTexts({
    required int resourceId,
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await _remoteDataSource.getTranslationChapter(
      chapterNumber: chapterNumber,
      bookId: resourceId,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (json) => _parse(() => _translationTextsFromJson(json)),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<TranslationText>> getTranslationForChapter({
    required int resourceId,
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await getTranslationChapterTexts(
      chapterNumber: chapterNumber,
      resourceId: resourceId,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (texts) => _parse(
        () => _combineChapterTranslationText(
          texts,
          resourceId: resourceId,
          chapterNumber: chapterNumber,
        ),
      ),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<TranslationText>> getTranslationForAyah({
    required int resourceId,
    required int chapterNumber,
    required int ayahNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await getTranslationChapterTexts(
      chapterNumber: chapterNumber,
      resourceId: resourceId,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (texts) => _parse(
        () => _translationTextForAyah(
          texts,
          resourceId: resourceId,
          chapterNumber: chapterNumber,
          ayahNumber: ayahNumber,
        ),
      ),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<TafsirText>> getTafsirForChapter({
    required int resourceId,
    required int chapterNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await getTafsirChapterTexts(
      chapterNumber: chapterNumber,
      resourceId: resourceId,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (texts) => _parse(
        () => _combineChapterTafsirText(
          texts,
          resourceId: resourceId,
          chapterNumber: chapterNumber,
        ),
      ),
      error: DataError.new,
    );
  }

  @override
  Future<DataResult<TafsirText>> getTafsirForAyah({
    required int resourceId,
    required int chapterNumber,
    required int ayahNumber,
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  }) async {
    final result = await getTafsirChapterTexts(
      chapterNumber: chapterNumber,
      resourceId: resourceId,
      fetchPolicy: fetchPolicy,
    );

    return result.when(
      success: (texts) => _parse(
        () => _tafsirTextForAyah(
          texts,
          resourceId: resourceId,
          chapterNumber: chapterNumber,
          ayahNumber: ayahNumber,
        ),
      ),
      error: DataError.new,
    );
  }

  QuranChapter _chapterFromJson(Object? value) {
    if (value is! JsonMap) {
      throw FormatException(
        'Expected chapter item to be a JSON object.',
        value,
      );
    }

    return QuranChapterDto.fromJson(value).toDomain();
  }

  Tafsir _tafsirFromJson(Object? value) {
    if (value is! JsonMap) {
      throw FormatException('Expected tafsir item to be a JSON object.', value);
    }

    final dto = TafsirDto.fromJson(value);
    return Tafsir(
      id: dto.id,
      name: dto.name,
      authorName: dto.authorName,
      slug: dto.slug,
      languageName: dto.languageName,
      resourceName: dto.translatedName?.name,
    );
  }

  List<TafsirText> _tafsirTextsFromJson(JsonMap json) {
    final verses = json['verses'];
    if (verses is JsonList && verses.isNotEmpty) {
      final tafsirTexts = verses
          .map((value) {
            if (value is! JsonMap) {
              throw FormatException(
                'Expected tafsir verse item to be a JSON object.',
                value,
              );
            }

            return _tafsirTextFromJson(value);
          })
          .toList(growable: false);

      tafsirTexts.sort(_compareTafsirTexts);
      return tafsirTexts;
    }

    // Fallback: try to parse directly
    return [_tafsirTextFromJson(json)];
  }

  TafsirText _tafsirTextFromJson(JsonMap json) {
    final dto = TafsirTextDto.fromJson(json);
    return TafsirText(
      resourceId: dto.resourceId,
      resourceName: dto.resourceName,
      text: dto.text,
      verseKey: dto.verseKey,
      verseNumber: dto.verseNumber,
      chapterId: dto.chapterId,
    );
  }

  TafsirText _combineChapterTafsirText(
    List<TafsirText> texts, {
    required int resourceId,
    required int chapterNumber,
  }) {
    if (texts.isEmpty) {
      throw FormatException(
        'Expected chapter tafsir to contain at least one verse.',
        {'resourceId': resourceId, 'chapterNumber': chapterNumber},
      );
    }

    final orderedTexts = [...texts]..sort(_compareTafsirTexts);
    final combinedText = orderedTexts
        .map((text) => text.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n\n');

    return TafsirText(
      resourceId: orderedTexts.first.resourceId,
      resourceName: orderedTexts.first.resourceName,
      text: combinedText,
      chapterId: chapterNumber,
    );
  }

  TafsirText _tafsirTextForAyah(
    List<TafsirText> texts, {
    required int resourceId,
    required int chapterNumber,
    required int ayahNumber,
  }) {
    if (texts.isEmpty) {
      throw FormatException(
        'Expected tafsir chapter to contain at least one verse.',
        {'resourceId': resourceId, 'chapterNumber': chapterNumber},
      );
    }

    for (final text in texts) {
      if (text.verseNumber == ayahNumber ||
          text.verseKey == '$chapterNumber:$ayahNumber') {
        return text;
      }
    }

    return texts.first;
  }

  Translation _translationFromJson(Object? value) {
    if (value is! JsonMap) {
      throw FormatException(
        'Expected translation item to be a JSON object.',
        value,
      );
    }

    final dto = TranslationDto.fromJson(value);
    return Translation(
      id: dto.id,
      name: dto.name,
      authorName: dto.authorName,
      slug: dto.slug,
      languageName: dto.languageName,
      resourceName: dto.translatedName?.name,
    );
  }

  List<TranslationText> _translationTextsFromJson(JsonMap json) {
    final verses = json['verses'];
    if (verses is JsonList && verses.isNotEmpty) {
      final translationTexts = verses
          .map((value) {
            if (value is! JsonMap) {
              throw FormatException(
                'Expected translation verse item to be a JSON object.',
                value,
              );
            }

            return _translationTextFromJson(value);
          })
          .toList(growable: false);

      translationTexts.sort(_compareTranslationTexts);
      return translationTexts;
    }

    return [_translationTextFromJson(json)];
  }

  TranslationText _translationTextFromJson(JsonMap json) {
    final dto = TranslationTextDto.fromJson(json);
    return TranslationText(
      resourceId: dto.resourceId,
      resourceName: dto.resourceName,
      text: dto.text,
      verseKey: dto.verseKey,
      verseNumber: dto.verseNumber,
      chapterId: dto.chapterId,
    );
  }

  TranslationText _combineChapterTranslationText(
    List<TranslationText> texts, {
    required int resourceId,
    required int chapterNumber,
  }) {
    if (texts.isEmpty) {
      throw FormatException(
        'Expected chapter translation to contain at least one verse.',
        {'resourceId': resourceId, 'chapterNumber': chapterNumber},
      );
    }

    final orderedTexts = [...texts]..sort(_compareTranslationTexts);
    final combinedText = orderedTexts
        .map((text) => text.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n\n');

    return TranslationText(
      resourceId: orderedTexts.first.resourceId,
      resourceName: orderedTexts.first.resourceName,
      text: combinedText,
      chapterId: chapterNumber,
    );
  }

  TranslationText _translationTextForAyah(
    List<TranslationText> texts, {
    required int resourceId,
    required int chapterNumber,
    required int ayahNumber,
  }) {
    if (texts.isEmpty) {
      throw FormatException(
        'Expected chapter translation to contain at least one verse.',
        {'resourceId': resourceId, 'chapterNumber': chapterNumber},
      );
    }

    for (final text in texts) {
      if (text.verseNumber == ayahNumber ||
          text.verseKey == '$chapterNumber:$ayahNumber') {
        return text;
      }
    }

    return texts.first;
  }

  int _compareTranslationTexts(TranslationText left, TranslationText right) {
    final leftVerse = left.verseNumber ?? 0;
    final rightVerse = right.verseNumber ?? 0;
    final verseComparison = leftVerse.compareTo(rightVerse);
    if (verseComparison != 0) {
      return verseComparison;
    }

    return left.text.compareTo(right.text);
  }

  int _compareTafsirTexts(TafsirText left, TafsirText right) {
    final leftVerse = left.verseNumber ?? 0;
    final rightVerse = right.verseNumber ?? 0;
    final verseComparison = leftVerse.compareTo(rightVerse);
    if (verseComparison != 0) {
      return verseComparison;
    }

    return left.text.compareTo(right.text);
  }

  QuranVersesPageDto _versesPageFromJson(JsonMap json) {
    final versesJson = json['verses'];
    if (versesJson is! JsonList) {
      throw FormatException('Expected "verses" to be a JSON list.', json);
    }

    final verses = versesJson
        .map((value) {
          if (value is! JsonMap) {
            throw FormatException(
              'Expected verse item to be a JSON object.',
              value,
            );
          }

          return QuranVerseDto.fromJson(value);
        })
        .toList(growable: false);

    final paginationJson = json['pagination'];
    final pagination = paginationJson is JsonMap
        ? QuranPaginationDto.fromJson(paginationJson)
        : null;

    return QuranVersesPageDto(verses: verses, pagination: pagination);
  }

  DataResult<T> _parse<T>(T Function() parser) {
    try {
      return DataSuccess(parser());
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse Quran.com data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unexpected Quran.com parsing error.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
