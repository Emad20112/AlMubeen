# Force Update & In-App Update

```yaml
dependencies:
  in_app_update: ^4.2.3         # Android in-app updates (Play Store)
  upgrader: ^10.3.0              # Cross-platform update prompts
  package_info_plus: ^8.0.2     # Get current app version
```

---

## Android In-App Update (Play Store API)

Google Play provides two update flows natively:

### Flexible Update (recommended for non-critical)
Downloads in background, user prompted to install at their convenience.

```dart
@lazySingleton
class InAppUpdateService {
  Future<void> checkAndPromptUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {

        if (updateInfo.immediateUpdateAllowed) {
          // Critical update — force immediately
          await _startImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Non-critical — download in background
          await _startFlexibleUpdate(context);
        }
      }
    } on PlatformException catch (e) {
      log.w('In-app update check failed: ${e.message}');
      // Fail silently — don't disrupt user experience
    }
  }

  Future<void> _startImmediateUpdate() async {
    final result = await InAppUpdate.performImmediateUpdate();
    if (result == AppUpdateResult.success) {
      log.i('Immediate update completed');
    }
  }

  Future<void> _startFlexibleUpdate(BuildContext context) async {
    await InAppUpdate.startFlexibleUpdate();

    // Monitor download progress
    InAppUpdate.snackBarOnFlexibleUpdateDownloaded(context);
    // OR manually monitor:
    // Listen to updateStates stream and show custom UI
  }
}
```

### Immediate Update (force — use for critical security fixes)
```dart
// Blocks the app until update is installed
Future<void> forceImmediateUpdate() async {
  try {
    final result = await InAppUpdate.performImmediateUpdate();
    // result: AppUpdateResult.success / userDenied / failed
    if (result == AppUpdateResult.userDenied) {
      // User skipped critical update — exit app
      SystemNavigator.pop();
    }
  } catch (e) {
    log.e('Force update failed', e);
  }
}
```

---

## Cross-Platform Force Update (Remote Config)

Use Firebase Remote Config to control minimum version server-side.

```dart
@lazySingleton
class ForceUpdateService {
  final FirebaseRemoteConfig _remoteConfig;
  ForceUpdateService(this._remoteConfig);

  Future<UpdateStatus> checkForceUpdate() async {
    await _remoteConfig.fetchAndActivate();

    final minVersionStr = _remoteConfig.getString('min_app_version');
    // e.g. "2.1.0" in Remote Config

    final currentInfo = await PackageInfo.fromPlatform();
    final currentVersion = Version.parse(currentInfo.version);
    final minVersion = Version.parse(minVersionStr);

    if (currentVersion < minVersion) {
      return UpdateStatus.forceUpdate;
    }

    final latestVersionStr = _remoteConfig.getString('latest_app_version');
    final latestVersion = Version.parse(latestVersionStr);

    if (currentVersion < latestVersion) {
      return UpdateStatus.softUpdate;
    }

    return UpdateStatus.upToDate;
  }

  String get storeUrl => Platform.isIOS
      ? _remoteConfig.getString('app_store_url')
      : _remoteConfig.getString('play_store_url');
}

enum UpdateStatus { forceUpdate, softUpdate, upToDate }
```

### Firebase Remote Config values to set:
```json
{
  "min_app_version": "2.0.0",
  "latest_app_version": "2.3.1",
  "app_store_url": "https://apps.apple.com/app/idXXXXXXXXX",
  "play_store_url": "https://play.google.com/store/apps/details?id=com.yourapp"
}
```

---

## Force Update Gate Widget

Wrap your entire app in this — blocks navigation until updated.

```dart
class UpdateGate extends ConsumerWidget {
  final Widget child;
  const UpdateGate({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateStatus = ref.watch(updateStatusProvider);

    return updateStatus.when(
      loading: () => child, // don't block while checking
      error: (_, __) => child, // fail open — never block on error
      data: (status) => switch (status) {
        UpdateStatus.forceUpdate => const ForceUpdateScreen(),
        UpdateStatus.softUpdate  => SoftUpdateBanner(child: child),
        UpdateStatus.upToDate    => child,
      },
    );
  }
}

// Force update — no way out
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope( // prevent back button
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                Text('Update Required',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text(
                  'A critical update is available. Please update to continue.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _openStore(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Update Now'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openStore(BuildContext context) {
    final url = getIt<ForceUpdateService>().storeUrl;
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

// Soft update — dismissible banner at top
class SoftUpdateBanner extends StatefulWidget {
  final Widget child;
  const SoftUpdateBanner({required this.child, super.key});

  @override
  State<SoftUpdateBanner> createState() => _SoftUpdateBannerState();
}

class _SoftUpdateBannerState extends State<SoftUpdateBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_dismissed)
          MaterialBanner(
            content: const Text('A new update is available'),
            leading: const Icon(Icons.system_update),
            backgroundColor:
                Theme.of(context).colorScheme.secondaryContainer,
            actions: [
              TextButton(
                onPressed: () => setState(() => _dismissed = true),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: () {
                  final url = getIt<ForceUpdateService>().storeUrl;
                  launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
```

---

## upgrader Package (Simple Cross-Platform)

```dart
// Wrap MaterialApp — auto-checks store version
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        minAppVersion: '2.0.0',     // force below this
        durationUntilAlertAgain: const Duration(days: 1),
        dialogStyle: Platform.isIOS
            ? UpgradeDialogStyle.cupertino
            : UpgradeDialogStyle.material,
        canDismissDialog: false,    // true = soft, false = force
        showIgnore: true,
        showLater: true,
        showReleaseNotes: true,
      ),
      child: MaterialApp(
        // your app
      ),
    );
  }
}
```

---

## When to Use Which Approach

| Scenario | Solution |
|----------|----------|
| Critical security fix | Remote Config force update gate |
| Android Play Store rollout | `in_app_update` immediate flow |
| Minor feature update | `in_app_update` flexible or soft banner |
| iOS App Store update | `upgrader` package or Remote Config |
| No Firebase | `upgrader` package with version API |
| Full control of UI | Remote Config + custom gate widget |
