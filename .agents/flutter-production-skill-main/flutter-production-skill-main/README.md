# Flutter Production Skill — 2026 Edition

The most complete Flutter production skill for Claude AI. 45 reference files covering every aspect of building, shipping, and maintaining real-world Flutter apps.

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Claude Skill](https://img.shields.io/badge/Claude-Skill-D97706?style=flat-square)](https://claude.ai)
[![License](https://img.shields.io/badge/License-MIT-22C55E?style=flat-square)](LICENSE)
[![Release](https://img.shields.io/github/v/release/AbdulManan-official/flutter-production-skill?style=flat-square&color=6366f1)](https://github.com/AbdulManan-official/flutter-production-skill/releases/latest)

Built by [Abdul Manan](https://github.com/AbdulManan-official) — Flutter Developer

---

## Download

**[→ Download flutter-production.skill (v1.0.1)](https://github.com/AbdulManan-official/flutter-production-skill/releases/latest/download/flutter-production.skill)**

Or go to [All Releases](https://github.com/AbdulManan-official/flutter-production-skill/releases) to download a specific version.

---

## Install

1. Download `flutter-production.skill` from the link above
2. Open [claude.ai](https://claude.ai) → Settings → Skills → Upload Skill
3. Done — every Flutter question now gets production-grade answers

> Requires Claude.ai (any plan) · Flutter 3.16+ · Dart 3.0+

---

## What This Skill Does

Claude reads the relevant reference file(s) automatically before answering your Flutter question — enforcing production patterns, 2026-compliant APIs, and smooth animations in every response.

| Without this skill | With this skill |
|---|---|
| Generic widget examples | Clean Architecture with proper DI |
| Missing error handling | `Either<Failure, T>` on every async call |
| Deprecated APIs | Auto-corrected to 2026 equivalents |
| No animations | `FadeSlideRoute`, staggered lists, tap feedback |
| Insecure storage | `flutter_secure_storage` + SSL pinning |
| No performance patterns | `const`, `RepaintBoundary`, `CachedNetworkImage` everywhere |

---

## Example Prompts

```
"Show me a production GetX controller for VPN connection with error handling"
"Set up Riverpod with Clean Architecture for a server list screen"
"How do I implement SSL pinning with Dio in Flutter?"
"Create a full Firebase Auth service with Google Sign-In and token refresh"
"Set up GitHub Actions CI for Flutter with Play Store deployment"
"Build an encrypted Hive service for storing user session data"
"Set up Dart 3 sealed classes for auth states"
"Create a paywall screen with RevenueCat in Flutter"
"Build a skeleton loading screen without any shimmer package"
"How do I fix ANR errors in my Flutter VPN app?"
```

---

## Deprecated APIs — Auto-Corrected in Every Response

| Deprecated | 2026 Replacement |
|---|---|
| `.withOpacity(x)` | `.withValues(alpha: x)` |
| `surfaceVariant` | `surfaceContainerHighest` |
| `background` color role | `surface` |
| `onBackground` color role | `onSurface` |
| `CardTheme(...)` | `CardThemeData(...)` |
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

## 45 Topics Covered

### Architecture
- Clean Architecture, MVVM, MVC, Repository Pattern, Use Cases, DI — `architecture.md`
- DTO↔Entity Mappers, UseCase Base Classes, Result/Either — `architecture_advanced.md`
- Modularization, Melos Monorepo, Internal Packages — `modularization.md`

### State Management
- GetX (Rx, Workers, Bindings), Riverpod (AsyncNotifier, StreamNotifier), BLoC (Sealed Events, Freezed States), Provider — `state.md`

### UI / UX
- Responsive Design, Light/Dark Theming, Custom Widgets, Animations, Page Transitions — `ui.md`
- Skeleton Loading, Empty States, Error UX, Paywall Strategies — `ux_states.md`
- Custom Painter — Arc Gauges, Line Charts, Dashed Borders — `custom_painter.md`
- Accessibility — Semantics, Contrast, Screen Readers, Reduced Motion — `accessibility.md`
- Onboarding, Feature Discovery, What's New Dialog — `onboarding.md`

### Navigation
- GoRouter, GetX Routing, Deep Links, Bottom Nav State — `navigation.md`
- App Links, Universal Links, Branch.io, Dynamic Links — `deeplinks.md`

### Networking
- Dio Production Setup, Retry, Error Handling, JSON Serialization — `networking.md`
- Request Cancellation, Rate Limiting, API Versioning — `networking_advanced.md`
- HTTP Response Caching, Stale-While-Revalidate — `http_caching.md`

### Backend Integration
- Firebase (Firestore, Storage, Batch), Supabase (Auth, Realtime, RPC) — `backend.md`
- Email/Google/Phone Auth, FCM Push, WebSockets — `auth_notifications.md`
- MQTT, Socket.IO, SignalR, Raw WebSocket with Heartbeat & Reconnect — `realtime_protocols.md`

### Storage & Data
- SharedPreferences, Hive, SQLite, Cache-First Strategy, Offline Support — `storage.md`
- Encrypted Hive, AES-256-at-Rest, SQLCipher, Key Rotation — `encrypted_storage.md`
- Offline-First Sync, Conflict Resolution, SQLite DB Migrations — `data_sync.md`

### Security
- Obfuscation, flutter_secure_storage, SSL Pinning, API Key Protection, Root Detection — `security.md`
- Biometric Auth — Fingerprint, Face ID, Auto-Lock — `biometric.md`

### Performance
- const, ListView.builder, RepaintBoundary, compute(), Image Caching — `performance.md`
- Isolates, DevTools Profiling, List Virtualization, Pagination — `performance_advanced.md`

### Monetization
- AdMob + Yandex Unified Manager, Banner/Interstitial/Rewarded, GDPR — `monetization.md`
- Stripe PaymentSheet, Google Pay, Apple Pay, PayPal — `payments.md`

### Notifications
- Local Notifications Setup, Daily/Weekly Scheduled, In-App Banner — `local_notifications.md`
- Action Buttons, Background FCM Isolate, Notification Grouping — `notifications_advanced.md`

### Localization
- ARB Files, 10 Languages, RTL Support, Locale Persistence — `localization.md`

### Testing
- Unit Tests (mocktail, BLoC test, Riverpod container), Widget, Golden, Integration — `testing.md`

### CI/CD & Deployment
- GitHub Actions (test → build Android → build iOS → deploy), App Signing, ProGuard — `cicd.md`
- Fastlane, Flavor Builds, Store Automation — `cicd_advanced.md`

### Analytics & Observability
- Structured Logger, Firebase Crashlytics, Firebase Analytics, Screen Tracking — `observability.md`
- Remote Config, Feature Flags, A/B Testing, Funnel Tracking — `analytics_advanced.md`
- Sentry, Datadog — Non-Firebase Crash Reporting, RUM — `crash_reporting_advanced.md`

### Device & Platform
- Camera, GPS, Platform Channels (Flutter↔Kotlin), WorkManager, Background Services — `device.md`
- App Lifecycle, Privacy Overlay, Wakelock, Battery State, Network Reaction — `lifecycle.md`

### Configuration & Flavors
- dev/staging/prod AppConfig, Firebase per Flavor, VS Code Launch Configs — `flavors.md`
- Force Update Gate, In-App Update (Play Store API), Remote Config Versioning — `force_update.md`

### Code Quality
- analysis_options.yaml, Flutter Lints, Formatting, Build Runner — `quality.md`
- Strict Analysis, Custom Lint Rules, dart_code_metrics, Naming Conventions — `quality_advanced.md`

### More
- Error Boundary, FeedbackService (Snackbars/Dialogs/Loading Overlay) — `error_feedback.md`
- File Sharing, PDF Generation, Excel Export — `file_sharing.md`
- App Size Analysis, Startup Optimization, ASO, In-App Review — `store_readiness.md`
- Records, Pattern Matching, Sealed Classes, Switch Expressions — `dart3.md`

---

## Core Principles

Every response enforces these rules without exception:

1. **2026 API compliance** — All deprecated APIs auto-replaced. Every response compiles against Flutter stable 2026.
2. **Architecture first** — Layer boundaries are strict. UI never touches business logic.
3. **Smooth animations** — Every interactive element has tactile feedback. Lists stagger. Screens use `FadeSlideRoute`. Default curve: `Curves.easeOutCubic`.
4. **Crash-safe async** — `mounted`/`isClosed` on every `await`. `onError` on every stream. `Either<Failure, T>` on every repository call.
5. **State management consistency** — GetX for VPN/utility apps, Riverpod for new projects, BLoC for enterprise.
6. **Null safety** — Fully null-safe code. `required`, `?`, `??` used appropriately.
7. **No magic strings** — Constants, enums, and generated code everywhere.
8. **Separation of concerns** — UI renders. Controllers hold state. Repositories fetch. Services handle platform logic.
9. **Security by default** — No secrets in code. `flutter_secure_storage`. SSL pinning on prod.
10. **Performance by default** — `const` everywhere. `ListView.builder` always. `RepaintBoundary` around animations.
11. **Testability** — All dependencies injected. Services never instantiated inside widgets.

---

## Quick Decision Guide

**Which architecture?**
- Complex app, team, multiple data sources → Clean Architecture
- Medium app, solo dev → MVVM
- Large multi-feature app → Feature-first + Clean *(recommended)*

**Which state management?**
- New project, testability matters → Riverpod
- VPN / utility / solo app → GetX
- Enterprise, strict event flow → BLoC
- Simple / legacy migration → Provider

---

## Folder Structure

```
lib/
├── core/
│   ├── constants/         # AppColors, AppSizes, AppStrings, AppRoutes
│   ├── errors/            # Failures (sealed), Exceptions
│   ├── network/           # DioClient, NetworkInfo, Interceptors
│   ├── services/          # SecureStorageService, AnalyticsService, FeedbackService
│   ├── theme/             # AppTheme, AppColors
│   ├── utils/             # Extensions, Helpers, Validators, Responsive
│   ├── widgets/           # Pressable, SkeletonBox, AppButton, StaggeredAnimationList
│   └── di/                # Dependency injection
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           ├── controllers/
│           └── bindings/
├── l10n/
├── generated/
└── main.dart
```

---

## Repository Structure

```
flutter-production-skill/
├── README.md
├── flutter-production.skill     ← Download & install in Claude
├── SKILL.md                     ← Master routing table
└── references/                  ← 45 reference files
    ├── architecture.md
    ├── state.md
    ├── ui.md
    ├── networking.md
    ├── security.md
    ├── testing.md
    ├── performance.md
    └── ...
```

---

## Contributing

Found a gap or outdated pattern? Open a PR.

- Add a new reference file or improve an existing one
- Code must be null-safe and 2026-compliant
- Production patterns only — no toy examples

---

## License

MIT © [Abdul Manan](https://github.com/AbdulManan-official)
