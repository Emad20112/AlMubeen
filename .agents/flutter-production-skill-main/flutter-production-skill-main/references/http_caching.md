# HTTP Response Caching — dio_cache_interceptor & Strategies

```yaml
dependencies:
  dio_cache_interceptor: ^3.5.0
  dio_cache_interceptor_hive_store: ^3.2.1   # Hive backend
  # or:
  dio_cache_interceptor_db_store: ^3.2.1      # SQLite backend
```

---

## Setup

```dart
@lazySingleton
class CachedDioClient {
  late final Dio _dio;
  late final CacheStore _store;
  late final CacheOptions _defaultOptions;

  Future<void> init() async {
    // Hive-backed persistent cache
    final dir = await getApplicationDocumentsDirectory();
    _store = HiveCacheStore(
      '${dir.path}/http_cache',
      hiveBoxName: 'http_cache',
    );

    _defaultOptions = CacheOptions(
      store: _store,
      policy: CachePolicy.request,      // use cache if valid, else fetch
      hitCacheOnErrorExcept: [401, 403], // serve stale cache on 5xx
      maxStale: const Duration(days: 7), // max age of stale cache
      priority: CachePriority.normal,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
    );

    _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl))
      ..interceptors.addAll([
        DioCacheInterceptor(options: _defaultOptions),
        AuthInterceptor(),
        if (kDebugMode) PrettyDioLogger(),
      ]);
  }
}
```

---

## Cache Policies Explained

```dart
// CachePolicy.request (default)
// → Use cache if valid (within maxAge), else fetch and store
// → Best for: server lists, config data

// CachePolicy.forceCache
// → Always use cache — fetch only if no cache exists
// → Best for: static content (country flags, help articles)

// CachePolicy.noCache
// → Never cache — always fetch fresh
// → Best for: user balance, real-time prices

// CachePolicy.refreshForceCache
// → Force fetch, then save to cache
// → Best for: manual pull-to-refresh

// CachePolicy.network
// → Always fetch, ignore cache completely
// → Best for: POST requests (sometimes)
```

---

## Per-Request Cache Override

```dart
extension DioCache on DioClient {
  // Force fresh fetch (pull-to-refresh)
  Future<T> getFresh<T>(String path, {T Function(dynamic)? fromJson}) async {
    final response = await _dio.get(
      path,
      options: _defaultOptions.copyWith(
        policy: CachePolicy.refreshForceCache,
      ).toOptions(),
    );
    return fromJson != null ? fromJson(response.data) : response.data as T;
  }

  // Force use cache (offline mode)
  Future<T?> getCachedOnly<T>(String path, {T Function(dynamic)? fromJson}) async {
    try {
      final response = await _dio.get(
        path,
        options: _defaultOptions.copyWith(
          policy: CachePolicy.forceCache,
          maxStale: const Duration(days: 30),
        ).toOptions(),
      );
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException {
      return null; // no cache available
    }
  }

  // Never cache (real-time data)
  Future<T> getNoCache<T>(String path, {T Function(dynamic)? fromJson}) async {
    final response = await _dio.get(
      path,
      options: _defaultOptions.copyWith(
        policy: CachePolicy.noCache,
      ).toOptions(),
    );
    return fromJson != null ? fromJson(response.data) : response.data as T;
  }
}
```

---

## Stale-While-Revalidate Pattern

Show cached data immediately, refresh in background, update UI when fresh data arrives.

```dart
// In repository
Stream<List<Server>> watchServers() async* {
  // 1. Emit cached data immediately
  final cached = await _getCachedServers();
  if (cached != null) yield cached;

  // 2. Fetch fresh in background
  try {
    final fresh = await _dio.get<List<Server>>(
      '/servers',
      options: CacheOptions(
        store: _store,
        policy: cached != null
            ? CachePolicy.refreshForceCache  // force fresh
            : CachePolicy.request,
      ).toOptions(),
    );
    yield fresh;
  } on DioException catch (e) {
    if (cached == null) {
      // No cache and network failed — emit error
      throw NetworkFailure(e.message ?? 'Failed to fetch servers');
    }
    // Had cache — silently swallow network error
  }
}

// In Riverpod
@riverpod
Stream<List<Server>> servers(ServersRef ref) {
  return ref.watch(serverRepositoryProvider).watchServers();
}

// UI shows data immediately from cache, auto-updates when fresh arrives
ref.watch(serversProvider).when(
  loading: () => const ServerListSkeleton(), // only on truly first load
  data: (servers) => ServerList(servers: servers),
  error: (e, _) => ErrorStateWidget(message: e.toString()),
)
```

---

## Cache Management

```dart
@lazySingleton
class CacheManagerService {
  final CacheStore _store;
  CacheManagerService(this._store);

  // Clear all cached responses
  Future<void> clearAll() => _store.clean(strategy: DeleteStrategy.bandwidthUsage);

  // Clear expired entries only
  Future<void> clearExpired() => _store.clean(strategy: DeleteStrategy.requestSortedByDate);

  // Clear specific endpoint cache
  Future<void> clearEndpoint(String url) async {
    final key = CacheOptions.defaultCacheKeyBuilder(
      RequestOptions(path: url, baseUrl: AppConfig.baseUrl),
    );
    await _store.delete(key);
  }

  // Check if endpoint has valid cache
  Future<bool> hasCacheFor(String url) async {
    final key = CacheOptions.defaultCacheKeyBuilder(
      RequestOptions(path: url, baseUrl: AppConfig.baseUrl),
    );
    final response = await _store.get(key);
    return response != null && !response.isExpired;
  }
}

// Clear relevant caches after mutation
Future<void> updateServer(Server server) async {
  await _remote.updateServer(server);
  await _cacheManager.clearEndpoint('/servers');       // invalidate list
  await _cacheManager.clearEndpoint('/servers/${server.id}'); // invalidate detail
}
```

---

## Cache Strategy by Endpoint

| Endpoint | Policy | maxAge | Notes |
|----------|--------|--------|-------|
| `GET /servers` | `request` | 30 min | Refresh on pull-to-refresh |
| `GET /config` | `forceCache` | 24 hours | App config rarely changes |
| `GET /user/profile` | `request` | 5 min | User data freshness |
| `GET /servers/:id` | `request` | 1 hour | Server details |
| `POST /connect` | `noCache` | — | Never cache mutations |
| `GET /prices` | `noCache` | — | Always fresh |
| `GET /help/articles` | `forceCache` | 7 days | Static content |

---

## Debug Cache Headers

```dart
// In debug mode — log cache status of each response
if (kDebugMode) {
  _dio.interceptors.add(InterceptorsWrapper(
    onResponse: (response, handler) {
      final fromCache = response.extra[CacheResponse.cacheKey] != null;
      final cacheStatus = response.extra[CacheResponse.fromNetwork] == true
          ? '🌐 NETWORK'
          : '💾 CACHE';
      debugPrint('$cacheStatus ${response.requestOptions.path}');
      handler.next(response);
    },
  ));
}
```
