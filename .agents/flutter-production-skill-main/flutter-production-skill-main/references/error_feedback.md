# Error Handling & User Feedback — 2026

## Global Error Boundary (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter framework errors
  FlutterError.onError = (details) {
    AppLogger.fatal('Flutter error', details.exception, details.stack);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Async / platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.fatal('Platform error', error, stack);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}
```

---

## Either / Result Pattern (domain layer)

```dart
// core/errors/failures.dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data error']);
}
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

// Exhaustive user message — no default needed (sealed)
String failureMessage(Failure f) => switch (f) {
  NetworkFailure() => 'Check your internet connection',
  ServerFailure()  => 'Server error. Please try again',
  AuthFailure()    => 'Session expired. Please sign in',
  CacheFailure()   => 'Local data unavailable',
  TimeoutFailure() => 'Request timed out. Try again',
};
```

---

## Repository Error Handling Pattern

```dart
// Always wrap remote calls — never let raw exceptions bubble to UI
Future<Either<Failure, List<Server>>> getServers() async {
  try {
    final response = await _remote.getServers();
    return Right(response.map(ServerModel.toEntity).toList());
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionError) {
      return const Left(NetworkFailure());
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const Left(TimeoutFailure());
    }
    return Left(ServerFailure(e.message ?? 'Unknown server error'));
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } catch (e, st) {
    AppLogger.error('Unexpected error in getServers', e, st);
    return Left(ServerFailure(e.toString()));
  }
}
```

---

## Unified Feedback Service

```dart
// core/services/feedback_service.dart
class FeedbackService {
  final GlobalKey<NavigatorState> _navigatorKey;
  const FeedbackService(this._navigatorKey);

  BuildContext get _ctx => _navigatorKey.currentContext!;

  void showSuccess(String msg) => _snack(msg, icon: Icons.check_circle_outline,
      color: const Color(0xFF2ECC71));

  void showError(String msg) => _snack(msg, icon: Icons.error_outline,
      color: const Color(0xFFE74C3C));

  void showWarning(String msg) => _snack(msg, icon: Icons.warning_amber_rounded,
      color: const Color(0xFFF39C12));

  void showInfo(String msg) => _snack(msg, icon: Icons.info_outline,
      color: const Color(0xFF3498DB));

  void _snack(String msg, {required IconData icon, required Color color}) {
    ScaffoldMessenger.of(_ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
        ]),
      ));
  }

  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: _ctx,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Loading overlay — uses withValues (not withOpacity)
  OverlayEntry? _loadingOverlay;

  void showLoading({String? message}) {
    _loadingOverlay?.remove();
    _loadingOverlay = OverlayEntry(
      builder: (_) => Stack(children: [
        ModalBarrier(
          color: Colors.black.withValues(alpha: 0.45),
          dismissible: false,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(_ctx).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ],
            ),
          ),
        ),
      ]),
    );
    Overlay.of(_ctx).insert(_loadingOverlay!);
  }

  void hideLoading() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }
}
```

---

## Controller Error Handling (GetX)

```dart
class ServersController extends GetxController {
  final ServerRepository _repo;
  ServersController(this._repo);

  final servers = <Server>[].obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchServers();
  }

  Future<void> fetchServers() async {
    if (isClosed) return;
    isLoading.value = true;
    error.value = null;

    final result = await _repo.getServers();

    if (isClosed) return;             // guard after await
    isLoading.value = false;

    result.fold(
      (failure) => error.value = failureMessage(failure),
      (data) => servers.value = data,
    );
  }
}
```

---

## UI Error / Empty / Loading States

```dart
// Reusable three-state wrapper
class AsyncStateWidget<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final T? data;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final VoidCallback? onRetry;

  const AsyncStateWidget({
    required this.isLoading,
    required this.data,
    required this.builder,
    this.error,
    this.loadingWidget,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingWidget ?? const Center(child: CircularProgressIndicator());
    if (error != null) return ErrorStateWidget(message: error!, onRetry: onRetry);
    if (data == null) return const EmptyStateWidget(title: 'No data', icon: Icons.inbox);
    return builder(data as T);
  }
}

// Empty state
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    required this.title,
    required this.icon,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline),
                textAlign: TextAlign.center),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}

// Error state
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({required this.message, this.onRetry, super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ],
      ),
    ),
  );
}
```

---

## Either → Feedback Extension

```dart
extension EitherFeedback<L extends Failure, R> on Either<L, R> {
  void showFeedback({
    String? successMessage,
    String Function(L)? errorMessage,
  }) {
    fold(
      (f) => getIt<FeedbackService>().showError(
          errorMessage?.call(f) ?? failureMessage(f)),
      (_) {
        if (successMessage != null) {
          getIt<FeedbackService>().showSuccess(successMessage);
        }
      },
    );
  }
}
```
