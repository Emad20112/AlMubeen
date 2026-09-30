# Authentication, Push Notifications & Real-time Data

## Authentication Patterns

### Auth State Management (Riverpod)
```dart
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<void> build() async {}

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthServiceProvider).signInWithEmail(email, password);
      final user = FirebaseAuth.instance.currentUser!;
      await ref.read(analyticsServiceProvider).setUserId(user.uid);
    });
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firebaseAuthServiceProvider).signInWithGoogle(),
    );
  }

  Future<void> logout() async {
    await ref.read(firebaseAuthServiceProvider).signOut();
    await ref.read(secureStorageServiceProvider).clearAll();
    ref.read(routerProvider).go('/auth/login');
  }
}
```

### Auth Gate (Route guard)
```dart
class AuthGate extends ConsumerWidget {
  final Widget child;
  const AuthGate({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      loading: () => const SplashScreen(),
      error: (_, __) => const LoginScreen(),
      data: (user) => user != null ? child : const LoginScreen(),
    );
  }
}
```

### Auth with GetX
```dart
class AuthController extends GetxController {
  final FirebaseAuthService _authService;
  AuthController(this._authService);

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind auth state to reactive variable
    currentUser.bindStream(_authService.authStateChanges);
    // Auto-navigate based on auth state
    ever(currentUser, (user) {
      if (user != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/auth/login');
      }
    });
  }

  Future<void> loginWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      await _authService.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Failed', _mapAuthError(e.code),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  String _mapAuthError(String code) => switch (code) {
    'user-not-found' => 'No account found with this email',
    'wrong-password' => 'Incorrect password',
    'email-already-in-use' => 'Email already registered',
    'too-many-requests' => 'Too many attempts. Try again later',
    'network-request-failed' => 'No internet connection',
    _ => 'Authentication failed',
  };
}
```

---

## Phone Auth (OTP)

```dart
class PhoneAuthController extends GetxController {
  final RxString _verificationId = ''.obs;
  final RxBool isCodeSent = false.obs;
  final RxBool isLoading = false.obs;

  Future<void> sendOtp(String phoneNumber) async {
    isLoading.value = true;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Auto-verified on Android
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        isLoading.value = false;
        Get.snackbar('Error', e.message ?? 'Verification failed');
      },
      codeSent: (verificationId, _) {
        _verificationId.value = verificationId;
        isCodeSent.value = true;
        isLoading.value = false;
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId.value = verificationId;
      },
    );
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId.value.isEmpty) return;
    isLoading.value = true;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId.value,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Invalid OTP');
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

## Push Notifications (FCM — Full Setup)

### Android Setup
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

<application>
  <!-- FCM default channel -->
  <meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
  <meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
</application>
```

### iOS Setup
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

### Full Notification Service
```dart
@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize({required GoRouter router}) async {
    // 1. Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // 2. Setup local notifications for foreground display
    await _initLocalNotifications();

    // 3. Get & save FCM token
    await _setupToken();

    // 4. Handle messages in all app states
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _handleTap(m, router));

    // 5. Handle notification that launched app from terminated state
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      // Delay navigation until app is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleTap(initial, router);
      });
    }

    // 6. iOS foreground notification display
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {
        // Handle tap on local notification
      },
    );

    // Create high importance channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
        ));
  }

  Future<void> _setupToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _saveFcmToken(token);
    _messaging.onTokenRefresh.listen(_saveFcmToken);
  }

  Future<void> _saveFcmToken(String token) async {
    // Save to your backend so you can send targeted notifications
    await getIt<UserRepository>().saveFcmToken(token);
    log.d('FCM token: $token');
  }

  void _handleForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleTap(RemoteMessage message, GoRouter router) {
    final route = message.data['route'] as String?;
    final id = message.data['id'] as String?;

    if (route == null) return;
    if (id != null) {
      router.go('$route/$id');
    } else {
      router.go(route);
    }
  }
}
```

---

## Real-time Data

### Firestore Streams
```dart
// In repository
Stream<List<Message>> watchMessages(String chatId) {
  return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('created_at', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => MessageModel.fromJson(d.data()))
          .toList());
}

// In Riverpod provider
@riverpod
Stream<List<Message>> chatMessages(ChatMessagesRef ref, String chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
}

// In UI
ref.watch(chatMessagesProvider(chatId)).when(
  loading: () => const LoadingList(),
  error: (e, _) => ErrorView(message: e.toString()),
  data: (messages) => MessageList(messages: messages),
)
```

### WebSockets (for non-Firebase backends)
```dart
@lazySingleton
class WebSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get stream => _controller.stream;

  Future<void> connect(String url, {Map<String, String>? headers}) async {
    _channel = WebSocketChannel.connect(
      Uri.parse(url),
      protocols: headers?.entries.map((e) => e.value).toList(),
    );
    _channel!.stream.listen(
      _controller.add,
      onError: (e) {
        log.e('WebSocket error', e);
        _controller.addError(e);
        _scheduleReconnect(url);
      },
      onDone: () => _scheduleReconnect(url),
    );
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void _scheduleReconnect(String url) {
    Future.delayed(const Duration(seconds: 3), () => connect(url));
  }

  void dispose() {
    _channel?.sink.close();
    _controller.close();
  }
}
```

### Supabase Realtime
```dart
// In SupabaseService — already covered in backend.md
// Listen to changes:
final channel = supabase
    .channel('public:messages')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) => onNewMessage(payload.newRecord),
    )
    .subscribe();

// Cleanup
await supabase.removeChannel(channel);
```
