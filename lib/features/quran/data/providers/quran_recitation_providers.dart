part of '../quran_providers.dart';

import 'package:al_mubeen/features/quran/data/helpers/reciter_normalizer.dart';
import 'package:al_mubeen/features/quran/data/providers/quran_data_providers.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      uniqueMap[normKey] = r.copyWith(  category: cat);
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
