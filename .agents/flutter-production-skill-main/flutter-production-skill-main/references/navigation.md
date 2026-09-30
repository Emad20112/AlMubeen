# Navigation, Routing & Deep Linking

## GoRouter (Recommended for Production)

```yaml
dependencies:
  go_router: ^13.2.0
```

### Router Setup
```dart
// core/router/app_router.dart
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isOnAuth) return '/auth/login';
      if (isLoggedIn && isOnAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home',
      ),
      GoRoute(
        path: '/auth/login',
        name: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/servers',
            name: AppRoutes.servers,
            builder: (_, __) => const ServersScreen(),
            routes: [
              GoRoute(
                path: ':serverId',
                name: AppRoutes.serverDetail,
                builder: (_, state) => ServerDetailScreen(
                  serverId: state.pathParameters['serverId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            name: AppRoutes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/premium',
            name: AppRoutes.premium,
            builder: (_, __) => const PremiumScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => ErrorScreen(error: state.error),
  );
}

// Route name constants
class AppRoutes {
  static const login = 'login';
  static const home = 'home';
  static const servers = 'servers';
  static const serverDetail = 'serverDetail';
  static const settings = 'settings';
  static const premium = 'premium';
}
```

### Navigation Usage
```dart
// Push
context.go('/home');
context.goNamed(AppRoutes.serverDetail, pathParameters: {'serverId': id});

// Replace
context.replace('/auth/login');

// Push on top (back button works)
context.push('/premium');

// With extra data
context.push('/servers', extra: {'filter': 'premium'});
```

---

## Deep Linking

### Android Setup
```xml
<!-- AndroidManifest.xml -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="yourapp.com" />
</intent-filter>

<!-- Custom scheme (for non-verified deep links) -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="turbovpn" />
</intent-filter>
```

### iOS Setup
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>turbovpn</string></array>
  </dict>
</array>
```

### GoRouter Deep Link Config
```dart
GoRouter(
  // GoRouter handles deep links automatically
  // Test with: adb shell am start -W -a android.intent.action.VIEW
  //            -d "https://yourapp.com/servers/us-1" your.package.name
)
```

---

## GetX Navigation

```dart
// In main.dart
GetMaterialApp(
  initialRoute: '/',
  getPages: AppPages.routes,
  unknownRoute: GetPage(name: '/404', page: () => const NotFoundScreen()),
)

// core/routes/app_pages.dart
class AppPages {
  static final routes = [
    GetPage(
      name: '/',
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/servers',
      page: () => const ServersScreen(),
      binding: ServersBinding(),
    ),
    GetPage(
      name: '/server/:id',
      page: () => const ServerDetailScreen(),
    ),
  ];
}

// Navigation
Get.toNamed('/servers');
Get.offAllNamed('/home');
Get.toNamed('/server/${server.id}');
Get.back();
final id = Get.parameters['id']; // path params
```

---

## Bottom Navigation with State Preservation

```dart
// With GoRouter ShellRoute + IndexedStack
class AppShell extends StatefulWidget { ... }

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _tabs = ['/home', '/servers', '/settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          context.go(_tabs[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.wifi), label: 'Servers'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```
