# Device Features, Platform Channels & Background Services

## Camera

```yaml
dependencies:
  image_picker: ^1.1.2
  camera: ^0.11.0  # for full camera control
```

```dart
@lazySingleton
class MediaService {
  final _picker = ImagePicker();

  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    return xFile != null ? File(xFile.path) : null;
  }

  Future<File?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    final xFile = await _picker.pickVideo(source: source);
    return xFile != null ? File(xFile.path) : null;
  }
}
```

### Permissions (permission_handler)
```dart
Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }
  return status.isGranted;
}
```

---

## GPS / Location

```yaml
dependencies:
  geolocator: ^12.0.0
  geocoding: ^3.0.0
```

```dart
@lazySingleton
class LocationService {
  Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Stream<Position> watchPosition() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 50,
    ),
  );

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    final place = placemarks.firstOrNull;
    if (place == null) return null;
    return '${place.locality}, ${place.country}';
  }
}
```

---

## Platform Channels (Native Code Integration)

```dart
// Flutter side
class VpnPlatformChannel {
  static const _channel = MethodChannel('com.yourapp/vpn');
  static const _eventChannel = EventChannel('com.yourapp/vpn_status');

  Future<bool> connect(String serverIp, int port) async {
    try {
      final result = await _channel.invokeMethod<bool>('connect', {
        'server_ip': serverIp,
        'port': port,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw VpnException(e.message ?? 'VPN connection failed');
    }
  }

  Future<void> disconnect() =>
      _channel.invokeMethod('disconnect');

  Stream<VpnStatus> get statusStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return VpnStatus.values.firstWhere(
        (s) => s.name == event,
        orElse: () => VpnStatus.disconnected,
      );
    });
  }
}
```

```kotlin
// Android — MainActivity.kt
class MainActivity : FlutterActivity() {
    private val vpnChannel = "com.yourapp/vpn"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, vpnChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "connect" -> {
                        val ip = call.argument<String>("server_ip") ?: ""
                        val port = call.argument<Int>("port") ?: 1194
                        // Your native VPN logic here
                        result.success(true)
                    }
                    "disconnect" -> result.success(null)
                    else -> result.notImplemented()
                }
            }
    }
}
```

---

## Background Services

```yaml
dependencies:
  workmanager: ^0.5.2          # Scheduled background tasks
  flutter_background_service: ^5.0.5  # Long-running foreground services
```

### WorkManager (Periodic tasks)
```dart
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case 'syncData':
        await getIt<SyncService>().sync();
      case 'checkSubscription':
        await getIt<IAPService>().refreshStatus();
    }
    return Future.value(true);
  });
}

// Register
await Workmanager().initialize(callbackDispatcher);
await Workmanager().registerPeriodicTask(
  'syncTask',
  'syncData',
  frequency: const Duration(hours: 1),
  constraints: Constraints(networkType: NetworkType.connected),
  existingWorkPolicy: ExistingWorkPolicy.replace,
);
```

### Background Service (Long-running)
```dart
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'vpn_service',
      initialNotificationTitle: 'VPN Active',
      initialNotificationContent: 'Tap to manage your connection',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(onForeground: onStart),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((_) => service.stopSelf());

  Timer.periodic(const Duration(seconds: 5), (_) {
    service.invoke('update', {'timestamp': DateTime.now().toIso8601String()});
  });
}
```

---

## File System

```yaml
dependencies:
  path_provider: ^2.1.3
  file_picker: ^8.0.7
```

```dart
// App directories
Future<String> getDocumentsPath() async =>
    (await getApplicationDocumentsPath());

Future<String> getTempPath() async =>
    (await getTemporaryDirectory()).path;

// File picker
Future<File?> pickFile({List<String>? allowedExtensions}) async {
  final result = await FilePicker.platform.pickFiles(
    type: allowedExtensions != null ? FileType.custom : FileType.any,
    allowedExtensions: allowedExtensions,
    withData: false,
    withReadStream: true,
  );
  return result?.files.single.path != null
      ? File(result!.files.single.path!)
      : null;
}
```

---

## Sensors

```yaml
dependencies:
  sensors_plus: ^6.0.1
```

```dart
// Accelerometer stream
accelerometerEventStream().listen((AccelerometerEvent event) {
  final x = event.x, y = event.y, z = event.z;
  // Process sensor data
});

// Shake detection
double _lastMagnitude = 0;
const _shakeThreshold = 15.0;

accelerometerEventStream().listen((event) {
  final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  if ((magnitude - _lastMagnitude).abs() > _shakeThreshold) {
    _onShake();
  }
  _lastMagnitude = magnitude;
});
```
