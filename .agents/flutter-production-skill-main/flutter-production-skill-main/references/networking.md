# Networking — REST API, Dio, HTTP Clients, JSON Serialization

## Dio Setup (Production)

```yaml
dependencies:
  dio: ^5.4.3
  pretty_dio_logger: ^1.3.1
  connectivity_plus: ^6.0.3
```

```dart
// core/network/dio_client.dart
@lazySingleton
class DioClient {
  late final Dio _dio;

  DioClient(AppConfig config, AuthInterceptor authInterceptor) {
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Version': config.version,
      },
    ));

    _dio.interceptors.addAll([
      authInterceptor,
      RetryInterceptor(dio: _dio, retries: 3),
      if (kDebugMode) PrettyDioLogger(requestBody: true, responseBody: true),
    ]);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return fromJson != null ? fromJson(response.data) : response.data as T;
  }

  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> data,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.post(path, data: data);
    return fromJson != null ? fromJson(response.data) : response.data as T;
  }

  Future<T> put<T>(String path, {required Map<String, dynamic> data}) async {
    final response = await _dio.put(path, data: data);
    return response.data as T;
  }

  Future<void> delete(String path) async => _dio.delete(path);
}
```

---

## Network Info

```dart
@lazySingleton
class NetworkInfo {
  final Connectivity _connectivity;
  NetworkInfo(this._connectivity);

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<bool> get connectivityStream =>
      _connectivity.onConnectivityChanged
          .map((r) => r != ConnectivityResult.none);
}
```

---

## Error Handling from API

```dart
// core/network/error_handler.dart
DioException handling:

Either<Failure, T> handleDioError<T>(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return Left(NetworkFailure('Connection timed out'));
    case DioExceptionType.connectionError:
      return Left(NetworkFailure('No internet connection'));
    case DioExceptionType.badResponse:
      return Left(_handleStatusCode(e.response?.statusCode));
    default:
      return Left(ServerFailure('Unexpected error'));
  }
}

Failure _handleStatusCode(int? code) => switch (code) {
  400 => const ValidationFailure('Invalid request'),
  401 => const AuthFailure('Unauthorized'),
  403 => const AuthFailure('Forbidden'),
  404 => const NotFoundFailure('Resource not found'),
  422 => const ValidationFailure('Validation failed'),
  500 => const ServerFailure('Internal server error'),
  503 => const ServerFailure('Service unavailable'),
  _ => const ServerFailure('Unknown error'),
};
```

---

## JSON Serialization

### Manual (small models)
```dart
class ServerModel {
  final String id;
  final String country;
  final String flag;
  final int ping;
  final bool isPremium;

  const ServerModel({
    required this.id,
    required this.country,
    required this.flag,
    required this.ping,
    required this.isPremium,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) => ServerModel(
    id: json['id'] as String,
    country: json['country'] as String,
    flag: json['flag'] as String,
    ping: json['ping'] as int,
    isPremium: json['is_premium'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'country': country,
    'flag': flag,
    'ping': ping,
    'is_premium': isPremium,
  };
}
```

### With json_serializable (recommended for larger models)
```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class ServerModel {
  final String id;
  final String country;
  @JsonKey(name: 'is_premium', defaultValue: false)
  final bool isPremium;

  const ServerModel({required this.id, required this.country, required this.isPremium});

  factory ServerModel.fromJson(Map<String, dynamic> json) =>
      _$ServerModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServerModelToJson(this);
}
// Run: flutter pub run build_runner build
```

### Paginated Response
```dart
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int perPage;
  final bool hasNextPage;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.hasNextPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}

// Usage:
final response = PaginatedResponse<ServerModel>.fromJson(
  json,
  (e) => ServerModel.fromJson(e as Map<String, dynamic>),
);
```

---

## Retry Interceptor

```dart
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    var attempt = err.requestOptions.extra['retryCount'] ?? 0;

    final shouldRetry = attempt < retries &&
        (err.type == DioExceptionType.connectionError ||
         err.type == DioExceptionType.connectionTimeout);

    if (shouldRetry) {
      attempt++;
      err.requestOptions.extra['retryCount'] = attempt;
      await Future.delayed(retryDelay * attempt);
      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
```

---

## Multipart / File Upload

```dart
Future<String> uploadImage(File file) async {
  final fileName = path.basename(file.path);
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: MediaType('image', 'jpeg'),
    ),
  });

  final response = await _dio.post(
    '/upload',
    data: formData,
    onSendProgress: (sent, total) {
      uploadProgress.value = sent / total;
    },
  );
  return response.data['url'] as String;
}
```
