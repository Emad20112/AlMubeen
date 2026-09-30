# Localization — ARB Files, Multi-language, RTL Support

## Setup

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true
```

```yaml
# l10n.yaml (project root)
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

---

## ARB File Structure

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",

  "appName": "Turbo VPN",
  "@appName": { "description": "Application name" },

  "connect": "Connect",
  "@connect": { "description": "Connect button label" },

  "disconnect": "Disconnect",
  "connecting": "Connecting...",
  "connected": "Connected",

  "connectedTo": "Connected to {location}",
  "@connectedTo": {
    "description": "Status text when connected",
    "placeholders": {
      "location": { "type": "String", "example": "United States" }
    }
  },

  "sessionDuration": "Session: {duration}",
  "@sessionDuration": {
    "placeholders": {
      "duration": { "type": "String" }
    }
  },

  "serversCount": "{count, plural, =0{No servers} =1{1 server} other{{count} servers}}",
  "@serversCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

```json
// lib/l10n/app_ar.arb (Arabic — RTL)
{
  "@@locale": "ar",
  "connect": "اتصال",
  "disconnect": "قطع الاتصال",
  "connectedTo": "متصل بـ {location}",
  "sessionDuration": "الجلسة: {duration}"
}
```

---

## Supported Locales Setup

```dart
// main.dart
MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('pt'), // Portuguese
    Locale('ar'), // Arabic (RTL)
    Locale('hi'), // Hindi
    Locale('ru'), // Russian
    Locale('tr'), // Turkish
    Locale('nl'), // Dutch
  ],
  locale: ref.watch(localeProvider), // from SharedPreferences
)
```

---

## Usage in Code

```dart
// In widgets
final l10n = AppLocalizations.of(context);
Text(l10n.connect)
Text(l10n.connectedTo('United States'))
Text(l10n.serversCount(42))

// Extension for convenience
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// Usage with extension:
Text(context.l10n.connect)
```

---

## RTL Support

### Automatic RTL (Flutter handles most cases)
Flutter automatically mirrors layouts for RTL locales. Ensure:
- Use `start`/`end` instead of `left`/`right`
- Use `EdgeInsetsDirectional` instead of `EdgeInsets`
- Use `Directionality` widget when needed

```dart
// ✅ RTL-safe
Padding(
  padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
)
Row(
  textDirection: Directionality.of(context),
  children: [...]
)

// ❌ Not RTL-safe
Padding(padding: const EdgeInsets.only(left: 16, right: 8))
```

### Detect RTL in code
```dart
final isRtl = Directionality.of(context) == TextDirection.rtl;

// Conditional layout
isRtl
  ? const Row(children: [icon, SizedBox(width: 8), label])
  : const Row(children: [label, SizedBox(width: 8), icon])

// Or use Directionality-aware widgets
Row(
  children: [
    if (!isRtl) leadingIcon,
    label,
    if (isRtl) leadingIcon,
  ],
)
```

### RTL Text Alignment
```dart
Text(
  content,
  textAlign: isRtl ? TextAlign.right : TextAlign.left,
  // Or let Flutter handle it:
  textAlign: TextAlign.start, // ✅ automatically correct
)
```

---

## Locale Persistence

```dart
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _key = 'locale';

  @override
  Locale build() {
    final saved = ref.read(sharedPrefsProvider).getString(_key);
    return saved != null ? Locale(saved) : const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    await ref.read(sharedPrefsProvider).setString(_key, locale.languageCode);
    state = locale;
  }
}
```

---

## Language Picker Widget

```dart
class LanguagePicker extends ConsumerWidget {
  static const _languages = {
    'en': '🇬🇧 English',
    'es': '🇪🇸 Español',
    'fr': '🇫🇷 Français',
    'de': '🇩🇪 Deutsch',
    'pt': '🇧🇷 Português',
    'ar': '🇸🇦 العربية',
    'hi': '🇮🇳 हिंदी',
    'ru': '🇷🇺 Русский',
    'tr': '🇹🇷 Türkçe',
    'nl': '🇳🇱 Nederlands',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);

    return DropdownButton<String>(
      value: currentLocale.languageCode,
      items: _languages.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (code) {
        if (code != null) {
          ref.read(localeNotifierProvider.notifier).setLocale(Locale(code));
        }
      },
    );
  }
}
```

---

## Generate Translations
```bash
flutter gen-l10n
# or auto-generated during build:
flutter pub run build_runner build
```
