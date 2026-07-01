import 'package:flutter/foundation.dart';

/// Lightweight handle for aborting a single in-flight request.
///
/// The handle is intentionally simple: one request attaches one abort callback,
/// and the owner can trigger it when pause/cancel is requested.
final class RequestAbortHandle {
  VoidCallback? _abortCallback;
  bool _isAborted = false;

  bool get isAborted => _isAborted;

  void attach(VoidCallback abortCallback) {
    if (_isAborted) {
      abortCallback();
      return;
    }

    _abortCallback = abortCallback;
  }

  void clear() {
    _abortCallback = null;
  }

  void abort() {
    if (_isAborted) {
      return;
    }

    _isAborted = true;
    _abortCallback?.call();
    _abortCallback = null;
  }
}
