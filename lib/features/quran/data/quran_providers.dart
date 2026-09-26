import 'dart:async';

import 'package:al_mubeen/core/config/app_config.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/quran/application/default_tafsir_seed_service.dart';
import 'package:al_mubeen/features/quran/data/cache/chapter_lru_cache.dart';
import 'package:al_mubeen/features/quran/data/cache/quran_memory_cache_providers.dart';
import 'package:al_mubeen/features/quran/data/helpers/reciter_normalizer.dart';
import 'package:al_mubeen/features/quran/data/local/islamic_app_recitation_store.dart';
import 'package:al_mubeen/features/quran/data/local/quran_bookmark_service.dart';
import 'package:al_mubeen/features/quran/data/local/quran_reciter_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/quran_resource_catalog_storage.dart';
import 'package:al_mubeen/features/quran/data/local/tafsir_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/tafsir_muyassar_asset_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/translation_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/remote/islamic_app_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_audio_repository_impl.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_com_repository.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_reciter_repository_impl.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/domain/tafsir_defaults.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final quranComApiClientProvider = Provider<QuranComApiClient>((ref) {
  final client = HttpQuranComApiClient(baseUri: AppConfig.quranBackendUrl);
  ref.onDispose(client.dispose);
  return client;
});

final islamicAppApiClientProvider = Provider<QuranComApiClient>((ref) {
  final client = HttpQuranComApiClient(
    baseUri: Uri.parse('https://api.islamic.app/v1/audio'),
  );
  ref.onDispose(client.dispose);
  return client;
});

final islamicAppRemoteDataSourceProvider = Provider<IslamicAppRemoteDataSource>(
  (ref) {
    return IslamicAppRemoteDataSource(
      apiClient: ref.watch(islamicAppApiClientProvider),
    );
  },
);

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

final tafsirMuyassarAssetDataSourceProvider =
    Provider<TafsirMuyassarAssetDataSource>((ref) {
      return TafsirMuyassarAssetDataSource();
    });

final translationLocalDataSourceProvider = Provider<TranslationLocalDataSource>(
  (ref) {
    return TranslationLocalDataSource(database: ref.watch(appDatabaseProvider));
  },
);
final quranResourceCatalogStorageProvider =
    Provider<QuranResourceCatalogStorage>((ref) {
      return QuranResourceCatalogStorage();
    });

final downloadedTafsirsProvider = FutureProvider<List<Tafsir>>((ref) async {
  try {
    final downloadedTafsirs = await ref
        .watch(tafsirLocalDataSourceProvider)
        .getDownloadedTafsirs();
    return _prependBuiltInDefaultTafsir(downloadedTafsirs);
  } catch (_) {
    return const <Tafsir>[defaultBuiltInTafsir];
  }
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

final defaultTafsirSeedServiceProvider = Provider<DefaultTafsirSeedService>((
  ref,
) {
  return DefaultTafsirSeedService(
    localDataSource: ref.watch(tafsirLocalDataSourceProvider),
    assetDataSource: ref.watch(tafsirMuyassarAssetDataSourceProvider),
    onSeedCompleted: () => ref.invalidate(downloadedTafsirsProvider),
  );
});

final islamicAppRecitationStoreProvider = Provider<IslamicAppRecitationStore>((
  ref,
) {
  return IslamicAppRecitationStore();
});

final quranAudioRepositoryProvider = Provider<QuranAudioRepository>((ref) {
  return QuranAudioRepositoryImpl(
    remoteDataSource: ref.watch(quranComRemoteDataSourceProvider),
    islamicAppRecitationsFuture: () =>
        ref.read(islamicAppRecitationsProvider.future),
  );
});

final islamicAppRecitationsProvider = FutureProvider<List<QuranRecitation>>((
  ref,
) async {
  final store = ref.watch(islamicAppRecitationStoreProvider);
  final result = await ref
      .watch(islamicAppRemoteDataSourceProvider)
      .fetchReciters();

  return result.when<Future<List<QuranRecitation>>>(
    success: (recitations) async {
      if (recitations.isNotEmpty) {
        unawaited(store.save(recitations));
      }
      return recitations;
    },
    error: (failure) {
      debugPrint('Failed to load islamic app recitations: ${failure.message}');
      return store.load();
    },
  );
});

final quranRecitationsProvider = FutureProvider<List<QuranRecitation>>((
  ref,
) async {
  final result = await ref
      .watch(quranReciterRepositoryProvider)
      .getRecitations(language: 'ar', fetchPolicy: DataFetchPolicy.cacheFirst);

  final quranComRecitations = result.when(
    success: (recitations) => recitations,
    error: (failure) => <QuranRecitation>[],
  );

  final islamicAppRecitations = await ref.watch(
    islamicAppRecitationsProvider.future,
  );

  final Map<String, QuranRecitation> uniqueMap = {};

  for (final r in quranComRecitations) {
    final normKey = normalizeReciterName(r.reciterName);
    if (normKey.isNotEmpty) {
      final cat = assignReciterCategory(r, isIslamicApp: false);
      uniqueMap[normKey] = r.copyWith(category: cat);
    }
  }

  for (final r in islamicAppRecitations) {
    final normKey = normalizeReciterName(r.reciterName);
    if (normKey.isNotEmpty) {
      final cat = assignReciterCategory(r, isIslamicApp: true);
      if (uniqueMap.containsKey(normKey)) {
        final existing = uniqueMap[normKey]!;
        uniqueMap[normKey] = existing.copyWith(
          hasAyahAudio: existing.hasAyahAudio || r.hasAyahAudio,
          hasSurahAudio: existing.hasSurahAudio || r.hasSurahAudio,
        );
      } else {
        uniqueMap[normKey] = r.copyWith(category: cat);
      }
    }
  }

  return uniqueMap.values.toList();
});

final selectedQuranRecitationProvider = StateProvider<QuranRecitation?>(
  (ref) => null,
);

final quranBookmarkServiceProvider = Provider<QuranBookmarkService>((ref) {
  return QuranBookmarkService(database: ref.watch(appDatabaseProvider));
});

final quranBookmarksProvider = StreamProvider<List<QuranBookmarkEntry>>((ref) {
  return ref.watch(quranBookmarkServiceProvider).watchAll();
});

final tafsirSearchProvider = FutureProvider.autoDispose
    .family<List<TafsirSearchResult>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <TafsirSearchResult>[];
      }

      final localDataSource = ref.watch(tafsirLocalDataSourceProvider);
      return localDataSource.searchTafsirTexts(trimmedQuery);
    });

final translationSearchProvider = FutureProvider.autoDispose
    .family<List<TranslationSearchResult>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <TranslationSearchResult>[];
      }

      final localDataSource = ref.watch(translationLocalDataSourceProvider);
      return localDataSource.searchTexts(trimmedQuery);
    });

final recitationSearchProvider = FutureProvider.autoDispose
    .family<List<QuranRecitation>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <QuranRecitation>[];
      }

      final localDataSource = ref.watch(quranReciterLocalDataSourceProvider);
      final result = await localDataSource.searchRecitations(trimmedQuery);
      return result.when(
        success: (recitations) => recitations,
        error: (_) => const <QuranRecitation>[],
      );
    });

/// Search tafsir books by name/author
final tafsirNameSearchProvider = FutureProvider.autoDispose
    .family<List<Tafsir>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <Tafsir>[];
      }
      final normalized = _normalizeForSearch(trimmedQuery);
      final tafsirs = await ref.watch(tafsirsProvider.future);
      return tafsirs.where((t) {
        final searchable = [
          t.name,
          t.authorName,
          t.translatedAuthorName,
          t.resourceName,
          t.slug,
        ].whereType<String>().join(' ');
        return _normalizeForSearch(searchable).contains(normalized);
      }).toList();
    });

/// Search translation books by name/author
final translationNameSearchProvider = FutureProvider.autoDispose
    .family<List<Translation>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <Translation>[];
      }
      final normalized = _normalizeForSearch(trimmedQuery);
      final translations = await ref.watch(translationsProvider.future);
      return translations.where((t) {
        final searchable = [
          t.name,
          t.authorName,
          t.translatedAuthorName,
          t.resourceName,
          t.slug,
        ].whereType<String>().join(' ');
        return _normalizeForSearch(searchable).contains(normalized);
      }).toList();
    });

/// Search reciters by name
final reciterNameSearchProvider = FutureProvider.autoDispose
    .family<List<QuranRecitation>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <QuranRecitation>[];
      }
      final normalized = _normalizeForSearch(trimmedQuery);
      final recitations = await ref.watch(quranRecitationsProvider.future);
      return recitations.where((r) {
        final searchable = [
          r.reciterName,
          r.translatedName,
          r.style,
        ].whereType<String>().join(' ');
        return _normalizeForSearch(searchable).contains(normalized);
      }).toList();
    });

String _normalizeForSearch(String input) {
  return input
      .replaceAll('ٱ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ى', 'ي')
      .replaceAll('ـ', '')
      .replaceAll(
        RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      )
      .toLowerCase()
      .trim();
}

/// Provider for fetching the list of available tafsirs
final tafsirsProvider = FutureProvider<List<Tafsir>>((ref) async {
  final storage = ref.watch(quranResourceCatalogStorageProvider);
  final localArabicTafsirs = await storage.getTafsirs(language: 'ar');
  final localEnglishTafsirs = await storage.getTafsirs(language: 'en');

  if (localArabicTafsirs.isNotEmpty && localEnglishTafsirs.isNotEmpty) {
    return _mergeTafsirs(localArabicTafsirs, localEnglishTafsirs);
  }

  final remoteTafsirs = await _fetchTafsirsCatalog(
    ref: ref,
    storage: storage,
    fallbackArabicTafsirs: localArabicTafsirs,
    fallbackEnglishTafsirs: localEnglishTafsirs,
  );
  if (remoteTafsirs.isNotEmpty) {
    return remoteTafsirs;
  }

  final localMergedTafsirs = _mergeTafsirs(
    localArabicTafsirs,
    localEnglishTafsirs,
  );
  if (localMergedTafsirs.isNotEmpty) {
    return localMergedTafsirs;
  }

  final localDownloadedTafsirs = await ref.watch(
    downloadedTafsirsProvider.future,
  );
  return localDownloadedTafsirs;
});

/// Provider for fetching the list of available translations
final translationsProvider = FutureProvider<List<Translation>>((ref) async {
  final storage = ref.watch(quranResourceCatalogStorageProvider);
  final localArabicTranslations = await storage.getTranslations(language: 'ar');
  final localEnglishTranslations = await storage.getTranslations(
    language: 'en',
  );

  if (localArabicTranslations.isNotEmpty &&
      localEnglishTranslations.isNotEmpty) {
    return _mergeTranslations(
      localArabicTranslations,
      localEnglishTranslations,
    );
  }

  final remoteTranslations = await _fetchTranslationsCatalog(
    ref: ref,
    storage: storage,
    fallbackArabicTranslations: localArabicTranslations,
    fallbackEnglishTranslations: localEnglishTranslations,
  );
  if (remoteTranslations.isNotEmpty) {
    return remoteTranslations;
  }

  final localMergedTranslations = _mergeTranslations(
    localArabicTranslations,
    localEnglishTranslations,
  );
  if (localMergedTranslations.isNotEmpty) {
    return localMergedTranslations;
  }

  final localDownloadedTranslations = await ref.watch(
    downloadedTranslationsProvider.future,
  );
  return localDownloadedTranslations;
});

/// Provider for fetching tafsir text for a specific chapter
final tafsirChapterProvider =
    FutureProvider.family<TafsirText, ({int resourceId, int chapterNumber})>((
      ref,
      params,
    ) async {
      final cacheKey = ResourceChapterKey(
        resourceId: params.resourceId,
        chapterNumber: params.chapterNumber,
      );
      final tafsirChapterCache = ref.watch(tafsirChapterCacheProvider);
      final localDataSource = ref.watch(tafsirLocalDataSourceProvider);
      final displayResourceName = await _resolveTafsirDisplayName(
        ref,
        params.resourceId,
      );

      final memoryTexts = tafsirChapterCache.get(cacheKey);
      if (memoryTexts != null && memoryTexts.isNotEmpty) {
        return _combineTafsirChapterTexts(
          memoryTexts,
          chapterNumber: params.chapterNumber,
          resourceName: displayResourceName ?? memoryTexts.first.resourceName,
        );
      }

      final cachedTexts = await localDataSource.getTafsirTextForChapter(
        resourceId: params.resourceId,
        chapterId: params.chapterNumber,
      );
      if (cachedTexts.isNotEmpty) {
        tafsirChapterCache.put(cacheKey, cachedTexts);
        return _combineTafsirChapterTexts(
          cachedTexts,
          chapterNumber: params.chapterNumber,
          resourceName: displayResourceName ?? cachedTexts.first.resourceName,
        );
      }

      if (params.resourceId == defaultTafsirResourceId) {
        final builtInTexts = await _loadBuiltInTafsirChapterTexts(
          ref: ref,
          chapterNumber: params.chapterNumber,
        );
        if (builtInTexts.isNotEmpty) {
          tafsirChapterCache.put(cacheKey, builtInTexts);
          return _combineTafsirChapterTexts(
            builtInTexts,
            chapterNumber: params.chapterNumber,
            resourceName:
                displayResourceName ?? builtInTexts.first.resourceName,
          );
        }
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
          tafsirChapterCache.put(cacheKey, tafsirTexts);
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
      final cacheKey = ResourceChapterKey(
        resourceId: params.resourceId,
        chapterNumber: params.chapterNumber,
      );
      final tafsirChapterCache = ref.watch(tafsirChapterCacheProvider);
      final localDataSource = ref.watch(tafsirLocalDataSourceProvider);
      final displayResourceName = await _resolveTafsirDisplayName(
        ref,
        params.resourceId,
      );

      final memoryTexts = tafsirChapterCache.get(cacheKey);
      if (memoryTexts != null && memoryTexts.isNotEmpty) {
        return _withResourceName(
          _findTafsirAyahText(
            memoryTexts,
            chapterNumber: params.chapterNumber,
            ayahNumber: params.ayahNumber,
          ),
          displayResourceName ?? memoryTexts.first.resourceName,
        );
      }

      // Try to get from local cache first
      final cachedTafsir = await localDataSource.getTafsirText(
        resourceId: params.resourceId,
        chapterId: params.chapterNumber,
        ayahNumber: params.ayahNumber,
      );
      if (cachedTafsir != null) {
        return _withResourceName(
          cachedTafsir,
          displayResourceName ?? cachedTafsir.resourceName,
        );
      }

      if (params.resourceId == defaultTafsirResourceId) {
        final builtInTexts = await _loadBuiltInTafsirChapterTexts(
          ref: ref,
          chapterNumber: params.chapterNumber,
        );
        if (builtInTexts.isNotEmpty) {
          tafsirChapterCache.put(cacheKey, builtInTexts);
          return _withResourceName(
            _findTafsirAyahText(
              builtInTexts,
              chapterNumber: params.chapterNumber,
              ayahNumber: params.ayahNumber,
            ),
            displayResourceName ?? builtInTexts.first.resourceName,
          );
        }
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
          tafsirChapterCache.put(cacheKey, tafsirTexts);
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
      final cacheKey = ResourceChapterKey(
        resourceId: params.resourceId,
        chapterNumber: params.chapterNumber,
      );
      final translationChapterCache = ref.watch(
        translationChapterCacheProvider,
      );
      final localDataSource = ref.watch(translationLocalDataSourceProvider);
      final displayResourceName = await _resolveTranslationDisplayName(
        ref,
        params.resourceId,
      );

      final memoryTexts = translationChapterCache.get(cacheKey);
      if (memoryTexts != null && memoryTexts.isNotEmpty) {
        return _combineTranslationChapterTexts(
          memoryTexts,
          chapterNumber: params.chapterNumber,
          resourceName: displayResourceName ?? memoryTexts.first.resourceName,
        );
      }

      final cachedTexts = await localDataSource.getTranslationTextForChapter(
        resourceId: params.resourceId,
        chapterId: params.chapterNumber,
      );
      if (cachedTexts.isNotEmpty) {
        translationChapterCache.put(cacheKey, cachedTexts);
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
          translationChapterCache.put(cacheKey, translationTexts);
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
      final cacheKey = ResourceChapterKey(
        resourceId: params.resourceId,
        chapterNumber: params.chapterNumber,
      );
      final translationChapterCache = ref.watch(
        translationChapterCacheProvider,
      );
      final localDataSource = ref.watch(translationLocalDataSourceProvider);
      final displayResourceName = await _resolveTranslationDisplayName(
        ref,
        params.resourceId,
      );

      final memoryTexts = translationChapterCache.get(cacheKey);
      if (memoryTexts != null && memoryTexts.isNotEmpty) {
        return _withTranslationResourceName(
          _findTranslationAyahText(
            memoryTexts,
            chapterNumber: params.chapterNumber,
            ayahNumber: params.ayahNumber,
          ),
          displayResourceName ?? memoryTexts.first.resourceName,
        );
      }

      final cachedTranslation = await localDataSource.getTranslationText(
        resourceId: params.resourceId,
        chapterId: params.chapterNumber,
        ayahNumber: params.ayahNumber,
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
          translationChapterCache.put(cacheKey, translationTexts);
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
final selectedTafsirProvider = StateProvider<int>(
  (ref) => defaultTafsirResourceId,
);

List<Tafsir> _prependBuiltInDefaultTafsir(List<Tafsir> tafsirs) {
  return <Tafsir>[
    defaultBuiltInTafsir,
    ...tafsirs.where((tafsir) => tafsir.id != defaultTafsirResourceId),
  ];
}

Future<List<TafsirText>> _loadBuiltInTafsirChapterTexts({
  required Ref ref,
  required int chapterNumber,
}) async {
  final localDataSource = ref.watch(tafsirLocalDataSourceProvider);
  final assetDataSource = ref.watch(tafsirMuyassarAssetDataSourceProvider);
  final chapterTexts = await assetDataSource.getChapterTexts(chapterNumber);
  if (chapterTexts.isEmpty) {
    return const <TafsirText>[];
  }

  await localDataSource.saveTafsirTexts(
    resourceId: defaultTafsirResourceId,
    chapterId: chapterNumber,
    tafsirTexts: chapterTexts,
  );
  await _syncBuiltInTafsirMetadata(ref, localDataSource);
  return chapterTexts;
}

Future<void> _syncBuiltInTafsirMetadata(
  Ref ref,
  TafsirLocalDataSource localDataSource,
) async {
  if (await localDataSource.isTafsirDownloaded(defaultTafsirResourceId)) {
    await localDataSource.saveDownloadedTafsir(defaultBuiltInTafsir);
    ref.invalidate(downloadedTafsirsProvider);
  }
}

Future<List<Tafsir>> _fetchTafsirsCatalog({
  required Ref ref,
  required QuranResourceCatalogStorage storage,
  required List<Tafsir> fallbackArabicTafsirs,
  required List<Tafsir> fallbackEnglishTafsirs,
}) async {
  final repository = ref.watch(quranRepositoryProvider);
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

  final fetchedArabicTafsirs = results[0].when(
    success: (tafsirs) => tafsirs,
    error: (_) => <Tafsir>[],
  );
  final fetchedEnglishTafsirs = results[1].when(
    success: (tafsirs) => tafsirs,
    error: (_) => <Tafsir>[],
  );

  if (fetchedArabicTafsirs.isNotEmpty) {
    await storage.saveTafsirs(fetchedArabicTafsirs, language: 'ar');
  }
  if (fetchedEnglishTafsirs.isNotEmpty) {
    await storage.saveTafsirs(fetchedEnglishTafsirs, language: 'en');
  }

  return _mergeTafsirs(
    fetchedArabicTafsirs.isNotEmpty
        ? fetchedArabicTafsirs
        : fallbackArabicTafsirs,
    fetchedEnglishTafsirs.isNotEmpty
        ? fetchedEnglishTafsirs
        : fallbackEnglishTafsirs,
  );
}

Future<List<Translation>> _fetchTranslationsCatalog({
  required Ref ref,
  required QuranResourceCatalogStorage storage,
  required List<Translation> fallbackArabicTranslations,
  required List<Translation> fallbackEnglishTranslations,
}) async {
  final repository = ref.watch(quranRepositoryProvider);
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

  final fetchedArabicTranslations = results[0].when(
    success: (translations) => translations,
    error: (_) => <Translation>[],
  );
  final fetchedEnglishTranslations = results[1].when(
    success: (translations) => translations,
    error: (_) => <Translation>[],
  );

  if (fetchedArabicTranslations.isNotEmpty) {
    await storage.saveTranslations(fetchedArabicTranslations, language: 'ar');
  }
  if (fetchedEnglishTranslations.isNotEmpty) {
    await storage.saveTranslations(fetchedEnglishTranslations, language: 'en');
  }

  return _mergeTranslations(
    fetchedArabicTranslations.isNotEmpty
        ? fetchedArabicTranslations
        : fallbackArabicTranslations,
    fetchedEnglishTranslations.isNotEmpty
        ? fetchedEnglishTranslations
        : fallbackEnglishTranslations,
  );
}

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
  if (resourceId == defaultTafsirResourceId) {
    return defaultBuiltInTafsir.name;
  }

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

  throw FormatException(
    'Unable to locate tafsir text for ayah $chapterNumber:$ayahNumber.',
    {'chapterNumber': chapterNumber, 'ayahNumber': ayahNumber},
  );
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

  throw FormatException(
    'Unable to locate translation text for ayah $chapterNumber:$ayahNumber.',
    {'chapterNumber': chapterNumber, 'ayahNumber': ayahNumber},
  );
}
