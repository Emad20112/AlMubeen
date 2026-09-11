part of '../quran_providers.dart';

import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/features/quran/data/local/quran_bookmark_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quranBookmarkServiceProvider = Provider<QuranBookmarkService>((ref) {
  return QuranBookmarkService(database: ref.watch(appDatabaseProvider));
});

final quranBookmarksProvider = StreamProvider<List<QuranBookmarkEntry>>((ref) {
  return ref.watch(quranBookmarkServiceProvider).watchAll();
});
