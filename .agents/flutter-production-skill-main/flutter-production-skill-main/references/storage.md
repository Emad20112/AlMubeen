# Local Storage, Caching & Offline Support

## SharedPreferences (Simple key-value)

```dart
@lazySingleton
class PrefsService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Typed getters/setters — never use raw keys outside this class
  String? get authToken => _prefs.getString('auth_token');
  Future<void> setAuthToken(String token) => _prefs.setString('auth_token', token);

  String get locale => _prefs.getString('locale') ?? 'en';
  Future<void> setLocale(String code) => _prefs.setString('locale', code);

  bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool('dark_mode', value);

  String? get lastConnectedServer => _prefs.getString('last_server');
  Future<void> setLastServer(String id) => _prefs.setString('last_server', id);

  Future<void> clear() => _prefs.clear();
}
```

---

## Hive (Fast local NoSQL)

```yaml
dependencies:
  hive_flutter: ^1.1.0
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

```dart
// Hive type adapter
@HiveType(typeId: 0)
class CachedServer extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String country;
  @HiveField(2) String ip;
  @HiveField(3) int ping;
  @HiveField(4) DateTime cachedAt;

  CachedServer({
    required this.id,
    required this.country,
    required this.ip,
    required this.ping,
    required this.cachedAt,
  });
}

// Init in main
await Hive.initFlutter();
Hive.registerAdapter(CachedServerAdapter());
await Hive.openBox<CachedServer>('servers');
await Hive.openBox('settings'); // generic box

// Usage
@lazySingleton
class ServerCacheService {
  late final Box<CachedServer> _box;
  static const _ttl = Duration(hours: 1);

  Future<void> init() async {
    _box = Hive.box<CachedServer>('servers');
  }

  Future<void> saveServers(List<Server> servers) async {
    await _box.clear();
    final entries = {
      for (final s in servers)
        s.id: CachedServer(
          id: s.id, country: s.country, ip: s.ip,
          ping: s.ping, cachedAt: DateTime.now(),
        )
    };
    await _box.putAll(entries);
  }

  List<Server>? getCachedServers() {
    if (_box.isEmpty) return null;
    final first = _box.values.first;
    if (DateTime.now().difference(first.cachedAt) > _ttl) return null;
    return _box.values.map((c) => Server(id: c.id, country: c.country,
        ip: c.ip, ping: c.ping)).toList();
  }
}
```

---

## SQLite (Structured relational data)

```yaml
dependencies:
  sqflite: ^2.3.3+1
  path: ^1.9.0
```

```dart
@lazySingleton
class DatabaseService {
  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = join(await getDatabasesPath(), 'app.db');
    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE servers (
            id TEXT PRIMARY KEY,
            country TEXT NOT NULL,
            ip TEXT NOT NULL,
            ping INTEGER DEFAULT 0,
            is_premium INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE servers ADD COLUMN ping INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<void> insertServer(ServerModel server) async {
    final db = await database;
    await db.insert(
      'servers',
      server.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ServerModel>> getServers() async {
    final db = await database;
    final maps = await db.query('servers', orderBy: 'ping ASC');
    return maps.map(ServerModel.fromDb).toList();
  }
}
```

---

## Caching Strategy

```dart
// Repository with cache-first strategy
class ServerRepositoryImpl implements ServerRepository {
  final ServerRemoteDataSource _remote;
  final ServerCacheService _cache;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Server>>> getServers() async {
    // 1. Try cache first
    final cached = _cache.getCachedServers();
    if (cached != null) return Right(cached);

    // 2. Fetch from network if online
    if (!await _networkInfo.isConnected) {
      return Left(const NetworkFailure());
    }

    try {
      final servers = await _remote.getServers();
      await _cache.saveServers(servers);
      return Right(servers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

## Offline Support

```dart
// Show offline banner
class ConnectivityBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOnline ? 0 : 32,
      color: Colors.red,
      child: isOnline
          ? null
          : const Center(
              child: Text('No internet connection',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
    );
  }
}

// Connectivity provider
@riverpod
Stream<bool> connectivity(ConnectivityRef ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((r) => r != ConnectivityResult.none);
}
```

---

## Secure Local Storage

Always use `flutter_secure_storage` for:
- Auth tokens
- Refresh tokens
- User credentials
- Encryption keys

Never use `SharedPreferences` or Hive (unencrypted) for sensitive data.
See `security.md` for the full `SecureStorageService` implementation.
