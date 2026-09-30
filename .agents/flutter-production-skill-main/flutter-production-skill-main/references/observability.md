# Logging, Crash Reporting & Analytics

## Structured Logging

```yaml
dependencies:
  logger: ^2.3.0
```

```dart
// core/services/logger_service.dart
@lazySingleton
class AppLogger {
  late final Logger _logger;

  AppLogger() {
    _logger = Logger(
      printer: kDebugMode
          ? PrettyPrinter(
              methodCount: 2,
              errorMethodCount: 8,
              lineLength: 120,
              colors: true,
              printEmojis: true,
            )
          : SimplePrinter(printTime: true),
      level: kDebugMode ? Level.debug : Level.warning,
    );
  }

  void d(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  void i(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  void w(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    if (!kDebugMode && error != null) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: message,
        fatal: false,
      );
    }
  }

  void fatal(String message, dynamic error, StackTrace? stackTrace) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: message,
      fatal: true,
    );
  }
}

// Global instance for convenience
final log = getIt<AppLogger>();

// Usage
log.d('VPN connecting to ${server.country}');
log.i('User subscribed to premium plan');
log.w('Ad failed to load, retrying...');
log.e('API call failed', error, stackTrace);
```

---

## Crashlytics Setup

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught Flutter errors to Crashlytics
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Pass all uncaught async errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Disable in debug mode
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  runApp(const MyApp());
}
```

### Add Custom Keys to Crash Reports
```dart
// Set user context for crash reports
Future<void> setUserContext(User user) async {
  await FirebaseCrashlytics.instance.setUserIdentifier(user.id);
  await FirebaseCrashlytics.instance.setCustomKey('email', user.email);
  await FirebaseCrashlytics.instance.setCustomKey('plan', user.plan);
}

// Log breadcrumbs
FirebaseCrashlytics.instance.log('User tapped Connect button');
```

---

## Analytics

```dart
@lazySingleton
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (kDebugMode) {
      log.d('Analytics: $name | $parameters');
      return;
    }
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  // Typed event methods
  Future<void> logVpnConnected(String serverCountry) =>
      logEvent('vpn_connected', parameters: {'server_country': serverCountry});

  Future<void> logVpnDisconnected(int sessionSeconds) =>
      logEvent('vpn_disconnected', parameters: {'session_duration': sessionSeconds});

  Future<void> logAdWatched(String adType) =>
      logEvent('ad_watched', parameters: {'ad_type': adType});

  Future<void> logPurchase(String planId, double price) =>
      logEvent('purchase', parameters: {'plan_id': planId, 'price': price});

  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  Future<void> setUserProperty(String name, String value) =>
      _analytics.setUserProperty(name: name, value: value);

  Future<void> setUserId(String userId) =>
      _analytics.setUserId(id: userId);
}
```

### Screen Tracking (GoRouter)
```dart
GoRouter(
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  ...
)
```

### Screen Tracking (GetX)
```dart
GetMaterialApp(
  navigatorObservers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    GetObserver(), // GetX observer
  ],
)
```

---

## Dio Logging Interceptor

```dart
class AppLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log.d('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log.d('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log.e(
      '✗ ${err.requestOptions.path}',
      err,
      err.stackTrace,
    );
    handler.next(err);
  }
}
```
