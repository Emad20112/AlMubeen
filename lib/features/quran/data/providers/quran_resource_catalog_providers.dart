part of '../quran_providers.dart';

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
