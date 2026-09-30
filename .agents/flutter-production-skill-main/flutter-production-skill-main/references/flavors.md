# App Flavors & Environments

## Flavor Setup (dev / staging / prod)

### Android
```groovy
// android/app/build.gradle
android {
    flavorDimensions "environment"

    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "MyApp Dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "MyApp Staging"
        }
        prod {
            dimension "environment"
            resValue "string", "app_name", "MyApp"
        }
    }
}
```

### iOS
```bash
# In Xcode: Product → Scheme → Edit Scheme
# Duplicate the Runner scheme → name it Dev / Staging / Prod
# In each scheme's Run → Arguments → Add:
#   --dart-define=FLAVOR=dev
#   --dart-define=FLAVOR=staging
#   --dart-define=FLAVOR=prod
```

---

## AppConfig Pattern

```dart
// core/config/app_config.dart
enum AppFlavor { dev, staging, prod }

class AppConfig {
  final AppFlavor flavor;
  final String baseUrl;
  final String appName;
  final bool enableLogs;
  final bool enableCrashlytics;
  final String admobAppId;

  const AppConfig._({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
    required this.enableLogs,
    required this.enableCrashlytics,
    required this.admobAppId,
  });

  static AppConfig get dev => const AppConfig._(
    flavor: AppFlavor.dev,
    baseUrl: 'https://api.dev.yourapp.com',
    appName: 'MyApp Dev',
    enableLogs: true,
    enableCrashlytics: false,
    admobAppId: 'ca-app-pub-3940256099942544~3347511713', // test ID
  );

  static AppConfig get staging => const AppConfig._(
    flavor: AppFlavor.staging,
    baseUrl: 'https://api.staging.yourapp.com',
    appName: 'MyApp Staging',
    enableLogs: true,
    enableCrashlytics: true,
    admobAppId: 'ca-app-pub-3940256099942544~3347511713',
  );

  static AppConfig get prod => const AppConfig._(
    flavor: AppFlavor.prod,
    baseUrl: 'https://api.yourapp.com',
    appName: 'MyApp',
    enableLogs: false,
    enableCrashlytics: true,
    admobAppId: String.fromEnvironment('ADMOB_APP_ID'),
  );

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}
```

---

## Flavor Entry Points

```dart
// lib/main_dev.dart
void main() async {
  await _bootstrap(AppConfig.dev);
}

// lib/main_staging.dart
void main() async {
  await _bootstrap(AppConfig.staging);
}

// lib/main.dart (prod)
void main() async {
  await _bootstrap(AppConfig.prod);
}

// lib/bootstrap.dart
Future<void> _bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: _firebaseOptions(config.flavor),
  );
  await configureDependencies(config);
  runApp(ProviderScope(
    overrides: [appConfigProvider.overrideWithValue(config)],
    child: const MyApp(),
  ));
}

FirebaseOptions _firebaseOptions(AppFlavor flavor) => switch (flavor) {
  AppFlavor.dev => DevFirebaseOptions.currentPlatform,
  AppFlavor.staging => StagingFirebaseOptions.currentPlatform,
  AppFlavor.prod => DefaultFirebaseOptions.currentPlatform,
};
```

---

## Firebase Per Flavor

```
# Folder structure for Firebase configs
android/app/src/
├── dev/
│   └── google-services.json       ← dev Firebase project
├── staging/
│   └── google-services.json       ← staging Firebase project
└── main/
    └── google-services.json       ← prod Firebase project

ios/Runner/
├── dev/
│   └── GoogleService-Info.plist
├── staging/
│   └── GoogleService-Info.plist
└── GoogleService-Info.plist       ← prod
```

---

## Running Flavors

```bash
# Run
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor prod -t lib/main.dart

# Build
flutter build apk --flavor prod -t lib/main.dart --release \
  --obfuscate --split-debug-info=build/debug-symbols \
  --dart-define=ADMOB_APP_ID=ca-app-pub-xxxx

flutter build appbundle --flavor prod -t lib/main.dart --release

# iOS
flutter build ipa --flavor prod -t lib/main.dart --release
```

---

## VS Code Launch Configs

```json
// .vscode/launch.json
{
  "configurations": [
    {
      "name": "Dev",
      "type": "dart",
      "request": "launch",
      "program": "lib/main_dev.dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "Staging",
      "type": "dart",
      "request": "launch",
      "program": "lib/main_staging.dart",
      "args": ["--flavor", "staging"]
    },
    {
      "name": "Production",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--flavor", "prod"]
    }
  ]
}
```

---

## Flavor-Specific Assets

```yaml
# pubspec.yaml — flavor assets
flutter:
  assets:
    - assets/common/
    - assets/dev/         # dev-only assets (banners, debug overlays)
    - assets/prod/        # prod assets (app icons, splash)
```

```dart
// Load flavor-specific asset
String assetPath(String name) {
  final flavor = getIt<AppConfig>().flavor.name;
  return 'assets/$flavor/$name';
}

// Usage
Image.asset(assetPath('logo.png'))
```

---

## Debug Banner & Overlay

```dart
// Show flavor badge in dev/staging
class FlavorBanner extends StatelessWidget {
  final Widget child;
  const FlavorBanner({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.read(appConfigProvider);
    if (config.isProd) return child;

    return Stack(
      children: [
        child,
        Positioned(
          top: 0, right: 0,
          child: Banner(
            message: config.flavor.name.toUpperCase(),
            location: BannerLocation.topEnd,
            color: config.isDev ? Colors.red : Colors.orange,
          ),
        ),
      ],
    );
  }
}
```
