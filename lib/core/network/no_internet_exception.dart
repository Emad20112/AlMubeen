/// Thrown when an operation is attempted while the device is offline.
///
/// This is a clean, intentional exception that controllers can catch
/// and map to a user-friendly error state instead of letting raw
/// [SocketException] or [TimeoutException] propagate to a crash screen.
class NoInternetException implements Exception {
  const NoInternetException([
    this.message = 'لا يوجد اتصال بالإنترنت.',
  ]);

  final String message;

  @override
  String toString() => 'NoInternetException: $message';
}
