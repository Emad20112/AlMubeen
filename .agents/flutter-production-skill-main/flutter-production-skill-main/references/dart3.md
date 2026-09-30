# Dart 3 — Records, Patterns, Sealed Classes & Switch Expressions

## Records (Dart 3.0+)

Records are anonymous, immutable, typed tuples. Use them to return multiple values without creating a class.

```dart
// ✅ Return multiple values cleanly
(String, int) getServerInfo() => ('United States', 42);

final (country, ping) = getServerInfo();
print(country); // United States
print(ping);    // 42

// Named fields (preferred for clarity)
({String country, int ping, bool isPremium}) getServer() =>
    (country: 'Germany', ping: 18, isPremium: true);

final server = getServer();
print(server.country);   // Germany
print(server.isPremium); // true

// In async operations
Future<({User user, List<Server> servers})> loadHomeData() async {
  final (user, servers) = await (
    _userRepo.getCurrentUser(),
    _serverRepo.getServers(),
  ).wait; // parallel await with records
  return (user: user, servers: servers);
}

// Usage
final data = await loadHomeData();
print(data.user.email);
print(data.servers.length);
```

### Records in Repository pattern
```dart
// Return result + metadata together
Future<({List<Server> servers, bool fromCache, DateTime fetchedAt})>
    getServersWithMeta() async {
  final cached = _cache.get();
  if (cached != null) {
    return (servers: cached, fromCache: true, fetchedAt: _cache.cachedAt!);
  }
  final fresh = await _remote.getServers();
  return (servers: fresh, fromCache: false, fetchedAt: DateTime.now());
}
```

---

## Pattern Matching (Dart 3.0+)

### Switch Expressions (replace verbose switch statements)
```dart
// ❌ Old verbose switch statement
String statusLabel(VpnStatus status) {
  switch (status) {
    case VpnStatus.connected:
      return 'Connected';
    case VpnStatus.connecting:
      return 'Connecting...';
    case VpnStatus.disconnected:
      return 'Disconnected';
    case VpnStatus.error:
      return 'Error';
  }
}

// ✅ Dart 3 switch expression — concise, exhaustive
String statusLabel(VpnStatus status) => switch (status) {
  VpnStatus.connected    => 'Connected',
  VpnStatus.connecting   => 'Connecting...',
  VpnStatus.disconnected => 'Disconnected',
  VpnStatus.error        => 'Error',
};

// With widget return
Widget statusIcon(VpnStatus status) => switch (status) {
  VpnStatus.connected    => const Icon(Icons.shield, color: Colors.green),
  VpnStatus.connecting   => const CircularProgressIndicator(),
  VpnStatus.disconnected => const Icon(Icons.shield_outlined),
  VpnStatus.error        => const Icon(Icons.error, color: Colors.red),
};

// Switch with guards (when clause)
String pingLabel(int ping) => switch (ping) {
  < 50                  => 'Excellent',
  >= 50 && < 100        => 'Good',
  >= 100 && < 200       => 'Fair',
  _                     => 'Poor',
};

// Switch with type patterns
String describeValue(Object value) => switch (value) {
  int n when n < 0      => 'Negative int: $n',
  int n                 => 'Positive int: $n',
  String s when s.isEmpty => 'Empty string',
  String s              => 'String: $s',
  null                  => 'null',
  _                     => 'Unknown: $value',
};
```

### Destructuring Patterns
```dart
// List patterns
final [first, second, ...rest] = [1, 2, 3, 4, 5];
print(first);  // 1
print(rest);   // [3, 4, 5]

// Map patterns
final {'name': String name, 'ping': int ping} =
    {'name': 'US Server', 'ping': 42, 'premium': true};

// Object patterns
final Server(:country, :ping, :isPremium) = server; // destructure object
print(country);

// In if statements
if (result case Right(value: final user)) {
  print(user.email);
}

// Nested patterns
final response = {'data': {'user': {'id': '123', 'email': 'a@b.com'}}};
if (response case {'data': {'user': {'id': String id, 'email': String email}}}) {
  print('User $id: $email');
}
```

---

## Sealed Classes (Dart 3.0+)

Sealed classes guarantee exhaustive pattern matching. Perfect for states, failures, and domain events.

```dart
// Sealed class — all subtypes must be in same file
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ✅ Exhaustive switch — compiler error if case missing
Widget buildAuthUI(AuthState state) => switch (state) {
  AuthInitial()               => const SplashScreen(),
  AuthLoading()               => const LoadingScreen(),
  AuthAuthenticated(:final user) => HomeScreen(user: user),
  AuthUnauthenticated()       => const LoginScreen(),
  AuthError(:final message)   => ErrorScreen(message: message),
};

// Sealed failures
sealed class Failure {
  final String message;
  const Failure(this.message);
}
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No connection']);
}
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

// Exhaustive handling — no default needed
String userMessage(Failure failure) => switch (failure) {
  NetworkFailure() => 'Check your internet connection',
  ServerFailure()  => 'Server error. Try again',
  AuthFailure()    => 'Session expired. Please sign in',
  CacheFailure()   => 'Local data error',
};
```

### Sealed Classes for UI Events
```dart
// Replace GetX Rx events or BLoC events cleanly
sealed class ServerEvent {}
class ConnectRequested extends ServerEvent {
  final Server server;
  const ConnectRequested(this.server);
}
class DisconnectRequested extends ServerEvent {}
class ServerRefreshRequested extends ServerEvent {}
class FilterChanged extends ServerEvent {
  final ServerFilter filter;
  const FilterChanged(this.filter);
}
```

---

## Class Modifiers (Dart 3.0+)

```dart
// interface — can implement but not extend
interface class Serializable {
  Map<String, dynamic> toJson();
}

// base — can extend but not implement outside library
base class BaseRepository {}

// final — cannot extend or implement outside library
final class UserModel {}

// mixin class — can be used as both mixin and class
mixin class Loggable {
  void log(String message) => debugPrint('[${runtimeType}] $message');
}

class UserRepository with Loggable {
  Future<User> getUser(String id) async {
    log('Fetching user $id');
    // ...
  }
}
```

---

## Dart 3 Async Patterns

```dart
// Parallel await with records
Future<void> initializeApp() async {
  final (config, user, servers) = await (
    _configService.load(),
    _authService.getCurrentUser(),
    _serverRepo.getCached(),
  ).wait;

  // All three ran in parallel
}

// Stream.fromFutures replacement
Stream<T> combineStreams<T>(List<Stream<T>> streams) async* {
  for (final stream in streams) {
    yield* stream;
  }
}
```

---

## When to Use What

| Feature | Use When |
|---------|----------|
| **Records** | Returning 2-3 related values, parallel async results |
| **Switch expression** | Any switch that returns a value (replace ternary chains) |
| **Sealed classes** | State machines, error hierarchies, domain events |
| **Pattern matching** | Destructuring API responses, type-based dispatch |
| **Class modifiers** | Library APIs, enforcing architecture boundaries |
