# Onboarding, Feature Discovery & First-Run Flows

```yaml
dependencies:
  shared_preferences: ^2.2.3
  smooth_page_indicator: ^1.1.0
  showcaseview: ^3.0.0          # feature spotlight/tooltip
  introduction_screen: ^3.1.12  # full onboarding screens
  lottie: ^3.1.2                # animations for onboarding
```

---

## First-Run Detection

```dart
@lazySingleton
class OnboardingService {
  final SharedPreferences _prefs;
  OnboardingService(this._prefs);

  static const _onboardingKey    = 'onboarding_completed';
  static const _appVersionKey    = 'last_seen_version';
  static const _featureKeys      = 'shown_features';

  bool get isFirstLaunch => !_prefs.getBool(_onboardingKey, );

  Future<void> markOnboardingComplete() =>
      _prefs.setBool(_onboardingKey, true);

  // Show what's new when app updates
  Future<bool> isNewVersion() async {
    final info = await PackageInfo.fromPlatform();
    final lastSeen = _prefs.getString(_appVersionKey);
    if (lastSeen == null || lastSeen != info.version) {
      await _prefs.setString(_appVersionKey, info.version);
      return lastSeen != null; // true = update (not first install)
    }
    return false;
  }

  // Feature tooltip tracking
  bool hasSeenFeature(String featureKey) {
    final seen = _prefs.getStringList(_featureKeys) ?? [];
    return seen.contains(featureKey);
  }

  Future<void> markFeatureSeen(String featureKey) async {
    final seen = _prefs.getStringList(_featureKeys) ?? [];
    if (!seen.contains(featureKey)) {
      seen.add(featureKey);
      await _prefs.setStringList(_featureKeys, seen);
    }
  }
}
```

---

## Full Onboarding Screen (Custom)

```dart
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    OnboardingPage(
      lottiePath: 'assets/lottie/shield.json',
      title: 'Military-Grade Security',
      subtitle: 'Your data is encrypted end-to-end.\nNo logs. No tracking. Ever.',
    ),
    OnboardingPage(
      lottiePath: 'assets/lottie/globe.json',
      title: '50+ Countries',
      subtitle: 'Connect to servers worldwide\nwith one tap.',
    ),
    OnboardingPage(
      lottiePath: 'assets/lottie/speed.json',
      title: 'Lightning Fast',
      subtitle: 'Optimized servers for\nstreaming, gaming and browsing.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardingPageWidget(page: _pages[i]),
              ),
            ),

            // Indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),

            const SizedBox(height: 32),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton(
                onPressed: _isLastPage ? _finish : _nextPage,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_isLastPage ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _nextPage() => _pageController.nextPage(
      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

  Future<void> _finish() async {
    await getIt<OnboardingService>().markOnboardingComplete();
    if (mounted) context.go('/home');
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(page.lottiePath, height: 280, repeat: true),
          const SizedBox(height: 32),
          Text(page.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(page.subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String lottiePath;
  final String title;
  final String subtitle;
  const OnboardingPage({
    required this.lottiePath,
    required this.title,
    required this.subtitle,
  });
}
```

---

## Feature Spotlight (ShowcaseView)

Highlight new features to existing users after an update.

```dart
// 1. Define global keys for widgets to spotlight
final _connectButtonKey  = GlobalKey();
final _premiumBadgeKey   = GlobalKey();
final _serverFilterKey   = GlobalKey();

// 2. Wrap target widget
Showcase(
  key: _connectButtonKey,
  title: 'One-Tap Connect',
  description: 'Tap to connect to the fastest server near you',
  tooltipBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
  textColor: Theme.of(context).colorScheme.onPrimaryContainer,
  child: ConnectButton(),
)

// 3. Trigger showcase after build
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final onboarding = getIt<OnboardingService>();
    if (!onboarding.hasSeenFeature('connect_button_v2')) {
      ShowCaseWidget.of(context).startShowCase([
        _connectButtonKey,
        _premiumBadgeKey,
        _serverFilterKey,
      ]);
      await onboarding.markFeatureSeen('connect_button_v2');
    }
  });
}

// 4. Wrap screen/app with ShowCaseWidget
ShowCaseWidget(
  onComplete: (index, key) {
    if (index == 2) { // last step
      log.d('Showcase tour complete');
    }
  },
  builder: (context) => HomeScreen(),
)
```

---

## "What's New" Dialog (After Update)

```dart
Future<void> showWhatsNewIfNeeded(BuildContext context) async {
  final isUpdate = await getIt<OnboardingService>().isNewVersion();
  if (!isUpdate || !context.mounted) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.new_releases, color: Colors.blue),
        SizedBox(width: 8),
        Text("What's New"),
      ]),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WhatsNewItem(
            icon: Icons.speed,
            text: '30% faster connection speeds',
          ),
          _WhatsNewItem(
            icon: Icons.public,
            text: '5 new server locations in Asia',
          ),
          _WhatsNewItem(
            icon: Icons.bug_report,
            text: 'Fixed iOS 17 connection drops',
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Let's Go!"),
        ),
      ],
    ),
  );
}

class _WhatsNewItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _WhatsNewItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ]),
    );
  }
}
```

---

## Onboarding in GoRouter (Auth Gate)

```dart
GoRouter(
  redirect: (context, state) {
    final onboarding = getIt<OnboardingService>();
    final isLoggedIn  = getIt<AuthService>().isLoggedIn;

    // First-run → onboarding
    if (onboarding.isFirstLaunch &&
        state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }

    // Not logged in → login
    if (!isLoggedIn &&
        !state.matchedLocation.startsWith('/auth')) {
      return '/auth/login';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/auth/login',  builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/home',        builder: (_, __) => const HomeScreen()),
  ],
)
```
