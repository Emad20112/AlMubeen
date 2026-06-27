import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/config/app_config.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/quran/data/local/quran_bookmark_service.dart';
import 'package:al_mubeen/features/quran/data/local/quran_reading_progress.dart';
import 'package:al_mubeen/features/quran/data/local/quran_reciter_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/translation_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/tafsir_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_audio_repository_impl.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_com_repository.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_reciter_repository_impl.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final quranComApiClientProvider = Provider<QuranComApiClient>((ref) {
  final client = HttpQuranComApiClient(baseUri: AppConfig.quranBackendUrl);
  ref.onDispose(client.dispose);
  return client;
});

final quranComRemoteDataSourceProvider = Provider<QuranComRemoteDataSource>((
  ref,
) {
  return QuranComRemoteDataSource(
    apiClient: ref.watch(quranComApiClientProvider),
  );
});

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranComRepository(
    remoteDataSource: ref.watch(quranComRemoteDataSourceProvider),
  );
});

final quranReciterLocalDataSourceProvider =
    Provider<QuranReciterLocalDataSource>((ref) {
      return QuranReciterLocalDataSource(
        database: ref.watch(appDatabaseProvider),
      );
    });

final tafsirLocalDataSourceProvider = Provider<TafsirLocalDataSource>((ref) {
  return TafsirLocalDataSource(database: ref.watch(appDatabaseProvider));
});

final translationLocalDataSourceProvider = Provider<TranslationLocalDataSource>(
  (ref) {
    return TranslationLocalDataSource(database: ref.watch(appDatabaseProvider));
  },
);

final downloadedTafsirsProvider = FutureProvider<List<Tafsir>>((ref) async {
  return ref.watch(tafsirLocalDataSourceProvider).getDownloadedTafsirs();
});

final downloadedTranslationsProvider = FutureProvider<List<Translation>>((
  ref,
) async {
  return ref
      .watch(translationLocalDataSourceProvider)
      .getDownloadedTranslations();
});

final quranReciterRepositoryProvider = Provider<QuranReciterRepository>((ref) {
  return QuranReciterRepositoryImpl(
    remoteDataSource: ref.watch(quranComRemoteDataSourceProvider),
    localDataSource: ref.watch(quranReciterLocalDataSourceProvider),
  );
});

final quranAudioRepositoryProvider = Provider<QuranAudioRepository>((ref) {
  return QuranAudioRepositoryImpl(
    remoteDataSource: ref.watch(quranComRemoteDataSourceProvider),
  );
});

final quranRecitationsProvider = FutureProvider<List<QuranRecitation>>((
  ref,
) async {
  final result = await ref
      .watch(quranReciterRepositoryProvider)
      .getRecitations(language: 'ar', fetchPolicy: DataFetchPolicy.cacheFirst);

  return result.when(
    success: (recitations) => recitations,
    error: (failure) => throw failure,
  );
});

final selectedQuranRecitationProvider = StateProvider<QuranRecitation?>(
  (ref) => null,
);

final quranReadingProgressServiceProvider =
    Provider<QuranReadingProgressService>((ref) {
      return QuranReadingProgressService(
        database: ref.watch(appDatabaseProvider),
      );
    });

final quranBookmarkServiceProvider = Provider<QuranBookmarkService>((ref) {
  return QuranBookmarkService(database: ref.watch(appDatabaseProvider));
});

final quranBookmarksProvider = StreamProvider<List<QuranBookmarkEntry>>((ref) {
  return ref.watch(quranBookmarkServiceProvider).watchAll();
});

/// Returns the last saved page number, or 1 (Al-Fatiha) if no progress exists.
final quranLastSavedPageProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(quranReadingProgressServiceProvider);
  final entry = await service.getLastPosition();
  return entry?.lastPage ?? 1;
});

/// Provider for fetching the list of available tafsirs
final tafsirsProvider = FutureProvider<List<Tafsir>>((ref) async {
  final repository = ref.watch(quranRepositoryProvider);
  final localDownloadedTafsirs = await ref.watch(
    downloadedTafsirsProvider.future,
  );

  final results = await Future.wait([
    repository.getTafsirs(
      language: 'ar',
      fetchPolicy: DataFetchPolicy.networkOnly,
    ),
    repository.getTafsirs(
      language: 'en',
      fetchPolicy: DataFetchPolicy.networkOnly,
    ),
  ]);

  final arabicTafsirs = results[0].when(
    success: (tafsirs) => tafsirs,
    error: (_) => <Tafsir>[],
  );
  final englishTafsirs = results[1].when(
    success: (tafsirs) => tafsirs,
    error: (_) => <Tafsir>[],
  );

  if (arabicTafsirs.isEmpty && englishTafsirs.isEmpty) {
    return localDownloadedTafsirs;
  }

  final mergedRemoteTafsirs = _mergeTafsirs(arabicTafsirs, englishTafsirs);
  if (mergedRemoteTafsirs.isNotEmpty) {
    return mergedRemoteTafsirs;
  }

  return localDownloadedTafsirs;
});

/// Provider for fetching the list of available translations
final translationsProvider = FutureProvider<List<Translation>>((ref) async {
  final repository = ref.watch(quranRepositoryProvider);
  final localDownloadedTranslations = await ref.watch(
    downloadedTranslationsProvider.future,
  );

  final results = await Future.wait([
    repository.getTranslations(
      language: 'ar',
      fetchPolicy: DataFetchPolicy.networkOnly,
    ),
    repository.getTranslations(
      language: 'en',
      fetchPolicy: DataFetchPolicy.networkOnly,
    ),
  ]);

  final arabicTranslations = results[0].when(
    success: (translations) => translations,
    error: (_) => <Translation>[],
  );
  final englishTranslations = results[1].when(
    success: (translations) => translations,
    error: (_) => <Translation>[],
  );

  if (arabicTranslations.isEmpty && englishTranslations.isEmpty) {
    return localDownloadedTranslations;
  }

  final mergedRemoteTranslations = _mergeTranslations(
    arabicTranslations,
    englishTranslations,
  );
  if (mergedRemoteTranslations.isNotEmpty) {
    return mergedRemoteTranslations;
  }

  return localDownloadedTranslations;
});

/// Provider for fetching tafsir text for a specific chapter
final tafsirChapterProvider =
    FutureProvider.family<TafsirText, ({int resourceId, int chapterNumber})>((
      ref,
      params,
    ) async {
      final localDataSource = ref.watch(tafsirLocalDataSourceProvider);
      final cachedTexts = await localDataSource.getTafsirTextForChapter(
        resourceId: params.resourceId,
        chapterId: params.chapterNumber,
      );
      final displayResourceName = await _resolveTafsirDisplayName(
        ref,
        params.resourceId,
      );

      if (cachedTexts.isNotEmpty) {
        return _combineTafsirChapterTexts(
          cachedTexts,
          chapterNumber: params.chapterNumber,
          resourceName: displayResourceName ?? cachedTexts.first.resourceName,
        );
      }

      final result = await ref
          .watch(quranRepositoryProvider)
          .getTafsirChapterTexts(
            resourceId: params.resourceId,
            chapterNumber: params.chapterNumber,
            fetchPolicy: DataFetchPolicy.networkOnly,
          );

      return result.when(
        success: (tafsirTexts) async {
          await localDataSource.saveTafsirTexts(
            resourceId: params.resourceId,
            chapterId: params.chapterNumber,
            tafsirTexts: tafsirTexts,
          );
          return _combineTafsirChapterTexts(
            tafsirTexts,
            chapterNumber: params.chapterNumber,
            resourceName:
                displayResourceName ??
                (tafsirTexts.isNotEmpty
                    ? tafsirTexts.first.resourceName
                    : null),
          );
        },
        error: (failure) => throw failure,
      );
    });

/// Provider for fetching tafsir text for a specific ayah
final tafsirAyahProvider =
    FutureProvider.family<
      TafsirText,
      ({int resourceId, int chapterNumber, int ayahNumber})
    >((ref, params) async {
      // Try to get from local cache first
      final localDataSource = ref.watch(tafsirLocalDataSourceProvider);
      final cachedTafsir = await localDataSource.getTafsirText(
        resourceId: params.resourceId,
        chapterId: params.chapterNumber,
        ayahNumber: params.ayahNumber,
      );
      final displayResourceName = await _resolveTafsirDisplayName(
        ref,
        params.resourceId,
      );

      if (cachedTafsir != null) {
        return _withResourceName(
          cachedTafsir,
          displayResourceName ?? cachedTafsir.resourceName,
        );
      }

      // If not in cache, fetch from network
      final result = await ref
          .watch(quranRepositoryProvider)
          .getTafsirChapterTexts(
            resourceId: params.resourceId,
            chapterNumber: params.chapterNumber,
            fetchPolicy: DataFetchPolicy.networkOnly,
          );

      return result.when(
        success: (tafsirTexts) async {
          // Cache the result
          await localDataSource.saveTafsirTexts(
            resourceId: params.resourceId,
            chapterId: params.chapterNumber,
            tafsirTexts: tafsirTexts,
          );
          return _withResourceName(
            _findTafsirAyahText(
              tafsirTexts,
              chapterNumber: params.chapterNumber,
              ayahNumber: params.ayahNumber,
            ),
            displayResourceName ??
                (tafsirTexts.isNotEmpty
                    ? tafsirTexts.first.resourceName
                    : null),
          );
        },
        error: (failure) => throw failure,
      );
    });

final selectedTranslationProvider = StateProvider<int?>((ref) => null);

final translationChapterProvider =
    FutureProvider.family<
      TranslationText,
      ({int resourceId, int chapterNumber})
    >((ref, params) async {
      final localDataSource = ref.watch(translationLocalDataSourceProvider);
      final cachedTexts = await localDataSource.getTranslationTextForChapter(
        resourceId: params.resourceId,
        chapterId: params.chapterNumber,
      );
      final displayResourceName = await _resolveTranslationDisplayName(
        ref,
        params.resourceId,
      );

      if (cachedTexts.isNotEmpty) {
        return _combineTranslationChapterTexts(
          cachedTexts,
          chapterNumber: params.chapterNumber,
          resourceName: displayResourceName ?? cachedTexts.first.resourceName,
        );
      }

      final result = await ref
          .watch(quranRepositoryProvider)
          .getTranslationChapterTexts(
            resourceId: params.resourceId,
            chapterNumber: params.chapterNumber,
            fetchPolicy: DataFetchPolicy.networkOnly,
          );

      return result.when(
        success: (translationTexts) async {
          await localDataSource.saveTranslationTexts(
            resourceId: params.resourceId,
            chapterId: params.chapterNumber,
            translationTexts: translationTexts,
          );
          return _combineTranslationChapterTexts(
            translationTexts,
            chapterNumber: params.chapterNumber,
            resourceName:
                displayResourceName ??
                (translationTexts.isNotEmpty
                    ? translationTexts.first.resourceName
                    : null),
          );
        },
        error: (failure) => throw failure,
      );
    });

final translationAyahProvider =
    FutureProvider.family<
      TranslationText,
      ({int resourceId, int chapterNumber, int ayahNumber})
    >((ref, params) async {
      final localDataSource = ref.watch(translationLocalDataSourceProvider);
      final cachedTranslation = await localDataSource.getTranslationText(
        resourceId: params.resourceId,
        chapterId: params.chapterNumber,
        ayahNumber: params.ayahNumber,
      );
      final displayResourceName = await _resolveTranslationDisplayName(
        ref,
        params.resourceId,
      );

      if (cachedTranslation != null) {
        return _withTranslationResourceName(
          cachedTranslation,
          displayResourceName ?? cachedTranslation.resourceName,
        );
      }

      final result = await ref
          .watch(quranRepositoryProvider)
          .getTranslationChapterTexts(
            resourceId: params.resourceId,
            chapterNumber: params.chapterNumber,
            fetchPolicy: DataFetchPolicy.networkOnly,
          );

      return result.when(
        success: (translationTexts) async {
          await localDataSource.saveTranslationTexts(
            resourceId: params.resourceId,
            chapterId: params.chapterNumber,
            translationTexts: translationTexts,
          );
          return _withTranslationResourceName(
            _findTranslationAyahText(
              translationTexts,
              chapterNumber: params.chapterNumber,
              ayahNumber: params.ayahNumber,
            ),
            displayResourceName ??
                (translationTexts.isNotEmpty
                    ? translationTexts.first.resourceName
                    : null),
          );
        },
        error: (failure) => throw failure,
      );
    });

/// Provider for the currently selected tafsir (defaults to Tafsir Muyassar - ID 16)
final selectedTafsirProvider = StateProvider<int>((ref) => 16);

List<Tafsir> _mergeTafsirs(
  List<Tafsir> arabicTafsirs,
  List<Tafsir> englishTafsirs,
) {
  final englishById = {for (final tafsir in englishTafsirs) tafsir.id: tafsir};
  final merged = <Tafsir>[];
  final seenIds = <int>{};

  for (final arabicTafsir in arabicTafsirs) {
    merged.add(_mergeTafsir(arabicTafsir, englishById[arabicTafsir.id]));
    seenIds.add(arabicTafsir.id);
  }

  for (final englishTafsir in englishTafsirs) {
    if (seenIds.contains(englishTafsir.id)) {
      continue;
    }
    merged.add(_mergeTafsir(null, englishTafsir));
  }

  return merged;
}

Tafsir _mergeTafsir(Tafsir? arabicTafsir, Tafsir? englishTafsir) {
  final primary = arabicTafsir ?? englishTafsir;
  if (primary == null) {
    throw StateError('Unable to merge empty tafsir entries.');
  }

  final arabicName =
      arabicTafsir?.resourceName ??
      arabicTafsir?.name ??
      englishTafsir?.resourceName ??
      englishTafsir?.name ??
      primary.name;
  final englishName =
      englishTafsir?.resourceName ??
      englishTafsir?.name ??
      arabicTafsir?.resourceName ??
      arabicTafsir?.name;
  final arabicAuthor = arabicTafsir?.authorName ?? englishTafsir?.authorName;
  final englishAuthor = englishTafsir?.authorName;

  return Tafsir(
    id: primary.id,
    name: arabicName,
    authorName: arabicAuthor,
    translatedAuthorName: englishAuthor != null && englishAuthor != arabicAuthor
        ? englishAuthor
        : null,
    slug: arabicTafsir?.slug ?? englishTafsir?.slug,
    languageName: arabicTafsir?.languageName ?? englishTafsir?.languageName,
    resourceName: englishName != arabicName ? englishName : null,
  );
}

Future<String?> _resolveTafsirDisplayName(Ref ref, int resourceId) async {
  try {
    final tafsirs = await ref.watch(tafsirsProvider.future);
    for (final tafsir in tafsirs) {
      if (tafsir.id == resourceId) {
        return tafsir.name;
      }
    }
  } catch (_) {
    // If the bilingual resource list fails, keep the tafsir text flow working.
  }

  return null;
}

List<Translation> _mergeTranslations(
  List<Translation> arabicTranslations,
  List<Translation> englishTranslations,
) {
  final englishById = {
    for (final translation in englishTranslations) translation.id: translation,
  };
  final merged = <Translation>[];
  final seenIds = <int>{};

  for (final arabicTranslation in arabicTranslations) {
    merged.add(
      _mergeTranslation(arabicTranslation, englishById[arabicTranslation.id]),
    );
    seenIds.add(arabicTranslation.id);
  }

  for (final englishTranslation in englishTranslations) {
    if (seenIds.contains(englishTranslation.id)) {
      continue;
    }
    merged.add(_mergeTranslation(null, englishTranslation));
  }

  return merged;
}

Translation _mergeTranslation(
  Translation? arabicTranslation,
  Translation? englishTranslation,
) {
  final primary = arabicTranslation ?? englishTranslation;
  if (primary == null) {
    throw StateError('Unable to merge empty translation entries.');
  }

  final arabicName =
      arabicTranslation?.resourceName ??
      arabicTranslation?.name ??
      englishTranslation?.resourceName ??
      englishTranslation?.name ??
      primary.name;
  final englishName =
      englishTranslation?.resourceName ??
      englishTranslation?.name ??
      arabicTranslation?.resourceName ??
      arabicTranslation?.name;
  final arabicAuthor =
      arabicTranslation?.authorName ?? englishTranslation?.authorName;
  final englishAuthor = englishTranslation?.authorName;

  return Translation(
    id: primary.id,
    name: arabicName,
    authorName: arabicAuthor,
    translatedAuthorName: englishAuthor != null && englishAuthor != arabicAuthor
        ? englishAuthor
        : null,
    slug: arabicTranslation?.slug ?? englishTranslation?.slug,
    languageName:
        arabicTranslation?.languageName ?? englishTranslation?.languageName,
    resourceName: englishName != arabicName ? englishName : null,
  );
}

Future<String?> _resolveTranslationDisplayName(Ref ref, int resourceId) async {
  try {
    final translations = await ref.watch(translationsProvider.future);
    for (final translation in translations) {
      if (translation.id == resourceId) {
        return translation.name;
      }
    }
  } catch (_) {
    // If the bilingual resource list fails, keep the translation text flow working.
  }

  return null;
}

TafsirText _withResourceName(TafsirText tafsirText, String? resourceName) {
  if (resourceName == null ||
      resourceName.trim().isEmpty ||
      tafsirText.resourceName == resourceName) {
    return tafsirText;
  }

  return TafsirText(
    resourceId: tafsirText.resourceId,
    resourceName: resourceName,
    text: tafsirText.text,
    verseKey: tafsirText.verseKey,
    verseNumber: tafsirText.verseNumber,
    chapterId: tafsirText.chapterId,
  );
}

TafsirText _combineTafsirChapterTexts(
  List<TafsirText> tafsirTexts, {
  required int chapterNumber,
  String? resourceName,
}) {
  if (tafsirTexts.isEmpty) {
    throw FormatException(
      'Expected tafsir chapter to contain at least one verse.',
      {'chapterNumber': chapterNumber},
    );
  }

  final orderedTexts = [...tafsirTexts]
    ..sort((left, right) {
      final leftVerse = left.verseNumber ?? 0;
      final rightVerse = right.verseNumber ?? 0;
      final verseComparison = leftVerse.compareTo(rightVerse);
      if (verseComparison != 0) {
        return verseComparison;
      }

      return left.text.compareTo(right.text);
    });

  return TafsirText(
    resourceId: orderedTexts.first.resourceId,
    resourceName: resourceName ?? orderedTexts.first.resourceName,
    text: orderedTexts
        .map((tafsirText) => tafsirText.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n\n'),
    chapterId: chapterNumber,
  );
}

TafsirText _findTafsirAyahText(
  List<TafsirText> tafsirTexts, {
  required int chapterNumber,
  required int ayahNumber,
}) {
  if (tafsirTexts.isEmpty) {
    throw FormatException(
      'Expected tafsir chapter to contain at least one verse.',
      {'chapterNumber': chapterNumber},
    );
  }

  for (final tafsirText in tafsirTexts) {
    if (tafsirText.verseNumber == ayahNumber ||
        tafsirText.verseKey == '$chapterNumber:$ayahNumber') {
      return tafsirText;
    }
  }

  return tafsirTexts.first;
}

TranslationText _withTranslationResourceName(
  TranslationText translationText,
  String? resourceName,
) {
  if (resourceName == null ||
      resourceName.trim().isEmpty ||
      translationText.resourceName == resourceName) {
    return translationText;
  }

  return TranslationText(
    resourceId: translationText.resourceId,
    resourceName: resourceName,
    text: translationText.text,
    verseKey: translationText.verseKey,
    verseNumber: translationText.verseNumber,
    chapterId: translationText.chapterId,
  );
}

TranslationText _combineTranslationChapterTexts(
  List<TranslationText> translationTexts, {
  required int chapterNumber,
  String? resourceName,
}) {
  if (translationTexts.isEmpty) {
    throw FormatException(
      'Expected translation chapter to contain at least one verse.',
      {'chapterNumber': chapterNumber},
    );
  }

  final orderedTexts = [...translationTexts]
    ..sort((left, right) {
      final leftVerse = left.verseNumber ?? 0;
      final rightVerse = right.verseNumber ?? 0;
      final verseComparison = leftVerse.compareTo(rightVerse);
      if (verseComparison != 0) {
        return verseComparison;
      }

      return left.text.compareTo(right.text);
    });

  return TranslationText(
    resourceId: orderedTexts.first.resourceId,
    resourceName: resourceName ?? orderedTexts.first.resourceName,
    text: orderedTexts
        .map((translationText) => translationText.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n\n'),
    chapterId: chapterNumber,
  );
}

TranslationText _findTranslationAyahText(
  List<TranslationText> translationTexts, {
  required int chapterNumber,
  required int ayahNumber,
}) {
  if (translationTexts.isEmpty) {
    throw FormatException(
      'Expected translation chapter to contain at least one verse.',
      {'chapterNumber': chapterNumber},
    );
  }

  for (final translationText in translationTexts) {
    if (translationText.verseNumber == ayahNumber ||
        translationText.verseKey == '$chapterNumber:$ayahNumber') {
      return translationText;
    }
  }

  return translationTexts.first;
}
