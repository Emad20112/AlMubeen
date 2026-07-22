import 'package:al_mubeen/core/audio/audio_repository.dart';
import 'package:al_mubeen/core/audio/download_manager.dart';
import 'package:al_mubeen/core/audio/download_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DownloadManager — the single source of truth for all download operations.
final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final manager = DownloadManager();
  ref.onDispose(manager.dispose);
  return manager;
});

/// DownloadRepository — manages file persistence and verification.
final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepository(
    downloadManager: ref.watch(downloadManagerProvider),
  );
});

/// AudioRepository — decides local vs network source.
final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return AudioRepository(
    downloadRepository: ref.watch(downloadRepositoryProvider),
  );
});
