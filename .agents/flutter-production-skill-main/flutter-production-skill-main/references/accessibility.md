# Accessibility — Semantics, Screen Readers, Contrast & Large Text

## Semantics

```dart
// Add semantics to custom widgets
Semantics(
  label: 'Connect to VPN',
  hint: 'Double tap to connect',
  button: true,
  enabled: !isConnected,
  child: GestureDetector(
    onTap: onConnect,
    child: ConnectOrb(),
  ),
)

// Exclude decorative elements from screen readers
Semantics(
  excludeSemantics: true,
  child: DecorativeBackground(),
)

// Merge semantics for grouped info
MergeSemantics(
  child: Row(children: [
    CountryFlag(country),
    const SizedBox(width: 8),
    Text(country.name),    // screen reader reads both together
    const Spacer(),
    Text('${country.ping}ms'),
  ]),
)

// Custom semantic value (e.g. for toggles)
Semantics(
  label: 'Dark mode',
  value: isDark ? 'enabled' : 'disabled',
  toggled: isDark,
  onTap: toggleTheme,
  child: Switch(value: isDark, onChanged: (_) => toggleTheme()),
)
```

---

## Accessible Custom Widgets

```dart
// Always provide tooltip for icon-only buttons
IconButton(
  icon: const Icon(Icons.wifi),
  tooltip: 'Connect to VPN',  // ← required for accessibility
  onPressed: onConnect,
)

// Image descriptions
Image.asset(
  'assets/server_map.png',
  semanticLabel: 'World map showing VPN server locations',
)

// Progress indicators
Semantics(
  label: 'Connection progress',
  value: '${(progress * 100).round()}%',
  child: LinearProgressIndicator(value: progress),
)

// List items with full context
ListView.builder(
  itemBuilder: (context, i) {
    final server = servers[i];
    return Semantics(
      label: '${server.country} server, ping ${server.ping} milliseconds'
             '${server.isPremium ? ", premium only" : ""}',
      button: true,
      child: ServerTile(server: server),
    );
  },
)
```

---

## Color Contrast

```dart
// WCAG AA requires 4.5:1 for normal text, 3:1 for large text
// WCAG AAA requires 7:1 for normal text

// Check contrast in your theme:
// ✅ Use colorScheme — Material 3 guarantees accessible contrast
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6C63FF),
    brightness: Brightness.light,
  ),
)

// ✅ Use onPrimary/onSurface for text on colored backgrounds
Container(
  color: colorScheme.primary,
  child: Text('Connect', style: TextStyle(color: colorScheme.onPrimary)),
)

// ❌ Never use low-contrast combos:
// white text on yellow, grey text on white, etc.

// Utility to check contrast ratio at runtime (debug only)
double contrastRatio(Color foreground, Color background) {
  final fLum = foreground.computeLuminance();
  final bLum = background.computeLuminance();
  final lighter = math.max(fLum, bLum);
  final darker = math.min(fLum, bLum);
  return (lighter + 0.05) / (darker + 0.05);
}
```

---

## Large Text & Dynamic Type Support

```dart
// ✅ Always use theme text styles — they scale with system font size
Text('Connect', style: Theme.of(context).textTheme.headlineMedium)

// ✅ Use textScaler-aware layouts
LayoutBuilder(
  builder: (context, constraints) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final isLargeText = textScale > 1.3;
    return isLargeText
        ? Column(children: [label, value])  // vertical for large text
        : Row(children: [label, value]);    // horizontal for normal
  },
)

// ✅ Set maxLines + overflow for text that might wrap
Text(
  server.country,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  style: Theme.of(context).textTheme.bodyLarge,
)

// ❌ Never use fixed font sizes without theme:
// const Text('Connect', style: TextStyle(fontSize: 16)) — won't scale
```

---

## Focus & Keyboard Navigation

```dart
// Correct focus order for forms
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(children: [
    FocusTraversalOrder(
      order: const NumericFocusOrder(1),
      child: AppTextField(label: 'Email', controller: emailCtrl),
    ),
    FocusTraversalOrder(
      order: const NumericFocusOrder(2),
      child: AppTextField(label: 'Password', controller: passCtrl),
    ),
    FocusTraversalOrder(
      order: const NumericFocusOrder(3),
      child: AppButton(label: 'Login', onTap: onLogin),
    ),
  ]),
)

// Handle Enter key submission
TextField(
  textInputAction: TextInputAction.next,   // moves focus forward
  onSubmitted: (_) => FocusScope.of(context).nextFocus(),
)

TextField(
  textInputAction: TextInputAction.done,   // triggers submit
  onSubmitted: (_) => onLogin(),
)
```

---

## Screen Reader Testing

```dart
// Enable in debug mode to test semantics tree
MaterialApp(
  showSemanticsDebugger: kDebugMode && _showA11yDebugger,
)

// Add this to debug overlay button:
FloatingActionButton(
  onPressed: () => setState(() => _showA11yDebugger = !_showA11yDebugger),
  child: const Icon(Icons.accessibility_new),
)
```

---

## Reduced Motion

```dart
// Respect user's "reduce motion" setting
class AccessibleAnimation extends StatelessWidget {
  final Widget animated;
  final Widget reduced;

  const AccessibleAnimation({
    required this.animated,
    required this.reduced,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return reduceMotion ? reduced : animated;
  }
}

// Usage:
AccessibleAnimation(
  animated: PulseAnimation(child: ConnectButton()),
  reduced: ConnectButton(), // static version
)
```

---

## Accessibility Checklist

- [ ] All interactive widgets have `tooltip` or `Semantics(label:)`
- [ ] Images have `semanticLabel` (or `excludeSemantics: true` if decorative)
- [ ] Color contrast ≥ 4.5:1 for body text, ≥ 3:1 for large text
- [ ] App usable with system font size at 200%
- [ ] Text uses `Theme.of(context).textTheme` (never fixed `fontSize`)
- [ ] Form fields have correct `textInputAction` and focus order
- [ ] No information conveyed by color alone (use icons + color)
- [ ] Animations respect `MediaQuery.disableAnimations`
- [ ] Tested with TalkBack (Android) and VoiceOver (iOS)
- [ ] Minimum tap target size 48×48dp
