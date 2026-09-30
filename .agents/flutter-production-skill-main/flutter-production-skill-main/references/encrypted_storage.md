# Encrypted Local Storage — Encrypted Hive, AES-at-Rest & Secure Data

```yaml
dependencies:
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  encrypt: ^5.0.3
  crypto: ^3.0.3
```

---

## Encrypted Hive (Best for local structured data)

Hive supports AES-256 encryption out of the box. The key is stored in `flutter_secure_storage`.

```dart
@lazySingleton
class EncryptedStorageService {
  static const _keyName = 'hive_encryption_key';
  final FlutterSecureStorage _secureStorage;

  EncryptedStorageService(this._secureStorage);

  Future<void> init() async {
    // Get or generate encryption key
    final existingKey = await _secureStorage.read(key: _keyName);

    Uint8List encryptionKey;
    if (existingKey == null) {
      // Generate a new 32-byte AES key
      encryptionKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _keyName,
        value: base64Url.encode(encryptionKey),
      );
    } else {
      encryptionKey = base64Url.decode(existingKey);
    }

    // Open encrypted boxes
    final cipher = HiveAesCipher(encryptionKey);

    await Hive.openBox<String>('secure_prefs',
        encryptionCipher: cipher);
    await Hive.openBox<Map>('secure_data',
        encryptionCipher: cipher);
  }

  // Typed access helpers
  Box<String> get _prefsBox => Hive.box<String>('secure_prefs');
  Box<Map> get _dataBox => Hive.box<Map>('secure_data');

  // Key-value prefs (encrypted)
  Future<void> setString(String key, String value) =>
      _prefsBox.put(key, value);
  String? getString(String key) => _prefsBox.get(key);

  Future<void> setBool(String key, bool value) =>
      _prefsBox.put(key, value.toString());
  bool getBool(String key, {bool defaultValue = false}) =>
      _prefsBox.get(key) == 'true' ? true : defaultValue;

  // Structured data (encrypted)
  Future<void> setObject(String key, Map<String, dynamic> data) =>
      _dataBox.put(key, data);
  Map<String, dynamic>? getObject(String key) =>
      _dataBox.get(key)?.cast<String, dynamic>();

  Future<void> delete(String key) async {
    await _prefsBox.delete(key);
    await _dataBox.delete(key);
  }

  Future<void> clearAll() async {
    await _prefsBox.clear();
    await _dataBox.clear();
  }
}
```

### Use encrypted Hive for:
```dart
// User profile data (cached locally)
await encryptedStorage.setObject('user_profile', {
  'id': user.id,
  'email': user.email,
  'subscription': user.plan,
});

// Session data
await encryptedStorage.setString('session_id', sessionId);
await encryptedStorage.setString('device_id', deviceId);

// API keys from Remote Config (cached)
await encryptedStorage.setString('api_endpoint', apiEndpoint);
```

---

## AES Encryption for Any Data

Use for encrypting arbitrary strings/JSON before storing in SQLite or plain Hive.

```dart
@lazySingleton
class AesEncryptionService {
  static const _keyStorageKey = 'aes_data_key';
  static const _ivStorageKey  = 'aes_iv_key';

  late final encrypt_lib.Encrypter _encrypter;
  late final encrypt_lib.IV _iv;

  final FlutterSecureStorage _secureStorage;
  AesEncryptionService(this._secureStorage);

  Future<void> init() async {
    // Load or generate AES-256 key
    String? keyB64 = await _secureStorage.read(key: _keyStorageKey);
    String? ivB64  = await _secureStorage.read(key: _ivStorageKey);

    if (keyB64 == null || ivB64 == null) {
      final key = encrypt_lib.Key.fromSecureRandom(32); // AES-256
      final iv  = encrypt_lib.IV.fromSecureRandom(16);
      keyB64 = key.base64;
      ivB64  = iv.base64;
      await _secureStorage.write(key: _keyStorageKey, value: keyB64);
      await _secureStorage.write(key: _ivStorageKey,  value: ivB64);
    }

    final key = encrypt_lib.Key.fromBase64(keyB64);
    _iv         = encrypt_lib.IV.fromBase64(ivB64);
    _encrypter  = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc));
  }

  String encrypt(String plainText) =>
      _encrypter.encrypt(plainText, iv: _iv).base64;

  String decrypt(String encryptedBase64) =>
      _encrypter.decrypt64(encryptedBase64, iv: _iv);

  String encryptJson(Map<String, dynamic> data) =>
      encrypt(jsonEncode(data));

  Map<String, dynamic> decryptJson(String encryptedBase64) =>
      jsonDecode(decrypt(encryptedBase64));
}
```

---

## Encrypted SQLite (SQLCipher)

For full database encryption when you need relational queries on sensitive data.

```yaml
dependencies:
  sqflite_sqlcipher: ^2.2.1+1
```

```dart
@lazySingleton
class EncryptedDatabaseService {
  Database? _db;
  final FlutterSecureStorage _secureStorage;

  EncryptedDatabaseService(this._secureStorage);

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    // Get or generate DB password
    var password = await _secureStorage.read(key: 'db_password');
    if (password == null) {
      password = _generatePassword();
      await _secureStorage.write(key: 'db_password', value: password);
    }

    final dbPath = join(await getDatabasesPath(), 'app_encrypted.db');
    return openDatabaseWithOptions(
      dbPath,
      version: 1,
      options: OpenDatabaseOptions(
        password: password,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE sensitive_records (
              id TEXT PRIMARY KEY,
              data TEXT NOT NULL,   -- store AES-encrypted JSON
              created_at TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  }

  String _generatePassword() {
    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }
}
```

---

## Data Classification — What to Encrypt Where

| Data Type | Storage | Encryption |
|-----------|---------|------------|
| Auth tokens, refresh tokens | `flutter_secure_storage` | OS keychain/keystore |
| User profile, session data | Encrypted Hive | AES-256 |
| Medical records, private notes | Encrypted SQLite | SQLCipher |
| API responses (cached) | Plain Hive / SQLite | Not needed |
| App preferences (theme, locale) | SharedPreferences | Not needed |
| Payment card data | **Never store locally** | N/A |
| Encryption keys themselves | `flutter_secure_storage` | OS keychain |

---

## Key Rotation

```dart
// When user changes password or re-authenticates, rotate the key
Future<void> rotateEncryptionKey() async {
  // 1. Read all existing encrypted data
  final existingData = await _readAllSecureData();

  // 2. Generate new key
  final newKey = Hive.generateSecureKey();
  final newCipher = HiveAesCipher(newKey);

  // 3. Re-encrypt all data
  await Hive.deleteBoxFromDisk('secure_data');
  await Hive.openBox<Map>('secure_data', encryptionCipher: newCipher);
  await _writeAllSecureData(existingData);

  // 4. Store new key securely
  await _secureStorage.write(
    key: _keyName,
    value: base64Url.encode(newKey),
  );
}
```

---

## Security Checklist for Local Data

- [ ] Tokens → `flutter_secure_storage` (never SharedPreferences)
- [ ] User PII cached locally → Encrypted Hive
- [ ] Sensitive queries → SQLCipher
- [ ] Encryption keys → OS keychain only
- [ ] No sensitive data in plain Hive boxes
- [ ] No sensitive data in logs
- [ ] Clear encrypted storage on logout
- [ ] Key rotation on password change
