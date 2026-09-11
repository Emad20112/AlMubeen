part of '../quran_providers.dart';

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
