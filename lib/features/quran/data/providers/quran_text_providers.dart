part of '../quran_providers.dart';

import 'package:al_mubeen/features/quran/data/cache/quran_memory_cache_providers.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart' show tafsirLocalDataSourceProvider;
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
