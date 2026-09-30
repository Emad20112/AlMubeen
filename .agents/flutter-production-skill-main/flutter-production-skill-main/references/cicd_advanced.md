# CI/CD Advanced — Fastlane, Automated Testing Pipeline & Store Readiness

## Fastlane Setup

```bash
# Install
gem install fastlane
cd ios && fastlane init
cd android && fastlane init
```

### Android Fastfile
```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Run tests"
  lane :test do
    gradle(task: "test")
  end

  desc "Build and deploy to Play Store Internal"
  lane :internal do
    # Bump version code
    increment_version_code(
      gradle_file_path: "app/build.gradle"
    )

    # Build release AAB
    gradle(
      task: "bundle",
      build_type: "Release",
      flavor: "prod",
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"],
      }
    )

    # Upload to Play Store
    upload_to_play_store(
      track: "internal",
      aab: "app/build/outputs/bundle/prodRelease/app-prod-release.aab",
      json_key: ENV["PLAY_STORE_JSON_KEY"],
      skip_upload_apk: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )

    # Notify team on Slack
    slack(
      message: "🚀 Android build deployed to internal track!",
      webhook_url: ENV["SLACK_WEBHOOK"]
    )
  end

  desc "Promote internal → production"
  lane :promote_to_prod do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "production",
      rollout: "0.1",  # 10% rollout
      json_key: ENV["PLAY_STORE_JSON_KEY"],
      skip_upload_changelogs: false,
    )
  end
end
```

### iOS Fastfile
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Sync certificates"
  lane :certs do
    match(
      type: "appstore",
      app_identifier: "com.yourcompany.yourapp",
      readonly: true,
    )
  end

  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "Runner",
      devices: ["iPhone 15"],
    )
  end

  desc "Build and deploy to TestFlight"
  lane :beta do
    certs

    # Bump build number to timestamp
    increment_build_number(
      build_number: Time.now.strftime("%Y%m%d%H%M")
    )

    build_app(
      scheme: "prod",
      configuration: "Release",
      export_method: "app-store",
    )

    upload_to_testflight(
      api_key_path: "fastlane/app_store_connect_key.json",
      skip_waiting_for_build_processing: true,
    )

    slack(
      message: "🍎 iOS build deployed to TestFlight!",
      webhook_url: ENV["SLACK_WEBHOOK"]
    )
  end

  desc "Deploy to App Store"
  lane :release do
    certs
    build_app(scheme: "prod", configuration: "Release")
    deliver(
      api_key_path: "fastlane/app_store_connect_key.json",
      submit_for_review: false, # true for automatic submission
      automatic_release: false,
      skip_screenshots: true,
      skip_metadata: false,
    )
  end
end
```

---

## GitHub Actions + Fastlane Integration

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    tags: ['v*']   # trigger on version tags: v1.4.2

jobs:
  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.22.0', cache: true }

      - name: Setup Ruby + Fastlane
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: android

      - name: Run tests first
        run: flutter test --coverage

      - name: Build & Deploy
        working-directory: android
        env:
          KEYSTORE_PATH: ${{ secrets.KEYSTORE_PATH }}
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          PLAY_STORE_JSON_KEY: ${{ secrets.PLAY_STORE_JSON_KEY }}
        run: bundle exec fastlane internal
```

---

## App Size Optimization

```bash
# Analyze APK/AAB size
flutter build apk --release --analyze-size
flutter build appbundle --release --analyze-size
# Opens DevTools with treemap visualization

# Split by ABI (reduces download size 30-40%)
flutter build apk --release --split-per-abi
# Produces: arm64-v8a, armeabi-v7a, x86_64 APKs
```

```groovy
// android/app/build.gradle
android {
  buildTypes {
    release {
      minifyEnabled true      // enable R8 code shrinking
      shrinkResources true    // remove unused resources
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                   'proguard-rules.pro'
    }
  }
}
```

```yaml
# pubspec.yaml — remove unused packages regularly
# Run: flutter pub deps | grep unused
# Use: dart pub global activate dart_code_metrics
# Run: dart run dart_code_metrics:metrics analyze lib
```

### Asset Optimization
```bash
# Compress PNG assets
pngquant --quality=80 assets/**/*.png

# Convert to WebP (smaller than PNG)
cwebp -q 80 input.png -o output.webp

# Use SVG for icons (vector = tiny + sharp at any size)
# flutter_svg: ^2.0.0 handles SVG efficiently

# Only include necessary Google Fonts weights
# Don't include all 9 weights if you only use Regular + Bold
```

---

## App Startup Time Optimization

```dart
// 1. Defer non-critical initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL — must finish before first frame
  await Firebase.initializeApp();
  await configureDependencies();

  runApp(const MyApp());

  // DEFERRED — initialize after first frame renders
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await getIt<RemoteConfigService>().initialize();
    await getIt<NotificationService>().initialize();
    await getIt<AnalyticsService>().init();
    await getIt<IAPService>().initialize();
  });
}

// 2. Lazy initialization — don't init unless actually used
@lazySingleton            // ← only created when first requested
class HeavyService { ... }

// 3. Splash screen buys time — use it
// flutter_native_splash: covers while Dart VM starts
```

---

## Store Readiness (ASO Basics)

### Play Store Checklist
```
Title (30 chars):     Turbo VPN - Fast & Secure
Short Description (80 chars):  Lightning-fast VPN. 50+ servers. 1-tap connect.
Description (4000 chars): Lead with the key benefit in first 3 lines.
                          Use keywords naturally (not stuffed).
                          Address: speed, security, ease of use.

Keywords to include naturally:
  VPN, free VPN, secure VPN, fast VPN, private browsing,
  wifi security, anonymous browsing, proxy

Screenshots:          Show the app in action, not just UI.
                      First screenshot = most important.
                      Add captions/overlays with key benefits.
Feature Graphic:      1024×500px, visually striking.
Category:             Tools > Network
Content Rating:       Complete IARC questionnaire honestly
```

### App Store Checklist
```
Name (30 chars):        Turbo VPN - Fast & Secure
Subtitle (30 chars):    Private & Secure Connection
Keywords (100 chars):   vpn,secure,private,wifi,proxy,shield,guard,fast
Description:            Same rules as Play Store.
                        First 3 lines shown before "More" tap.
Screenshots:            6.7" + 5.5" required. iPad optional.
App Preview Video:      15-30s. Show actual usage. No device frame needed.
Privacy Policy URL:     Required for apps collecting any data.
App Privacy:            Complete Data Types section accurately.
```

### Crash Rate Target
```
Play Store:   Target < 1% crash-free sessions
App Store:    Target > 99.5% crash-free users
Monitor via:  Firebase Crashlytics dashboard
              Play Console → Android Vitals
              App Store Connect → Crashes
```
