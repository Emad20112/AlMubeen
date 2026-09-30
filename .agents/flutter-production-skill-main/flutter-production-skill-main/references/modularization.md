# Modularization — Internal Packages & Melos Monorepo

## Why Modularize?

- **Build speed** — only rebuild changed packages
- **Reuse** — share code across multiple apps (VPN Max, Turbo VPN, etc.)
- **Encapsulation** — enforce layer boundaries at compile time
- **Team scale** — teams own packages independently

---

## Internal Package Structure

```
your_workspace/
├── apps/
│   ├── turbo_vpn/          ← your main app
│   └── vpn_max/            ← second app reusing packages
├── packages/
│   ├── core/               ← shared utilities, constants, base classes
│   ├── ui_kit/             ← shared design system (widgets, theme, tokens)
│   ├── network/            ← Dio setup, interceptors, error handling
│   ├── auth/               ← authentication feature package
│   ├── vpn_engine/         ← VPN connection logic
│   └── monetization/       ← ads, IAP, RevenueCat
└── melos.yaml
```

---

## Creating an Internal Package

```bash
# Create a new package
flutter create --template=package packages/ui_kit

# Package structure
packages/ui_kit/
├── lib/
│   ├── src/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── theme/
│   │   └── typography/
│   └── ui_kit.dart          ← public barrel export
├── test/
└── pubspec.yaml
```

```yaml
# packages/ui_kit/pubspec.yaml
name: ui_kit
version: 1.0.0
description: Shared UI components

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

```dart
// packages/ui_kit/lib/ui_kit.dart
library ui_kit;

export 'src/buttons/app_button.dart';
export 'src/buttons/icon_button.dart';
export 'src/cards/server_card.dart';
export 'src/theme/app_theme.dart';
export 'src/theme/app_colors.dart';
export 'src/typography/text_styles.dart';
export 'src/widgets/shimmer_box.dart';
export 'src/widgets/empty_state.dart';
```

```yaml
# apps/turbo_vpn/pubspec.yaml
dependencies:
  ui_kit:
    path: ../../packages/ui_kit
  network:
    path: ../../packages/network
  monetization:
    path: ../../packages/monetization
```

---

## Melos Setup

```bash
dart pub global activate melos
```

```yaml
# melos.yaml (workspace root)
name: your_workspace

packages:
  - apps/**
  - packages/**

command:
  bootstrap:
    usePubspecOverrides: true   # local path overrides

scripts:
  # Run tests across all packages
  test:
    run: flutter test
    packageFilters:
      dirExists: test
    exec:
      concurrency: 4

  # Analyze all packages
  analyze:
    run: flutter analyze
    exec:
      concurrency: 4

  # Format all packages
  format:
    run: dart format .
    exec:
      concurrency: 6

  # Build runner in packages that need it
  codegen:
    run: flutter pub run build_runner build --delete-conflicting-outputs
    packageFilters:
      dependsOn: build_runner

  # Get dependencies everywhere
  get:
    run: flutter pub get

  # Clean everything
  clean:
    run: flutter clean

  # Run specific app
  run:dev:
    run: flutter run --flavor dev -t lib/main_dev.dart
    packageFilters:
      scope: turbo_vpn
```

```bash
# Bootstrap (links all packages)
melos bootstrap

# Run all tests across workspace
melos test

# Run specific script
melos analyze
melos codegen

# Run in specific package only
melos run test --scope=ui_kit
melos run analyze --scope=network
```

---

## Package Visibility Rules

```dart
// ✅ Public API — visible to consumers
// packages/network/lib/network.dart
export 'src/dio_client.dart';
export 'src/network_info.dart';
export 'src/interceptors/auth_interceptor.dart';
// Do NOT export internal implementation details

// ❌ Internal only — NOT exported
// packages/network/lib/src/interceptors/_token_cache.dart
// Underscore prefix = private by convention
```

---

## Feature Package Template

```
packages/auth/
├── lib/
│   ├── src/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   ├── mappers/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/    ← abstract
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── controllers/
│   └── auth.dart                ← public barrel
├── test/
│   ├── unit/
│   └── widget/
└── pubspec.yaml
```

---

## Custom Lint Rules

```yaml
# packages/custom_lints/pubspec.yaml
name: custom_lints
dependencies:
  custom_lint_builder: ^0.6.4
```

```dart
// packages/custom_lints/lib/custom_lints.dart
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _CustomLintPlugin();

class _CustomLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    NoPrintRule(),
    UseConstConstructorRule(),
    NoHardcodedStringsRule(),
  ];
}

// Example: forbid print() in production code
class NoPrintRule extends DartLintRule {
  const NoPrintRule() : super(code: const LintCode(
    name: 'no_print',
    problemMessage: 'Avoid using print(). Use the AppLogger service instead.',
  ));

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter,
      CustomLintContext context) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'print') {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
```

```yaml
# In app's analysis_options.yaml
analyzer:
  plugins:
    - custom_lints
```

---

## Code Metrics

```yaml
dev_dependencies:
  dart_code_metrics: ^5.7.6
```

```yaml
# analysis_options.yaml
dart_code_metrics:
  metrics:
    cyclomatic-complexity: 10    # max complexity per function
    maximum-nesting-level: 5     # max nesting depth
    number-of-parameters: 5      # max params per function
    source-lines-of-code: 50     # max lines per function
  metrics-exclude:
    - test/**
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  rules:
    - avoid-late-keyword
    - avoid-non-null-assertion
    - prefer-trailing-comma
    - prefer-correct-type-name
```

```bash
# Run metrics report
dart run dart_code_metrics:metrics analyze lib --reporter=html
# Opens HTML report with hotspots
```
