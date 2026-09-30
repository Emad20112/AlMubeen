# Code Quality, Linting, Formatting & Package Management

## Analysis Options

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/generated/**"
  errors:
    missing_required_param: error
    missing_return: error
    dead_code: warning

linter:
  rules:
    # Style
    - always_declare_return_types
    - avoid_print               # use logger
    - avoid_empty_else
    - avoid_unnecessary_containers
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    - prefer_single_quotes
    - unnecessary_const
    - unnecessary_new
    - sized_box_for_whitespace
    - use_key_in_widget_constructors

    # Safety
    - always_require_non_null_named_parameters
    - cancel_subscriptions
    - close_sinks
    - unawaited_futures

    # Performance
    - avoid_function_literals_in_foreach_calls
    - prefer_collection_literals
```

---

## Recommended Production Packages

### Core
| Package | Version | Use |
|---------|---------|-----|
| `get_it` | ^7.6.7 | Service locator / DI |
| `injectable` | ^2.3.2 | Code-gen DI annotations |
| `dartz` | ^0.10.1 | Functional Either/Option |
| `freezed` | ^2.4.7 | Immutable models |
| `json_serializable` | ^6.7.1 | JSON code gen |

### State Management
| Package | Use |
|---------|-----|
| `flutter_riverpod` + `riverpod_annotation` | Riverpod |
| `get` | GetX |
| `flutter_bloc` | BLoC |
| `provider` | Provider |

### Networking
| Package | Use |
|---------|-----|
| `dio` | HTTP client |
| `connectivity_plus` | Network status |
| `pretty_dio_logger` | Debug logging |

### Storage
| Package | Use |
|---------|-----|
| `flutter_secure_storage` | Sensitive data |
| `hive_flutter` | Fast local cache |
| `sqflite` | Relational local DB |
| `shared_preferences` | Simple key-value |

### UI
| Package | Use |
|---------|-----|
| `cached_network_image` | Image caching |
| `flutter_svg` | SVG assets |
| `shimmer` | Loading skeletons |
| `flutter_screenutil` | Responsive sizes |
| `google_fonts` | Custom typography |
| `lottie` | JSON animations |

### Navigation
| Package | Use |
|---------|-----|
| `go_router` | Declarative routing |

### Firebase
| Package | Use |
|---------|-----|
| `firebase_core` | Init |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `firebase_storage` | File storage |
| `firebase_messaging` | Push notifications |
| `firebase_crashlytics` | Crash reporting |
| `firebase_analytics` | Analytics |

### Ads & Monetization
| Package | Use |
|---------|-----|
| `google_mobile_ads` | AdMob |
| `purchases_flutter` | RevenueCat IAP |

### Testing
| Package | Use |
|---------|-----|
| `mocktail` | Mocking |
| `bloc_test` | BLoC testing |
| `integration_test` | E2E tests |
| `golden_toolkit` | Screenshot tests |

### Dev Tools
| Package | Use |
|---------|-----|
| `flutter_native_splash` | Splash screen |
| `flutter_launcher_icons` | App icons |
| `envied` | Env var safety |
| `cider` | Version bumping |

---

## Formatting

```bash
# Format all dart files
dart format lib/ test/

# Check (CI-safe, fails if changes needed)
dart format --set-exit-if-changed lib/ test/

# Fix imports ordering
flutter pub run import_sorter:main
```

---

## Build Runner

```bash
# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (development)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean && \
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## pubspec.yaml Best Practices

```yaml
# Pin major versions, allow patches
dependencies:
  flutter:
    sdk: flutter

  # ✅ Good — constrained range
  dio: ^5.4.3        # allows 5.4.x, 5.5.x, etc.
  get: ">=4.6.6 <5.0.0"

  # ❌ Avoid — any version
  dio: any

  # ❌ Avoid — exact pin (makes upgrades hard)
  dio: 5.4.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  freezed: ^2.4.7
  injectable_generator: ^2.4.1
  flutter_lints: ^4.0.0
```

---

## Git Hooks (Pre-commit Quality Gate)

```bash
# .git/hooks/pre-commit
#!/bin/sh
echo "Running Flutter pre-commit checks..."

dart format --set-exit-if-changed lib/ test/
if [ $? -ne 0 ]; then
  echo "❌ Format check failed. Run: dart format lib/ test/"
  exit 1
fi

flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Analysis failed."
  exit 1
fi

flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed."
  exit 1
fi

echo "✅ All checks passed!"
```

Make executable: `chmod +x .git/hooks/pre-commit`
