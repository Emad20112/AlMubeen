import 'dart:async';

import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

final tafsirDownloadControllerProvider =
    NotifierProvider<TafsirDownloadController, TafsirDownloadState>(
      TafsirDownloadController.new,
    );

enum TafsirDownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

@immutable
final class TafsirDownloadState {
  const TafsirDownloadState({
    required this.status,
    required this.progress,
    required this.totalChapters,
    required this.completedChapters,
    this.currentChapter,
    this.resourceId,
    this.resourceName,
    this.message,
    this.errorMessage,
  });

  const TafsirDownloadState.idle()
    : status = TafsirDownloadStatus.idle,
      progress = 0,
      totalChapters = 114,
      completedChapters = 0,
      currentChapter = null,
      resourceId = null,
      resourceName = null,
      message = null,
      errorMessage = null;

  const TafsirDownloadState.downloading({
    required this.totalChapters,
    required this.completedChapters,
    required this.resourceId,
    required this.resourceName,
    this.currentChapter,
    this.progress = 0,
    this.message,
  }) : status = TafsirDownloadStatus.downloading,
       errorMessage = null;

  const TafsirDownloadState.completed({
    required this.totalChapters,
    required this.completedChapters,
    required this.resourceId,
    required this.resourceName,
    this.currentChapter,
    this.progress = 1,
    this.message,
  }) : status = TafsirDownloadStatus.completed,
       errorMessage = null;

  const TafsirDownloadState.failed({
    required this.totalChapters,
    required this.completedChapters,
    required this.resourceId,
    required this.resourceName,
    this.currentChapter,
    required this.errorMessage,
    this.progress = 0,
    this.message,
  }) : status = TafsirDownloadStatus.failed;

  final TafsirDownloadStatus status;
  final double progress;
  final int totalChapters;
  final int completedChapters;
  final int? currentChapter;
  final int? resourceId;
  final String? resourceName;
  final String? message;
  final String? errorMessage;

  bool get isDownloading => status == TafsirDownloadStatus.downloading;
  bool get isPaused => status == TafsirDownloadStatus.paused;

  TafsirDownloadState copyWith({
    TafsirDownloadStatus? status,
    double? progress,
    int? totalChapters,
    int? completedChapters,
    int? currentChapter,
    int? resourceId,
    String? resourceName,
    String? message,
    String? errorMessage,
    bool clearMessage = false,
    bool clearErrorMessage = false,
  }) {
    return TafsirDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalChapters: totalChapters ?? this.totalChapters,
      completedChapters: completedChapters ?? this.completedChapters,
      currentChapter: currentChapter ?? this.currentChapter,
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      message: clearMessage ? null : (message ?? this.message),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

final class TafsirDownloadController extends Notifier<TafsirDownloadState> {
  static const int _totalChapters = 114;

  bool _isCancelled = false;
  bool _isPaused = false;
  Completer<void>? _pauseCompleter;

  @override
  TafsirDownloadState build() {
    return const TafsirDownloadState.idle();
  }

  void pauseDownload() {
    if (!state.isDownloading) return;
    _isPaused = true;
    _pauseCompleter = Completer<void>();
    state = state.copyWith(
      status: TafsirDownloadStatus.paused,
      message: 'تم إيقاف التنزيل مؤقتًا',
    );
  }

  void resumeDownload() {
    if (!state.isPaused) return;
    _isPaused = false;
    _pauseCompleter?.complete();
    _pauseCompleter = null;
    state = state.copyWith(
      status: TafsirDownloadStatus.downloading,
      message: 'جاري استئناف التنزيل...',
    );
  }

  void cancelDownload() {
    if (!state.isDownloading && !state.isPaused) return;
    _isCancelled = true;
    if (_isPaused) {
      _isPaused = false;
      _pauseCompleter?.complete();
    }
    state = state.copyWith(
      status: TafsirDownloadStatus.cancelled,
      message: 'تم إلغاء التنزيل',
    );
  }

  Future<bool> ensureDefaultTafsirDownloaded({
    int defaultResourceId = 16,
  }) async {
    final localDataSource = ref.read(tafsirLocalDataSourceProvider);
    if (await localDataSource.isTafsirDownloaded(defaultResourceId)) {
      final downloadedTafsirs = await localDataSource.getDownloadedTafsirs();
      final hasMetadata = downloadedTafsirs.any(
        (tafsir) => tafsir.id == defaultResourceId,
      );
      if (!hasMetadata) {
        final tafsir = await _resolveTafsir(defaultResourceId);
        await localDataSource.saveDownloadedTafsir(tafsir);
        ref.invalidate(downloadedTafsirsProvider);
      }

      return true;
    }

    final tafsir = await _resolveTafsir(defaultResourceId);
    return downloadTafsirBook(tafsir: tafsir, selectOnComplete: true);
  }

  Future<bool> downloadTafsirBook({
    required Tafsir tafsir,
    bool selectOnComplete = true,
    bool force = false,
  }) async {
    if (state.isDownloading || state.isPaused) {
      return false;
    }

    _isCancelled = false;
    _isPaused = false;
    _pauseCompleter = null;

    final localDataSource = ref.read(tafsirLocalDataSourceProvider);
    final repository = ref.read(quranRepositoryProvider);
    final cachedChapters = force
        ? <int>{}
        : await localDataSource.getCachedTafsirChapterIds(tafsir.id);
    final missingChapters = <int>[
      for (var chapter = 1; chapter <= _totalChapters; chapter++)
        if (!cachedChapters.contains(chapter)) chapter,
    ];

    if (missingChapters.isEmpty) {
      await localDataSource.saveDownloadedTafsir(tafsir);
      ref.invalidate(downloadedTafsirsProvider);
      if (selectOnComplete) {
        ref.read(selectedTafsirProvider.notifier).state = tafsir.id;
      }

      state = TafsirDownloadState.completed(
        totalChapters: _totalChapters,
        completedChapters: _totalChapters,
        resourceId: tafsir.id,
        resourceName: tafsir.name,
        currentChapter: _totalChapters,
        message: 'التفسير محمّل محليًا بالفعل.',
      );
      return true;
    }

    state = TafsirDownloadState.downloading(
      totalChapters: _totalChapters,
      completedChapters: cachedChapters.length,
      resourceId: tafsir.id,
      resourceName: tafsir.name,
      currentChapter: missingChapters.first,
      progress: cachedChapters.length / _totalChapters,
      message: 'جاري تنزيل كتاب التفسير محليًا...',
    );

    var completedChapters = cachedChapters.length;
    var failures = 0;

    for (final chapterNumber in missingChapters) {
      if (_isCancelled) {
        state = state.copyWith(
          status: TafsirDownloadStatus.cancelled,
          message: 'تم إلغاء التنزيل بناءً على طلبك.',
        );
        return false;
      }
      if (_isPaused) {
        await _pauseCompleter?.future;
        if (_isCancelled) {
          state = state.copyWith(
            status: TafsirDownloadStatus.cancelled,
            message: 'تم إلغاء التنزيل بناءً على طلبك.',
          );
          return false;
        }
      }

      state = state.copyWith(
        currentChapter: chapterNumber,
        completedChapters: completedChapters,
        progress: completedChapters / _totalChapters,
        message: 'تنزيل تفسير سورة ${getSurahNameArabic(chapterNumber)}',
        clearErrorMessage: true,
      );

      final result = await repository.getTafsirChapterTexts(
        resourceId: tafsir.id,
        chapterNumber: chapterNumber,
        fetchPolicy: DataFetchPolicy.networkOnly,
      );

      final tafsirTexts = result.valueOrNull;
      if (tafsirTexts == null || tafsirTexts.isEmpty) {
        failures++;
        completedChapters++;
        state = state.copyWith(
          completedChapters: completedChapters,
          progress: completedChapters / _totalChapters,
          message: 'تعذر تنزيل تفسير سورة ${getSurahNameArabic(chapterNumber)}',
          errorMessage: 'لم يتم العثور على نص التفسير لهذه السورة.',
        );
        continue;
      }

      await localDataSource.saveTafsirTexts(
        resourceId: tafsir.id,
        chapterId: chapterNumber,
        tafsirTexts: tafsirTexts,
      );

      completedChapters++;
      state = state.copyWith(
        completedChapters: completedChapters,
        progress: completedChapters / _totalChapters,
        message: 'تم تنزيل تفسير سورة ${getSurahNameArabic(chapterNumber)}',
        clearErrorMessage: true,
      );
    }

    final isFullyCached = await localDataSource.isTafsirDownloaded(tafsir.id);
    if (failures == 0 && isFullyCached) {
      await localDataSource.saveDownloadedTafsir(tafsir);
      ref.invalidate(downloadedTafsirsProvider);
      if (selectOnComplete) {
        ref.read(selectedTafsirProvider.notifier).state = tafsir.id;
      }

      state = TafsirDownloadState.completed(
        totalChapters: _totalChapters,
        completedChapters: _totalChapters,
        resourceId: tafsir.id,
        resourceName: tafsir.name,
        currentChapter: _totalChapters,
        message: 'اكتمل تنزيل كتاب التفسير.',
      );
      return true;
    }

    state = TafsirDownloadState.failed(
      totalChapters: _totalChapters,
      completedChapters: completedChapters,
      resourceId: tafsir.id,
      resourceName: tafsir.name,
      currentChapter: state.currentChapter,
      progress: completedChapters / _totalChapters,
      message: 'اكتمل التنزيل مع بعض الأخطاء.',
      errorMessage: 'فشل تنزيل بعض السور. يمكن إعادة المحاولة لاحقًا.',
    );
    return false;
  }

  Future<Tafsir> _resolveTafsir(int resourceId) async {
    try {
      final tafsirs = await ref.read(tafsirsProvider.future);
      for (final tafsir in tafsirs) {
        if (tafsir.id == resourceId) {
          return tafsir;
        }
      }
    } catch (_) {
      // Fall through to a minimal fallback entry when the resource list fails.
    }

    return Tafsir(
      id: resourceId,
      name: 'Tafsir $resourceId',
      resourceName: 'Tafsir $resourceId',
    );
  }
}
