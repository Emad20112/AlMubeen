# CI/CD, Deployment & App Signing

## GitHub Actions — Full Flutter Pipeline

```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.22.0'

jobs:
  test:
    name: Test & Analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: flutter pub run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze

      - name: Format check
        run: dart format --set-exit-if-changed .

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build-android:
    name: Build Android
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Setup signing
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks
          echo "storeFile=keystore.jks" >> android/key.properties
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties

      - name: Build AAB
        run: |
          flutter build appbundle --release \
            --obfuscate \
            --split-debug-info=build/debug-symbols \
            --dart-define=API_KEY=${{ secrets.API_KEY }} \
            --dart-define=ADMOB_APP_ID=${{ secrets.ADMOB_APP_ID }}

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_JSON }}
          packageName: com.yourcompany.yourapp
          releaseFiles: build/app/outputs/bundle/release/*.aab
          track: internal

  build-ios:
    name: Build iOS
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install certs
        uses: apple-actions/import-codesign-certs@v2
        with:
          p12-file-base64: ${{ secrets.IOS_CERT_BASE64 }}
          p12-password: ${{ secrets.IOS_CERT_PASSWORD }}

      - name: Install provisioning profile
        uses: apple-actions/download-provisioning-profiles@v1
        with:
          bundle-id: com.yourcompany.yourapp
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}

      - name: Build IPA
        run: |
          flutter build ipa --release \
            --obfuscate \
            --split-debug-info=build/debug-symbols \
            --dart-define=API_KEY=${{ secrets.API_KEY }}

      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/ipa/*.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}
```

---

## Android App Signing

```groovy
// android/app/build.gradle
android {
    signingConfigs {
        release {
            def keyPropertiesFile = rootProject.file("key.properties")
            def keyProperties = new Properties()
            keyProperties.load(new FileInputStream(keyPropertiesFile))

            storeFile file(keyProperties['storeFile'])
            storePassword keyProperties['storePassword']
            keyAlias keyProperties['keyAlias']
            keyPassword keyProperties['keyPassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

```properties
# android/key.properties (NEVER commit this file)
storeFile=keystore.jks
storePassword=your_password
keyAlias=your_alias
keyPassword=your_key_password
```

```
# .gitignore
android/key.properties
android/app/*.jks
ios/Runner/GoogleService-Info.plist
.env
```

---

## ProGuard Rules

```pro
# android/app/proguard-rules.pro
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Gson / JSON
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Your models (adjust package)
-keep class com.yourcompany.yourapp.data.models.** { *; }
```

---

## Versioning

```yaml
# pubspec.yaml
version: 1.4.2+23  # version_name+version_code
```

```bash
# Bump version automatically in CI
flutter pub run cider bump patch   # 1.4.2 → 1.4.3
flutter pub run cider bump minor   # 1.4.2 → 1.5.0
flutter pub run cider bump major   # 1.4.2 → 2.0.0
```

---

## Codemagic Alternative

```yaml
# codemagic.yaml
workflows:
  android-workflow:
    name: Android Release
    environment:
      flutter: 3.22.0
      groups:
        - google_play_credentials
        - signing_credentials
    scripts:
      - flutter pub get
      - flutter pub run build_runner build --delete-conflicting-outputs
      - flutter test
      - flutter build appbundle --release --obfuscate --split-debug-info=build/debug-symbols
    artifacts:
      - build/**/outputs/**/*.aab
      - build/debug-symbols
    publishing:
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
```

---

## Deployment Checklist

### Android
- [ ] `key.properties` file created (not committed)
- [ ] `signingConfig` set in `build.gradle`
- [ ] `minifyEnabled true` and `shrinkResources true`
- [ ] ProGuard rules added
- [ ] App icons at all densities
- [ ] `--obfuscate` flag in build command
- [ ] AAB (not APK) uploaded to Play Store

### iOS
- [ ] Provisioning profiles installed
- [ ] Bundle identifier matches
- [ ] App icons at all sizes
- [ ] Capabilities enabled (Push, In-App Purchase, etc.)
- [ ] `NSAppTransportSecurity` configured
- [ ] Build number incremented
