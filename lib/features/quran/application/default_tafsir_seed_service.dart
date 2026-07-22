import 'dart:async';

import 'package:al_mubeen/features/quran/data/local/tafsir_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/tafsir_muyassar_asset_data_source.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/domain/tafsir_defaults.dart';
import 'package:flutter/foundation.dart';

class DefaultTafsirSeedService {
  DefaultTafsirSeedService({
    required TafsirLocalDataSource localDataSource,
    required TafsirMuyassarAssetDataSource assetDataSource,
    this.onSeedCompleted,
  }) : _localDataSource = localDataSource,
       _assetDataSource = assetDataSource;

  final TafsirLocalDataSource _localDataSource;
  final TafsirMuyassarAssetDataSource _assetDataSource;
  final VoidCallback? onSeedCompleted;

  Future<void>? _runningFuture;

  Future<void> ensureSeeded() {
    final runningFuture = _runningFuture;
    if (runningFuture != null) {
      return runningFuture;
    }

    final completer = Completer<void>();
    _runningFuture = completer.future;

    () async {
      try {
        final cachedChapterIds = await _localDataSource
            .getCachedTafsirChapterIds(defaultTafsirResourceId);
        if (cachedChapterIds.length < 114) {
          final allChapterTexts =
              await _assetDataSource.getAllChapterTextsMap();

          final chapterTextsToInsert = <int, List<TafsirText>>{};
          for (final entry in allChapterTexts.entries) {
            if (!cachedChapterIds.contains(entry.key)) {
              chapterTextsToInsert[entry.key] = entry.value;
            }
          }

          if (chapterTextsToInsert.isNotEmpty) {
            await _localDataSource.saveAllTafsirTexts(
              resourceId: defaultTafsirResourceId,
              chapterTexts: chapterTextsToInsert,
            );
          }
        }

        if (await _localDataSource.isTafsirDownloaded(
          defaultTafsirResourceId,
        )) {
          await _localDataSource.saveDownloadedTafsir(defaultBuiltInTafsir);
        }

        onSeedCompleted?.call();
        completer.complete();
      } catch (error, stackTrace) {
        debugPrint('DefaultTafsirSeedService.ensureSeeded failed: $error');
        debugPrint('$stackTrace');
        completer.complete();
      } finally {
        _runningFuture = null;
      }
    }();

    return completer.future;
  }
}
