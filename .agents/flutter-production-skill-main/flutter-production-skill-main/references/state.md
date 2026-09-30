# State Management — GetX / Provider / Riverpod / BLoC

## Choosing the Right Solution
- **Riverpod** → New projects, async state, testability
- **GetX** → Fast development, utility/VPN apps, existing GetX projects
- **BLoC** → Large teams, strict event-driven architecture
- **Provider** → Simple apps, widget-scoped state, migration path

---

## GetX

### Controller Types
```dart
// GetxController — reactive with Rx variables
class VpnController extends GetxController {
  final ConnectVpn _connectVpn;
  VpnController({required ConnectVpn connectVpn}) : _connectVpn = connectVpn;

  final RxBool isConnected = false.obs;
  final RxString serverLocation = ''.obs;
  final RxInt sessionSeconds = 0.obs;
  final Rx<VpnStatus> status = VpnStatus.disconnected.obs;

  Timer? _sessionTimer;

  Future<void> connect(Server server) async {
    status.value = VpnStatus.connecting;
    final result = await _connectVpn(server);
    result.fold(
      (failure) {
        status.value = VpnStatus.disconnected;
        Get.snackbar('Error', failure.message);
      },
      (_) {
        isConnected.value = true;
        status.value = VpnStatus.connected;
        serverLocation.value = server.location;
        _startTimer();
      },
    );
  }

  void _startTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      sessionSeconds.value++;
    });
  }

  @override
  void onClose() {
    _sessionTimer?.cancel();
    super.onClose();
  }
}
```

### Reactive UI
```dart
// Obx for reactive widgets
Obx(() => Text(controller.sessionSeconds.value.toTimeString()))

// GetX widget (access + reactive)
GetX<VpnController>(
  builder: (ctrl) => ConnectButton(status: ctrl.status.value),
)

// GetBuilder for non-reactive (manual update())
GetBuilder<SettingsController>(
  builder: (ctrl) => ThemeToggle(isDark: ctrl.isDarkMode),
)
```

### Workers (Event Listeners)
```dart
@override
void onInit() {
  super.onInit();
  ever(isConnected, _onConnectionChanged);
  debounce(searchQuery, _performSearch, time: const Duration(milliseconds: 300));
  interval(sessionSeconds, _checkSessionLimit, time: const Duration(minutes: 1));
}
```

---

## Riverpod

### Provider Types
```dart
// State provider — simple value
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// AsyncNotifier — async with loading/error states (preferred for data)
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build(String userId) async {
    return ref.watch(userRepositoryProvider).getUser(userId);
  }

  Future<void> updateEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).updateEmail(email),
    );
  }
}

// StreamNotifier — real-time data
@riverpod
Stream<List<Message>> messages(MessagesRef ref, String chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
}

// FutureProvider with family — parameterized
@riverpod
Future<Server> serverDetail(ServerDetailRef ref, String serverId) async {
  return ref.watch(serverRepositoryProvider).getServer(serverId);
}
```

### Consuming Providers
```dart
class UserScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider('user-id'));

    return userAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => ErrorView(message: err.toString()),
      data: (user) => UserProfile(user: user),
    );
  }
}

// ConsumerStatefulWidget for lifecycle access
class ChatScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // ref.read is safe here
    ref.read(chatNotifierProvider.notifier).joinRoom(widget.chatId);
  }
}
```

### Testing with Riverpod
```dart
test('user loads correctly', () async {
  final container = ProviderContainer(
    overrides: [
      userRepositoryProvider.overrideWithValue(MockUserRepository()),
    ],
  );
  addTearDown(container.dispose);

  final user = await container.read(userNotifierProvider('id').future);
  expect(user.email, 'test@test.com');
});
```

---

## BLoC

### Event-State-Bloc Pattern
```dart
// Events
sealed class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email, password;
  const LoginRequested(this.email, this.password);
}
class LogoutRequested extends AuthEvent {}

// States (with Freezed)
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser _loginUser;
  AuthBloc({required LoginUser loginUser})
      : _loginUser = loginUser,
        super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _loginUser(LoginParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }
}
```

### BLoC UI
```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    state.mapOrNull(
      authenticated: (_) => context.go('/home'),
      error: (s) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.message))),
    );
  },
  builder: (context, state) => state.map(
    initial: (_) => const LoginForm(),
    loading: (_) => const CircularProgressIndicator(),
    authenticated: (_) => const SizedBox.shrink(),
    unauthenticated: (_) => const LoginForm(),
    error: (s) => LoginForm(errorMessage: s.message),
  ),
)
```

---

## Provider (ChangeNotifier)

```dart
// provider + proxy_provider pattern
MultiProvider(
  providers: [
    Provider<DioClient>(create: (_) => DioClient()),
    ProxyProvider<DioClient, UserRepository>(
      update: (_, dio, __) => UserRepositoryImpl(dio),
    ),
    ChangeNotifierProxyProvider<UserRepository, ProfileViewModel>(
      create: (ctx) => ProfileViewModel(ctx.read()),
      update: (_, repo, vm) => vm!..updateRepository(repo),
    ),
  ],
  child: const MyApp(),
)

// Usage
context.watch<ProfileViewModel>().user
context.read<ProfileViewModel>().loadUser()
```
