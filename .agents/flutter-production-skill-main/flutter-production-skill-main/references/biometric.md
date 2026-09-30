# Biometric Authentication (Fingerprint, Face ID, Local Auth)

```yaml
dependencies:
  local_auth: ^2.3.0
```

## Android Setup
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>

<!-- In activity tag -->
<activity android:name=".MainActivity"
  android:theme="@style/LaunchTheme"
  android:launchMode="singleTop"
  android:windowSoftInputMode="adjustResize">
```

## iOS Setup
```xml
<!-- ios/Runner/Info.plist -->
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to authenticate quickly and securely.</string>
```

---

## Biometric Service

```dart
@lazySingleton
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometrics and has enrolled biometrics
  Future<BiometricAvailability> checkAvailability() async {
    try {
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!isDeviceSupported) return BiometricAvailability.notSupported;

      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return BiometricAvailability.notEnrolled;

      final available = await _auth.getAvailableBiometrics();
      if (available.isEmpty) return BiometricAvailability.notEnrolled;

      return BiometricAvailability.available;
    } on PlatformException catch (e) {
      log.w('Biometric availability check failed: ${e.message}');
      return BiometricAvailability.notSupported;
    }
  }

  /// Get the type of biometric available
  Future<BiometricType> getBiometricType() async {
    final available = await _auth.getAvailableBiometrics();
    if (available.contains(BiometricType.face)) return BiometricType.face;
    if (available.contains(BiometricType.fingerprint)) return BiometricType.fingerprint;
    if (available.contains(BiometricType.iris)) return BiometricType.iris;
    return BiometricType.weak;
  }

  /// Authenticate with biometrics
  Future<BiometricResult> authenticate({
    String localizedReason = 'Authenticate to continue',
    bool biometricOnly = false,
  }) async {
    try {
      final availability = await checkAvailability();
      if (availability != BiometricAvailability.available) {
        return BiometricResult.unavailable;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
            biometricHint: 'Touch sensor',
            biometricNotRecognized: 'Not recognized. Try again.',
            biometricSuccess: 'Authenticated!',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Biometrics not set up. Go to Settings.',
          ),
        ],
        options: AuthenticationOptions(
          stickyAuth: true,            // keeps prompt alive if app goes background
          biometricOnly: biometricOnly, // false = also allow PIN fallback
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );

      return authenticated ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      return switch (e.code) {
        'NotEnrolled' => BiometricResult.notEnrolled,
        'LockedOut' || 'PermanentlyLockedOut' => BiometricResult.lockedOut,
        'NotAvailable' => BiometricResult.unavailable,
        _ => BiometricResult.error,
      };
    }
  }

  Future<void> stopAuthentication() => _auth.stopAuthentication();
}

enum BiometricAvailability { available, notSupported, notEnrolled }

enum BiometricResult { success, failed, notEnrolled, lockedOut, unavailable, error }
```

---

## Biometric Lock Screen

```dart
class BiometricLockScreen extends ConsumerWidget {
  final Widget child;
  const BiometricLockScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(biometricUnlockedProvider);
    if (isUnlocked) return child;
    return _LockScreen();
  }
}

class _LockScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 80),
            const SizedBox(height: 24),
            const Text('App Locked', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            const Text('Authenticate to continue'),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => ref.read(biometricUnlockedProvider.notifier)
                  .authenticate(context),
              icon: const Icon(Icons.fingerprint),
              label: const Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}

@riverpod
class BiometricUnlocked extends _$BiometricUnlocked {
  @override
  bool build() {
    // Auto-trigger on first build
    Future.microtask(() => authenticate(null));
    return false;
  }

  Future<void> authenticate(BuildContext? context) async {
    final result = await getIt<BiometricService>().authenticate(
      localizedReason: 'Unlock the app',
    );

    if (result == BiometricResult.success) {
      state = true;
    } else if (result == BiometricResult.notEnrolled && context != null) {
      // Fall back to PIN / passcode
      getIt<FeedbackService>().showInfo(
          'Set up biometrics in device settings for faster access');
      state = true; // allow access with a warning
    }
  }

  void lock() => state = false;
}
```

---

## App Lock on Background

```dart
// In AppLifecycleObserver — auto-lock after N seconds in background
class AppLifecycleObserver extends WidgetsBindingObserver {
  final Ref ref;
  DateTime? _backgroundedAt;
  static const _lockAfter = Duration(minutes: 5);

  AppLifecycleObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _backgroundedAt = DateTime.now();
      case AppLifecycleState.resumed:
        if (_backgroundedAt != null) {
          final elapsed = DateTime.now().difference(_backgroundedAt!);
          if (elapsed > _lockAfter) {
            ref.read(biometricUnlockedProvider.notifier).lock();
          }
        }
      default:
        break;
    }
  }
}
```

---

## Biometric Preference Toggle

```dart
// Settings screen toggle
class BiometricToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBiometricEnabled = ref.watch(biometricEnabledProvider);

    return SwitchListTile(
      title: const Text('Biometric Login'),
      subtitle: const Text('Use fingerprint or Face ID to unlock'),
      secondary: const Icon(Icons.fingerprint),
      value: isBiometricEnabled,
      onChanged: (value) async {
        if (value) {
          // Verify before enabling
          final result = await getIt<BiometricService>().authenticate(
            localizedReason: 'Verify to enable biometric login',
          );
          if (result == BiometricResult.success) {
            ref.read(biometricEnabledProvider.notifier).enable();
          }
        } else {
          ref.read(biometricEnabledProvider.notifier).disable();
        }
      },
    );
  }
}
```
