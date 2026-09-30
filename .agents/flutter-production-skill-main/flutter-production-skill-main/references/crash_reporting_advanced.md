# Non-Firebase Crash Reporting — Sentry & Datadog

## When to Use Non-Firebase Solutions

- Enterprise clients that prohibit Google services
- Apps distributed outside Play Store (Huawei AppGallery, Samsung Galaxy Store)
- Need for richer error context, performance monitoring, and session replay
- Multi-platform teams already using Sentry/Datadog for backend

---

## Sentry (Most Popular Alternative)

```yaml
dependencies:
  sentry_flutter: ^8.3.0
  sentry_dio: ^8.3.0        # Dio HTTP tracking
  sentry_logging: ^8.3.0    # logger integration
```

### Setup
```dart
// main.dart
Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = AppConfig.sentryDsn // from dart-define
        ..environment = AppConfig.flavor.name  // dev/staging/prod
        ..release = 'your.app@${AppConfig.version}'
        ..dist = AppConfig.buildNumber
        ..tracesSampleRate = AppConfig.isProd ? 0.2 : 1.0 // 20% in prod
        ..profilesSampleRate = 0.1
        ..attachScreenshot = true
        ..attachViewHierarchy = true
        ..debug = !AppConfig.isProd
        ..beforeSend = (event, hint) {
          // Filter out non-actionable errors
          if (event.throwable is SocketException) return null;
          return event;
        };
    },
    appRunner: () => runApp(
      DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: const MyApp(),
      ),
    ),
  );
}
```

### Dio Integration (HTTP breadcrumbs)
```dart
// Add to Dio interceptors
_dio.addSentry(
  captureFailedRequests: true,
  failedRequestStatusCodes: [
    SentryStatusCode.range(400, 499),
    SentryStatusCode.range(500, 599),
  ],
  maxRequestBodySize: MaxRequestBodySize.small,
  maxResponseBodySize: MaxResponseBodySize.small,
);
```

### Manual Error Capture
```dart
@lazySingleton
class CrashReportingService {
  // Capture handled exception with context
  Future<void> captureException(
    dynamic exception,
    StackTrace? stackTrace, {
    String? message,
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.error,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (message != null) scope.setTag('message', message);
        extras?.forEach((k, v) => scope.setExtra(k, v));
        scope.level = level;
      },
    );
  }

  // Capture message (non-exception)
  Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extras,
  }) async {
    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        extras?.forEach((k, v) => scope.setExtra(k, v));
      },
    );
  }

  // Set user context
  Future<void> setUser(User user) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: user.id,
        email: user.email,
        data: {'plan': user.plan},
      ));
    });
  }

  Future<void> clearUser() async {
    await Sentry.configureScope((scope) => scope.setUser(null));
  }

  // Add breadcrumb (navigation/action trail)
  void addBreadcrumb(String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category ?? 'app',
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  // Performance transaction
  ISentrySpan startTransaction(String name, String operation) =>
      Sentry.startTransaction(name, operation, bindToScope: true);
}

// Usage:
crashReporting.addBreadcrumb('User tapped Connect', category: 'ui.click');
crashReporting.addBreadcrumb('VPN connecting to US-1', category: 'vpn');

final transaction = crashReporting.startTransaction('vpn_connect', 'task');
try {
  await connectToVpn(server);
  transaction.status = SpanStatus.ok();
} catch (e, s) {
  transaction.status = SpanStatus.internalError();
  await crashReporting.captureException(e, s, message: 'VPN connect failed');
  rethrow;
} finally {
  await transaction.finish();
}
```

### Navigation Tracking (GoRouter)
```dart
// Custom observer for Sentry
class SentryNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    Sentry.addBreadcrumb(Breadcrumb.navigation(
      from: previousRoute?.settings.name ?? '/',
      to: route.settings.name ?? 'unknown',
    ));
  }
}

// In GoRouter
GoRouter(
  observers: [SentryNavigatorObserver()],
)
```

---

## Datadog (Enterprise — RUM + Traces + Logs unified)

```yaml
dependencies:
  datadog_flutter_plugin: ^2.3.0
  datadog_tracking_http_client: ^2.3.0
```

```dart
// main.dart
final config = DatadogConfiguration(
  clientToken: AppConfig.datadogClientToken,
  env: AppConfig.flavor.name,
  site: DatadogSite.us1,
  nativeCrashReportEnabled: true,
  loggingConfiguration: DatadogLoggingConfiguration(
    sendNetworkInfo: true,
  ),
  rumConfiguration: DatadogRumConfiguration(
    applicationId: AppConfig.datadogAppId,
    sessionSamplingRate: AppConfig.isProd ? 20 : 100,
    tracingSamplingRate: 20,
    detectLongTasks: true,
    longTaskThreshold: 0.1,
  ),
);

await DatadogSdk.instance.initialize(config, TrackingConsent.granted);
runApp(
  DatadogUserInteractionWidget(child: const MyApp()),
);

// HTTP tracking
final datadogClient = DatadogTrackingHttpClient(DatadogSdk.instance, dio);
```

---

## Unified Crash Reporting Interface

Abstract over provider so you can swap without changing call sites:

```dart
abstract class CrashReportingProvider {
  Future<void> init();
  Future<void> setUser(String id, String email, Map<String, dynamic> extras);
  Future<void> clearUser();
  Future<void> captureException(dynamic e, StackTrace? s, {String? message});
  void addBreadcrumb(String message, {String? category});
  void log(String message, {Map<String, dynamic>? extras});
}

// Implementations: FirebaseCrashlyticsProvider, SentryProvider, DatadogProvider
// Register the right one in DI based on AppConfig:
@module
abstract class CrashReportingModule {
  @lazySingleton
  CrashReportingProvider get provider => AppConfig.useFirebase
      ? FirebaseCrashlyticsProvider()
      : SentryProvider();
}
```

---

## Comparison

| Feature | Firebase Crashlytics | Sentry | Datadog |
|---------|---------------------|--------|---------|
| Free tier | Generous | 5k errors/month | 14-day trial |
| Setup complexity | Easy | Easy | Medium |
| Error grouping | Basic | Excellent | Good |
| Performance monitoring | No | Yes | Yes (RUM) |
| Session replay | No | Yes (paid) | Yes (paid) |
| Google dependency | Yes | No | No |
| Self-host option | No | Yes (open-source) | No |
| Best for | Firebase apps | Most apps | Enterprise |
