import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

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
  Future<void>? _warmupTask;

  @override
  QcfFontBootstrapState build() {
    return const QcfFontBootstrapState.idle();
  }

  Future<void> start({bool force = false}) {
    if (!force && state.status == QcfFontBootstrapStatus.ready) {
      return Future<void>.value();
    }

    if (_warmupTask != null) {
      return Future<void>.value();
    }

    state = const QcfFontBootstrapState.ready();
    _warmupTask = _warmUpOpeningPages();
    return Future<void>.value();
  }

  Future<void> _warmUpOpeningPages() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));

      for (var page = 1; page <= 12; page++) {
        await QcfFontLoader.ensureFontLoaded(page);
        await Future<void>.delayed(const Duration(milliseconds: 12));
      }
    } catch (error) {
      debugPrint('QCF opening font warmup failed: $error');
    } finally {
      _warmupTask = null;
    }
  }
}
