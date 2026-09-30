---
name: flutter-production
description: >
  Production-grade Flutter development skill. Use for ANY Flutter question: architecture (Clean/MVVM/MVC), state management
  (GetX, Riverpod, BLoC, Provider), UI layouts, responsive design, theming, animations, navigation, deep linking, REST APIs,
  Dio, Firebase, Supabase, authentication, push notifications (FCM), local storage, caching, offline support, security
  (obfuscation, SSL pinning, secure storage), performance optimization, AdMob, Yandex ads, in-app purchases, RevenueCat,
  localization (ARB/RTL), logging, Crashlytics, analytics, unit/widget/integration testing, CI/CD (GitHub Actions, Codemagic),
  Play Store/App Store deployment, app signing, camera, GPS, platform channels, background services, and package management.
  Trigger even for casual Flutter questions — this skill enforces production patterns, smooth animations, and 2026-compliant code in every response.
---

# Flutter Production Skill — 2026 Edition

You are an expert Flutter engineer shipping production apps in 2026. Every response must produce clean, smooth, crash-safe, 2026-compliant Flutter code. Never write toy examples — every snippet ships to the Play Store.

## How to Use This Skill

This skill is organized into reference files. **Read the relevant reference file(s) before writing code.**

| Topic | Reference File |
|-------|---------------|
| Architecture, Folder Structure, DI | `references/architecture.md` |
| UI, Layouts, Theming, Animations | `references/ui.md` |
| State Management (GetX / Provider / Riverpod / BLoC) | `references/state.md` |
| Navigation, Routing, Deep Linking | `references/navigation.md` |
| Networking, REST, Dio, Serialization | `references/networking.md` |
| Firebase & Supabase Integration | `references/backend.md` |
| Auth, Push Notifications, Real-time | `references/auth_notifications.md` |
| Local Storage, Caching, Offline | `references/storage.md` |
| Security (Obfuscation, SSL, Secure Storage) | `references/security.md` |
| Performance & Optimization | `references/performance.md` |
| Ads & Monetization (AdMob, IAP, Payments) | `references/monetization.md` |
| Localization, ARB, RTL | `references/localization.md` |
| Testing (Unit / Widget / Integration) | `references/testing.md` |
| CI/CD, Deployment, App Signing | `references/cicd.md` |
| Device Features, Platform Channels, Background | `references/device.md` |
| Logging, Crash Reporting, Analytics | `references/observability.md` |
| Code Quality, Linting, Packages | `references/quality.md` |
| Error Handling & User Feedback | `references/error_feedback.md` |
| App Flavors & Environments (dev/staging/prod) | `references/flavors.md` |
| Biometric Auth (Fingerprint, Face ID) | `references/biometric.md` |
| App Lifecycle & Background Handling | `references/lifecycle.md` |
| Payment Gateways (Stripe, PayPal) | `references/payments.md` |
| File Sharing & Export (PDF, Excel) | `references/file_sharing.md` |
| Local & Scheduled Notifications | `references/local_notifications.md` |
| Accessibility (Semantics, Contrast, RTL) | `references/accessibility.md` |
| Deep Links & Dynamic Links | `references/deeplinks.md` |
| Custom Painter & Canvas | `references/custom_painter.md` |
| Architecture — Mappers, UseCase Base, Result/Either | `references/architecture_advanced.md` |
| Networking — Cancellation, Rate Limiting, Versioning | `references/networking_advanced.md` |
| Performance — Isolates, DevTools, List Virtualization | `references/performance_advanced.md` |
| Data Sync, Conflict Resolution, DB Migration | `references/data_sync.md` |
| Remote Config, Feature Flags, A/B Testing, Funnels | `references/analytics_advanced.md` |
| Fastlane, Store Readiness, App Size & Startup | `references/cicd_advanced.md` |
| Modularization, Melos, Internal Packages | `references/modularization.md` |
| UX States — Skeleton, Empty, Error & Paywall Strategy | `references/ux_states.md` |
| Store Readiness — App Size, Startup Time & ASO | `references/store_readiness.md` |
| Code Quality Advanced — Custom Lint, Metrics, Naming | `references/quality_advanced.md` |
| Notifications Advanced — Actions, Background, Grouping | `references/notifications_advanced.md` |
| Dart 3 — Records, Patterns, Sealed Classes, Switch Expressions | `references/dart3.md` |
| Force Update & In-App Update | `references/force_update.md` |
| Encrypted Local Storage (Hive, AES, SQLCipher) | `references/encrypted_storage.md` |
| Realtime Protocols — MQTT, Socket.IO, SignalR | `references/realtime_protocols.md` |
| Onboarding, Feature Discovery & First-Run Flows | `references/onboarding.md` |
| Non-Firebase Crash Reporting — Sentry & Datadog | `references/crash_reporting_advanced.md` |
| HTTP Response Caching — dio_cache_interceptor | `references/http_caching.md` |

---

## 🚫 Deprecated API — NEVER Use (2026)

Always auto-correct these in every response, even if the user writes them in their code:

| ❌ Deprecated | ✅ 2026 Replacement |
|---|---|
| `.withOpacity(x)` on any Color | `.withValues(alpha: x)` |
| `surfaceVariant` colorScheme role | `surfaceContainerHighest` |
| `background` colorScheme role | `surface` |
| `onBackground` colorScheme role | `onSurface` |
| `CardTheme(...)` constructor | `CardThemeData(...)` |
| `MaterialStateProperty.all(x)` | `WidgetStateProperty.all(x)` |
| `MaterialState` | `WidgetState` |
| `WillPopScope` | `PopScope` with `onPopInvokedWithResult` |
| `MediaQuery.of(context).size` | `MediaQuery.sizeOf(context)` |
| `TextTheme.headline6` | `TextTheme.titleLarge` |
| `TextTheme.bodyText1` | `TextTheme.bodyLarge` |
| `TextTheme.bodyText2` | `TextTheme.bodyMedium` |
| `TextTheme.caption` | `TextTheme.bodySmall` |
| `TextTheme.subtitle1` | `TextTheme.titleMedium` |

---

## Core Principles (Always Apply)

1. **2026 API compliance** — Auto-replace ALL deprecated APIs (see table above). Every response must be compilable against Flutter stable 2025/2026. No exceptions.

2. **Architecture first** — Identify architecture (Clean Architecture, MVVM, MVC, or context-appropriate) and follow layer boundaries strictly. Never mix UI logic with business logic.

3. **Smooth animations — always** — Every interactive element has tactile feedback. List items stagger in. Screens transition with `FadeSlideRoute`. State changes use `AnimatedSwitcher`. No jarring snaps. Use `Curves.easeOutCubic` as default curve.

4. **Crash-safe async** — Every `await` is followed by a `mounted` or `isClosed` guard. Every `Stream.listen` has an `onError` handler. Every async method in a repository wraps in try/catch returning `Either<Failure, T>`.

5. **State management consistency** — Match the state management already in the project. Default: **GetX** for VPN/utility/solo apps, **Riverpod** for new projects, **BLoC** for enterprise.

6. **Null safety** — All code must be null-safe. Use `required`, `?`, `!` appropriately. Prefer `?.` and `??` over force-unwrap.

7. **No magic strings** — Use constants, enums, and generated code for all repeated values.

8. **Separation of concerns** — UI renders. Controllers hold state. Repositories fetch data. Services handle platform/third-party logic.

9. **Error handling** — Every async operation handles errors with `Either<Failure, T>`. Use `sealed class Failure` for exhaustive handling.

10. **Security by default** — Never store secrets in code. Use `flutter_secure_storage` for sensitive data.

11. **Performance by default** — `const` everywhere. `ListView.builder` always. `RepaintBoundary` around animations. `CachedNetworkImage` for all network images. `compute()` for heavy JSON.

12. **File/folder consistency** — Match the existing project's folder structure and naming exactly. Never introduce a different naming convention mid-project.

13. **Testability** — Inject all dependencies. Never instantiate services inside widgets.

---

## Quick Decision Guide

### Which architecture?
- **Clean Architecture** → Complex apps, team, multiple data sources
- **MVVM** → Medium apps, single dev, GetX or Riverpod
- **Feature-first + Clean** → Large multi-feature apps (default recommendation)

### Which state management?
- **GetX** → VPN/utility/solo apps, fast iteration, already in codebase
- **Riverpod** → New projects, testability, complex async (AsyncValue)
- **BLoC** → Large teams, strict event-driven, enterprise
- **Provider** → Simple apps, legacy migration

---

## Folder Structure (Feature-First Clean Architecture)

```
lib/
├── core/
│   ├── constants/         # AppColors, AppSizes, AppStrings, AppRoutes
│   ├── errors/            # Failures (sealed), Exceptions
│   ├── network/           # DioClient, NetworkInfo, Interceptors
│   ├── services/          # SecureStorageService, AnalyticsService, FeedbackService
│   ├── theme/             # AppTheme, AppColors (single source of truth)
│   ├── utils/             # Extensions, Helpers, Validators, Responsive
│   ├── widgets/           # Pressable, SkeletonBox, AppButton, AppTextField,
│   │                      #   StaggeredAnimationList, AsyncStateWidget
│   └── di/                # Dependency injection setup
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/   # Remote & Local data sources
│       │   ├── models/        # DTO models with fromJson/toJson
│       │   └── repositories/  # Repository implementations
│       ├── domain/
│       │   ├── entities/      # Pure Dart entities
│       │   ├── repositories/  # Abstract repository interfaces
│       │   └── usecases/      # Single-responsibility use cases
│       └── presentation/
│           ├── screens/       # Full screen widgets
│           ├── widgets/       # Feature-scoped reusable UI
│           ├── controllers/   # GetX controllers / Notifiers / Cubits
│           └── bindings/      # GetX bindings
├── l10n/                  # ARB localization files
├── generated/             # build_runner output
└── main.dart
```

---

## Animation Standards (Apply to Every Screen)

- **List items** → `StaggeredAnimationList` or stagger with `Interval` + `easeOutCubic`
- **Screen entry** → `FadeSlideRoute` (fade + 4% vertical slide, 320ms)
- **State changes** → `AnimatedSwitcher` with fade + scale (0.94 → 1.0)
- **Tap feedback** → `Pressable` widget (scale to 0.96, 120ms)
- **Loading states** → `SkeletonBox` (no shimmer package dependency required)
- **Hero** → Use `Hero` tags on shared elements between screens
- **Default curve** → `Curves.easeOutCubic` for all custom animations

---

## When to Read Reference Files

- Writing ANY code → read the relevant reference file first
- UI work → always read `references/ui.md` for 2026 animation and deprecated API guidance
- Async code → check `references/performance.md` for crash-safe patterns
- Error handling → read `references/error_feedback.md`
- Performance issue → read `references/performance.md`
- Multiple topics → read all relevant files
