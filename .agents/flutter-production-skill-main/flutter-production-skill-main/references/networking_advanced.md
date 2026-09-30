# Networking Advanced — Cancellation, Rate Limiting, API Versioning

## Request Cancellation

```dart
// Cancel tokens — one per screen/request group
class ServerRepository {
  final DioClient _dio;
  CancelToken? _searchToken;

  // Cancel previous search when new one starts
  Future<Either<Failure, List<Server>>> searchServers(String query) async {
    _searchToken?.cancel('New search started');
    _searchToken = CancelToken();

    try {
      final servers = await _dio.get<List<Server>>(
        '/servers/search',
        queryParameters: {'q': query},
        cancelToken: _searchToken,
        fromJson: (data) => (data as List)
            .map((e) => ServerModel.fromJson(e))
            .toList(),
      );
      return Right(servers);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return Left(const CancelledFailure());
      }
      return Left(ServerFailure(e.message ?? 'Search failed'));
    }
  }

  void cancelSearch() => _searchToken?.cancel('User cancelled');
}

// CancelToken per screen — cancel all on screen dispose
class SearchScreenController extends GetxController {
  final _cancelToken = CancelToken();

  @override
  void onClose() {
    _cancelToken.cancel('Screen disposed');
    super.onClose();
  }

  Future<void> search(String query) async {
    // pass _cancelToken to your repository method
  }
}

// In Riverpod — auto-cancel with ref.onDispose
@riverpod
Future<List<Server>> searchServers(SearchServersRef ref, String query) async {
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  return ref.watch(serverRepositoryProvider)
      .searchServers(query, cancelToken: cancelToken);
}
```

---

## Rate Limiting & Throttling

```dart
// Throttle interceptor — limit requests per time window
class RateLimitInterceptor extends Interceptor {
  final int maxRequests;
  final Duration window;
  final _timestamps = <DateTime>[];

  RateLimitInterceptor({
    this.maxRequests = 60,
    this.window = const Duration(minutes: 1),
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    // Remove timestamps outside the window
    _timestamps.removeWhere((t) => t.isBefore(windowStart));

    if (_timestamps.length >= maxRequests) {
      final oldest = _timestamps.first;
      final waitTime = oldest.add(window).difference(now);
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          message: 'Rate limit exceeded. Retry in ${waitTime.inSeconds}s',
          error: RateLimitException(retryAfter: waitTime),
        ),
      );
    }

    _timestamps.add(now);
    handler.next(options);
  }
}

class RateLimitException implements Exception {
  final Duration retryAfter;
  const RateLimitException({required this.retryAfter});
}

// Debounce at controller level (search-as-you-type)
class SearchController extends GetxController {
  final RxString query = ''.obs;
  Timer? _debounce;

  void onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim().isNotEmpty) _search(value.trim());
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}

// Throttle extension for RxDart
// query.debounceTime(const Duration(milliseconds: 400)).listen(_search)
```

---

## Retry Strategy (Exponential Backoff)

```dart
class SmartRetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  SmartRetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  });

  static const _retryCountKey = 'retry_count';

  bool _shouldRetry(DioException e) {
    final status = e.response?.statusCode;
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        status == 429 ||  // Too Many Requests
        status == 503;    // Service Unavailable
  }

  Duration _getDelay(int attempt, DioException e) {
    // Respect Retry-After header if present
    final retryAfter = e.response?.headers.value('retry-after');
    if (retryAfter != null) {
      final seconds = int.tryParse(retryAfter);
      if (seconds != null) return Duration(seconds: seconds);
    }
    // Exponential backoff: 1s, 2s, 4s...
    return baseDelay * math.pow(2, attempt - 1).toInt();
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra[_retryCountKey] ?? 0) as int;

    if (attempt < maxRetries && _shouldRetry(err)) {
      final nextAttempt = attempt + 1;
      err.requestOptions.extra[_retryCountKey] = nextAttempt;

      final delay = _getDelay(nextAttempt, err);
      log.w('Retry $nextAttempt/$maxRetries after ${delay.inMilliseconds}ms');
      await Future.delayed(delay);

      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }

    handler.next(err);
  }
}
```

---

## API Versioning

### URL-Based Versioning (Most Common)
```dart
@lazySingleton
class ApiVersioning {
  static const currentVersion = 'v2';
  static const legacyVersion = 'v1';

  // Versioned endpoint helper
  static String endpoint(String path, {String? version}) =>
      '/${version ?? currentVersion}$path';
}

// DioClient with versioned base
class DioClient {
  late final Dio _dio;

  DioClient(AppConfig config) {
    _dio = Dio(BaseOptions(
      baseUrl: '${config.baseUrl}/api/${ApiVersioning.currentVersion}',
    ));
  }
}

// Override per-request when needed
Future<T> getV1<T>(String path) async {
  final response = await _dio.get(
    path,
    options: Options(
      extra: {'version_override': 'v1'},
    ),
  );
  return response.data as T;
}
```

### Header-Based Versioning
```dart
class ApiVersionInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final versionOverride = options.extra['api_version'] as String?;
    options.headers['API-Version'] = versionOverride ?? '2024-01-01';
    handler.next(options);
  }
}
```

### Version-Aware Repository
```dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
}

// V2 implementation — uses new fields
class UserRepositoryV2 implements UserRepository {
  @override
  Future<Either<Failure, User>> getUser(String id) async {
    final response = await _dio.get('/users/$id');
    return Right(UserMapperV2().map(UserDtoV2.fromJson(response.data)));
  }
}

// Register correct version via DI
@module
abstract class RepositoryModule {
  @lazySingleton
  UserRepository get userRepository => AppConfig.apiVersion >= 2
      ? UserRepositoryV2(getIt())
      : UserRepositoryV1(getIt());
}
```

---

## Request Deduplication

```dart
// Prevent identical concurrent requests (e.g. auth token refresh)
class DeduplicatingClient {
  final Map<String, Future<Response>> _pending = {};

  Future<Response> get(String url) {
    final key = 'GET:$url';
    return _pending.putIfAbsent(key, () async {
      try {
        final response = await _dio.get(url);
        return response;
      } finally {
        _pending.remove(key);
      }
    });
  }
}
```

---

## Timeout Strategy by Endpoint Type
```dart
// Different timeouts for different request types
extension DioClientTimeouts on DioClient {
  Options get uploadOptions => Options(
    sendTimeout: const Duration(minutes: 5),
    receiveTimeout: const Duration(minutes: 5),
  );

  Options get quickOptions => Options(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  );

  Options get streamOptions => Options(
    receiveTimeout: null, // no timeout for streaming
  );
}
```
