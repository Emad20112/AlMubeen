# Firebase & Supabase Integration

## Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli
flutterfire configure  # auto-generates firebase_options.dart
```

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const MyApp());
}
```

---

## Authentication

### Firebase Auth
```dart
@lazySingleton
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUpWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw const AuthCancelledException();
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signInWithPhone({
    required String phoneNumber,
    required void Function(String, int?) codeSent,
    required void Function(FirebaseAuthException) failed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (cred) => _auth.signInWithCredential(cred),
      verificationFailed: failed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOtp(String verificationId, String smsCode) {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(cred);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
```

---

## Firestore

```dart
@lazySingleton
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get once
  Future<T?> getDocument<T>({
    required String collection,
    required String id,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final doc = await _db.collection(collection).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return fromJson(doc.data()!);
  }

  // Real-time stream
  Stream<T?> watchDocument<T>({
    required String collection,
    required String id,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return _db.collection(collection).doc(id).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return fromJson(snap.data()!);
    });
  }

  // Collection with query
  Stream<List<T>> watchCollection<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromJson,
    Query Function(CollectionReference)? query,
  }) {
    Query<Map<String, dynamic>> ref = _db.collection(collection);
    if (query != null) ref = query(ref) as Query<Map<String, dynamic>>;
    return ref.snapshots().map(
      (snap) => snap.docs.map((d) => fromJson(d.data())).toList(),
    );
  }

  // Write
  Future<void> setDocument({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
    bool merge = true,
  }) => _db.collection(collection).doc(id).set(data, SetOptions(merge: merge));

  // Batch write
  Future<void> batchWrite(List<BatchOperation> operations) async {
    final batch = _db.batch();
    for (final op in operations) {
      switch (op.type) {
        case BatchType.set:
          batch.set(_db.collection(op.collection).doc(op.id), op.data!);
        case BatchType.update:
          batch.update(_db.collection(op.collection).doc(op.id), op.data!);
        case BatchType.delete:
          batch.delete(_db.collection(op.collection).doc(op.id));
      }
    }
    await batch.commit();
  }
}
```

---

## Supabase

```dart
// main.dart
await Supabase.initialize(
  url: AppConfig.supabaseUrl,
  anonKey: AppConfig.supabaseAnonKey,
);

final supabase = Supabase.instance.client;
```

```dart
@lazySingleton
class SupabaseService {
  final _client = Supabase.instance.client;

  // Auth
  Future<AuthResponse> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Database
  Future<List<Map<String, dynamic>>> getRows({
    required String table,
    String? filter,
    dynamic filterValue,
    int? limit,
  }) async {
    var query = _client.from(table).select();
    if (filter != null) query = query.eq(filter, filterValue!);
    if (limit != null) query = query.limit(limit);
    return await query;
  }

  Future<Map<String, dynamic>> insertRow({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final response = await _client.from(table).insert(data).select().single();
    return response;
  }

  Future<void> updateRow({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) => _client.from(table).update(data).eq('id', id);

  // Real-time
  RealtimeChannel watchTable({
    required String table,
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
  }) {
    return _client.channel('public:$table')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: table,
        callback: (payload) => onInsert(payload.newRecord),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        callback: (payload) => onUpdate(payload.newRecord),
      )
      .subscribe();
  }

  // Storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    await _client.storage.from(bucket).upload(path, file);
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
```

---

## Push Notifications (FCM)

```dart
@lazySingleton
class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token
    final token = await _messaging.getToken();
    if (token != null) await _saveTokenToServer(token);

    // Handle token refresh
    _messaging.onTokenRefresh.listen(_saveTokenToServer);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Terminated state tap
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);

    // Local notification setup for foreground
    await _initLocalNotifications();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification when app is in foreground
    _showLocalNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate based on data payload
    final route = message.data['route'];
    if (route != null) {
      router.go(route); // your router instance
    }
  }
}
```
