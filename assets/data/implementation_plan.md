# 🔬 تحليل عميق لمشروع المبين — المشاكل والحلول

> هذا التحليل يغطي: الأداء، الكود النظيف، التقنيات الضعيفة، البيانات المتكررة، الأخطاء المعمارية، والاستخدامات الخاطئة.

---

## 📑 فهرس المشاكل

| # | الفئة | الخطورة | الملف الرئيسي |
|---|-------|---------|---------------|
| 1 | 🔴 ملف Providers عملاق (1313 سطر) | حرجة | `quran_providers.dart` |
| 2 | 🔴 استخدام `HttpClient` خام مباشرة | حرجة | `quran_providers.dart` |
| 3 | 🔴 Global mutable cache خارج Riverpod | حرجة | `quran_providers.dart` |
| 4 | 🟠 تكرار `pubspec.yaml` dependencies | متوسطة | `pubspec.yaml` |
| 5 | 🟠 استخدام Riverpod `legacy.dart` | متوسطة | `quran_providers.dart` |
| 6 | 🟠 `SizedBox` بدلاً من `Gap` (39+ ملف) | متوسطة | مشروع كامل |
| 7 | 🟠 `MediaQuery.of()` بدلاً من الأصناف المتخصصة | متوسطة | 5 ملفات |
| 8 | 🟠 نظام `AppConfig` مع `Platform.environment` | متوسطة | `app_config.dart` |
| 9 | 🟠 `ConnectivityService` لا يتحقق من الإنترنت الفعلي | متوسطة | `connectivity_service.dart` |
| 10 | 🟡 `LayoutBuilder` داخل `PageView` | أداء | `quran_page_reader.dart` |
| 11 | 🟡 عدم وجود `RepaintBoundary` على عناصر متحركة | أداء | ملفات متعددة |
| 12 | 🟡 Warm-up متسلسل بدلاً من متوازي | أداء | `app_bootstrap.dart` |
| 13 | 🟡 `AudioPlayer` مزدوج | هدر موارد | `audio_player_service.dart` + `quran_audio_controller.dart` |
| 14 | 🟡 `Theme.of(context)` متكرر في `build()` | أداء | مشروع كامل |
| 15 | 🟡 `dynamic` type منتشر | كود نظيف | 19 ملف |
| 16 | 🔵 عدم وجود ProviderScope overrides للاختبار | معمارية | `app_database_provider.dart` |
| 17 | 🔵 Schema migration غير آمنة | استقرار | `app_database.dart` |
| 18 | 🔵 عدم وجود `GoRouter` redirect/guards | أمان | `app_router.dart` |
| 19 | 🔵 `AppTheme` لا يحدد `fontFamily` | تصميم | `app_theme.dart` |
| 20 | 🔵 `shared_preferences` في pubspec لكن لا يُستخدم | تنظيف | `pubspec.yaml` |

---

## 🔴 المشاكل الحرجة

### 1. ملف `quran_providers.dart` العملاق (God File — 1313 سطر)

**الملف:** [`quran_providers.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/data/quran_providers.dart)

**المشكلة:**
- ملف واحد يحتوي على **+50 provider و +25 helper function** و LRU Cache و network calls و merge logic.
- يخالف مبدأ Single Responsibility بشكل صارخ.
- أي تعديل بسيط يجبرك على قراءة 1300+ سطر.
- يجعل code review وdebugging شبه مستحيل.

**البيانات التي تُقرأ كل مرة:**
- كل `FutureProvider` بدون `.autoDispose` يبقى حيًا طوال عمر التطبيق.
- `islamicAppRecitationsProvider` يجري **HTTP call لـ `api.islamic.app`** كل مرة يُعاد بناؤه (وهو `FutureProvider` بدون autoDispose، لذا يظل مؤقتاً ثم يعيد الجلب عند invalidation).

**الحل:**
```
lib/features/quran/data/
├── providers/
│   ├── quran_data_providers.dart       # Repository + DataSource providers فقط
│   ├── quran_recitation_providers.dart  # كل ما يخص القراء
│   ├── quran_tafsir_providers.dart      # providers التفسير + cache + merge
│   ├── quran_translation_providers.dart # providers الترجمة + cache + merge
│   ├── quran_search_providers.dart      # providers البحث
│   └── quran_bookmark_providers.dart    # providers الإشارات المرجعية
├── cache/
│   └── chapter_lru_cache.dart           # LRU Cache class مستقل
└── helpers/
    ├── reciter_normalizer.dart          # _normalizeReciterName + _assignCategory
    └── resource_merger.dart             # _mergeTafsirs + _mergeTranslations
```

---

### 2. استخدام `HttpClient` الخام مباشرة داخل Provider

**الملف:** [`quran_providers.dart` سطر 253](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/data/quran_providers.dart#L248-L306)

**المشكلة:**
```dart
// ❌ داخل FutureProvider مباشرة!
final client = HttpClient();
try {
  final request = await client.getUrl(Uri.parse('https://api.islamic.app/v1/audio/reciters'));
  // ...
} finally {
  client.close(force: true);
}
```

- **Network call مباشر** داخل Provider بدلاً من Repository/DataSource pattern.
- إنشاء `HttpClient` جديد كل مرة (مكلف — يفتح socket pool جديد).
- لا يوجد timeout، لا retry، لا cancellation.
- يكسر طبقة Clean Architecture: الـ data layer يجب أن تمر عبر API Client.

**الحل:**
```dart
// ✅ نقل الاستدعاء إلى IslamicAppRemoteDataSource
class IslamicAppRemoteDataSource {
  IslamicAppRemoteDataSource({required HttpQuranComApiClient apiClient});

  Future<List<QuranRecitation>> fetchReciters() async {
    // اسخدام apiClient الموجود بدلاً من HttpClient خام
    // مع timeout + retry + error handling
  }
}
```

---

### 3. Global Mutable Cache خارج Riverpod

**الملف:** [`quran_providers.dart` سطر 77-82](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/data/quran_providers.dart#L77-L82)

**المشكلة:**
```dart
// ❌ متغيرات عامة قابلة للتعديل — غير آمنة للاختبار وتسرب الذاكرة
final _tafsirChapterMemoryCache = _ChapterLruCache<List<TafsirText>>(maxEntries: 24);
final _translationChapterMemoryCache = _ChapterLruCache<List<TranslationText>>(maxEntries: 24);
```

- هذه caches تعيش طوال عمر العملية (process lifetime) — لا يمكن تنظيفها.
- غير قابلة للاختبار: لا يمكنك override أو reset أو inject mock.
- إذا أعيد تشغيل `ProviderScope`، تبقى البيانات القديمة.

**الحل:**
```dart
// ✅ تحويلها إلى Provider مع ref.onDispose
final tafsirChapterCacheProvider = Provider<ChapterLruCache<List<TafsirText>>>((ref) {
  final cache = ChapterLruCache<List<TafsirText>>(maxEntries: 24);
  ref.onDispose(cache.clear);
  return cache;
});
```

---

## 🟠 مشاكل متوسطة الخطورة

### 4. تكرار في `pubspec.yaml`

**الملف:** [`pubspec.yaml`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/pubspec.yaml)

**المشكلة:**
```yaml
dev_dependencies:
  build_runner: ^2.15.1    # سطر 67
  drift_dev: ^2.34.0       # سطر 68
  # ...
  drift_dev: ^2.33.0       # سطر 90 — مكرر بإصدار مختلف!
  build_runner: ^2.15.0    # سطر 91 — مكرر بإصدار مختلف!
```

- `drift_dev` و `build_runner` مُعرّفان مرتين بإصدارات مختلفة.
- Dart pub يأخذ التعريف الأخير فقط، مما يعني أنك تستخدم `^2.33.0` بدلاً من `^2.34.0`.

**الحل:** احذف التكرار (السطور 90-91) واحتفظ بالإصدارات الأحدث فقط.

---

### 5. استخدام Riverpod `legacy.dart`

**الملف:** [`quran_providers.dart` سطر 29](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/data/quran_providers.dart#L29)

**المشكلة:**
```dart
import 'package:flutter_riverpod/legacy.dart'; // ❌ deprecated!
```

- هذا import يستخدم لـ `StateProvider` القديم الذي تم تصنيفه كـ deprecated.
- في Riverpod 3.x الحديث، يجب استخدام `NotifierProvider` بدلاً منه.

**المواقع المتأثرة:**
```dart
final selectedQuranRecitationProvider = StateProvider<QuranRecitation?>((ref) => null); // سطر 353
final selectedTranslationProvider = StateProvider<int?>((ref) => null);                // سطر 732
final selectedTafsirProvider = StateProvider<int>((ref) => defaultTafsirResourceId);   // سطر 873
```

**الحل:**
```dart
// ✅ استبدال StateProvider بـ simple Notifier
class SelectedRecitationController extends Notifier<QuranRecitation?> {
  @override
  QuranRecitation? build() => null;

  void select(QuranRecitation? recitation) => state = recitation;
}

final selectedRecitationProvider = NotifierProvider<SelectedRecitationController, QuranRecitation?>(
  SelectedRecitationController.new,
);
```

---

### 6. `SizedBox` بدلاً من `Gap` — 39+ ملف

**الانتشار:** `SizedBox(height: X)` مستخدم في **39 ملف على الأقل** بدلاً من `Gap(X)`.

> **ملاحظة:** القاعدة في AGENTS.md تنص صراحةً على: "**NEVER** use `SizedBox(height: X)` for spacing. **ALWAYS** use `Gap(X)`."

**المشكلة:**
- `SizedBox` لا يتكيف تلقائيًا مع المحور الرئيسي (`Column` vs `Row`).
- `Gap` أخف وزنًا — لا ينشئ RenderBox، بل يحسب المسافة فقط.

**الحل:**
1. أضف `gap: ^3.0.1` إلى `pubspec.yaml`.
2. استبدل جميع `SizedBox(height: X)` و `SizedBox(width: X)` داخل `Column`/`Row` بـ `Gap(X)`.

---

### 7. `MediaQuery.of(context)` — إعادة بناء كاملة

**المشكلة:**
```dart
// ❌ يُسبب إعادة بناء عند أي تغيير في MediaQuery (لوحة مفاتيح، دوران، إلخ)
final mediaQuery = MediaQuery.of(context);
final dialogWidth = MediaQuery.of(context).size.width * 0.92;
kQuranReaderIconNavBarHeight + MediaQuery.of(context).padding.bottom;
```

**الملفات المتأثرة:** [`al_mubeen_app.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/app/al_mubeen_app.dart#L26), [`quran_page_reader.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/presentation/pages/quran_page_reader.dart#L574), [`wird_dialog.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/presentation/widgets/wird_dialog.dart#L249)

**الحل:**
```dart
// ✅ استخدام الأصناف المتخصصة — تُعيد البناء فقط عند تغيير القيمة المحددة
final size = MediaQuery.sizeOf(context);        // بدلاً من MediaQuery.of(context).size
final padding = MediaQuery.paddingOf(context);  // بدلاً من MediaQuery.of(context).padding
final textScaler = MediaQuery.textScalerOf(context);
```

---

### 8. `AppConfig` يستخدم `Platform.environment` على الموبايل

**الملف:** [`app_config.dart` سطر 53](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/core/config/app_config.dart#L46-L58)

**المشكلة:**
```dart
final fromSystem = Platform.environment[key]?.trim(); // ❌ لا يعمل على Android/iOS
```

- `Platform.environment` فارغ دائمًا على Android و iOS.
- هذا كود ميت يضيف تعقيدًا بدون فائدة.

**الحل:** احذف `Platform.environment` fallback وابقِ على `dotenv` فقط.

---

### 9. `ConnectivityService` لا يتحقق من الإنترنت الفعلي

**الملف:** [`connectivity_service.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/core/network/connectivity_service.dart)

**المشكلة:**
- `connectivity_plus` يتحقق فقط من وجود **اتصال شبكة** (WiFi/Mobile Data)، لكن **لا يتحقق من الوصول الفعلي للإنترنت**.
- يمكن أن يكون الجهاز متصلاً بـ WiFi بدون إنترنت فعلي → التطبيق يظن أنه online.

**الحل:**
```dart
Future<bool> checkConnection() async {
  final results = await _connectivity.checkConnectivity();
  final hasNetwork = results.any((r) => r != ConnectivityResult.none);
  if (!hasNetwork) return false;

  // ✅ تحقق فعلي من الإنترنت
  try {
    final result = await InternetAddress.lookup('example.com')
        .timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  } on TimeoutException catch (_) {
    return false;
  }
}
```

---

## 🟡 مشاكل الأداء

### 10. `LayoutBuilder` داخل `PageView.builder` — حساب مكلف كل إطار

**الملف:** [`quran_page_reader.dart` سطر 225](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/presentation/pages/quran_page_reader.dart#L225-L377)

**المشكلة:**
```dart
return LayoutBuilder(  // ❌ يُعاد حسابه مع كل scroll frame!
  builder: (context, constraints) {
    final availableHeight = constraints.maxHeight;
    // ... حسابات معقدة لحجم الخط ...
    return PageView.builder(  // PageView داخل LayoutBuilder!
```

- `LayoutBuilder` يُعاد حسابه مع كل إطار أثناء التمرير.
- حسابات `fontSize` و `verseHeight` تُنفذ **604 مرة × 60 FPS**.

**الحل:**
```dart
@override
Widget build(BuildContext context) {
  // ✅ حساب الأبعاد مرة واحدة فقط
  final screenSize = MediaQuery.sizeOf(context);
  final availableHeight = screenSize.height - MediaQuery.paddingOf(context).vertical;
  final fontSize = _calculateFontSize(availableHeight, fontScale);

  return PageView.builder(  // PageView مباشرة بدون LayoutBuilder
    // ...
  );
}
```

---

### 11. Warm-up متسلسل بدلاً من متوازي

**الملف:** [`app_bootstrap.dart` سطر 121-138](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/app/bootstrap/app_bootstrap.dart#L121-L138)

**المشكلة:**
```dart
// ❌ متسلسل — كل واحد ينتظر الذي قبله
await _warmUpReciters();      // ~200ms
await _warmUpNamesOfAllah();  // ~150ms
await _warmUpHadithNawawi();  // ~100ms
// المجموع: ~450ms
```

**الحل:**
```dart
// ✅ متوازي — الثلاثة يبدأون معًا
await Future.wait([
  _warmUpReciters(),
  _warmUpNamesOfAllah(),
  _warmUpHadithNawawi(),
]);
// المجموع: ~200ms (أطول واحد فقط)
```

---

### 12. `AudioPlayer` مُنشأ مرتين — هدر موارد النظام

**الملفات:**
- [`audio_player_service.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/core/audio/audio_player_service.dart) — يُنشئ `AudioPlayer()` في الـ constructor
- [`quran_audio_controller.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/application/quran_audio_controller.dart#L99) — يُنشئ `AudioPlayer()` آخر في `build()`
- [`quran_surah_player_controller.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/application/quran_surah_player_controller.dart#L146) — يُنشئ `AudioPlayer()` ثالث

**المشكلة:**
- `AudioPlayerService` موجود كـ wrapper لكن **لا يُستخدم** من قبل الـ controllers الفعلية!
- كل controller يُنشئ `AudioPlayer` خاص به مباشرة.
- 3 instances من `AudioPlayer` تعني 3 audio sessions + 3 socket pools.
- `AudioPlayerService` كود ميت (dead code).

**الحل:**
- إما **احذف `AudioPlayerService`** لأنه لا يُستخدم.
- أو **وحّد** كل الـ controllers لتستخدمه بدلاً من إنشاء `AudioPlayer` مباشرة.

---

### 13. `Theme.of(context)` متكرر في `build()`

**المشكلة:** في عدة شاشات يُستدعى `Theme.of(context).brightness` عدة مرات:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

**الحل:** هذا ليس حرجاً لأن Flutter يخزن مرجعياً (O(1) lookup)، لكن الأفضل تخزينه في متغير واحد في أعلى `build()`.

---

## 🔵 مشاكل معمارية ومشاكل إضافية مُكتشفة

### 14. `pubspec.yaml` يحتوي `shared_preferences` غير مُستخدم

**الملف:** [`pubspec.yaml` سطر 51](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/pubspec.yaml#L51)

```yaml
shared_preferences: ^2.2.2  # ❌ موجود لكن التطبيق يستخدم JSON file store
```

**المشكلة:** التطبيق يستخدم `AppUserPreferencesStore` (ملف JSON) لتخزين الإعدادات، فـ `shared_preferences` dependency ميتة تزيد حجم APK بلا فائدة.

**الحل:** احذفها من `pubspec.yaml` إذا لم تُستخدم في أي مكان.

---

### 15. `audio_service` في pubspec لكن لا يُستخدم

**الملف:** [`pubspec.yaml` سطر 32](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/pubspec.yaml#L32)

```yaml
audio_service: ^0.18.18  # ❌ موجود لكن لا يوجد BackgroundAudioHandler
```

**المشكلة:**
- `audio_service` يُستخدم لتشغيل الصوت في الخلفية مع إشعارات (notification controls).
- لا يوجد في الكود أي `AudioHandler` أو `AudioService.init()`.
- هذا يعني أن التلاوة **تتوقف عند قفل الشاشة** أو الخروج من التطبيق.

> [!IMPORTANT]
> هذه مشكلة كبيرة لتطبيق قرآن! المستخدم يتوقع أن يستمر القارئ بالتلاوة حتى بعد قفل الشاشة.

**الحل:**
```dart
// ✅ إنشاء AudioHandler متكامل
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  // ربط just_audio بـ audio_service
  // عرض إشعار مع أزرار التحكم
  // دعم التشغيل في الخلفية
}

// في main.dart:
await AudioService.init(
  builder: () => QuranAudioHandler(),
  config: const AudioServiceConfig(
    androidNotificationChannelId: 'com.almubeen.audio',
    androidNotificationChannelName: 'تلاوة القرآن',
    androidNotificationOngoing: true,
  ),
);
```

---

### 16. Schema Migration غير آمنة

**الملف:** [`app_database.dart` سطر 403-546](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/core/database/app_database.dart#L403-L546)

**المشكلة:**
```dart
// ❌ Migration 8 و 9 تستخدم customStatement مع CREATE TABLE IF NOT EXISTS
await (migrator.database as AppDatabase).customStatement('''
  CREATE TABLE IF NOT EXISTS downloaded_tafsirs (...)
''');
```

- خلط بين `migrator.createTable` (Drift-managed) و `customStatement` (raw SQL).
- `IF NOT EXISTS` يُخفي الأخطاء — لو فشل الـ migration سابقاً، لن يُعاد.
- **Schema version 11 مفقود!** (`from < 11` غير موجود) — القفز من 10 إلى 12.
- `from < 13` يحاول `addColumn` لأعمدة قد تكون موجودة فعلاً (migration 7 أنشأت الجدول).

**الحل:**
- استخدام Drift's migration testing tools (`package:drift_dev/api/migrations.dart`).
- إصلاح الفجوة في schema version 11.
- استخدام `migrator.createTable` دائمًا بدلاً من raw SQL.

---

### 17. `GoRouter` بدون redirect/guards

**الملف:** [`app_router.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/app/routing/app_router.dart)

**المشكلة:**
```dart
final appRouter = GoRouter(routes: [...]); // ❌ لا يوجد redirect أو guard
```

- لا يوجد guard يمنع الوصول للشاشات قبل إكمال onboarding.
- لا يوجد `refreshListenable` لربط الـ router بحالة التفضيلات.
- الـ router هو `final` عام (global) بدلاً من Provider.

**الحل:**
```dart
// ✅ Router كـ Provider مع redirect logic
final appRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(appUserPreferencesProvider);
  return GoRouter(
    redirect: (context, state) {
      final hasCompletedWelcome = prefs.valueOrNull?.hasCompletedWelcome ?? false;
      if (!hasCompletedWelcome && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [/* ... */],
  );
});
```

---

### 18. `AppTheme` لا يحدد `fontFamily`

**الملف:** [`app_theme.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/app/theme/app_theme.dart)

**المشكلة:**
```dart
textTheme: Typography.blackMountainView.apply(  // ❌ خط Roboto الافتراضي
  bodyColor: AppColors.ink,
);
```

- تطبيق عربي 100% يستخدم خط `Roboto` الافتراضي.
- `Typography.blackMountainView` مصمم للنصوص اللاتينية.

**الحل:**
```dart
// ✅ استخدام خط عربي مناسب (مثل Amiri, Noto Naskh Arabic, Cairo)
textTheme: Typography.blackMountainView.apply(
  bodyColor: AppColors.ink,
  fontFamily: 'Amiri', // أو أي خط عربي مضاف في assets
),
```

---

### 19. `NamesOfAllahLocalDataSource` — تخزين مؤقت غير ضروري على القرص

**الملف:** [`names_of_allah_local_data_source.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/names_of_allah/data/names_of_allah_local_data_source.dart)

**المشكلة:**
- البيانات الأصلية موجودة كـ **asset مضمن** (25KB فقط).
- الكود يقرأ الـ asset → يحلله بـ Isolate → يكتبه في ملف cache → يقرأه من cache في المرة التالية.
- **لماذا نكتب cache لبيانات ثابتة لا تتغير أبداً؟**

**الحل:**
```dart
// ✅ تبسيط: قراءة الـ asset مرة واحدة + تخزين في الذاكرة فقط
Future<List<AllahNameEntry>> _loadEntries() async {
  final jsonString = await rootBundle.loadString(_assetPath);
  return await Isolate.run(() => _parseAllahNamesAsset(jsonString))
      .then((raw) => raw.map(AllahNameEntry.fromJson).toList()
        ..sort((a, b) => a.id.compareTo(b.id)));
}
// لا حاجة لـ _writeCache أو _readCachedEntries — الـ asset ثابت!
```

---

### 20. `DefaultTafsirSeedService` — Completer Pattern غير ضروري

**الملف:** [`default_tafsir_seed_service.dart`](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/application/default_tafsir_seed_service.dart#L32-L70)

**المشكلة:**
```dart
final completer = Completer<void>();
_runningFuture = completer.future;

() async {
  try {
    // ... work ...
    completer.complete();
  } catch (error, stackTrace) {
    completer.complete(); // ❌ يبتلع الخطأ بصمت!
  } finally {
    _runningFuture = null;
  }
}();
```

- Pattern معقد بلا داعي — يمكن تبسيطه بـ `async` عادي.
- الـ `catch` يستدعي `completer.complete()` بدلاً من `completeError()` — أي أن أي خطأ يُبتلع بصمت.

**الحل:**
```dart
Future<void> ensureSeeded() {
  return _runningFuture ??= _doSeed().whenComplete(() => _runningFuture = null);
}

Future<void> _doSeed() async {
  // ... work directly with async/await ...
}
```

---

## 📊 ملخص البيانات والمهام التي تُنفذ عند كل تشغيل

| المهمة | التوقيت | التكلفة | ملاحظة |
|--------|---------|---------|--------|
| قراءة `app.env` + dotenv parse | `main()` | ~10ms | ✅ مقبول |
| قراءة JSON preferences من القرص | `AppBootstrap.build()` | ~20ms | ✅ مقبول |
| QCF Font warm-up (getPageData, metadata) | `addPostFrameCallback` | ~50ms | ✅ مقبول |
| إنشاء `QcfPage(1)` خفي (probe) | أثناء التحميل | ~100ms | ⚠️ مكلف لكن مبرر |
| `QuranDownloadRecoveryService` | بعد 2 ثانية | ~30ms | ✅ مؤجل جيداً |
| `DefaultTafsirSeedService` (3MB JSON → SQLite) | بعد recovery | ~500-2000ms ❗ | 🔴 **أول تشغيل فقط** لكن يجمد الخيط الرئيسي |
| `_warmUpReciters()` — HTTP + DB query | `Priority.idle` | ~200ms | ⚠️ يجري HTTP call |
| `_warmUpNamesOfAllah()` — asset + isolate + disk cache | `Priority.idle` | ~150ms | ⚠️ كتابة قرص غير ضرورية |
| `_warmUpHadithNawawi()` — asset + isolate | `Priority.idle` | ~100ms | ✅ مقبول |
| `islamicAppRecitationsProvider` — raw HttpClient | عند أول watch | ~300ms+ | 🔴 HTTP خام بدون timeout |

---

## 🎯 خطة العمل المقترحة (مرتبة حسب الأولوية)

### المرحلة 1: إصلاحات حرجة (أسبوع 1)
1. [ ] تفكيك `quran_providers.dart` إلى 6+ ملفات
2. [ ] نقل `HttpClient` الخام إلى DataSource مناسب
3. [ ] تحويل Global caches إلى Providers
4. [ ] إصلاح تكرار `pubspec.yaml`
5. [ ] حذف `shared_preferences` و `audio_service` إذا لم تُستخدم — أو تفعيل `audio_service`

### المرحلة 2: تحسينات الأداء (أسبوع 2)
6. [ ] إزالة `LayoutBuilder` من داخل `PageView`
7. [ ] تحويل Warm-ups إلى `Future.wait` متوازي
8. [ ] استبدال `MediaQuery.of()` بالأصناف المتخصصة
9. [ ] حذف `AudioPlayerService` (كود ميت) أو توحيده
10. [ ] تبسيط `NamesOfAllahLocalDataSource` (إزالة disk cache)

### المرحلة 3: كود نظيف ومعمارية (أسبوع 3)
11. [ ] استبدال `StateProvider` بـ `NotifierProvider`
12. [ ] إضافة `Gap` واستبدال `SizedBox` spacing
13. [ ] إصلاح schema migration gaps
14. [ ] إضافة GoRouter guards
15. [ ] تحديد خط عربي مناسب في `AppTheme`

---

## Open Questions

> [!IMPORTANT]
> **سؤال 1:** هل تريد أن أبدأ بتنفيذ المرحلة 1 (الإصلاحات الحرجة) أم تريد التركيز على مشاكل محددة أولاً؟

> [!IMPORTANT]
> **سؤال 2:** بخصوص `audio_service` — هل التطبيق يحتاج فعلاً لتشغيل التلاوة في الخلفية (عند قفل الشاشة)؟ إذا نعم، فهذا يتطلب إعداد `AudioHandler` كامل.

> [!IMPORTANT]
> **سؤال 3:** هل يوجد خط عربي مُفضل تريد استخدامه في التطبيق (مثل Amiri, Cairo, Noto Naskh Arabic)؟
