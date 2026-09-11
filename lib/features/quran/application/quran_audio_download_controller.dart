import 'dart:async';
import 'dart:io';

import 'package:al_mubeen/core/audio/audio_providers.dart';
import 'package:al_mubeen/core/audio/download_manager.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:qcf_quran/qcf_quran.dart';

final quranAudioDownloadProvider =
    NotifierProvider<QuranAudioDownloadController, QuranAudioDownloadState>(
      QuranAudioDownloadController.new,
    );

enum QuranAudioDownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

@immutable
final class QuranAudioDownloadState {
  const QuranAudioDownloadState({
    this.status = QuranAudioDownloadStatus.idle,
    this.progress = 0.0,
    this.totalCount = 0,
    this.completedCount = 0,
    this.currentVerse = '',
    this.recitationId,
    this.reciterName,
    this.savePath,
    this.message,
    this.errorMessage,
    this.downloadingSurahNumber,
    this.surahDownloadProgress = const {},
    this.speedBytesPerSecond,
    this.remainingTime,
  });

  final QuranAudioDownloadStatus status;
  final double progress;
  final int totalCount;
  final int completedCount;
  final String currentVerse;
  final int? recitationId;
  final String? reciterName;
  final String? savePath;
  final String? message;
  final String? errorMessage;
  final int? downloadingSurahNumber;
  final Map<int, double> surahDownloadProgress;
  final int? speedBytesPerSecond;
  final Duration? remainingTime;

  bool get isDownloading => status == QuranAudioDownloadStatus.downloading;
  bool get isPaused => status == QuranAudioDownloadStatus.paused;
  bool get isActiveDownload =>
      status == QuranAudioDownloadStatus.downloading ||
      status == QuranAudioDownloadStatus.paused;

  bool isSurahFullyDownloaded(int surahNumber) {
    final p = surahDownloadProgress[surahNumber];
    return p != null && p >= 1.0;
  }

  QuranAudioDownloadState copyWith({
    QuranAudioDownloadStatus? status,
    double? progress,
    int? totalCount,
    int? completedCount,
    String? currentVerse,
    int? recitationId,
    String? reciterName,
    String? savePath,
    String? message,
    String? errorMessage,
    int? downloadingSurahNumber,
    Map<int, double>? surahDownloadProgress,
    int? speedBytesPerSecond,
    Duration? remainingTime,
    bool clearDownloadingSurah = false,
    bool clearSpeed = false,
  }) {
    return QuranAudioDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalCount: totalCount ?? this.totalCount,
      completedCount: completedCount ?? this.completedCount,
      currentVerse: currentVerse ?? this.currentVerse,
      recitationId: recitationId ?? this.recitationId,
      reciterName: reciterName ?? this.reciterName,
      savePath: savePath ?? this.savePath,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadingSurahNumber: clearDownloadingSurah
          ? null
          : (downloadingSurahNumber ?? this.downloadingSurahNumber),
      surahDownloadProgress:
          surahDownloadProgress ?? this.surahDownloadProgress,
      speedBytesPerSecond: clearSpeed
          ? null
          : (speedBytesPerSecond ?? this.speedBytesPerSecond),
      remainingTime: clearSpeed ? null : (remainingTime ?? this.remainingTime),
    );
  }
}

final class QuranAudioDownloadController
    extends Notifier<QuranAudioDownloadState> {
  static const Duration _stateUpdateInterval = Duration(milliseconds: 300);
  static const Duration _speedUpdateInterval = Duration(seconds: 1);

  final List<String> _activeTaskIds = [];
  int _completedDownloads = 0;
  int _totalDownloads = 0;
  Map<int, double> _surahProgressMap = {};
  DateTime? _lastProgressTime;
  DateTime? _lastStateUpdateTime;
  int _lastProgressBytes = 0;

  @override
  QuranAudioDownloadState build() {
    ref.onDispose(_cleanup);
    return const QuranAudioDownloadState();
  }

  void pauseDownload() {
    if (!state.isDownloading) return;
    final downloadManager = ref.read(downloadManagerProvider);
    for (final taskId in _activeTaskIds) {
      downloadManager.pauseDownload(taskId);
    }
    state = state.copyWith(
      status: QuranAudioDownloadStatus.paused,
      message: 'تم إيقاف التنزيل مؤقتًا',
    );
  }

  void resumeDownload() {
    if (!state.isPaused) return;
    final downloadManager = ref.read(downloadManagerProvider);
    for (final taskId in _activeTaskIds) {
      downloadManager.resumeDownload(taskId);
    }
    state = state.copyWith(
      status: QuranAudioDownloadStatus.downloading,
      message: 'جاري استئناف التنزيل...',
    );
  }

  void cancelDownload() {
    if (!state.isDownloading && !state.isPaused) return;
    final downloadManager = ref.read(downloadManagerProvider);
    downloadManager.cancelAllDownloads();
    _activeTaskIds.clear();
    state = state.copyWith(
      status: QuranAudioDownloadStatus.cancelled,
      message: 'تم إلغاء التنزيل',
    );
  }

  Future<void> downloadFullQuran({required QuranRecitation recitation}) async {
    if (state.isDownloading || state.isPaused) return;

    final downloadManager = ref.read(downloadManagerProvider);
    final audioRepo = ref.read(quranAudioRepositoryProvider);

    _completedDownloads = 0;
    _totalDownloads = _countTotalVerses();
    _surahProgressMap = {};
    _activeTaskIds.clear();
    _resetProgressTelemetry();

    state = state.copyWith(
      status: QuranAudioDownloadStatus.downloading,
      totalCount: _totalDownloads,
      completedCount: 0,
      progress: 0.0,
      currentVerse: 'جاري التحضير...',
      recitationId: recitation.id,
      reciterName: recitation.reciterName,
      message: 'جاري تنزيل صوت القرآن الكريم بالقارئ المحدد.',
      errorMessage: null,
      clearSpeed: true,
    );

    final baseDir = (await downloadManager.getBaseDownloadDirectory()).path;
    final existingAyahKeys = await _loadExistingAyahKeys(
      baseDir: baseDir,
      reciterId: recitation.id,
    );
    var errors = 0;

    try {
      // Listen for progress updates
      final progressSub = downloadManager.progressStream.listen((update) {
        _onProgressUpdate(update);
      });

      // Listen for status updates
      final statusSub = downloadManager.statusStream.listen((update) {
        _onStatusUpdate(update);
      });

      try {
        for (var surah = 1; surah <= totalSurahCount; surah++) {
          if (state.status != QuranAudioDownloadStatus.downloading) break;

          final verseCount = getVerseCount(surah);
          final surahName = getSurahNameArabic(surah);

          // Batch-fetch all ayah files for this surah in one request.
          final result = await audioRepo.getSurahAudioFiles(
            chapterNumber: surah,
            recitationId: recitation.id,
          );
          final audioFiles = result.valueOrNull;
          if (audioFiles == null || audioFiles.isEmpty) {
            errors++;
            continue;
          }

          final surahErrors = await _downloadAyahBatch(
            downloadManager: downloadManager,
            audioFiles: audioFiles,
            baseDir: baseDir,
            recitationId: recitation.id,
            existingAyahKeys: existingAyahKeys,
            surahNumber: surah,
            verseCount: verseCount,
            shouldContinue: () =>
                state.status == QuranAudioDownloadStatus.downloading,
            onProgress: (currentVerse, downloaded, total) =>
                _emitDownloadProgress(
                  completedCount: _completedDownloads + downloaded,
                  totalCount: _totalDownloads,
                  currentVerse: currentVerse,
                  message: 'تحميل $currentVerse',
                ),
          );
          errors += surahErrors;
          _completedDownloads += verseCount;

          if (state.status == QuranAudioDownloadStatus.downloading) {
            _surahProgressMap[surah] = 1.0;
            _emitDownloadProgress(
              completedCount: _completedDownloads,
              totalCount: _totalDownloads,
              currentVerse: 'اكتمل تحميل سورة $surahName.',
              message: 'اكتمل تحميل سورة $surahName.',
              force: true,
            );
          }
        }

        if (state.status == QuranAudioDownloadStatus.downloading) {
          state = state.copyWith(
            status: errors > 0
                ? QuranAudioDownloadStatus.failed
                : QuranAudioDownloadStatus.completed,
            progress: 1.0,
            completedCount: _totalDownloads,
            currentVerse: 'اكتمل التنزيل.',
            message: errors > 0
                ? 'اكتمل التنزيل مع بعض الأخطاء.'
                : 'اكتمل تنزيل جميع ملفات الصوت.',
            errorMessage: errors > 0
                ? 'فشل تنزيل بعض الآيات. راجع الاتصال وحاول مرة أخرى.'
                : null,
            surahDownloadProgress: Map.of(_surahProgressMap),
            clearSpeed: true,
          );
        }
      } finally {
        await progressSub.cancel();
        await statusSub.cancel();
      }
    } on Object catch (error, stackTrace) {
      if (state.status == QuranAudioDownloadStatus.cancelled) {
        return;
      }
      state = state.copyWith(
        status: QuranAudioDownloadStatus.failed,
        errorMessage: error.toString(),
        message: 'حدث خطأ أثناء تنزيل الصوت.',
        clearSpeed: true,
      );
      debugPrint('Quran audio download error: $error');
      debugPrint('$stackTrace');
    }
  }

  /// Scans the local filesystem and rebuilds [QuranAudioDownloadState.surahDownloadProgress]
  /// from the actual downloaded files for a given reciter.
  /// This is needed after app restart, because the in-memory map is lost.
  Future<void> refreshDownloadedSurahs({required int reciterId}) async {
    final downloadManager = ref.read(downloadManagerProvider);
    final baseDir = (await downloadManager.getBaseDownloadDirectory()).path;
    final reciterDirectory = Directory(
      path.join(baseDir, DownloadManager.reciterDirectoryName(reciterId)),
    );

    final Map<int, double> progressMap = {};

    if (await reciterDirectory.exists()) {
      await for (final surahEntity in reciterDirectory.list(
        followLinks: false,
      )) {
        if (surahEntity is! Directory) continue;

        final parsedSurah = _parseSurahDirectoryName(
          path.basename(surahEntity.path),
        );
        if (parsedSurah == null) continue;

        var ayahCount = 0;
        await for (final ayahEntity in surahEntity.list(followLinks: false)) {
          if (ayahEntity is! File) continue;
          final parsedAyah = _parseAyahFileName(path.basename(ayahEntity.path));
          if (parsedAyah != null) ayahCount++;
        }

        final verseCount = getVerseCount(parsedSurah);
        progressMap[parsedSurah] = verseCount <= 0
            ? 1.0
            : (ayahCount / verseCount).clamp(0.0, 1.0).toDouble();
      }
    }

    state = state.copyWith(
      surahDownloadProgress: progressMap,
      recitationId: reciterId,
    );
  }

  Future<void> downloadSurah({
    required int surahNumber,
    required QuranRecitation recitation,
  }) async {
    if (state.isDownloading || state.isPaused) return;
    if (surahNumber < 1 || surahNumber > totalSurahCount) return;

    final downloadManager = ref.read(downloadManagerProvider);
    final audioRepo = ref.read(quranAudioRepositoryProvider);

    _activeTaskIds.clear();
    _resetProgressTelemetry();
    _surahProgressMap = Map<int, double>.of(state.surahDownloadProgress);

    final verseCount = getVerseCount(surahNumber);
    final surahName = getSurahNameArabic(surahNumber);

    state = state.copyWith(
      status: QuranAudioDownloadStatus.downloading,
      totalCount: verseCount,
      completedCount: 0,
      progress: 0.0,
      currentVerse: 'جاري تحميل سورة $surahName...',
      recitationId: recitation.id,
      reciterName: recitation.reciterName,
      downloadingSurahNumber: surahNumber,
      message: 'جاري تنزيل سورة $surahName',
      errorMessage: null,
      clearSpeed: true,
    );

    final baseDir = (await downloadManager.getBaseDownloadDirectory()).path;
    final existingAyahKeys = await _loadExistingAyahKeys(
      baseDir: baseDir,
      reciterId: recitation.id,
      surahNumber: surahNumber,
    );
    var errors = 0;

    try {
      final progressSub = downloadManager.progressStream.listen((update) {
        _onProgressUpdate(update);
      });

      final statusSub = downloadManager.statusStream.listen((update) {
        _onStatusUpdate(update);
      });

      try {
        // Batch-fetch all ayah files for this surah in one request.
        final result = await audioRepo.getSurahAudioFiles(
          chapterNumber: surahNumber,
          recitationId: recitation.id,
        );
        final audioFiles = result.valueOrNull;
        if (audioFiles == null || audioFiles.isEmpty) {
          throw StateError('لم يتم العثور على ملفات صوتية لسورة $surahName.');
        }

        errors = await _downloadAyahBatch(
          downloadManager: downloadManager,
          audioFiles: audioFiles,
          baseDir: baseDir,
          recitationId: recitation.id,
          existingAyahKeys: existingAyahKeys,
          surahNumber: surahNumber,
          verseCount: verseCount,
          shouldContinue: () =>
              state.status == QuranAudioDownloadStatus.downloading,
          onProgress: (currentVerse, downloaded, total) =>
              _emitDownloadProgress(
                completedCount: downloaded,
                totalCount: total,
                currentVerse: currentVerse,
                message: 'تحميل $currentVerse',
                downloadingSurahNumber: surahNumber,
              ),
        );

        if (state.status == QuranAudioDownloadStatus.downloading) {
          state = state.copyWith(
            status: errors > 0
                ? QuranAudioDownloadStatus.failed
                : QuranAudioDownloadStatus.completed,
            progress: 1.0,
            completedCount: verseCount,
            currentVerse: 'اكتمل تحميل سورة $surahName.',
            message: errors > 0
                ? 'اكتمل التنزيل مع بعض الأخطاء.'
                : 'اكتمل تنزيل سورة $surahName.',
            errorMessage: errors > 0
                ? 'فشل تنزيل بعض الآيات. راجع الاتصال وحاول مرة أخرى.'
                : null,
            surahDownloadProgress: {
              ...state.surahDownloadProgress,
              surahNumber: 1.0,
            },
            clearDownloadingSurah: true,
            clearSpeed: true,
          );
        }
      } finally {
        await progressSub.cancel();
        await statusSub.cancel();
      }
    } on Object catch (error, stackTrace) {
      if (state.status == QuranAudioDownloadStatus.cancelled) {
        return;
      }
      state = state.copyWith(
        status: QuranAudioDownloadStatus.failed,
        errorMessage: error.toString(),
        message: 'حدث خطأ أثناء تنزيل الصوت.',
        clearDownloadingSurah: true,
        clearSpeed: true,
      );
      debugPrint('Quran audio download error: $error');
      debugPrint('$stackTrace');
    }
  }

  /// Downloads a list of ayah audio files sequentially — one task at a time.
  /// Files already present locally are skipped. Returns the number of files
  /// that failed to download. Sequential processing avoids the platform
  /// downloader and CDN stalling when many same-host downloads run at once.
  Future<int> _downloadAyahBatch({
    required DownloadManager downloadManager,
    required List<QuranAudioFile> audioFiles,
    required String baseDir,
    required int recitationId,
    required Set<String> existingAyahKeys,
    required int surahNumber,
    required int verseCount,
    required bool Function() shouldContinue,
    required void Function(String currentVerse, int downloaded, int total)
    onProgress,
  }) async {
    final total = audioFiles.length;
    var downloaded = 0;
    var errors = 0;

    void emit(int ayah) {
      _surahProgressMap[surahNumber] = verseCount <= 0
          ? 0
          : downloaded / verseCount;
      final currentVerse =
          'سورة ${getSurahNameArabic(surahNumber)} - آية $ayah';
      onProgress(currentVerse, downloaded, total);
    }

    for (final audioFile in audioFiles) {
      if (!shouldContinue()) break;

      final surah = audioFile.verseKey.surah;
      final ayah = audioFile.verseKey.ayah;
      final ayahKey = _ayahKey(surah, ayah);

      if (existingAyahKeys.contains(ayahKey)) {
        downloaded++;
        emit(ayah);
        continue;
      }

      final extension = path.extension(audioFile.url.path).isNotEmpty
          ? path.extension(audioFile.url.path)
          : '.mp3';
      final filePath = DownloadManager.ayahFilePath(
        baseDir: baseDir,
        reciterId: recitationId,
        surahNumber: surah,
        ayahNumber: ayah,
        extension: extension.substring(1),
      );

      emit(ayah);

      // Ensure the target directory exists; the platform downloader may fail
      // if it doesn't.
      final directoryPath = path.dirname(filePath);
      await Directory(directoryPath).create(recursive: true);

      final taskId = await downloadManager.downloadFile(
        url: audioFile.url,
        directoryPath: directoryPath,
        filename: path.basename(filePath),
      );
      _activeTaskIds.add(taskId);

      var completed = false;
      try {
        completed = await _waitForTask(taskId, downloadManager);
      } on Object {
        // A failed download shouldn't abort the rest of the surah.
        _activeTaskIds.remove(taskId);
        errors++;
        downloaded++;
        continue;
      }

      if (completed) {
        _activeTaskIds.remove(taskId);
        existingAyahKeys.add(ayahKey);
      } else {
        errors++;
      }

      downloaded++;
    }

    return errors;
  }

  /// Wait for a specific download task to reach a final state.
  /// Pause-like states do not complete this future; the same task is expected
  /// to continue after resume, and only a terminal state ends the wait.
  Future<bool> _waitForTask(
    String taskId,
    DownloadManager downloadManager,
  ) async {
    // If the task already reached a terminal state before this method
    // subscribed, resolve immediately from the tracked status.
    final current = downloadManager.getLastStatus(taskId);
    if (current != null) {
      switch (current) {
        case DownloadStatus.completed:
          return true;
        case DownloadStatus.failed:
        case DownloadStatus.notFound:
          throw Exception('Download failed for task $taskId');
        case DownloadStatus.cancelled:
          return false;
        case DownloadStatus.waiting:
        case DownloadStatus.downloading:
        case DownloadStatus.paused:
        case DownloadStatus.awaitingWifi:
          break;
      }
    }

    final completer = Completer<bool>();

    late final StreamSubscription sub;
    sub = downloadManager.statusStream.listen((update) {
      if (update.taskId != taskId) return;

      switch (update.status) {
        case DownloadStatus.completed:
          if (!completer.isCompleted) completer.complete(true);
        case DownloadStatus.failed:
        case DownloadStatus.notFound:
          if (!completer.isCompleted) {
            completer.completeError(
              Exception('Download failed for task $taskId'),
            );
          }
        case DownloadStatus.cancelled:
          if (!completer.isCompleted) completer.complete(false);
        case DownloadStatus.paused:
        case DownloadStatus.awaitingWifi:
        case DownloadStatus.waiting:
        case DownloadStatus.downloading:
          break;
      }
    });

    try {
      return await completer.future;
    } finally {
      await sub.cancel();
    }
  }

  void _onProgressUpdate(DownloadProgress progress) {
    if (!state.isDownloading) return;

    // Calculate speed
    final now = DateTime.now();
    final downloadedBytes = progress.downloadedBytes;
    if (downloadedBytes == null) {
      return;
    }

    final lastProgressTime = _lastProgressTime;
    if (lastProgressTime == null) {
      _lastProgressTime = now;
      _lastProgressBytes = downloadedBytes;
      return;
    }

    final elapsed = now.difference(lastProgressTime);
    if (elapsed < _speedUpdateInterval) {
      return;
    }

    final bytesDiff = downloadedBytes - _lastProgressBytes;
    final elapsedMs = elapsed.inMilliseconds;
    final speed = elapsedMs <= 0 ? 0 : (bytesDiff * 1000) ~/ elapsedMs;
    final remaining = progress.totalBytes != null && speed > 0
        ? Duration(seconds: (progress.totalBytes! - downloadedBytes) ~/ speed)
        : null;

    if (speed >= 0) {
      state = state.copyWith(
        speedBytesPerSecond: speed,
        remainingTime: remaining,
      );
    }

    _lastProgressTime = now;
    _lastProgressBytes = downloadedBytes;
  }

  void _onStatusUpdate(DownloadStatusUpdate update) {
    if (update.status == DownloadStatus.awaitingWifi) {
      state = state.copyWith(
        status: QuranAudioDownloadStatus.paused,
        message: 'في انتظار اتصال WiFi...',
      );
    } else if (update.status == DownloadStatus.paused) {
      state = state.copyWith(
        status: QuranAudioDownloadStatus.paused,
        message: 'تم إيقاف التنزيل مؤقتًا',
      );
    } else if (update.status == DownloadStatus.downloading && state.isPaused) {
      state = state.copyWith(
        status: QuranAudioDownloadStatus.downloading,
        message: 'جاري استئناف التنزيل...',
      );
    }
  }

  int _countTotalVerses() {
    var total = 0;
    for (var surah = 1; surah <= totalSurahCount; surah++) {
      total += getVerseCount(surah);
    }
    return total;
  }

  void _resetProgressTelemetry() {
    _lastProgressTime = null;
    _lastStateUpdateTime = null;
    _lastProgressBytes = 0;
  }

  void _emitDownloadProgress({
    required int completedCount,
    required int totalCount,
    required String currentVerse,
    required String message,
    int? downloadingSurahNumber,
    bool force = false,
  }) {
    if (!force && !state.isDownloading) return;

    final now = DateTime.now();
    final lastStateUpdateTime = _lastStateUpdateTime;
    if (!force &&
        lastStateUpdateTime != null &&
        now.difference(lastStateUpdateTime) < _stateUpdateInterval) {
      return;
    }

    _lastStateUpdateTime = now;
    state = state.copyWith(
      completedCount: completedCount,
      progress: totalCount <= 0 ? 0 : completedCount / totalCount,
      currentVerse: currentVerse,
      message: message,
      downloadingSurahNumber: downloadingSurahNumber,
      surahDownloadProgress: Map<int, double>.of(_surahProgressMap),
    );
  }

  Future<Set<String>> _loadExistingAyahKeys({
    required String baseDir,
    required int reciterId,
    int? surahNumber,
  }) async {
    final keys = <String>{};
    final reciterDirectory = Directory(
      path.join(baseDir, DownloadManager.reciterDirectoryName(reciterId)),
    );
    if (!await reciterDirectory.exists()) {
      return keys;
    }

    if (surahNumber != null) {
      await _collectSurahAyahKeys(
        keys: keys,
        surahDirectory: Directory(
          path.join(
            reciterDirectory.path,
            'surah_${surahNumber.toString().padLeft(3, '0')}',
          ),
        ),
        surahNumber: surahNumber,
      );
      return keys;
    }

    await for (final surahEntity in reciterDirectory.list(followLinks: false)) {
      if (surahEntity is! Directory) {
        continue;
      }

      final parsedSurah = _parseSurahDirectoryName(
        path.basename(surahEntity.path),
      );
      if (parsedSurah == null) {
        continue;
      }

      await _collectSurahAyahKeys(
        keys: keys,
        surahDirectory: surahEntity,
        surahNumber: parsedSurah,
      );
    }

    return keys;
  }

  Future<void> _collectSurahAyahKeys({
    required Set<String> keys,
    required Directory surahDirectory,
    required int surahNumber,
  }) async {
    if (!await surahDirectory.exists()) {
      return;
    }

    await for (final ayahEntity in surahDirectory.list(followLinks: false)) {
      if (ayahEntity is! File) {
        continue;
      }

      final ayahNumber = _parseAyahFileName(path.basename(ayahEntity.path));
      if (ayahNumber == null) {
        continue;
      }

      keys.add(_ayahKey(surahNumber, ayahNumber));
    }
  }

  int? _parseSurahDirectoryName(String name) {
    final match = RegExp(r'^surah_(\d{3})$').firstMatch(name);
    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1)!);
  }

  int? _parseAyahFileName(String name) {
    final match = RegExp(
      r'^ayah_(\d{3})\.(mp3|m4a)$',
      caseSensitive: false,
    ).firstMatch(name);
    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1)!);
  }

  String _ayahKey(int surahNumber, int ayahNumber) {
    return '$surahNumber:$ayahNumber';
  }

  void _cleanup() {
    _activeTaskIds.clear();
  }
}
