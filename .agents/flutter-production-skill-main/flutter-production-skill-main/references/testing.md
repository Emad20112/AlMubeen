# Testing — Unit, Widget & Integration Tests

## Unit Tests

```dart
// test/features/auth/domain/usecases/login_test.dart
void main() {
  late LoginUser loginUser;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUser = LoginUser(mockRepository);
  });

  group('LoginUser', () {
    const email = 'test@test.com';
    const password = 'password123';
    final user = User(id: '1', email: email);

    test('should return User on successful login', () async {
      // Arrange
      when(() => mockRepository.login(email: email, password: password))
          .thenAnswer((_) async => Right(user));

      // Act
      final result = await loginUser(LoginParams(email: email, password: password));

      // Assert
      expect(result, Right(user));
      verify(() => mockRepository.login(email: email, password: password)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure on invalid credentials', () async {
      when(() => mockRepository.login(email: email, password: password))
          .thenAnswer((_) async => Left(const AuthFailure('Invalid credentials')));

      final result = await loginUser(LoginParams(email: email, password: password));

      expect(result, const Left(AuthFailure('Invalid credentials')));
    });
  });
}
```

### Mock Generation (mocktail)
```yaml
dev_dependencies:
  mocktail: ^1.0.3
  flutter_test:
    sdk: flutter
```

```dart
// Create mock
class MockAuthRepository extends Mock implements AuthRepository {}
class MockDioClient extends Mock implements DioClient {}

// With build_runner (@GenerateMocks annotation)
@GenerateMocks([AuthRepository, DioClient, UserRepository])
void main() { ... }
// Run: flutter pub run build_runner build
```

### Testing Riverpod
```dart
test('auth notifier emits authenticated state', () async {
  final container = ProviderContainer(overrides: [
    authRepositoryProvider.overrideWithValue(MockAuthRepository()),
  ]);
  addTearDown(container.dispose);

  final notifier = container.read(authNotifierProvider.notifier);
  await notifier.login(email: 'test@test.com', password: 'pass');

  final state = container.read(authNotifierProvider);
  expect(state, isA<AsyncData<User>>());
  expect(state.value?.email, 'test@test.com');
});
```

### Testing BLoC
```dart
blocTest<AuthBloc, AuthState>(
  'emits [loading, authenticated] when login succeeds',
  build: () {
    when(() => mockLoginUser(any())).thenAnswer((_) async => Right(testUser));
    return AuthBloc(loginUser: mockLoginUser);
  },
  act: (bloc) => bloc.add(LoginRequested(email: 'test@test.com', password: 'pass')),
  expect: () => [
    const AuthState.loading(),
    AuthState.authenticated(testUser),
  ],
);
```

---

## Widget Tests

```dart
// test/features/home/presentation/home_screen_test.dart
void main() {
  late MockVpnController mockController;

  setUp(() {
    mockController = MockVpnController();
    Get.put<VpnController>(mockController);
  });

  tearDown(Get.reset);

  testWidgets('shows Connect button when disconnected', (tester) async {
    // Arrange
    when(() => mockController.isConnected).thenReturn(false.obs);
    when(() => mockController.status).thenReturn(VpnStatus.disconnected.obs);

    // Act
    await tester.pumpWidget(
      const GetMaterialApp(home: HomeScreen()),
    );

    // Assert
    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Disconnect'), findsNothing);
  });

  testWidgets('shows loading indicator when connecting', (tester) async {
    when(() => mockController.status).thenReturn(VpnStatus.connecting.obs);

    await tester.pumpWidget(const GetMaterialApp(home: HomeScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('tapping connect calls controller.connect()', (tester) async {
    when(() => mockController.isConnected).thenReturn(false.obs);
    when(() => mockController.connect(any())).thenAnswer((_) async {});

    await tester.pumpWidget(const GetMaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Connect'));
    await tester.pump();

    verify(() => mockController.connect(any())).called(1);
  });
}
```

### Golden Tests (Screenshot testing)
```yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
```

```dart
testWidgets('ServerTile matches golden', (tester) async {
  await tester.pumpWidgetBuilder(
    ServerTile(server: TestData.mockServer),
    surfaceSize: const Size(390, 80),
  );
  await expectLater(
    find.byType(ServerTile),
    matchesGoldenFile('goldens/server_tile.png'),
  );
});
// Run: flutter test --update-goldens (to generate)
```

---

## Integration Tests

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
```

```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('VPN App Flow', () {
    testWidgets('user can connect to VPN', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Connect
      expect(find.text('Connect'), findsOneWidget);
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Connected'), findsOneWidget);
    });
  });
}

// Run: flutter test integration_test/app_test.dart
// On device: flutter test integration_test/app_test.dart -d <device_id>
```

---

## Test Utilities

```dart
// test/helpers/test_data.dart
class TestData {
  static const mockUser = User(id: 'user-1', email: 'test@test.com');

  static const mockServer = Server(
    id: 'server-1',
    country: 'United States',
    flag: '🇺🇸',
    ping: 42,
    isPremium: false,
  );

  static final mockServers = List.generate(
    10,
    (i) => Server(id: 'server-$i', country: 'Country $i',
        flag: '🏳', ping: i * 10, isPremium: i > 5),
  );
}

// test/helpers/pump_app.dart
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget, {List<Override>? overrides}) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }
}
```

---

## Coverage

```bash
# Run with coverage
flutter test --coverage

# View HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Check coverage threshold (in CI)
flutter test --coverage && \
  lcov --summary coverage/lcov.info | grep "lines" | \
  awk '{if ($2+0 < 80) exit 1}'
```
