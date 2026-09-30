# Security — Obfuscation, Secure Storage, SSL Pinning, API Protection

## Code Obfuscation

### Build with Obfuscation
```bash
# Android release
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-symbols

# iOS release
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-symbols
```

**Always** save the `debug-symbols/` folder — needed to de-obfuscate crash stack traces.

---

## Secure Storage

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
// core/services/secure_storage_service.dart
@lazySingleton
class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
  );

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearAll() => _storage.deleteAll();
}
```

**NEVER** store tokens in `SharedPreferences`. Always use `flutter_secure_storage`.

---

## SSL Pinning

### With Dio + dio_certificate_pinner

```dart
// core/network/ssl_pinning.dart
class SslPinningInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Pinning is handled at the HttpClient level (see below)
    handler.next(options);
  }
}

// Create pinned HttpClient
HttpClient createPinnedHttpClient() {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) {
    // Verify the certificate's SHA-256 fingerprint
    final fingerprint = _getSha256Fingerprint(cert.der);
    return _allowedFingerprints.contains(fingerprint);
  };
  return client;
}

// Use native_dio_adapter for full pinning support:
// flutter pub add native_dio_adapter
final dio = Dio();
dio.httpClientAdapter = NativeAdapter(
  createHttpClient: () => createPinnedHttpClient(),
);
```

### Certificate Pinning with http_certificate_pinning
```yaml
dependencies:
  http_certificate_pinning: ^4.0.0
```

```dart
// Check before making requests
try {
  await HttpCertificatePinning.check(
    serverURL: 'https://api.yourserver.com',
    headerHttp: {},
    sha: SHA.SHA256,
    allowedSHAFingerprints: ['AA:BB:CC:...your-fingerprint...'],
    timeout: 20,
  );
} on PlatformException {
  throw SecurityException('Certificate pinning failed');
}
```

---

## API Key Protection

```dart
// NEVER do this:
const apiKey = 'sk-xxxxxxxx'; // ❌ Exposed in compiled code

// DO this — use dart-define at build time:
// flutter run --dart-define=API_KEY=your_key_here
// flutter build apk --dart-define=API_KEY=your_key_here

class AppConfig {
  static const apiKey = String.fromEnvironment('API_KEY');
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.dev.yourapp.com',
  );
}

// In CI/CD, inject via environment variables
```

### .env with flutter_dotenv (dev only)
```dart
// Only for dev — never ship .env in production
await dotenv.load(fileName: '.env');
final apiKey = dotenv.env['API_KEY'];
```

---

## Auth Token Interceptor

```dart
@injectable
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _tokenDio; // Separate Dio instance for refresh (no interceptors)

  AuthInterceptor(this._storage, @Named('tokenDio') this._tokenDio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        final token = await _storage.getToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await _tokenDio.fetch(err.requestOptions);
        return handler.resolve(response);
      } else {
        await _storage.clearAll();
        // Navigate to login
        Get.offAllNamed('/login'); // or your router's logout
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;
      final response = await _tokenDio.post('/auth/refresh',
          data: {'refresh_token': refreshToken});
      await _storage.saveToken(response.data['access_token']);
      return true;
    } catch (_) {
      return false;
    }
  }
}
```

---

## Root / Jailbreak Detection

```yaml
dependencies:
  flutter_jailbreak_detection: ^1.9.0
```

```dart
Future<void> checkDeviceSecurity() async {
  final isJailbroken = await FlutterJailbreakDetection.jailbroken;
  final isDeveloperMode = await FlutterJailbreakDetection.developerMode;

  if (isJailbroken) {
    // Show warning or block access based on your policy
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Security Warning'),
        content: const Text('This app cannot run on rooted/jailbroken devices.'),
      ),
    );
  }
}
```

---

## Network Security Config (Android)

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <base-config cleartextTrafficPermitted="false">
    <trust-anchors>
      <certificates src="system" />
    </trust-anchors>
  </base-config>
  <domain-config>
    <domain includeSubdomains="true">api.yourapp.com</domain>
    <pin-set>
      <pin digest="SHA-256">your_base64_pin_here</pin>
      <pin digest="SHA-256">your_backup_pin_here</pin>
    </pin-set>
  </domain-config>
</network-security-config>
```

```xml
<!-- AndroidManifest.xml -->
<application
  android:networkSecurityConfig="@xml/network_security_config"
  ...>
```

---

## Data Encryption (Local)

```dart
// Encrypt sensitive local data with encrypt package
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  late final Encrypter _encrypter;
  late final IV _iv;

  Future<void> init() async {
    final keyString = await _secureStorage.read(key: 'enc_key')
        ?? _generateAndStoreKey();
    final key = Key.fromBase64(keyString);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    _iv = IV.fromLength(16);
  }

  String encrypt(String plainText) =>
      _encrypter.encrypt(plainText, iv: _iv).base64;

  String decrypt(String encrypted) =>
      _encrypter.decrypt64(encrypted, iv: _iv);
}
```

---

## Security Checklist

- [ ] Release builds use `--obfuscate`
- [ ] All tokens stored in `flutter_secure_storage`
- [ ] No secrets or API keys in source code
- [ ] SSL pinning enabled for all production API calls
- [ ] Certificate fingerprints pinned in `network_security_config.xml`
- [ ] `clearTextTrafficPermitted="false"` in Android
- [ ] App Transport Security enforced on iOS
- [ ] ProGuard/R8 rules for Android release
- [ ] Root/jailbreak detection for sensitive apps (banking, VPN, etc.)
- [ ] Token refresh logic with automatic re-authentication
