# Architecture Enhancements — Mappers, UseCase Base Classes, Result Pattern

## DTO ↔ Entity Mapper Layer

The mapper layer sits between `data/models` (DTOs) and `domain/entities`. It keeps
transformation logic out of both layers and makes it independently testable.

```
data/
  models/       UserDto, ServerDto (JSON shape — matches API)
  mappers/      UserMapper, ServerMapper (transforms DTO ↔ Entity)
domain/
  entities/     User, Server (pure business objects)
```

### Mapper Base Class
```dart
// core/mapper/mapper.dart
abstract class Mapper<From, To> {
  To map(From input);

  List<To> mapList(List<From> input) => input.map(map).toList();
}

abstract class TwoWayMapper<A, B> extends Mapper<A, B> {
  A mapReverse(B input);

  List<A> mapReverseList(List<B> input) => input.map(mapReverse).toList();
}
```

### Concrete Mapper
```dart
// features/auth/data/mappers/user_mapper.dart
@injectable
class UserMapper extends TwoWayMapper<UserDto, User> {
  @override
  User map(UserDto dto) => User(
    id: dto.id,
    email: dto.email,
    displayName: dto.displayName ?? dto.email.split('@').first,
    avatarUrl: dto.profilePicture,
    isVerified: dto.emailVerified ?? false,
    plan: _mapPlan(dto.subscriptionTier),
    createdAt: DateTime.parse(dto.createdAt),
  );

  @override
  UserDto mapReverse(User entity) => UserDto(
    id: entity.id,
    email: entity.email,
    displayName: entity.displayName,
    profilePicture: entity.avatarUrl,
    emailVerified: entity.isVerified,
    subscriptionTier: entity.plan.name,
    createdAt: entity.createdAt.toIso8601String(),
  );

  UserPlan _mapPlan(String? tier) => switch (tier) {
    'premium' || 'pro' => UserPlan.premium,
    'enterprise' => UserPlan.enterprise,
    _ => UserPlan.free,
  };
}

// Repository uses mapper
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;
  final UserMapper _mapper;

  UserRepositoryImpl(this._remote, this._mapper);

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final dto = await _remote.getUser(id);
      return Right(_mapper.map(dto));       // DTO → Entity
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(User user) async {
    try {
      final dto = _mapper.mapReverse(user); // Entity → DTO
      await _remote.updateUser(dto);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

## UseCase Base Classes

### Standardised UseCase Interfaces
```dart
// core/usecase/usecase.dart

/// Async use case — most common
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// No-params use case
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Stream use case (real-time)
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Synchronous use case (local data only)
abstract class SyncUseCase<Type, Params> {
  Either<Failure, Type> call(Params params);
}

/// Singleton marker — used for use cases that manage long-lived state
abstract class ObservableUseCase<Type> {
  Stream<Type> get stream;
  void dispose();
}
```

### NoParams Helper
```dart
// For use cases that need no input
class NoParams {
  const NoParams();
  static const instance = NoParams();
}
```

### Concrete Use Cases
```dart
// ✅ With params
class GetUser implements UseCase<User, GetUserParams> {
  final UserRepository _repository;
  const GetUser(this._repository);

  @override
  Future<Either<Failure, User>> call(GetUserParams params) =>
      _repository.getUser(params.userId);
}

class GetUserParams {
  final String userId;
  const GetUserParams({required this.userId});
}

// ✅ No params
class GetCurrentUser implements NoParamsUseCase<User> {
  final UserRepository _repository;
  const GetCurrentUser(this._repository);

  @override
  Future<Either<Failure, User>> call() => _repository.getCurrentUser();
}

// ✅ Stream
class WatchVpnStatus implements StreamUseCase<VpnStatus, NoParams> {
  final VpnRepository _repository;
  const WatchVpnStatus(this._repository);

  @override
  Stream<Either<Failure, VpnStatus>> call(NoParams params) =>
      _repository.statusStream.map((s) => Right(s));
}

// ✅ In controller/notifier:
class HomeController extends GetxController {
  final GetCurrentUser _getCurrentUser;
  final WatchVpnStatus _watchVpnStatus;

  HomeController({
    required GetCurrentUser getCurrentUser,
    required WatchVpnStatus watchVpnStatus,
  })  : _getCurrentUser = getCurrentUser,
        _watchVpnStatus = watchVpnStatus;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    _watchStatus();
  }

  Future<void> _loadUser() async {
    final result = await _getCurrentUser();  // ← NoParams, just call()
    result.fold(
      (f) => log.e(f.message),
      (user) => currentUser.value = user,
    );
  }

  void _watchStatus() {
    _watchVpnStatus(NoParams.instance).listen((result) {
      result.fold(
        (f) => log.w('VPN status error: ${f.message}'),
        (status) => vpnStatus.value = status,
      );
    }).canceledBy(this); // GetX cancel extension
  }
}
```

---

## Result / Either Pattern — Full Consistency Guide

### Failure Hierarchy
```dart
// core/errors/failures.dart
abstract class Failure {
  final String message;
  final int? code;
  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure($message)';
}

// Network
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

// Server
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found'])
      : super(code: 404);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized'])
      : super(code: 401);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors, super.code = 422});
}

// Auth
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure()
      : super('Your session has expired. Please log in again.');
}

// Local
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

// Business Logic
class InsufficientPermissionsFailure extends Failure {
  const InsufficientPermissionsFailure(
      [super.message = 'Premium subscription required']);
}
```

### Failure → User Message Mapping
```dart
// core/errors/failure_messages.dart
extension FailureMessage on Failure {
  String get userMessage => switch (this) {
    NetworkFailure() => 'No internet connection. Check your network.',
    TimeoutFailure() => 'Request timed out. Try again.',
    SessionExpiredFailure() => 'Session expired. Please log in again.',
    UnauthorizedFailure() => 'Access denied.',
    NotFoundFailure() => 'Not found.',
    ValidationFailure f => f.message,
    InsufficientPermissionsFailure() => 'Upgrade to Premium for access.',
    ServerFailure f => 'Server error: ${f.message}',
    _ => 'Something went wrong. Try again.',
  };

  bool get isRecoverable => switch (this) {
    NetworkFailure() || TimeoutFailure() => true, // can retry
    SessionExpiredFailure() => false,             // must re-auth
    _ => true,
  };
}
```

### Async Result Handling Pattern
```dart
// In Riverpod notifiers
Future<void> connectVpn(Server server) async {
  state = const AsyncLoading();
  final result = await ref.read(connectVpnUseCaseProvider)(
    ConnectVpnParams(server: server),
  );
  state = result.fold(
    (failure) => AsyncError(failure, StackTrace.current),
    (_) => const AsyncData(null),
  );
}

// In GetX controllers
Future<void> loadServers() async {
  isLoading.value = true;
  final result = await _getServers(NoParams.instance);
  result.fold(
    (failure) {
      error.value = failure.userMessage;
      if (!failure.isRecoverable) Get.offAllNamed('/login');
    },
    (servers) => this.servers.value = servers,
  );
  isLoading.value = false;
}
```

### Either Chaining (Functional Style)
```dart
// Chain multiple Either operations without nested fold
Future<Either<Failure, UserProfile>> getEnrichedProfile(String userId) async {
  // If any step fails, short-circuit and return Left
  return (await getUser(userId))
      .flatMap((user) async => (await getSubscription(user.id))
          .map((sub) => UserProfile(user: user, subscription: sub)));
}

// Extension for async flatMap
extension EitherAsync<L, R> on Either<L, R> {
  Future<Either<L, T>> flatMap<T>(
      Future<Either<L, T>> Function(R right) f) async {
    return fold((l) async => Left(l), f);
  }
}
```
