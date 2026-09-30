# Code Quality Advanced — Custom Lint Rules, Strict Analysis & Code Metrics

## Strict analysis_options.yaml

```yaml
# analysis_options.yaml — production-grade strict config
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true          # no implicit dynamic casts
    strict-inference: true      # no inferred dynamic types
    strict-raw-types: true      # no raw generic types (List vs List<String>)

  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/generated/**"
    - "**/*.config.dart"

  errors:
    # Errors — fail the build
    missing_required_param: error
    missing_return: error
    dead_code: error
    invalid_annotation_target: error
    todo: info                  # TODOs show as info, not error

    # Warnings
    avoid_print: error          # no print() in production
    unawaited_futures: warning

linter:
  rules:
    # Correctness
    - always_declare_return_types
    - avoid_empty_else
    - avoid_relative_lib_imports
    - cancel_subscriptions
    - close_sinks
    - literal_only_boolean_expressions
    - no_duplicate_case_values
    - test_types_in_equals
    - throw_in_finally
    - unawaited_futures
    - unnecessary_statements
    - unrelated_type_equality_checks
    - valid_regexps

    # Style
    - always_put_required_named_parameters_first
    - avoid_bool_literals_in_conditional_expressions
    - avoid_catches_without_on_clauses
    - avoid_double_and_int_checks
    - avoid_field_initializers_in_const_classes
    - avoid_function_literals_in_foreach_calls
    - avoid_positional_boolean_parameters
    - avoid_print
    - avoid_redundant_argument_values
    - avoid_slow_async_io
    - avoid_type_to_string
    - avoid_unused_constructor_parameters
    - avoid_void_async
    - cascade_invocations
    - join_return_with_assignment
    - missing_whitespace_between_adjacent_strings
    - no_runtimeType_toString
    - noop_primitive_operations
    - only_throw_errors
    - parameter_assignments
    - prefer_asserts_with_message
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_if_null_operators
    - prefer_single_quotes
    - prefer_void_to_null
    - unnecessary_await_in_return
    - unnecessary_breaks
    - unnecessary_lambdas
    - unnecessary_null_checks
    - unnecessary_parenthesis
    - unnecessary_raw_strings
    - use_colored_box
    - use_decorated_box
    - use_enums
    - use_if_null_to_convert_nulls_to_bools
    - use_is_even_rather_than_modulo
    - use_named_constants
    - use_raw_strings
    - use_string_buffers
    - use_super_parameters           # Dart 3: super.key instead of key: key
    - use_to_and_as_if_applicable
```

---

## Custom Lint Rules (custom_lint + dart_lint)

```yaml
dev_dependencies:
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10   # if using Riverpod
```

```yaml
# analysis_options.yaml — add after include:
custom_lint:
  rules:
    - avoid_build_context_in_providers: true
    - provider_dependencies: true
```

### Write your own lint rule
```dart
// tools/lint/lib/avoid_hardcoded_colors.dart
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidHardcodedColors extends DartLintRule {
  const AvoidHardcodedColors() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_hardcoded_colors',
    problemMessage:
        'Avoid hardcoded colors. Use Theme.of(context).colorScheme instead.',
    correctionMessage: 'Replace with a colorScheme color.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType?.getDisplayString(withNullability: false);
      if (type == 'Color') {
        // Flag hardcoded Color() or Color(0xFFXXXXXX)
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}

// Register in plugin:
PluginBase createPlugin() => _LintPlugin();
class _LintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const AvoidHardcodedColors(),
  ];
}
```

---

## Code Metrics (dart_code_metrics)

```yaml
dev_dependencies:
  dart_code_metrics: ^5.7.6
```

```yaml
# analysis_options.yaml
dart_code_metrics:
  metrics:
    cyclomatic-complexity: 20       # max complexity per function
    lines-of-executable-code: 50   # max lines per method
    number-of-parameters: 7        # max params per function
    maximum-nesting-level: 5       # max if/for nesting depth
    source-lines-of-code: 100      # max lines per class
    weight-of-class: 0.33          # cohesion metric

  metrics-exclude:
    - test/**

  rules:
    - avoid-nested-conditional-expressions:
        severity: warning
    - avoid-returning-widgets:
        severity: warning
        ignored-names:
          - build
          - _buildX
    - avoid-unnecessary-setstate:
        severity: warning
    - binary-expression-operand-order:
        severity: style
    - double-literal-format:
        severity: style
    - member-ordering:
        severity: style
        order:
          - constructors
          - named-constructors
          - factory-constructors
          - public-fields
          - private-fields
          - public-getters-setters
          - private-getters-setters
          - public-methods
          - private-methods
    - no-boolean-literal-compare:
        severity: warning
    - no-empty-block:
        severity: warning
    - prefer-conditional-expressions:
        severity: style
    - prefer-first:
        severity: style
    - prefer-last:
        severity: style
```

### Run metrics report
```bash
# Terminal report
flutter pub run dart_code_metrics:metrics analyze lib

# HTML report (great for PRs)
flutter pub run dart_code_metrics:metrics analyze lib \
  --reporter=html --output-directory=reports/metrics

# Check specific metric threshold (CI gate)
flutter pub run dart_code_metrics:metrics analyze lib \
  --fatal-warnings   # fails CI if warnings found
```

---

## Enforce in CI

```yaml
# .github/workflows/quality.yml
- name: Code metrics
  run: |
    flutter pub run dart_code_metrics:metrics analyze lib \
      --reporter=github   # GitHub annotations
      --fatal-warnings

- name: Custom lint
  run: flutter pub run custom_lint

- name: Check for TODOs
  run: |
    count=$(grep -r "TODO\|FIXME\|HACK" lib/ | wc -l)
    echo "Found $count TODOs/FIXMEs"
    if [ $count -gt 20 ]; then
      echo "Too many TODOs — clean up before merging"
      exit 1
    fi
```

---

## Code Review Checklist

### Architecture
- [ ] Logic not in widgets (use controllers/notifiers/cubits)
- [ ] No `BuildContext` passed to non-UI classes
- [ ] Repository pattern followed (no direct API calls in controllers)
- [ ] Use cases are single-responsibility

### State Management
- [ ] No `setState` inside async callbacks without `mounted` check
- [ ] Streams/subscriptions disposed in `dispose()`/`onClose()`
- [ ] No unnecessary rebuilds (use `select`, `Obx` at leaf level)

### Performance
- [ ] `const` used on all static widgets
- [ ] `ListView.builder` used (never `ListView` with `.map`)
- [ ] Heavy operations use `compute()`

### Security
- [ ] No secrets/keys in source code
- [ ] Sensitive data in `flutter_secure_storage`
- [ ] No `print()` with sensitive data

### Testing
- [ ] New features have unit tests
- [ ] Complex UI has widget tests
- [ ] All tests pass

---

## Naming Conventions

```dart
// Files: snake_case
user_repository.dart
vpn_controller.dart
home_screen.dart

// Classes: PascalCase
class UserRepository {}
class VpnController {}
class HomeScreen {}

// Variables/methods: camelCase
final isConnected = false;
void connectToServer() {}

// Constants: camelCase (lowerCamel)
const maxRetryCount = 3;
const defaultTimeout = Duration(seconds: 15);

// Enums: PascalCase + values camelCase
enum VpnStatus { disconnected, connecting, connected, error }

// Private: leading underscore
final _dio = Dio();
void _handleError() {}

// Providers (Riverpod): camelCase + Provider suffix
final userProvider = ...
final vpnStatusProvider = ...

// Controllers (GetX): PascalCase + Controller suffix
class HomeController extends GetxController {}

// Screens: PascalCase + Screen suffix
class HomeScreen extends StatelessWidget {}

// Widgets: PascalCase, no suffix needed
class ServerTile extends StatelessWidget {}
class ConnectButton extends StatelessWidget {}
```
