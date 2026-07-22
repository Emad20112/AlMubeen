import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  QcfFontBootstrapState build() {
    return const QcfFontBootstrapState.idle();
  }

  Future<void> start({bool force = false}) {
    if (!force && state.status == QcfFontBootstrapStatus.ready) {
      return Future<void>.value();
    }

    state = const QcfFontBootstrapState.ready();
    return Future<void>.value();
  }
}
