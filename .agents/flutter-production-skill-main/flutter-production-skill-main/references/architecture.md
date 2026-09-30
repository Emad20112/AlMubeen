# Architecture, Folder Structure & Dependency Injection

## Clean Architecture — Layer Rules

```
Presentation → Domain ← Data
```
- **Domain layer** — Pure Dart. No Flutter imports. Entities, Use Cases, Repository interfaces.
- **Data layer** — Implements domain repositories. Contains models (DTOs), remote/local data sources.
- **Presentation layer** — Flutter widgets, screens, controllers/notifiers/cubits.

### Entity vs Model
```dart
// domain/entities/user.dart — pure Dart, immutable
class User {
  final String id;
  final String email;
  const User({required this.id, required this.email});
}

// data/models/user_model.dart — extends entity, adds serialization
class UserModel extends User {
  const UserModel({required super.id, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'], email: json['email']);

  Map<String, dynamic> toJson() => {'id': id, 'email': email};

  factory UserModel.fromEntity(User user) =>
      UserModel(id: user.id, email: user.email);
}
```

### Use Case Pattern
```dart
// domain/usecases/get_user.dart
import 'package:dartz/dartz.dart';

class GetUser {
  final UserRepository repository;
  const GetUser(this.repository);

  Future<Either<Failure, User>> call(String userId) =>
      repository.getUser(userId);
}
```

### Repository Pattern
```dart
// domain/repositories/user_repository.dart (abstract)
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, void>> updateUser(User user);
}

// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUser(id);
        await localDataSource.cacheUser(user);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final user = await localDataSource.getCachedUser(id);
        return Right(user);
      } on CacheException {
        return Left(const CacheFailure('No cached data'));
      }
    }
  }
}
```

---

## Dependency Injection

### With GetIt + Injectable (Recommended for Clean Architecture)

```yaml
# pubspec.yaml
dependencies:
  get_it: ^7.6.7
  injectable: ^2.3.2
dev_dependencies:
  injectable_generator: ^2.4.1
  build_runner: ^2.4.8
```

```dart
// core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

```dart
// Annotate classes:
@injectable          // transient
@singleton           // single instance
@lazySingleton       // created on first use (preferred for services)
@preResolve          // for async initialization

@lazySingleton
class DioClient {
  late final Dio _dio;
  DioClient(AppConfig config) {
    _dio = Dio(BaseOptions(baseUrl: config.baseUrl));
    _dio.interceptors.addAll([AuthInterceptor(), LoggingInterceptor()]);
  }
}
```

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### With GetX Bindings
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DioClient());
    Get.lazyPut(() => UserRemoteDataSource(Get.find()));
    Get.lazyPut(() => UserRepositoryImpl(Get.find()));
    Get.lazyPut(() => GetUser(Get.find()));
    Get.lazyPut(() => HomeController(getUser: Get.find()));
  }
}
```

### With Riverpod Providers
```dart
// Use provider overrides in ProviderScope for DI
void main() {
  runApp(
    ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(DioClient(AppConfig.prod)),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## MVVM Pattern

```dart
// ViewModel (with ChangeNotifier or StateNotifier)
class ProfileViewModel extends ChangeNotifier {
  final GetUser _getUser;
  ProfileViewModel(this._getUser);

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getUser(id);
    result.fold(
      (failure) => _error = failure.message,
      (user) => _user = user,
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

---

## Error Handling

```dart
// core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
```

---

## Freezed for Immutable Models

```dart
// Run: flutter pub add freezed freezed_annotation json_annotation
// Run: flutter pub add --dev build_runner json_serializable

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    @Default(false) bool isVerified,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```
