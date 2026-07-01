import 'dart:async';

import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/request_abort_handle.dart';
import 'package:al_mubeen/features/quran/data/local/translation_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

final translationDownloadControllerProvider =
    NotifierProvider<TranslationDownloadController, TranslationDownloadState>(
      TranslationDownloadController.new,
    );

enum TranslationDownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

@immutable
final class TranslationDownloadState {
  const TranslationDownloadState({
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

  const TranslationDownloadState.idle()
    : status = TranslationDownloadStatus.idle,
      progress = 0,
      totalChapters = 114,
      completedChapters = 0,
      currentChapter = null,
      resourceId = null,
      resourceName = null,
      message = null,
      errorMessage = null;

  const TranslationDownloadState.downloading({
    required this.totalChapters,
    required this.completedChapters,
    required this.resourceId,
    required this.resourceName,
    this.currentChapter,
    this.progress = 0,
    this.message,
  }) : status = TranslationDownloadStatus.downloading,
       errorMessage = null;

  const TranslationDownloadState.completed({
    required this.totalChapters,
    required this.completedChapters,
    required this.resourceId,
    required this.resourceName,
    this.currentChapter,
    this.progress = 1,
    this.message,
  }) : status = TranslationDownloadStatus.completed,
       errorMessage = null;

  const TranslationDownloadState.failed({
    required this.totalChapters,
    required this.completedChapters,
    required this.resourceId,
    required this.resourceName,
    this.currentChapter,
    required this.errorMessage,
    this.progress = 0,
    this.message,
  }) : status = TranslationDownloadStatus.failed;

  final TranslationDownloadStatus status;
  final double progress;
  final int totalChapters;
  final int completedChapters;
  final int? currentChapter;
  final int? resourceId;
  final String? resourceName;
  final String? message;
  final String? errorMessage;

  bool get isDownloading => status == TranslationDownloadStatus.downloading;
  bool get isPaused => status == TranslationDownloadStatus.paused;
  bool get isActiveDownload =>
      status == TranslationDownloadStatus.downloading ||
      status == TranslationDownloadStatus.paused;

  TranslationDownloadState copyWith({
    TranslationDownloadStatus? status,
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
    return TranslationDownloadState(
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

final class TranslationDownloadController
    extends Notifier<TranslationDownloadState> {
  static const int _totalChapters = 114;

  bool _isCancelled = false;
  bool _isPaused = false;
  bool _pauseInterruptRequested = false;
  Completer<void>? _pauseCompleter;
  RequestAbortHandle? _activeRequestAbortHandle;
  final Set<int> _sessionDownloadedChapters = <int>{};

  @override
  TranslationDownloadState build() {
    return const TranslationDownloadState.idle();
  }

  void pauseDownload() {
    if (!state.isDownloading) return;
    _isPaused = true;
    _pauseInterruptRequested = true;
    _activeRequestAbortHandle?.abort();
    _pauseCompleter = Completer<void>();
    state = state.copyWith(
      status: TranslationDownloadStatus.paused,
      message: 'تم إيقاف التنزيل مؤقتًا',
    );
  }

  void resumeDownload() {
    if (!state.isPaused) return;
    _isPaused = false;
    _pauseCompleter?.complete();
    _pauseCompleter = null;
    state = state.copyWith(
      status: TranslationDownloadStatus.downloading,
      message: 'جاري استئناف التنزيل...',
    );
  }

  void cancelDownload() {
    if (!state.isDownloading && !state.isPaused) return;
    _isCancelled = true;
    _pauseInterruptRequested = false;
    _activeRequestAbortHandle?.abort();
    if (_isPaused) {
      _isPaused = false;
      _pauseCompleter?.complete();
    }
    state = state.copyWith(
      status: TranslationDownloadStatus.cancelled,
      message: 'تم إلغاء التنزيل',
    );
  }

  Future<bool> downloadTranslationBook({
    required Translation translation,
    bool selectOnComplete = true,
    bool force = false,
  }) async {
    if (state.isDownloading || state.isPaused) {
      return false;
    }

    _isCancelled = false;
    _isPaused = false;
    _pauseCompleter = null;
    _pauseInterruptRequested = false;
    _activeRequestAbortHandle = null;
    _sessionDownloadedChapters.clear();

    final localDataSource = ref.read(translationLocalDataSourceProvider);
    final repository = ref.read(quranRepositoryProvider);
    final cachedChapters = force
        ? <int>{}
        : await localDataSource.getCachedTranslationChapterIds(translation.id);
    final missingChapters = <int>[
      for (var chapter = 1; chapter <= _totalChapters; chapter++)
        if (!cachedChapters.contains(chapter)) chapter,
    ];

    if (missingChapters.isEmpty) {
      await localDataSource.saveDownloadedTranslation(translation);
      ref.invalidate(downloadedTranslationsProvider);
      if (selectOnComplete) {
        ref.read(selectedTranslationProvider.notifier).state = translation.id;
      }

      state = TranslationDownloadState.completed(
        totalChapters: _totalChapters,
        completedChapters: _totalChapters,
        resourceId: translation.id,
        resourceName: translation.name,
        currentChapter: _totalChapters,
        message: 'الترجمة محمّلة محليًا بالفعل.',
      );
      return true;
    }

    state = TranslationDownloadState.downloading(
      totalChapters: _totalChapters,
      completedChapters: cachedChapters.length,
      resourceId: translation.id,
      resourceName: translation.name,
      currentChapter: missingChapters.first,
      progress: cachedChapters.length / _totalChapters,
      message: 'جاري تنزيل كتاب الترجمة محليًا...',
    );

    var completedChapters = cachedChapters.length;
    var failures = 0;
    var chapterIndex = 0;

    while (chapterIndex < missingChapters.length) {
      final chapterNumber = missingChapters[chapterIndex];

      if (_isCancelled) {
        await _discardDownloadedTranslationSession(
          localDataSource: localDataSource,
          resourceId: translation.id,
        );
        state = state.copyWith(
          status: TranslationDownloadStatus.cancelled,
          message: 'تم إلغاء التنزيل وتم حذف الملفات الجزئية.',
          clearErrorMessage: true,
        );
        return false;
      }
      if (_isPaused) {
        await _pauseCompleter?.future;
        if (_isCancelled) {
          await _discardDownloadedTranslationSession(
            localDataSource: localDataSource,
            resourceId: translation.id,
          );
          state = state.copyWith(
            status: TranslationDownloadStatus.cancelled,
            message: 'تم إلغاء التنزيل وتم حذف الملفات الجزئية.',
            clearErrorMessage: true,
          );
          return false;
        }
        continue;
      }

      state = state.copyWith(
        currentChapter: chapterNumber,
        completedChapters: completedChapters,
        progress: completedChapters / _totalChapters,
        message: 'تنزيل ترجمة سورة ${getSurahNameArabic(chapterNumber)}',
        clearErrorMessage: true,
      );

      final abortHandle = RequestAbortHandle();
      _activeRequestAbortHandle = abortHandle;
      final result = await repository.getTranslationChapterTexts(
        resourceId: translation.id,
        chapterNumber: chapterNumber,
        fetchPolicy: DataFetchPolicy.networkOnly,
        abortHandle: abortHandle,
      );
      if (_activeRequestAbortHandle == abortHandle) {
        _activeRequestAbortHandle = null;
      }

      final failure = result.failureOrNull;
      if (failure?.kind == DataFailureKind.cancelled) {
        if (_isCancelled) {
          await _discardDownloadedTranslationSession(
            localDataSource: localDataSource,
            resourceId: translation.id,
          );
          state = state.copyWith(
            status: TranslationDownloadStatus.cancelled,
            message: 'تم إلغاء التنزيل وتم حذف الملفات الجزئية.',
            clearErrorMessage: true,
          );
          return false;
        }

        if (_pauseInterruptRequested) {
          _pauseInterruptRequested = false;
          if (_isPaused) {
            await _pauseCompleter?.future;
            if (_isCancelled) {
              await _discardDownloadedTranslationSession(
                localDataSource: localDataSource,
                resourceId: translation.id,
              );
              state = state.copyWith(
                status: TranslationDownloadStatus.cancelled,
                message: 'تم إلغاء التنزيل وتم حذف الملفات الجزئية.',
                clearErrorMessage: true,
              );
              return false;
            }
          }

          continue;
        }

        state = state.copyWith(
          status: TranslationDownloadStatus.failed,
          message: 'تعذر متابعة تنزيل الترجمة.',
          errorMessage: 'تم إيقاف الطلب الجاري بشكل غير متوقع.',
        );
        return false;
      }

      final translationTexts = result.valueOrNull;
      if (translationTexts == null || translationTexts.isEmpty) {
        failures++;
        completedChapters++;
        state = state.copyWith(
          completedChapters: completedChapters,
          progress: completedChapters / _totalChapters,
          message: 'تعذر تنزيل ترجمة سورة ${getSurahNameArabic(chapterNumber)}',
          errorMessage: 'لم يتم العثور على نص الترجمة لهذه السورة.',
        );
        chapterIndex++;
        continue;
      }

      await localDataSource.saveTranslationTexts(
        resourceId: translation.id,
        chapterId: chapterNumber,
        translationTexts: translationTexts,
      );
      _sessionDownloadedChapters.add(chapterNumber);

      completedChapters++;
      state = state.copyWith(
        completedChapters: completedChapters,
        progress: completedChapters / _totalChapters,
        message: 'تم تنزيل ترجمة سورة ${getSurahNameArabic(chapterNumber)}',
        clearErrorMessage: true,
      );

      chapterIndex++;
    }

    final isFullyCached = await localDataSource.isTranslationDownloaded(
      translation.id,
    );
    if (failures == 0 && isFullyCached) {
      await localDataSource.saveDownloadedTranslation(translation);
      ref.invalidate(downloadedTranslationsProvider);
      _sessionDownloadedChapters.clear();
      _pauseInterruptRequested = false;
      if (selectOnComplete) {
        ref.read(selectedTranslationProvider.notifier).state = translation.id;
      }

      state = TranslationDownloadState.completed(
        totalChapters: _totalChapters,
        completedChapters: _totalChapters,
        resourceId: translation.id,
        resourceName: translation.name,
        currentChapter: _totalChapters,
        message: 'اكتمل تنزيل كتاب الترجمة.',
      );
      return true;
    }

    state = TranslationDownloadState.failed(
      totalChapters: _totalChapters,
      completedChapters: completedChapters,
      resourceId: translation.id,
      resourceName: translation.name,
      currentChapter: state.currentChapter,
      progress: completedChapters / _totalChapters,
      message: 'اكتمل التنزيل مع بعض الأخطاء.',
      errorMessage: 'فشل تنزيل بعض السور. يمكن إعادة المحاولة لاحقًا.',
    );
    return false;
  }

  Future<void> _discardDownloadedTranslationSession({
    required TranslationLocalDataSource localDataSource,
    required int resourceId,
  }) async {
    for (final chapterId in _sessionDownloadedChapters) {
      await localDataSource.deleteTranslationChapterCache(
        resourceId: resourceId,
        chapterId: chapterId,
      );
    }

    _sessionDownloadedChapters.clear();
    _pauseInterruptRequested = false;
    await localDataSource.deleteDownloadedTranslationMetadata(resourceId);
    ref.invalidate(downloadedTranslationsProvider);
  }
}
