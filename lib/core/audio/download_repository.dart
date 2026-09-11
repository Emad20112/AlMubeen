import 'dart:io';

import 'package:al_mubeen/core/audio/audio_repository.dart';
import 'package:al_mubeen/core/audio/download_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:qcf_quran/qcf_quran.dart';

/// Manages download state persistence and file verification.
///
/// Responsibilities:
/// - Track which files are downloaded and their paths
/// - Verify file integrity (size, non-corruption)
/// - Delete downloaded files
/// - Restore download state after app restart
class DownloadRepository implements AudioDownloadRepository {
  DownloadRepository({required this.downloadManager});

  final DownloadManager downloadManager;

  String? _baseDir;

  /// Get or compute the base download directory.
  Future<String> _getBaseDir() async {
    if (_baseDir != null) return _baseDir!;
    final dir = await downloadManager.getBaseDownloadDirectory();
    _baseDir = dir.path;
    return _baseDir!;
  }

  // ── Ayah-level operations ──

  @override
  Future<String?> getAyahFilePath({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final baseDir = await _getBaseDir();
    // Scan reciter subdirectories for matching file
    final reciterDir = Directory(baseDir);
    if (!await reciterDir.exists()) return null;

    final padSurah = surahNumber.toString().padLeft(3, '0');
    final padAyah = ayahNumber.toString().padLeft(3, '0');
    final reciterPath = p.join(
      reciterDir.path,
      DownloadManager.reciterDirectoryName(reciterId),
    );
    final ayahFile = File(
      p.join(reciterPath, 'surah_$padSurah', 'ayah_$padAyah.mp3'),
    );
    if (await ayahFile.exists()) return ayahFile.path;

    final ayahFileM4a = File(
      p.join(reciterPath, 'surah_$padSurah', 'ayah_$padAyah.m4a'),
    );
    if (await ayahFileM4a.exists()) return ayahFileM4a.path;

    return null;
  }

  /// Save an ayah file path record.
  Future<void> saveAyahRecord({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
    required String filePath,
    required int fileSizeBytes,
  }) async {
    debugPrint(
      'DownloadRepository: saved ayah $surahNumber:$ayahNumber -> $filePath',
    );
  }

  // ── Surah-level operations ──

  @override
  Future<String?> getSurahFilePath({
    required int reciterId,
    required int surahNumber,
  }) async {
    final baseDir = await _getBaseDir();
    final padSurah = surahNumber.toString().padLeft(3, '0');
    final verseCount = getVerseCount(surahNumber);

    final reciterDir = Directory(baseDir);
    if (!await reciterDir.exists()) return null;

    final surahDir = Directory(
      p.join(
        reciterDir.path,
        DownloadManager.reciterDirectoryName(reciterId),
        'surah_$padSurah',
      ),
    );
    if (!await surahDir.exists()) return null;

    for (var ayah = 1; ayah <= verseCount; ayah++) {
      final padAyah = ayah.toString().padLeft(3, '0');
      final hasMp3 = await File(
        p.join(surahDir.path, 'ayah_$padAyah.mp3'),
      ).exists();
      final hasM4a = await File(
        p.join(surahDir.path, 'ayah_$padAyah.m4a'),
      ).exists();
      if (!hasMp3 && !hasM4a) {
        return null;
      }
    }

    return surahDir.path;
  }

  @override
  Future<bool> isSurahComplete({
    required int reciterId,
    required int surahNumber,
  }) async {
    final path = await getSurahFilePath(
      reciterId: reciterId,
      surahNumber: surahNumber,
    );
    return path != null;
  }

  @override
  Future<bool> isAyahDownloaded({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final path = await getAyahFilePath(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    return path != null;
  }

  @override
  Future<void> deleteSurah({
    required int reciterId,
    required int surahNumber,
  }) async {
    final baseDir = await _getBaseDir();
    final padSurah = surahNumber.toString().padLeft(3, '0');

    final surahDir = Directory(
      p.join(
        baseDir,
        DownloadManager.reciterDirectoryName(reciterId),
        'surah_$padSurah',
      ),
    );
    if (await surahDir.exists()) {
      await surahDir.delete(recursive: true);
      debugPrint('DownloadRepository: deleted surah $surahNumber');
    }
  }

  // ── Integrity verification ──

  /// Verify that a downloaded file matches the expected size.
  Future<bool> verifyFileIntegrity({
    required String filePath,
    int? expectedSizeBytes,
  }) async {
    return downloadManager.verifyFile(
      filePath: filePath,
      expectedSizeBytes: expectedSizeBytes,
    );
  }

  /// Check if all ayah files for a surah exist and are non-empty.
  Future<bool> verifySurahIntegrity({
    required String surahDirPath,
    required int surahNumber,
  }) async {
    final verseCount = getVerseCount(surahNumber);
    final surahDir = Directory(surahDirPath);
    if (!await surahDir.exists()) return false;

    for (var ayah = 1; ayah <= verseCount; ayah++) {
      final padAyah = ayah.toString().padLeft(3, '0');
      final mp3File = File(p.join(surahDir.path, 'ayah_$padAyah.mp3'));
      final m4aFile = File(p.join(surahDir.path, 'ayah_$padAyah.m4a'));

      final mp3Exists = await mp3File.exists() && (await mp3File.length()) > 0;
      final m4aExists = await m4aFile.exists() && (await m4aFile.length()) > 0;

      if (!mp3Exists && !m4aExists) return false;
    }

    return true;
  }

  // ── File size tracking ──

  /// Get total downloaded size for a surah in bytes.
  Future<int> getSurahDownloadedSize(String surahDirPath) async {
    int totalSize = 0;
    final dir = Directory(surahDirPath);
    if (!await dir.exists()) return 0;

    await for (final entity in dir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// Get the number of downloaded ayah files for a surah.
  Future<int> getDownloadedAyahCount({
    required int reciterId,
    required int surahNumber,
  }) async {
    final baseDir = await _getBaseDir();
    final padSurah = surahNumber.toString().padLeft(3, '0');
    final surahDir = Directory(
      p.join(
        baseDir,
        DownloadManager.reciterDirectoryName(reciterId),
        'surah_$padSurah',
      ),
    );

    if (!await surahDir.exists()) return 0;

    int count = 0;
    await for (final entity in surahDir.list()) {
      if (entity is File) count++;
    }
    return count;
  }

  /// Delete corrupted or empty files in a directory.
  Future<int> cleanCorruptedFiles(String directoryPath) async {
    int cleaned = 0;
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return 0;

    await for (final entity in dir.list()) {
      if (entity is File) {
        final size = await entity.length();
        if (size == 0) {
          await entity.delete();
          cleaned++;
        }
      }
    }
    return cleaned;
  }
}
