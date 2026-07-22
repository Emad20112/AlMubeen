import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Wraps [Connectivity] to provide a clean interface for checking
/// and observing network availability throughout the app.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  /// Broadcasts `true` when the device has a viable network connection,
  /// `false` when it loses connectivity.
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = true;

  /// The last known connection state.
  bool get isConnected => _isConnected;

  /// Starts listening for connectivity changes. Call once at app startup.
  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected != _isConnected) {
        _isConnected = connected;
        _connectionController.add(connected);
        debugPrint('ConnectivityService: ${connected ? "online" : "offline"}');
      }
    });

    // Emit the initial state.
    _connectivity.checkConnectivity().then((results) {
      _isConnected = results.any((r) => r != ConnectivityResult.none);
      _connectionController.add(_isConnected);
    });
  }

  /// One-shot check: returns `true` if the device currently has a connection.
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    _isConnected = results.any((r) => r != ConnectivityResult.none);
    return _isConnected;
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}
