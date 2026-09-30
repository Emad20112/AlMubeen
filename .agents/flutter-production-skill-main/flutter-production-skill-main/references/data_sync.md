# Data Layer — Sync Strategy, Conflict Resolution & DB Migration

## Data Synchronization Strategy

### Sync Manager (Offline-First)
```dart
enum SyncStatus { idle, syncing, failed, success }
enum SyncDirection { pushOnly, pullOnly, bidirectional }

@lazySingleton
class SyncManager {
  final NetworkInfo _networkInfo;
  final List<Syncable> _syncables; // registered data sources

  final Rx<SyncStatus> status = SyncStatus.idle.obs;
  DateTime? _lastSyncedAt;

  SyncManager(this._networkInfo, this._syncables);

  Future<void> sync({SyncDirection direction = SyncDirection.bidirectional}) async {
    if (status.value == SyncStatus.syncing) return; // no double-sync
    if (!await _networkInfo.isConnected) {
      log.d('Sync skipped — no network');
      return;
    }

    status.value = SyncStatus.syncing;
    try {
      for (final syncable in _syncables) {
        if (direction != SyncDirection.pushOnly) {
          await syncable.pullFromRemote();
        }
        if (direction != SyncDirection.pullOnly) {
          await syncable.pushToRemote();
        }
      }
      _lastSyncedAt = DateTime.now();
      status.value = SyncStatus.success;
      log.i('Sync completed at $_lastSyncedAt');
    } catch (e, stack) {
      status.value = SyncStatus.failed;
      log.e('Sync failed', e, stack);
    }
  }

  bool get needsSync {
    if (_lastSyncedAt == null) return true;
    return DateTime.now().difference(_lastSyncedAt!) >
        const Duration(minutes: 15);
  }
}

abstract class Syncable {
  Future<void> pullFromRemote();
  Future<void> pushToRemote();
}
```

### Server Repository as Syncable
```dart
@injectable
class ServerSyncService implements Syncable {
  final ServerRemoteDataSource _remote;
  final ServerLocalDataSource _local;

  ServerSyncService(this._remote, this._local);

  @override
  Future<void> pullFromRemote() async {
    final remoteServers = await _remote.getAllServers();
    await _local.replaceAll(remoteServers); // full refresh
  }

  @override
  Future<void> pushToRemote() async {
    final pending = await _local.getPendingChanges();
    for (final change in pending) {
      await _remote.applyChange(change);
      await _local.markSynced(change.id);
    }
  }
}
```

---

## Offline Queue (Write-Ahead Log)

```dart
// Track changes made offline to replay when back online
@HiveType(typeId: 10)
class PendingOperation {
  @HiveField(0) final String id;
  @HiveField(1) final String type;        // 'create' | 'update' | 'delete'
  @HiveField(2) final String collection;  // e.g. 'servers'
  @HiveField(3) final String entityId;
  @HiveField(4) final String payload;     // JSON string
  @HiveField(5) final DateTime createdAt;
  @HiveField(6) int retryCount;

  PendingOperation({
    required this.id,
    required this.type,
    required this.collection,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });
}

@lazySingleton
class OfflineQueue {
  late Box<PendingOperation> _box;
  static const _maxRetries = 5;

  Future<void> init() async {
    _box = Hive.box<PendingOperation>('offline_queue');
  }

  Future<void> enqueue(PendingOperation op) =>
      _box.put(op.id, op);

  Future<void> processAll(RemoteDataSource remote) async {
    final ops = _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final op in ops) {
      try {
        await _applyOperation(op, remote);
        await _box.delete(op.id);
      } catch (e) {
        op.retryCount++;
        if (op.retryCount >= _maxRetries) {
          log.e('Permanent failure for op ${op.id}: $e');
          await _box.delete(op.id); // give up
        } else {
          await _box.put(op.id, op); // retry later
        }
      }
    }
  }

  Future<void> _applyOperation(
      PendingOperation op, RemoteDataSource remote) async {
    final data = jsonDecode(op.payload) as Map<String, dynamic>;
    switch (op.type) {
      case 'create': await remote.create(op.collection, data);
      case 'update': await remote.update(op.collection, op.entityId, data);
      case 'delete': await remote.delete(op.collection, op.entityId);
    }
  }
}
```

---

## Conflict Resolution

### Last-Write-Wins (Simple)
```dart
// Compare updatedAt timestamps — most recent wins
class LwwConflictResolver<T extends Timestamped> {
  T resolve(T local, T remote) =>
      remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
}

abstract class Timestamped {
  DateTime get updatedAt;
}
```

### Vector Clock (Complex Multi-Device)
```dart
// Track which device made which change
class VectorClock {
  final Map<String, int> _clock;

  VectorClock(this._clock);

  VectorClock increment(String deviceId) => VectorClock({
    ..._clock,
    deviceId: (_clock[deviceId] ?? 0) + 1,
  });

  ConflictState compare(VectorClock other) {
    bool thisAhead = false, otherAhead = false;
    final allKeys = {..._clock.keys, ...other._clock.keys};

    for (final key in allKeys) {
      final a = _clock[key] ?? 0;
      final b = other._clock[key] ?? 0;
      if (a > b) thisAhead = true;
      if (b > a) otherAhead = true;
    }

    if (thisAhead && !otherAhead) return ConflictState.localWins;
    if (otherAhead && !thisAhead) return ConflictState.remoteWins;
    if (thisAhead && otherAhead) return ConflictState.conflict;
    return ConflictState.equal;
  }
}

enum ConflictState { localWins, remoteWins, conflict, equal }
```

### Field-Level Merge (User Profile)
```dart
// Merge fields independently — most recent per-field wins
UserProfile mergeProfiles(UserProfile local, UserProfile remote) {
  return UserProfile(
    // Use whichever was updated more recently per field
    displayName: remote.displayNameUpdatedAt.isAfter(local.displayNameUpdatedAt)
        ? remote.displayName
        : local.displayName,
    avatarUrl: remote.avatarUpdatedAt.isAfter(local.avatarUpdatedAt)
        ? remote.avatarUrl
        : local.avatarUrl,
    // Always take remote for server-authoritative fields
    subscriptionTier: remote.subscriptionTier,
    serverCount: remote.serverCount,
  );
}
```

---

## Database Migration (SQLite)

```dart
@lazySingleton
class DatabaseService {
  static const _dbName = 'app.db';
  static const _currentVersion = 5; // increment with each schema change

  Future<Database> _initDb() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: _currentVersion,
      onCreate: _createSchema,
      onUpgrade: _migrateSchema,
      onDowngrade: onDatabaseDowngradeDelete, // re-create on downgrade
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    // Always create the latest schema from scratch
    await db.execute(_Migrations.v5_fullSchema);
  }

  Future<void> _migrateSchema(
      Database db, int oldVersion, int newVersion) async {
    log.i('Migrating DB from v$oldVersion to v$newVersion');

    // Apply migrations sequentially
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      try {
        await _applyMigration(db, v);
        log.i('Migration v$v applied');
      } catch (e, stack) {
        log.e('Migration v$v failed', e, stack);
        rethrow; // Let onDowngrade handle recovery
      }
    }
  }

  Future<void> _applyMigration(Database db, int version) async {
    switch (version) {
      case 2:
        await db.execute(_Migrations.v2);
      case 3:
        await db.execute(_Migrations.v3);
      case 4:
        await db.execute(_Migrations.v4);
      case 5:
        await db.execute(_Migrations.v5);
    }
  }
}

class _Migrations {
  // v1 → v2: Added 'ping' column to servers
  static const v2 = '''
    ALTER TABLE servers ADD COLUMN ping INTEGER DEFAULT 0;
  ''';

  // v2 → v3: Added 'favorites' table
  static const v3 = '''
    CREATE TABLE favorites (
      id TEXT PRIMARY KEY,
      server_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (server_id) REFERENCES servers(id)
    );
  ''';

  // v3 → v4: Renamed column (SQLite workaround — no RENAME COLUMN before 3.25)
  static const v4 = '''
    CREATE TABLE servers_new (
      id TEXT PRIMARY KEY,
      country TEXT NOT NULL,
      host TEXT NOT NULL,
      ping INTEGER DEFAULT 0,
      is_premium INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    );
    INSERT INTO servers_new SELECT id, country, ip AS host, ping, is_premium, created_at FROM servers;
    DROP TABLE servers;
    ALTER TABLE servers_new RENAME TO servers;
  ''';

  // v4 → v5: Added index for performance
  static const v5 = '''
    CREATE INDEX IF NOT EXISTS idx_servers_country ON servers(country);
    CREATE INDEX IF NOT EXISTS idx_servers_ping ON servers(ping);
  ''';

  // Full schema for fresh installs (always matches latest version)
  static const v5_fullSchema = '''
    CREATE TABLE IF NOT EXISTS servers (
      id TEXT PRIMARY KEY,
      country TEXT NOT NULL,
      host TEXT NOT NULL,
      ping INTEGER DEFAULT 0,
      is_premium INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    );
    CREATE INDEX IF NOT EXISTS idx_servers_country ON servers(country);
    CREATE INDEX IF NOT EXISTS idx_servers_ping ON servers(ping);
    CREATE TABLE IF NOT EXISTS favorites (
      id TEXT PRIMARY KEY,
      server_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (server_id) REFERENCES servers(id)
    );
  ''';
}
```

---

## Hive Schema Migration

```dart
// Hive doesn't support migration — use manual versioning
@lazySingleton
class HiveMigrationService {
  static const _versionKey = 'hive_schema_version';
  static const _currentVersion = 3;

  Future<void> runMigrations() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_versionKey) ?? 1;

    if (currentVersion < _currentVersion) {
      await _migrate(currentVersion, _currentVersion);
      await prefs.setInt(_versionKey, _currentVersion);
    }
  }

  Future<void> _migrate(int from, int to) async {
    for (var v = from + 1; v <= to; v++) {
      switch (v) {
        case 2:
          // v1→v2: ServerModel gained 'isPremium' field
          // Old data won't have it — default values handle it via @HiveField
          await _rebuildBox<CachedServer>('servers');
        case 3:
          // v2→v3: Completely new box structure
          await Hive.deleteBoxFromDisk('old_settings');
      }
    }
  }

  Future<void> _rebuildBox<T>(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
    await Hive.openBox<T>(boxName);
    // Data will be re-fetched from remote on next sync
  }
}
```
