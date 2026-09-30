# App Lifecycle & Foreground/Background Handling

## WidgetsBindingObserver

```dart
// Register in a long-lived widget or service
class AppLifecycleService extends WidgetsBindingObserver {
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  DateTime? _backgroundedAt;
  final _stateController = StreamController<AppLifecycleState>.broadcast();

  Stream<AppLifecycleState> get stateStream => _stateController.stream;
  AppLifecycleState get currentState => _currentState;
  bool get isInForeground => _currentState == AppLifecycleState.resumed;

  void init() => WidgetsBinding.instance.addObserver(this);
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateController.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _currentState = state;
    _stateController.add(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onForeground();
      case AppLifecycleState.paused:
        _onBackground();
      case AppLifecycleState.inactive:
        _onInactive(); // iOS: phone call overlay, Control Center, etc.
      case AppLifecycleState.detached:
        _onDetached(); // Flutter engine still running but view destroyed
      case AppLifecycleState.hidden:
        break; // Desktop/web only
    }
  }

  void _onForeground() {
    log.d('App foregrounded');
    if (_backgroundedAt != null) {
      final elapsed = DateTime.now().difference(_backgroundedAt!);
      log.d('Was in background for: ${elapsed.inSeconds}s');
      _backgroundedAt = null;

      // Refresh data if away for more than 5 minutes
      if (elapsed.inMinutes >= 5) {
        getIt<SyncService>().syncIfNeeded();
      }
    }
  }

  void _onBackground() {
    log.d('App backgrounded');
    _backgroundedAt = DateTime.now();
    // Pause media, timers, analytics sessions, etc.
  }

  void _onInactive() {
    // On iOS: hide sensitive data (blur overlay, clear clipboard)
  }

  void _onDetached() {
    // Save any critical state before engine shuts down
  }
}
```

---

## Register Lifecycle Observer

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... other init
  final lifecycleService = getIt<AppLifecycleService>()..init();
  runApp(MyApp());
}

// Or in a root ConsumerStatefulWidget
class MyApp extends ConsumerStatefulWidget { ... }
class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(appLifecycleProvider.notifier).update(state);
  }
}
```

---

## Sensitive Data Privacy Overlay

```dart
// Hide app content in task switcher (iOS/Android)
class PrivacyOverlay extends StatefulWidget {
  final Widget child;
  const PrivacyOverlay({required this.child, super.key});

  @override
  State<PrivacyOverlay> createState() => _PrivacyOverlayState();
}

class _PrivacyOverlayState extends State<PrivacyOverlay>
    with WidgetsBindingObserver {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _obscure = state == AppLifecycleState.inactive ||
                 state == AppLifecycleState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_obscure)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Image.asset('assets/logo.png', width: 80),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## Wakelock (Keep Screen On)

```yaml
dependencies:
  wakelock_plus: ^1.2.0
```

```dart
// Keep screen on during active VPN session or media playback
Future<void> enableWakelock() => WakelockPlus.enable();
Future<void> disableWakelock() => WakelockPlus.disable();

// In VPN controller:
@override
void onInit() {
  super.onInit();
  ever(isConnected, (connected) {
    if (connected) WakelockPlus.enable();
    else WakelockPlus.disable();
  });
}
```

---

## App Resume Actions

```dart
// Riverpod provider that reacts to lifecycle
@riverpod
class AppLifecycleNotifier extends _$AppLifecycleNotifier {
  @override
  AppLifecycleState build() {
    final observer = _LifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
    return AppLifecycleState.resumed;
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  final Ref ref;
  _LifecycleObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(appLifecycleNotifierProvider.notifier).update((s) => state);

    if (state == AppLifecycleState.resumed) {
      // Refresh subscription status on resume
      ref.read(iapServiceProvider).refreshStatus();
      // Refresh auth token if near expiry
      ref.read(authServiceProvider).refreshTokenIfNeeded();
    }
  }
}
```

---

## Battery & Power State

```yaml
dependencies:
  battery_plus: ^6.0.1
```

```dart
final battery = Battery();

// Current level
final level = await battery.batteryLevel; // 0-100

// Battery state stream
battery.onBatteryStateChanged.listen((BatteryState state) {
  switch (state) {
    case BatteryState.charging:
      log.d('Charging — can run background sync');
    case BatteryState.discharging:
      log.d('On battery — conserve resources');
    case BatteryState.full:
      break;
    case BatteryState.unknown:
      break;
    case BatteryState.connectedNotCharging:
      break;
  }
});
```

---

## Network Change Reaction

```dart
// React to network changes app-wide
@riverpod
Stream<bool> networkStatus(NetworkStatusRef ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((result) => result != ConnectivityResult.none)
      .distinct(); // only emit when status actually changes
}

// Usage in root widget — show banner when offline
class NetworkAwareApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(networkStatusProvider).valueOrNull ?? true;
    return Column(
      children: [
        Expanded(child: router),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 28,
          color: Colors.red,
          child: const Center(
            child: Text('No internet connection',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
```
