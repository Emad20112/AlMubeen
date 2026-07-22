import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

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
  /// Returns (AudioSource, isLocal) tuple.
  Future<({AudioSource source, bool isLocal})> resolveSurahSource({
    required int reciterId,
    required int surahNumber,
    required Uri networkUrl,
  }) async {
    final localPath = await downloadRepository.getSurahFilePath(
      reciterId: reciterId,
      surahNumber: surahNumber,
    );

    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        debugPrint('AudioRepository: using local file $localPath');
        return (source: AudioSource.file(localPath), isLocal: true);
      }
    }

    debugPrint('AudioRepository: using network URL $networkUrl');
    return (source: AudioSource.uri(networkUrl), isLocal: false);
  }

  /// Determine the audio source for an individual ayah.
  /// Returns (AudioSource, isLocal) tuple.
  Future<({AudioSource source, bool isLocal})> resolveAyahSource({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
    required Uri networkUrl,
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

    return (source: AudioSource.uri(networkUrl), isLocal: false);
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

  Future<void> deleteSurah({
    required int reciterId,
    required int surahNumber,
  });
}
