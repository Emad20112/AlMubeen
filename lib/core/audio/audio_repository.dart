import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:qcf_quran/qcf_quran.dart';

/// Decides the audio source: local file or network URL.
///
/// Responsibilities:
/// - Check if a downloaded file exists locally
/// - Return AudioSource.file() for local playback
/// - Return AudioSource.uri() for network playback
/// - NO caching, NO downloading, NO LockCachingAudioSource
class AudioRepository {
  AudioRepository({required this.downloadRepository});

  final AudioDownloadRepository downloadRepository;

  /// Determine the audio source for a surah (whole chapter file).
  /// Returns (sources, isLocal) tuple. Local playback returns one [AudioSource]
  /// per downloaded ayah; otherwise a single network source is returned.
  /// [networkUrl] is only required when no local files exist.
  Future<({List<AudioSource> sources, bool isLocal})> resolveSurahSource({
    required int reciterId,
    required int surahNumber,
    required Uri? networkUrl,
  }) async {
    final localPath = await downloadRepository.getSurahFilePath(
      reciterId: reciterId,
      surahNumber: surahNumber,
    );

    if (localPath != null) {
      final dir = Directory(localPath);
      if (await dir.exists()) {
        final localSources = await _buildLocalSurahSources(
          directoryPath: localPath,
          surahNumber: surahNumber,
        );
        if (localSources.isNotEmpty) {
          debugPrint('AudioRepository: using local surah directory $localPath');
          return (sources: localSources, isLocal: true);
        }
      }
    }

    final fallback = networkUrl;
    if (fallback == null) {
      throw StateError('No local surah files and no network URL available.');
    }
    debugPrint('AudioRepository: using network URL $fallback');
    return (sources: [AudioSource.uri(fallback)], isLocal: false);
  }

  Future<List<AudioSource>> _buildLocalSurahSources({
    required String directoryPath,
    required int surahNumber,
  }) async {
    final sources = <AudioSource>[];
    final verseCount = getVerseCount(surahNumber);

    for (var ayah = 1; ayah <= verseCount; ayah++) {
      final padAyah = ayah.toString().padLeft(3, '0');
      final mp3Path = p.join(directoryPath, 'ayah_$padAyah.mp3');
      final m4aPath = p.join(directoryPath, 'ayah_$padAyah.m4a');

      if (await File(mp3Path).exists()) {
        sources.add(AudioSource.file(mp3Path));
      } else if (await File(m4aPath).exists()) {
        sources.add(AudioSource.file(m4aPath));
      } else {
        return const [];
      }
    }

    return sources;
  }

  /// Determine the audio source for an individual ayah.
  /// Returns (AudioSource, isLocal) tuple.
  /// [networkUrl] is only required when no local file exists.
  Future<({AudioSource source, bool isLocal})> resolveAyahSource({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
    Uri? networkUrl,
  }) async {
    final localPath = await downloadRepository.getAyahFilePath(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        debugPrint('AudioRepository: using local ayah $localPath');
        return (source: AudioSource.file(localPath), isLocal: true);
      }
    }

    final fallback = networkUrl;
    if (fallback == null) {
      throw StateError('No local ayah file and no network URL available.');
    }
    return (source: AudioSource.uri(fallback), isLocal: false);
  }

  /// Check if a surah is fully downloaded locally.
  Future<bool> isSurahDownloaded({
    required int reciterId,
    required int surahNumber,
  }) async {
    return downloadRepository.isSurahComplete(
      reciterId: reciterId,
      surahNumber: surahNumber,
    );
  }

  /// Check if a specific ayah audio file is downloaded locally.
  Future<bool> isAyahDownloaded({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return downloadRepository.isAyahDownloaded(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }

  /// Delete a downloaded surah.
  Future<void> deleteSurah({
    required int reciterId,
    required int surahNumber,
  }) async {
    await downloadRepository.deleteSurah(
      reciterId: reciterId,
      surahNumber: surahNumber,
    );
  }
}

/// Interface for download repository — implemented separately.
abstract interface class AudioDownloadRepository {
  Future<String?> getSurahFilePath({
    required int reciterId,
    required int surahNumber,
  });

  Future<String?> getAyahFilePath({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  });

  Future<bool> isSurahComplete({
    required int reciterId,
    required int surahNumber,
  });

  Future<bool> isAyahDownloaded({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  });

  Future<void> deleteSurah({required int reciterId, required int surahNumber});
}
