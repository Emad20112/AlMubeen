part of '../quran_providers.dart';

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
