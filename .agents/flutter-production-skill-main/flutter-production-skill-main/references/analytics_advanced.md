# Analytics Advanced — Remote Config, Feature Flags, A/B Testing & Funnel Tracking

## Firebase Remote Config (Feature Flags)

```yaml
dependencies:
  firebase_remote_config: ^5.1.4
```

### Remote Config Service
```dart
@lazySingleton
class RemoteConfigService {
  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  // Default values — always define these. App works without network.
  static const _defaults = {
    'show_yandex_ads': false,
    'interstitial_frequency': 3,       // show every N disconnects
    'reward_duration_minutes': 30,
    'max_free_sessions_per_day': 5,
    'enable_new_onboarding': false,
    'paywall_variant': 'A',            // A/B test variant
    'maintenance_mode': false,
    'min_app_version': '1.0.0',
    'server_refresh_interval_minutes': 60,
    'enable_speed_test': true,
  };

  Future<void> initialize() async {
    await _config.setDefaults(_defaults);

    await _config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration(
        hours: AppConfig.isProd ? 1 : 0, // no cache in dev
      ),
    ));

    await fetchAndActivate();

    // Listen for real-time updates (without re-fetch)
    _config.onConfigUpdated.listen((_) async {
      await _config.activate();
      log.i('Remote config updated in real-time');
    });
  }

  Future<void> fetchAndActivate() async {
    try {
      await _config.fetchAndActivate();
    } catch (e) {
      log.w('Remote config fetch failed, using cached/defaults: $e');
    }
  }

  // Typed getters
  bool get showYandexAds => _config.getBool('show_yandex_ads');
  int get interstitialFrequency => _config.getInt('interstitial_frequency');
  int get rewardDurationMinutes => _config.getInt('reward_duration_minutes');
  int get maxFreeSessionsPerDay => _config.getInt('max_free_sessions_per_day');
  bool get enableNewOnboarding => _config.getBool('enable_new_onboarding');
  String get paywallVariant => _config.getString('paywall_variant');
  bool get maintenanceMode => _config.getBool('maintenance_mode');
  bool get enableSpeedTest => _config.getBool('enable_speed_test');

  // Version gate — force update if below minimum
  bool get isVersionSupported {
    final min = _config.getString('min_app_version');
    return _isVersionAtLeast(AppConfig.version, min);
  }
}

// Riverpod provider
@riverpod
RemoteConfigService remoteConfig(RemoteConfigRef ref) =>
    getIt<RemoteConfigService>();
```

### Feature Flag Gates in UI
```dart
// Conditional feature rendering
class FeatureFlag extends ConsumerWidget {
  final String flag;
  final Widget child;
  final Widget? fallback;

  const FeatureFlag({
    required this.flag,
    required this.child,
    this.fallback,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(remoteConfigProvider);
    final enabled = config.getBool(flag);
    if (!enabled) return fallback ?? const SizedBox.shrink();
    return child;
  }
}

// Usage
FeatureFlag(
  flag: 'enable_speed_test',
  child: SpeedTestButton(onTap: () => Get.to(SpeedTestScreen())),
)
```

---

## A/B Testing

```dart
@lazySingleton
class AbTestingService {
  final RemoteConfigService _config;
  final AnalyticsService _analytics;

  AbTestingService(this._config, this._analytics);

  // Get variant and log exposure automatically
  String getVariant(String testName) {
    final variant = _config.getString(testName);
    // Log that user was exposed to this test
    _analytics.logEvent('ab_test_exposure', parameters: {
      'test_name': testName,
      'variant': variant,
    });
    return variant;
  }

  bool isVariant(String testName, String variantName) =>
      getVariant(testName) == variantName;
}

// Paywall A/B test
class PaywallScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = getIt<AbTestingService>().getVariant('paywall_variant');

    return switch (variant) {
      'B' => const PaywallVariantB(), // feature-focused
      'C' => const PaywallVariantC(), // social proof
      _ => const PaywallVariantA(),  // default pricing table
    };
  }
}
```

---

## Funnel Tracking (User Journey)

```dart
// Define user funnels as typed events
enum OnboardingStep {
  appOpen,
  splashComplete,
  permissionPrompt,
  permissionGranted,
  permissionDenied,
  firstServerSelected,
  firstConnectTap,
  firstConnected,
  paywallShown,
  purchaseStarted,
  purchaseComplete,
}

@lazySingleton
class FunnelTracker {
  final AnalyticsService _analytics;

  FunnelTracker(this._analytics);

  Future<void> trackOnboarding(OnboardingStep step, {
    Map<String, dynamic>? extra,
  }) async {
    await _analytics.logEvent(
      'onboarding_${step.name}',
      parameters: {
        'step_index': step.index,
        'step_name': step.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?extra,
      },
    );
  }

  // VPN-specific funnel
  Future<void> trackVpnFunnel({
    required String event,  // 'connect_tap' | 'connected' | 'disconnected'
    String? serverCountry,
    int? sessionDuration,
  }) async {
    await _analytics.logEvent('vpn_funnel_$event', parameters: {
      if (serverCountry != null) 'server_country': serverCountry,
      if (sessionDuration != null) 'session_duration_s': sessionDuration,
    });
  }

  // Monetization funnel
  Future<void> trackMonetization(String event, {
    String? planId,
    double? price,
    String? currency,
  }) async {
    await _analytics.logEvent('monetization_$event', parameters: {
      if (planId != null) 'plan_id': planId,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
    });
  }
}
```

---

## Subscription Server-Side Validation

```dart
@lazySingleton
class SubscriptionValidator {
  final DioClient _dio;
  final SecureStorageService _storage;
  Timer? _pollingTimer;

  SubscriptionValidator(this._dio, this._storage);

  /// Validate with your backend (not just client-side receipt)
  Future<SubscriptionStatus> validateWithServer() async {
    try {
      // Get latest receipt from RevenueCat
      final info = await Purchases.getCustomerInfo();
      final isActive = info.entitlements.active.isNotEmpty;

      // Optionally verify with your own backend for extra security
      if (isActive) {
        final token = info.originalPurchaseDate;
        final response = await _dio.post('/subscriptions/verify', data: {
          'purchase_token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        });
        return SubscriptionStatus.fromJson(response as Map<String, dynamic>);
      }

      return const SubscriptionStatus(isActive: false);
    } catch (e) {
      log.w('Subscription validation failed: $e');
      // Fail open — don't block user on network issues
      return const SubscriptionStatus(isActive: false, isUncertain: true);
    }
  }

  /// Start polling (call from main.dart for active sessions)
  void startPolling({Duration interval = const Duration(seconds: 60)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) async {
      final status = await validateWithServer();
      getIt<AdManager>().isSubscribedRx.value = status.isActive;
    });
  }

  void stopPolling() => _pollingTimer?.cancel();
}

class SubscriptionStatus {
  final bool isActive;
  final bool isUncertain; // true when couldn't verify
  final DateTime? expiresAt;
  final String? planId;

  const SubscriptionStatus({
    required this.isActive,
    this.isUncertain = false,
    this.expiresAt,
    this.planId,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      SubscriptionStatus(
        isActive: json['is_active'] as bool,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        planId: json['plan_id'] as String?,
      );
}
```

---

## Maintenance Mode Gate
```dart
// Check remote config on app start
class MaintenanceModeGate extends ConsumerWidget {
  final Widget child;
  const MaintenanceModeGate({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMaintenanceMode =
        ref.watch(remoteConfigProvider).maintenanceMode;

    if (isMaintenanceMode) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.build_rounded, size: 64),
              SizedBox(height: 16),
              Text('We\'re under maintenance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Back shortly. Thank you for your patience.'),
            ],
          ),
        ),
      );
    }
    return child;
  }
}
```
