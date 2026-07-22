import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Manages file downloads using background_downloader.
///
/// Responsibilities:
/// - Start, pause, resume, cancel downloads
/// - Track progress, speed, file size
/// - Verify file integrity after download
/// - Restore tasks after app restart
/// - NO relation to just_audio whatsoever
class DownloadManager {
  DownloadManager() {
    _downloader = FileDownloader();
    _setupCallbacks();
  }

  late final FileDownloader _downloader;

  final _progressController =
      StreamController<DownloadProgress>.broadcast();
  final _statusController =
      StreamController<DownloadStatusUpdate>.broadcast();

  Stream<DownloadProgress> get progressStream => _progressController.stream;
  Stream<DownloadStatusUpdate> get statusStream => _statusController.stream;

  final Map<String, DownloadTask> _activeTasks = {};
  final Map<String, DownloadProgress> _lastProgress = {};

  // ── Public API ──

  /// Download a single file from [url] to the given directory.
  /// Returns the task ID.
  Future<String> downloadFile({
    required Uri url,
    required String directoryPath,
    required String filename,
    bool requiresWiFi = false,
  }) async {
    final task = DownloadTask(
      url: url.toString(),
      filename: filename,
      directory: directoryPath,
      requiresWiFi: requiresWiFi,
      updates: Updates.statusAndProgress,
      allowPause: true,
    );

    _activeTasks[task.taskId] = task;

    final result = await _downloader.enqueue(task);
    if (!result) {
      _activeTasks.remove(task.taskId);
      throw DownloadException('Failed to enqueue download task');
    }

    return task.taskId;
  }

  /// Pause a running download.
  Future<bool> pauseDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) return false;
    return _downloader.pause(task);
  }

  /// Resume a paused download.
  Future<bool> resumeDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) return false;
    return _downloader.resume(task);
  }

  /// Cancel a download.
  Future<void> cancelDownload(String taskId) async {
    await _downloader.cancelTaskWithId(taskId);
    _activeTasks.remove(taskId);
    _lastProgress.remove(taskId);
  }

  /// Cancel all active downloads.
  Future<void> cancelAllDownloads() async {
    await _downloader.reset();
    _activeTasks.clear();
    _lastProgress.clear();
  }

  /// Check if a file was downloaded successfully and is not corrupted.
  Future<bool> verifyFile({
    required String filePath,
    int? expectedSizeBytes,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      if (expectedSizeBytes != null) {
        final size = await file.length();
        if (size != expectedSizeBytes) return false;
      }

      final size = await file.length();
      if (size == 0) return false;

      return true;
    } catch (e) {
      debugPrint('DownloadManager.verifyFile error: $e');
      return false;
    }
  }

  /// Delete a downloaded file.
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('DownloadManager.deleteFile error: $e');
    }
  }

  /// Get the last known progress for a task.
  DownloadProgress? getProgress(String taskId) => _lastProgress[taskId];

  /// Restore tasks that were interrupted by app restart.
  Future<List<Task>> restoreInterruptedTasks() async {
    final tasks = await _downloader.allTasks();
    for (final task in tasks) {
      if (task is DownloadTask) {
        _activeTasks[task.taskId] = task;
      }
    }
    return tasks;
  }

  /// Get all active tasks.
  Future<List<Task>> getAllTasks() async {
    return _downloader.allTasks();
  }

  /// Get the base download directory for the app.
  Future<Directory> getBaseDownloadDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/quran-audio');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  /// Build the save path for an ayah audio file.
  static String ayahFilePath({
    required String baseDir,
    required String reciterName,
    required int surahNumber,
    required int ayahNumber,
    required String extension,
  }) {
    final padSurah = surahNumber.toString().padLeft(3, '0');
    final padAyah = ayahNumber.toString().padLeft(3, '0');
    final sanitizedReciter = _sanitizeFileName(reciterName);
    return p.join(
      baseDir,
      sanitizedReciter,
      'surah_$padSurah',
      'ayah_$padAyah.$extension',
    );
  }

  /// Build the directory path for a surah.
  static String surahDirectoryPath({
    required String baseDir,
    required String reciterName,
    required int surahNumber,
  }) {
    final padSurah = surahNumber.toString().padLeft(3, '0');
    final sanitizedReciter = _sanitizeFileName(reciterName);
    return p.join(baseDir, sanitizedReciter, 'surah_$padSurah');
  }

  // ── Callbacks ──

  void _setupCallbacks() {
    _downloader.registerCallbacks(
      taskStatusCallback: _onTaskStatus,
      taskProgressCallback: _onTaskProgress,
    );
  }

  void _onTaskStatus(TaskStatusUpdate update) {
    _statusController.add(DownloadStatusUpdate(
      taskId: update.task.taskId,
      status: _mapStatus(update.status),
    ));

    if (update.status.isFinalState) {
      _activeTasks.remove(update.task.taskId);
    }
  }

  void _onTaskProgress(TaskProgressUpdate update) {
    final dlProgress = DownloadProgress(
      taskId: update.task.taskId,
      progress: update.progress.clamp(0.0, 1.0),
      downloadedBytes: update.expectedFileSize > 0
          ? (update.expectedFileSize * update.progress).toInt()
          : null,
      totalBytes: update.expectedFileSize > 0 ? update.expectedFileSize : null,
    );
    _lastProgress[update.task.taskId] = dlProgress;
    _progressController.add(dlProgress);
  }

  DownloadStatus _mapStatus(TaskStatus status) {
    return switch (status) {
      TaskStatus.enqueued => DownloadStatus.waiting,
      TaskStatus.running => DownloadStatus.downloading,
      TaskStatus.complete => DownloadStatus.completed,
      TaskStatus.failed => DownloadStatus.failed,
      TaskStatus.notFound => DownloadStatus.notFound,
      TaskStatus.waitingToRetry => DownloadStatus.awaitingWifi,
      TaskStatus.paused => DownloadStatus.paused,
      TaskStatus.canceled => DownloadStatus.failed,
    };
  }

  // ── Helpers ──

  static String _sanitizeFileName(String input) {
    return input
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^\w\-_.]'), '');
  }

  void dispose() {
    _downloader.unregisterCallbacks();
    _progressController.close();
    _statusController.close();
  }
}

// ── Models ──

class DownloadProgress {
  const DownloadProgress({
    required this.taskId,
    required this.progress,
    this.downloadedBytes,
    this.totalBytes,
  });

  final String taskId;
  final double progress;
  final int? downloadedBytes;
  final int? totalBytes;
}

class DownloadStatusUpdate {
  const DownloadStatusUpdate({
    required this.taskId,
    required this.status,
  });

  final String taskId;
  final DownloadStatus status;
}

enum DownloadStatus {
  waiting,
  downloading,
  paused,
  completed,
  failed,
  notFound,
  awaitingWifi,
}

class DownloadException implements Exception {
  const DownloadException(this.message);
  final String message;

  @override
  String toString() => 'DownloadException: $message';
}
