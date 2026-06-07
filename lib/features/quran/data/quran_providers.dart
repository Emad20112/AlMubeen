import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/quran/data/local/quran_reciter_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_api_client.dart';
import 'package:al_mubeen/features/quran/data/remote/quran_com_remote_data_source.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_audio_repository_impl.dart';
import 'package:al_mubeen/features/quran/data/repositories/quran_reciter_repository_impl.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final quranComApiClientProvider = Provider<QuranComApiClient>((ref) {
  final client = HttpQuranComApiClient();
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

final quranReciterLocalDataSourceProvider =
    Provider<QuranReciterLocalDataSource>((ref) {
      return QuranReciterLocalDataSource(
        database: ref.watch(appDatabaseProvider),
      );
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
      .getRecitations(
        language: 'ar',
        fetchPolicy: DataFetchPolicy.cacheFirst,
      );

  return result.when(
    success: (recitations) => recitations,
    error: (failure) => throw failure,
  );
});

final selectedQuranRecitationProvider = StateProvider<QuranRecitation?>(
  (ref) => null,
);
