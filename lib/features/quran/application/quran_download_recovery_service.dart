import 'package:al_mubeen/features/quran/application/quran_download_session_store.dart';
import 'package:al_mubeen/features/quran/application/tafsir_download_controller.dart';
import 'package:al_mubeen/features/quran/application/translation_download_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranDownloadRecoveryService {
  QuranDownloadRecoveryService(this._ref);

  final WidgetRef _ref;
  final QuranDownloadSessionStore _sessionStore = QuranDownloadSessionStore();

  static bool _hasRecovered = false;

  Future<bool> hasPendingDownloads() async {
    final tafsirSession = await _sessionStore.readTafsirSession();
    if (tafsirSession != null && tafsirSession.isDownloading) {
      return true;
    }

    final translationSession = await _sessionStore.readTranslationSession();
    return translationSession != null && translationSession.isDownloading;
  }

  Future<void> restorePendingDownloads({
    Duration resumeDelay = Duration.zero,
  }) async {
    if (_hasRecovered) {
      return;
    }
    _hasRecovered = true;

    final hasPendingDownload = await hasPendingDownloads();
    if (!hasPendingDownload) {
      return;
    }

    if (resumeDelay > Duration.zero) {
      await Future<void>.delayed(resumeDelay);
    }

    await _waitUntilAppIsResumed();

    final stopwatch = Stopwatch()..start();
    debugPrint('QuranDownloadRecoveryService: restoring pending downloads.');
    await _restoreTafsirDownload();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await _restoreTranslationDownload();
    debugPrint(
      'QuranDownloadRecoveryService: recovery finished in '
      '${stopwatch.elapsedMilliseconds}ms.',
    );
  }

  Future<void> _waitUntilAppIsResumed() async {
    for (var attempt = 0; attempt < 30; attempt++) {
      final lifecycleState = WidgetsBinding.instance.lifecycleState;
      if (lifecycleState == null ||
          lifecycleState == AppLifecycleState.resumed) {
        return;
      }

      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _restoreTafsirDownload() async {
    final session = await _sessionStore.readTafsirSession();
    if (session == null || !session.isDownloading) {
      return;
    }

    if (_ref.read(tafsirDownloadControllerProvider).isActiveDownload) {
      return;
    }

    final controller = _ref.read(tafsirDownloadControllerProvider.notifier);
    try {
      await controller.downloadTafsirBook(
        tafsir: session.toTafsir(),
        selectOnComplete: session.selectOnComplete,
      );
    } on Object catch (error, stackTrace) {
      debugPrint('QuranDownloadRecoveryService tafsir restore failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _restoreTranslationDownload() async {
    final session = await _sessionStore.readTranslationSession();
    if (session == null || !session.isDownloading) {
      return;
    }

    if (_ref.read(translationDownloadControllerProvider).isActiveDownload) {
      return;
    }

    final controller = _ref.read(
      translationDownloadControllerProvider.notifier,
    );
    try {
      await controller.downloadTranslationBook(
        translation: session.toTranslation(),
        selectOnComplete: session.selectOnComplete,
      );
    } on Object catch (error, stackTrace) {
      debugPrint(
        'QuranDownloadRecoveryService translation restore failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }
}
