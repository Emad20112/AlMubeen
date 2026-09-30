# Deep Links & Dynamic Links

## App Links / Universal Links (Verified Deep Links)

### Android — App Links
```xml
<!-- AndroidManifest.xml -->
<activity android:name=".MainActivity" ...>
  <!-- Standard deep link (no verification needed) -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="yourapp" />
    <!-- yourapp://servers/us-1 -->
  </intent-filter>

  <!-- Verified App Links (https scheme, requires assetlinks.json) -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https"
          android:host="yourapp.com"
          android:pathPrefix="/app" />
    <!-- https://yourapp.com/app/servers/us-1 -->
  </intent-filter>
</activity>
```

```json
// Host at: https://yourapp.com/.well-known/assetlinks.json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.yourcompany.yourapp",
    "sha256_cert_fingerprints": ["AA:BB:CC:...your_release_fingerprint..."]
  }
}]
```

### iOS — Universal Links
```xml
<!-- ios/Runner/Info.plist -->
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

```json
// Host at: https://yourapp.com/.well-known/apple-app-site-association
{
  "applinks": {
    "apps": [],
    "details": [{
      "appID": "TEAMID.com.yourcompany.yourapp",
      "paths": ["/app/*"]
    }]
  }
}
```

---

## GoRouter Deep Link Handling

```dart
// GoRouter handles deep links automatically when configured
GoRouter(
  routes: [...],
  // Deep links like yourapp://servers/us-1 map to /servers/us-1
  // Flutter handles the scheme stripping automatically
)

// For custom scheme handling in main:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No extra setup needed — Flutter + GoRouter handles it
  runApp(const MyApp());
}
```

---

## uni_links (Manual Deep Link Handling)

```yaml
dependencies:
  app_links: ^6.1.4   # Modern replacement for uni_links
```

```dart
@lazySingleton
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _subscription;

  Future<void> initialize(GoRouter router) async {
    // Handle app opened from terminated state via deep link
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri, router);
    }

    // Handle deep links while app is running
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri, router),
      onError: (e) => log.e('Deep link error', e),
    );
  }

  void _handleUri(Uri uri, GoRouter router) {
    log.d('Deep link received: $uri');

    // yourapp://servers/us-1
    // https://yourapp.com/app/servers/us-1
    final path = _extractPath(uri);
    if (path != null) {
      router.go(path);
    }
  }

  String? _extractPath(Uri uri) {
    // Custom scheme: yourapp://servers/us-1 → /servers/us-1
    if (uri.scheme == 'yourapp') {
      return '/${uri.host}${uri.path}';
    }

    // HTTPS: https://yourapp.com/app/servers/us-1 → /servers/us-1
    if (uri.host == 'yourapp.com' && uri.path.startsWith('/app')) {
      return uri.path.replaceFirst('/app', '');
    }

    return null;
  }

  void dispose() => _subscription?.cancel();
}
```

---

## Firebase Dynamic Links (FDL)

> ⚠️ Firebase Dynamic Links is deprecated as of August 2025.
> Use Branch.io or manually crafted App Links/Universal Links instead.

### Branch.io Alternative

```yaml
dependencies:
  flutter_branch_sdk: ^7.1.0
```

```dart
@lazySingleton
class BranchService {
  Future<void> initialize(GoRouter router) async {
    await FlutterBranchSdk.init(useTestKey: !AppConfig.isProd);

    FlutterBranchSdk.initSession().listen((data) {
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        final route = data['\$deeplink_path'] as String?;
        if (route != null) router.go(route);
      }
    });
  }

  Future<String> createShareLink({
    required String title,
    required String description,
    required String route,
    String? imageUrl,
  }) async {
    final buo = BranchUniversalObject(
      canonicalIdentifier: route,
      title: title,
      contentDescription: description,
      imageUrl: imageUrl,
    );

    final lp = BranchLinkProperties()
      ..addControlParam('\$deeplink_path', route)
      ..addControlParam('\$desktop_url', 'https://yourapp.com$route');

    final response = await FlutterBranchSdk.getShortUrl(
      buo: buo,
      linkProperties: lp,
    );
    return response.result ?? 'https://yourapp.com$route';
  }
}
```

---

## Share Deep Link (Invite Flow)

```dart
Future<void> shareInviteLink(String userId) async {
  final link = await getIt<BranchService>().createShareLink(
    title: 'Join me on ${AppConfig.appName}!',
    description: 'Use my invite link to get 1 month free',
    route: '/invite/$userId',
  );

  await Share.share(
    'Join me on ${AppConfig.appName}! $link',
    subject: 'You\'re invited!',
  );
}
```

---

## Testing Deep Links

```bash
# Android — test custom scheme
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "yourapp://servers/us-1" \
  com.yourcompany.yourapp

# Android — test App Link (https)
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "https://yourapp.com/app/servers/us-1" \
  com.yourcompany.yourapp

# iOS Simulator
xcrun simctl openurl booted "yourapp://servers/us-1"
xcrun simctl openurl booted "https://yourapp.com/app/servers/us-1"
```
