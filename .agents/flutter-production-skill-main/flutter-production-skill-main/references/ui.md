# UI, Layouts, Theming, Animations & Custom Widgets — 2026

## Deprecated API Replacements (ALWAYS Apply)

| ❌ Deprecated | ✅ 2026 Replacement |
|---|---|
| `Colors.X.withOpacity(v)` | `Colors.X.withValues(alpha: v)` |
| `Color(0xFF...).withOpacity(v)` | `Color(0xFF...).withValues(alpha: v)` |
| `surfaceVariant` | `surfaceContainerHighest` |
| `background` color role | `surface` |
| `onBackground` | `onSurface` |
| `CardTheme(...)` | `CardTheme.raw(...)` or `CardThemeData(...)` |
| `MaterialStateProperty.all(x)` | `WidgetStateProperty.all(x)` |
| `MaterialState` | `WidgetState` |
| `MaterialStateBorderSide` | `WidgetStateBorderSide` |
| `TextTheme.headline6` | `TextTheme.titleLarge` |
| `TextTheme.bodyText1` | `TextTheme.bodyLarge` |
| `TextTheme.bodyText2` | `TextTheme.bodyMedium` |
| `TextTheme.caption` | `TextTheme.bodySmall` |
| `TextTheme.subtitle1` | `TextTheme.titleMedium` |
| `WillPopScope` | `PopScope` |
| `MediaQuery.of(context).size` | `MediaQuery.sizeOf(context)` |
| `Theme.of(context).colorScheme.background` | `Theme.of(context).colorScheme.surface` |

---

## Responsive Design

```dart
// core/utils/responsive.dart
class Responsive {
  static bool isMobile(BuildContext ctx) => MediaQuery.sizeOf(ctx).width < 600;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= 600 && MediaQuery.sizeOf(ctx).width < 1200;
  static bool isDesktop(BuildContext ctx) => MediaQuery.sizeOf(ctx).width >= 1200;

  static double w(BuildContext ctx, double percent) =>
      MediaQuery.sizeOf(ctx).width * percent / 100;
  static double h(BuildContext ctx, double percent) =>
      MediaQuery.sizeOf(ctx).height * percent / 100;
}
```

---

## Theming (Material 3, 2026)

```dart
// core/theme/app_theme.dart
class AppTheme {
  static const _primary = Color(0xFF6C63FF);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _primary),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
```

---

## Smooth Animations — Production Patterns

### Staggered Entry Animations (Content appears in flow)
```dart
// core/widgets/staggered_animation.dart
class StaggeredAnimationList extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  const StaggeredAnimationList({
    required this.children,
    this.itemDelay = const Duration(milliseconds: 80),
    this.itemDuration = const Duration(milliseconds: 400),
    super.key,
  });
  @override
  State<StaggeredAnimationList> createState() => _StaggeredAnimationListState();
}

class _StaggeredAnimationListState extends State<StaggeredAnimationList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(
      milliseconds: widget.itemDuration.inMilliseconds +
          (widget.itemDelay.inMilliseconds * widget.children.length),
    ))..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (i) {
        final start = (i * widget.itemDelay.inMilliseconds) /
            _ctrl.duration!.inMilliseconds;
        final end = start +
            widget.itemDuration.inMilliseconds / _ctrl.duration!.inMilliseconds;
        final anim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start.clamp(0, 1), end.clamp(0, 1),
              curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.18), end: Offset.zero)
                .animate(anim),
            child: widget.children[i],
          ),
        );
      }),
    );
  }
}

// Usage — items fade+slide in sequentially
StaggeredAnimationList(
  children: servers.map((s) => ServerTile(server: s)).toList(),
)
```

### Pressable Scale Widget (tap feedback on ANY widget)
```dart
// core/widgets/pressable.dart
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  const Pressable({
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 120),
    super.key,
  });
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween(begin: 1.0, end: widget.scale).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
    onTapCancel: () => _ctrl.reverse(),
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}
```

### Shimmer / Skeleton Loader (2026 pattern — no deprecated colors)
```dart
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
    super.key,
  });
  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Color.lerp(
            cs.surfaceContainerHighest,
            cs.surfaceContainer,
            _anim.value,
          ),
        ),
      ),
    );
  }
}
```

### Page Transitions (smooth, 2026)
```dart
// Fade + Slide (default for most screens)
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeSlideRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                    .animate(curved),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

// Shared axis (for tab-like navigation)
class SharedAxisRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SharedAxisRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, secondaryAnim, child) {
            final curved = CurvedAnimation(parent: anim, curve: Curves.easeInOutCubic);
            return SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
```

### AnimatedSwitcher (smooth state changes)
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  switchInCurve: Curves.easeOutCubic,
  switchOutCurve: Curves.easeInCubic,
  transitionBuilder: (child, anim) => FadeTransition(
    opacity: anim,
    child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(anim), child: child),
  ),
  child: isLoading
      ? const SkeletonBox(width: double.infinity, height: 60, key: ValueKey('skeleton'))
      : ContentWidget(key: ValueKey('content')),
)
```

### Hero Animations
```dart
// Source widget
Hero(
  tag: 'server_${server.id}',
  child: ServerCard(server: server),
)

// Destination widget
Hero(
  tag: 'server_${server.id}',
  child: ServerDetailHeader(server: server),
)
// Navigator push — Hero animates automatically
```

---

## PopScope (replaces WillPopScope)
```dart
PopScope(
  canPop: !_hasUnsavedChanges,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    final confirmed = await showConfirmDialog(context);
    if (confirmed && context.mounted) Navigator.pop(context);
  },
  child: Scaffold(...),
)
```

---

## Color Usage (no withOpacity — EVER)
```dart
// ❌ DEPRECATED — never use
color: Colors.black.withOpacity(0.5)
color: primaryColor.withOpacity(0.15)

// ✅ 2026 — always use withValues
color: Colors.black.withValues(alpha: 0.5)
color: primaryColor.withValues(alpha: 0.15)

// For overlays
decoration: BoxDecoration(
  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
)
```

---

## Custom Widgets

### App Button
```dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const AppButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );
    return isOutlined
        ? OutlinedButton(onPressed: isLoading ? null : onTap, child: child)
        : ElevatedButton(onPressed: isLoading ? null : onTap, child: child);
  }
}
```

### App TextField
```dart
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;

  const AppTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    obscureText: obscureText,
    keyboardType: keyboardType,
    decoration: InputDecoration(labelText: label, suffixIcon: suffix),
  );
}
```

---

## Layout Best Practices

- Always use `const` constructors for stateless widgets
- Use `SizedBox` instead of `Container` for spacing only
- Prefer `ListView.builder` — never `ListView` with `.map`
- Use `Expanded` / `Flexible` inside `Row`/`Column`
- Extract complex subtrees into named `StatelessWidget` classes
- `RepaintBoundary` around independently animating children
- `AutomaticKeepAliveClientMixin` for `TabView`/`PageView` page state
- `itemExtent` on `ListView.builder` when item height is fixed
- Wrap list items in `RepaintBoundary` if they animate independently
