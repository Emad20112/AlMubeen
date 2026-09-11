import 'package:al_mubeen/features/quran/data/cache/chapter_lru_cache.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tafsirChapterCacheProvider =
    Provider<ChapterLruCache<List<TafsirText>>>((ref) {
      final cache = ChapterLruCache<List<TafsirText>>(maxEntries: 24);
      ref.onDispose(cache.clear);
      return cache;
    });

final translationChapterCacheProvider =
    Provider<ChapterLruCache<List<TranslationText>>>((ref) {
      final cache = ChapterLruCache<List<TranslationText>>(maxEntries: 24);
      ref.onDispose(cache.clear);
      return cache;
    });
