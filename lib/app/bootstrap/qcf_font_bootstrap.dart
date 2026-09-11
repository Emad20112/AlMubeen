import 'dart:async';

import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran/qcf_quran.dart';

final qcfFontBootstrapProvider =
    NotifierProvider<QcfFontBootstrapController, QcfFontBootstrapState>(
      QcfFontBootstrapController.new,
    );

enum QcfFontBootstrapStatus { idle, loading, ready, failure }

@immutable
class QcfFontBootstrapState {
  const QcfFontBootstrapState({
    required this.status,
    required this.progress,
    this.errorMessage,
  });

  const QcfFontBootstrapState.idle()
    : status = QcfFontBootstrapStatus.idle,
      progress = 0,
      errorMessage = null;

  const QcfFontBootstrapState.loading({this.progress = 0})
    : status = QcfFontBootstrapStatus.loading,
      errorMessage = null;

  const QcfFontBootstrapState.ready()
    : status = QcfFontBootstrapStatus.ready,
      progress = 1,
      errorMessage = null;

  const QcfFontBootstrapState.failure({
    required this.errorMessage,
    this.progress = 0,
  }) : status = QcfFontBootstrapStatus.failure;

  final QcfFontBootstrapStatus status;
  final double progress;
  final String? errorMessage;
}

class QcfFontBootstrapController extends Notifier<QcfFontBootstrapState> {
  Future<void>? _runningFuture;

  @override
  QcfFontBootstrapState build() {
    return const QcfFontBootstrapState.idle();
  }

  Future<void> start({bool force = false}) {
    if (!force) {
      if (state.status == QcfFontBootstrapStatus.ready) {
        return Future<void>.value();
      }
      final running = _runningFuture;
      if (running != null) {
        return running;
      }
    }

    final completer = Completer<void>();
    _runningFuture = completer.future;

    () async {
      state = const QcfFontBootstrapState.loading(progress: 0.1);

      try {
        // Warm the QCF data access path and metadata caches.
        getPageData(1);
        QuranPageMetadataCache.instance.forPage(1);
        QuranPageMetadataCache.instance.forPage(2);

        state = const QcfFontBootstrapState.loading(progress: 0.6);

        // Warm frequently-used Quran helpers.
        getSurahNameArabic(1);
        getJuzNumber(1, 1);
        getHizbNumber(1, 1);
        QuranSurahMetadataCache.instance.all.length;

        state = const QcfFontBootstrapState.ready();
        completer.complete();
      } on Object catch (error, stackTrace) {
        debugPrint('QCF bootstrap failed: $error');
        debugPrint('$stackTrace');
        state = QcfFontBootstrapState.failure(errorMessage: error.toString());
        completer.complete();
      } finally {
        _runningFuture = null;
      }
    }();

    return completer.future;
  }
}
