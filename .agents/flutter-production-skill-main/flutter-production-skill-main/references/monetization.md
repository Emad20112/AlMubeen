# Ads & Monetization — AdMob, Yandex, IAP, Payment Gateways

## AdMob Setup

```yaml
dependencies:
  google_mobile_ads: ^5.1.0
```

### Unified Ad Manager
```dart
enum AdProvider { admob, yandex }

@lazySingleton
class AdManager {
  AdProvider _provider = AdProvider.admob;

  // Production Ad Unit IDs — store in AppConfig, NOT hardcoded
  String get _bannerId => _provider == AdProvider.admob
      ? AppConfig.admobBannerId
      : AppConfig.yandexBannerId;

  String get _interstitialId => _provider == AdProvider.admob
      ? AppConfig.admobInterstitialId
      : AppConfig.yandexInterstitialId;

  String get _rewardedId => _provider == AdProvider.admob
      ? AppConfig.admobRewardedId
      : AppConfig.yandexRewardedId;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  final RxBool isSubscribedRx = false.obs;
  bool get _showAds => !isSubscribedRx.value;

  // ── Banner ──────────────────────────────────────────────
  Future<BannerAd?> loadBannerAd() async {
    if (!_showAds) return null;
    final completer = Completer<BannerAd?>();
    _bannerAd = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => completer.complete(_bannerAd),
        onAdFailedToLoad: (_, error) {
          debugPrint('Banner failed: ${error.message}');
          completer.complete(null);
        },
      ),
    )..load();
    return completer.future;
  }

  // ── Interstitial ────────────────────────────────────────
  Future<void> loadInterstitial() async {
    if (!_showAds) return;
    await InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) =>
            debugPrint('Interstitial failed: ${error.message}'),
      ),
    );
  }

  Future<void> showInterstitial({VoidCallback? onDismissed}) async {
    if (!_showAds || _interstitialAd == null) {
      onDismissed?.call();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
        loadInterstitial(); // preload next
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
      },
    );
    await _interstitialAd!.show();
  }

  // ── Rewarded ────────────────────────────────────────────
  Future<void> loadRewarded() async {
    await RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) =>
            debugPrint('Rewarded failed: ${error.message}'),
      ),
    );
  }

  Future<bool> showRewarded() async {
    if (_rewardedAd == null) return false;
    final completer = Completer<bool>();
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
      },
    );
    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) => completer.complete(true),
    );
    // Complete with false if dismissed without reward
    if (!completer.isCompleted) completer.complete(false);
    return completer.future;
  }

  void switchProvider(AdProvider provider) {
    if (_provider == provider) return;
    _provider = provider;
    _bannerAd?.dispose();
    _bannerAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
```

### Banner Widget
```dart
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final ad = await getIt<AdManager>().loadBannerAd();
    if (mounted) setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        key: ValueKey(_ad),
        height: _ad!.size.height.toDouble(),
        width: _ad!.size.width.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
```

---

## In-App Purchases (Subscriptions + Consumables)

```yaml
dependencies:
  in_app_purchase: ^3.1.13
  # or revenue_cat for easier management:
  purchases_flutter: ^6.15.0
```

### RevenueCat (Recommended for Production)
```dart
@lazySingleton
class IAPService {
  Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
      PurchasesConfiguration(AppConfig.revenueCatApiKey)
        ..appUserID = null // Use anonymous ID or your own
    );
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      throw IAPException(e.message ?? 'Failed to load offerings');
    }
  }

  Future<CustomerInfo> purchase(Package package) async {
    try {
      return await Purchases.purchasePackage(package);
    } on PlatformException catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError.index.toString()) {
        throw IAPCancelledException();
      }
      throw IAPException(e.message ?? 'Purchase failed');
    }
  }

  Future<CustomerInfo> restorePurchases() =>
      Purchases.restorePurchases();

  Future<bool> get isSubscribed async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.isNotEmpty;
  }

  Stream<CustomerInfo> get customerInfoStream =>
      Purchases.customerInfoStream;
}
```

### Subscription UI Pattern
```dart
class PremiumScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return offeringsAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (offerings) {
        final current = offerings.current;
        if (current == null) return const NoOffersView();

        return Column(
          children: [
            ...current.availablePackages.map((pkg) =>
              PlanTile(
                package: pkg,
                onTap: () => ref.read(iapNotifierProvider.notifier).purchase(pkg),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

---

## Ad Unit ID Config Pattern

```dart
// core/config/app_config.dart
// Pass via --dart-define at build time
class AppConfig {
  // AdMob
  static const admobBannerId = String.fromEnvironment('ADMOB_BANNER_ID');
  static const admobInterstitialId = String.fromEnvironment('ADMOB_INTERSTITIAL_ID');
  static const admobRewardedId = String.fromEnvironment('ADMOB_REWARDED_ID');

  // Yandex
  static const yandexBannerId = String.fromEnvironment('YANDEX_BANNER_ID');
  static const yandexInterstitialId = String.fromEnvironment('YANDEX_INTERSTITIAL_ID');
  static const yandexRewardedId = String.fromEnvironment('YANDEX_REWARDED_ID');

  // RevenueCat
  static const revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');
}
```

---

## Subscription Polling (Background Check)

```dart
// In main.dart — poll for subscription cancellations during active sessions
Timer.periodic(const Duration(seconds: 60), (_) async {
  final iapService = getIt<IAPService>();
  final isSubscribed = await iapService.isSubscribed;
  getIt<AdManager>().isSubscribedRx.value = isSubscribed;
});
```

---

## GDPR / Consent (Required for AdMob in EU)

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> initializeAds() async {
  final params = ConsentRequestParameters();
  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
      }
      // Only initialize ads after consent
      await MobileAds.instance.initialize();
    },
    (error) => debugPrint('Consent error: ${error.message}'),
  );
}
```
