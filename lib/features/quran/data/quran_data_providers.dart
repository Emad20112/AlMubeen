import 'dart:async';

import 'package:al_mubeen/core/config/app_config.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/quran/application/default_tafsir_seed_service.dart';
import 'package:al_mubeen/features/quran/data/helpers/reciter_normalizer.dart';
import 'package:al_mubeen/features/quran/data/local/islamic_app_recitation_store.dart';
import 'package:al_mubeen/features/quran/data/local/quran_bookmark_service.dart';
import 'package:al_mubeen/features/quran/data/local/quran_reciter_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/quran_resource_catalog_storage.dart';
import 'package:al_mubeen/features/quran/data/local/tafsir_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/tafsir_muyassar_asset_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/translation_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/quran_catalog_providers.dart';
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

/// ─────────────────────────────────────────────────────────────────────────────
/// معرّفات الأساس (Core Wiring) لطبقة بيانات القرآن:
/// العملاء (API clients)، مصادر البيانات، المستودعات (Repositories)،
/// كتالوج الموارد، القرّاء، والعلامات المرجعية (Bookmarks).
///
/// تم فصل هذا الملف من `quran_providers.dart` (الذي كان يتجاوز 1000 سطر)
/// لتسريع الـ incremental compilation وتسهيل الصيانة والاختبار.
/// استخدم `quran_providers.dart` كـ barrel للاستيراد الموحّد.
/// ─────────────────────────────────────────────────────────────────────────────

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
    return prependBuiltInDefaultTafsir(downloadedTafsirs);
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
