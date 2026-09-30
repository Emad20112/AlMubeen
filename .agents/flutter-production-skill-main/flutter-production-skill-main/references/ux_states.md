# UX States — Loading, Skeleton, Empty, Error & Paywall Strategies

## The 4 States Rule

Every screen that loads data MUST handle all 4 states:
```
loading → data → empty → error
```
Never skip any. Users notice every gap.

---

## Loading State Strategy

### Rule: Match skeleton to actual layout
Never show a generic spinner for a screen with a known layout.
Show a skeleton that mirrors the real content structure.

```dart
// ✅ Content-matched skeleton
class ServerListSkeleton extends StatelessWidget {
  const ServerListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, __) => const _ServerTileSkeleton(),
    );
  }
}

class _ServerTileSkeleton extends StatelessWidget {
  const _ServerTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          // Flag placeholder
          Container(width: 32, height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 14, width: 120, color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 6)),
              Container(height: 11, width: 80, color: Colors.white),
            ],
          )),
          // Ping badge placeholder
          Container(width: 48, height: 24, color: Colors.white,
              margin: const EdgeInsets.only(right: 8)),
        ]),
      ),
    );
  }
}
```

### Shimmer for cards/profiles
```dart
class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Avatar
            const CircleAvatar(radius: 28, backgroundColor: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 13, width: 180, color: Colors.white),
                const SizedBox(height: 6),
                Container(height: 13, width: 120, color: Colors.white),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}
```

### AsyncValue unified handler (Riverpod)
```dart
extension AsyncValueUX<T> on AsyncValue<T> {
  Widget when({
    required Widget Function(T data) data,
    Widget Function()? loading,
    Widget Function(Object error, StackTrace? stack)? error,
  }) {
    return this.when(
      loading: loading ?? () => const SkeletonLoader(),
      error: error ?? (e, s) => ErrorStateWidget(
        message: _humanizeError(e),
        onRetry: null,
      ),
      data: data,
    );
  }

  String _humanizeError(Object e) {
    if (e is NetworkFailure) return 'No internet connection';
    if (e is ServerFailure) return 'Server error. Please try again';
    if (e is AuthFailure) return 'Session expired. Please login again';
    return 'Something went wrong';
  }
}
```

---

## Empty State Strategy

### Rule: Empty ≠ Error. Be helpful, not generic.

```dart
// ❌ Bad — Generic, unhelpful
const Center(child: Text('No data'))

// ✅ Good — Context-aware, actionable
EmptyStateWidget(
  icon: Icons.wifi_off_outlined,
  title: 'No servers found',
  subtitle: 'Try a different region or check your connection',
  actionLabel: 'Refresh',
  onAction: () => ref.invalidate(serversProvider),
)
```

### Context-specific empty states
```dart
class EmptyStates {
  static Widget noServers({VoidCallback? onRefresh}) => EmptyStateWidget(
    icon: Icons.dns_outlined,
    title: 'No servers available',
    subtitle: 'Pull down to refresh or try again later',
    actionLabel: 'Refresh',
    onAction: onRefresh,
  );

  static Widget noSearchResults(String query) => EmptyStateWidget(
    icon: Icons.search_off_outlined,
    title: 'No results for "$query"',
    subtitle: 'Try a different search term',
  );

  static Widget offlineMode() => EmptyStateWidget(
    icon: Icons.cloud_off_outlined,
    title: 'You\'re offline',
    subtitle: 'Connect to the internet to see servers',
    actionLabel: 'Open Settings',
    onAction: () => AppSettings.openNetworkSettings(),
  );

  static Widget notSubscribed({VoidCallback? onUpgrade}) => EmptyStateWidget(
    icon: Icons.lock_outline,
    title: 'Premium servers',
    subtitle: 'Upgrade to access 50+ premium locations',
    actionLabel: 'Upgrade to Premium',
    onAction: onUpgrade,
  );
}
```

---

## Error UX Strategy

### Rule: Give users a path forward, not just a message.

```dart
// Error hierarchy for user messaging
String userFriendlyMessage(Failure failure) => switch (failure) {
  NetworkFailure() => 'No internet. Check your connection and try again.',
  ServerFailure(message: final m) when m.contains('503') =>
      'Our servers are busy. Try again in a moment.',
  AuthFailure() => 'Your session expired. Please sign in again.',
  NotFoundFailure() => 'This item no longer exists.',
  ValidationFailure(message: final m) => m,
  _ => 'Something went wrong. We\'ve been notified.',
};

// Recovery actions per error type
Widget errorAction(Failure failure, {required VoidCallback retry}) {
  return switch (failure) {
    NetworkFailure() => OutlinedButton.icon(
        onPressed: retry,
        icon: const Icon(Icons.refresh),
        label: const Text('Try Again'),
      ),
    AuthFailure() => FilledButton(
        onPressed: () => context.go('/auth/login'),
        child: const Text('Sign In'),
      ),
    _ => OutlinedButton.icon(
        onPressed: retry,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
      ),
  };
}
```

### Inline vs Full-Screen Errors
```dart
// Inline error — for partial failures (one section fails, rest loads)
class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const InlineError({required this.message, this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 13))),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}

// Full-screen error — when the entire screen fails
class FullScreenError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const FullScreenError({required this.message, this.onRetry, super.key});

  @override
  Widget build(BuildContext context) => ErrorStateWidget(
    message: message, onRetry: onRetry,
  );
}
```

---

## Paywall UX Strategy

### High-converting paywall patterns:
```dart
class PaywallScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(offeringsProvider);

    return Scaffold(
      body: Stack(children: [
        // 1. Show what they're missing (blurred premium content behind)
        Positioned.fill(child: _BlurredPreview()),

        // 2. Value proposition — benefits, not features
        SafeArea(
          child: Column(children: [
            const _PremiumBadge(),
            const SizedBox(height: 24),
            // Benefits list — outcomes, not features
            const _BenefitTile(
              icon: Icons.speed,
              title: '3x Faster Speeds',
              subtitle: 'Premium servers with no throttling',
            ),
            const _BenefitTile(
              icon: Icons.public,
              title: '50+ Countries',
              subtitle: 'Access content from anywhere',
            ),
            const _BenefitTile(
              icon: Icons.block,
              title: 'Zero Ads',
              subtitle: 'Clean, uninterrupted experience',
            ),

            const Spacer(),

            // 3. Plan selector (annual highlighted as best value)
            offerings.when(
              loading: () => const _PlansSkeleton(),
              error: (_, __) => const SizedBox.shrink(),
              data: (o) => _PlanSelector(offerings: o),
            ),

            // 4. Primary CTA — clear, no dark patterns
            const _SubscribeButton(),

            // 5. Reassurance row
            const _ReassuranceRow(), // "Cancel anytime · Secure payment · 3-day free trial"

            // 6. Restore purchases
            TextButton(
              onPressed: () => ref.read(iapProvider.notifier).restore(),
              child: const Text('Restore Purchases'),
            ),
          ]),
        ),
      ]),
    );
  }
}

// Best value badge on annual plan
class _PlanTile extends StatelessWidget {
  final Package package;
  final bool isSelected;
  final bool isBestValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: _PlanContent(package: package, isSelected: isSelected),
        ),
        if (isBestValue)
          Positioned(
            top: -10, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('BEST VALUE',
                  style: TextStyle(color: Colors.white,
                      fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}
```

---

## Loading UX Decision Tree

```
Is the screen loading for the first time?
  YES → Show skeleton that matches layout
  NO (refresh/pull-to-refresh) → Show existing data + refresh indicator

Is a button action in progress?
  YES → Show inline CircularProgressIndicator inside button, disable button
  NO → Show normal button

Is a background operation running?
  YES → Show subtle linear progress at top (no full-screen block)
  NO → Nothing

Is data stale but available?
  YES → Show data immediately, refresh silently, show "Updated X mins ago"
  NO → Wait for fresh data with skeleton
```
