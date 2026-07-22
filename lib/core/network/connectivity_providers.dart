import 'package:al_mubeen/core/network/connectivity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Singleton [ConnectivityService] — shared across the entire app.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});

/// Convenience provider that exposes the current online/offline state
/// as a reactive boolean. Widgets can `ref.watch(isConnectedProvider)`
/// to rebuild when connectivity changes.
final isConnectedProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectionStream;
});
