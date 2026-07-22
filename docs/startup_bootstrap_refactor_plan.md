# خطة إعادة هندسة نظام الإقلاع وزراعة التفسير الميسر

## المشكلة الحالية

عند التشغيل الأول (Clean Install)، يعاني التطبيق من تجمد (ANR/Jank) بسبب:

1. **`rootBundle.loadString('assets/data/ar_muyassar.json')`** — يحمّل 3 MB على Main Isolate
2. **حلقة 114 فصل** في `DefaultTafsirSeedService.ensureSeeded()` — تفتح 114 transaction منفصلة مع تأخير 16ms
3. **`rootBundle.loadString`** في `NamesOfAllahLocalDataSource` و `HadithNawawiLocalDataSource` — على Main Isolate أيضاً
4. **مؤقتات عشوائية** (2s, 7s, 9s, 12s) تتداخل مع تفاعل المستخدم
5. **`_QuranLaunchShell`** يبني `QuranPageReader` الثقيلة مباشرة مع حركة الانتقال

---

## الملفات المتأثرة

| # | الملف | التغيير |
|---|-------|---------|
| 1 | `lib/features/quran/data/local/tafsir_muyassar_asset_data_source.dart` | نقل `rootBundle.loadString` إلى `compute()` |
| 2 | `lib/features/quran/application/default_tafsir_seed_service.dart` | استبدال الحلقة بـ batch واحد |
| 3 | `lib/features/quran/data/local/tafsir_local_data_source.dart` | إضافة دالة `saveAllTafsirTexts` للإدخال الجماعي |
| 4 | `lib/features/names_of_allah/data/names_of_allah_local_data_source.dart` | نقل `rootBundle.loadString` إلى `compute()` |
| 5 | `lib/features/hadith_nawawi/data/hadith_nawawi_local_data_source.dart` | نقل `rootBundle.loadString` إلى `compute()` |
| 6 | `lib/app/bootstrap/app_bootstrap.dart` | استبدال المؤقتات بخط متسلسل + تأخير رسم القرآن |

---

## الخطوة 1: نقل `rootBundle.loadString` إلى Isolate المنفصل

### المشكلة
`rootBundle.loadString` يقرأ الأصل من الذاكرة المضغوطة ويفك الضغط على **Main Isolate**. مع ملف 3 MB، هذا يسبب freeze.

### الحل
دمج قراءة الأصل + التحليل في **دالة واحدة** داخل `Isolate.run()` (أو `compute()`).

---

### 1أ. `tafsir_muyassar_asset_data_source.dart`

**الحالي** (سطر 113-118):
```dart
final jsonString = await rootBundle.loadString(defaultTafsirAssetPath);
final recordsByChapter = await compute(
  _parseAndGroupMuyassarAsset,
  jsonString,
);
```

**المطلوب**:
```dart
final recordsByChapter = await Isolate.run(() {
  final jsonString = rootBundle.loadString(defaultTafsirAssetPath);
  return _parseAndGroupMuyassarAsset(jsonString);
});
```

> **ملاحظة**: `Isolate.run()` تنشئ Isolate جديدة وتقتلها بعد الانتهاء. لا يمكن استخدام `rootBundle` داخل `compute()` لأن `compute()` لا تدعم async. الحل هو استخدام `Isolate.run()` مع `compute()` internally لكن الأفضل هنا هو `Isolate.run(() async { ... })`.

**الصيغة النهائية**:
```dart
final recordsByChapter = await Isolate.run(() async {
  final jsonString = await rootBundle.loadString(defaultTafsirAssetPath);
  return _parseAndGroupMuyassarAsset(jsonString);
});
```

**تكرار التخزين المؤقت**: الـ cache (`_cachedChapterRecords`) يبقى كما هو — يتم ملؤه مرة واحدة فقط بعد أول استدعاء.

---

### 1ب. `names_of_allah_local_data_source.dart`

**الحالي** (سطر 64-65):
```dart
final jsonString = await rootBundle.loadString(_assetPath);
final rawEntries = await compute(_parseAllahNamesAsset, jsonString);
```

**المطلوب**:
```dart
final rawEntries = await Isolate.run(() async {
  final jsonString = await rootBundle.loadString(_assetPath);
  return _parseAllahNamesAsset(jsonString);
});
```

**ملاحظة إضافية**: بعد `compute`، التحويل `rawEntries.map(AllahNameEntry.fromJson)` والـ sort يقعان على Main Isolate — هذا مقبول لأن العدد 99 عنصر فقط.

---

### 1ج. `hadith_nawawi_local_data_source.dart`

**الحالي** (سطر 45-46):
```dart
final jsonString = await rootBundle.loadString(_assetPath);
final entries = await compute(_parseHadithNawawi, jsonString);
```

**المطلوب**:
```dart
final entries = await Isolate.run(() async {
  final jsonString = await rootBundle.loadString(_assetPath);
  return _parseHadithNawawi(jsonString);
});
```

---

## الخطوة 2: الإدخال الجماعي للتفسير (Single Batch Transaction)

### المشكلة
`DefaultTafsirSeedService.ensureSeeded()` يكرر على 114 فصل، لكل فصل:
- `saveTafsirTexts()` → `_database.batch()` → `INSERT OR REPLACE` (transaction واحدة)
- `Future.delayed(16ms)`
= **114 transaction** + **114 تأخير** = ~3-5 ثوانٍ

### الحل

**2أ. إضافة دالة `saveAllTafsirTexts` في `TafsirLocalDataSource`**:

```dart
Future<void> saveAllTafsirTexts({
  required int resourceId,
  required Map<int, List<TafsirText>> chapterTexts,
}) async {
  if (chapterTexts.isEmpty) return;

  final now = DateTime.now();
  await _database.batch((batch) {
    batch.insertAllOnConflictUpdate(
      _database.tafsirTextCache,
      [
        for (final entry in chapterTexts.entries)
          for (final tafsirText in entry.value)
            TafsirTextCacheCompanion(
              resourceId: Value(resourceId),
              chapterId: Value(entry.key),
              ayahNumber: Value(
                tafsirText.verseNumber ??
                    _ayahNumberFromVerseKey(tafsirText.verseKey),
              ),
              tafsirText: Value(tafsirText.text),
              resourceName: Value(tafsirText.resourceName),
              cachedAt: Value(now),
            ),
      ],
    );
  });
}
```

> **النتيجة**: ~6236 سطر في **transaction واحدة** بدلاً من 114. الوقت المتوقع: **< 200ms** بدلاً من 3-5 ثوانٍ.

---

**2ب. تعديل `DefaultTafsirSeedService.ensureSeeded()`**:

```dart
Future<void> ensureSeeded({bool lowPriority = true}) async {
  final runningFuture = _runningFuture;
  if (runningFuture != null) return runningFuture;

  final completer = Completer<void>();
  _runningFuture = completer.future;

  () async {
    try {
      final cachedChapterIds = await _localDataSource
          .getCachedTafsirChapterIds(defaultTafsirResourceId);
      if (cachedChapterIds.length < 114) {
        // تحميل وتحليل كل التفسير في Isolate واحد
        final allChapterTexts = await _assetDataSource.getAllChapterTextsMap();

        // حذف الفصول المُخزّنة مسبقاً وإدخال الباقي في batch واحد
        final chapterTextsToInsert = <int, List<TafsirText>>{};
        for (final entry in allChapterTexts.entries) {
          if (!cachedChapterIds.contains(entry.key)) {
            chapterTextsToInsert[entry.key] = entry.value;
          }
        }

        if (chapterTextsToInsert.isNotEmpty) {
          await _localDataSource.saveAllTafsirTexts(
            resourceId: defaultTafsirResourceId,
            chapterTexts: chapterTextsToInsert,
          );
        }
      }

      if (await _localDataSource.isTafsirDownloaded(defaultTafsirResourceId)) {
        await _localDataSource.saveDownloadedTafsir(defaultBuiltInTafsir);
      }

      onSeedCompleted?.call();
      completer.complete();
    } catch (error, stackTrace) {
      debugPrint('DefaultTafsirSeedService.ensureSeeded failed: $error');
      debugPrint('$stackTrace');
      completer.complete();
    } finally {
      _runningFuture = null;
    }
  }();

  return completer.future;
}
```

---

**2ج. إضافة `getAllChapterTextsMap()` في `TafsirMuyassarAssetDataSource`**:

```dart
Future<Map<int, List<TafsirText>>> getAllChapterTextsMap() async {
  final cached = _cachedChapterTexts;
  if (cached != null) return cached;

  final recordsByChapter = await _loadChapterRecordsMap();
  final chapterTexts = <int, List<TafsirText>>{};

  for (final entry in recordsByChapter.entries) {
    chapterTexts[entry.key] = _chapterTextsFromRecords(
      chapterId: entry.key,
      records: entry.value,
    );
  }

  _cachedChapterTexts = chapterTexts;
  return chapterTexts;
}
```

> **ملاحظة**: `_loadChapterRecordsMap()` سيستدعي `Isolate.run()` الآن بدلاً من `rootBundle.loadString` على Main.

---

## الخطوة 3: إعادة كتابة `_QuranLaunchShell` مع تأخير الرسم

### المشكلة
`QuranPageReader` يُبنى فوراً مع حركة `FadeTransition` (500ms)، مما يسبب اصطدام بناء واجهة ثقيلة مع رسوم الحركة.

### الحل
عرض حاوية فارغة (placeholder) أثناء الحركة، ثمحقن `QuranPageReader` بعد 150ms.

```dart
class _QuranLaunchShellState extends State<_QuranLaunchShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final int _initialPage;
  bool _renderHeavyQuran = false;

  @override
  void initState() {
    super.initState();
    _initialPage = widget.initialPage;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();

    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _renderHeavyQuran = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fade,
      child: _renderHeavyQuran
          ? QuranPageReader(initialPage: _initialPage)
          : Scaffold(
              backgroundColor: isDark
                  ? AppColors.darkScaffold
                  : AppColors.parchment,
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.maroon800),
              ),
            ),
    );
  }
}
```

> **النتيجة**: `FadeTransition` ترسم بـ 60/120 FPS بدون أي اصطدام. `QuranPageReader` لا يُبنى إلا بعد 150ms.

---

## الخطوة 4: الخط المتسلسل في `AppBootstrap`

### المشكلة
المؤقتات العشوائية (2s, 7s, 9s, 12s) تتداخل مع تفاعل المستخدم وتنافس على SQLite.

### الحل
استبدال المؤقتات بـ `async/await` متسلسل في `addPostFrameCallback`.

```dart
void _scheduleStartupTasks() {
  if (_startupScheduled) return;
  _startupScheduled = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    _runSequentialStartupPipeline();
  });
}

Future<void> _runSequentialStartupPipeline() async {
  // الخطوة أ: استرداد التنزيلات المعلقة (بعد 2 ثانية من الاستقرار)
  try {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await QuranDownloadRecoveryService(ref)
        .restorePendingDownloads(resumeDelay: const Duration(seconds: 3));
  } catch (error, stackTrace) {
    debugPrint('Startup pipeline: download recovery failed: $error');
    debugPrint('$stackTrace');
  }

  // الخطوة ب: زراعة التفسير الميسر (العملية الأثقل)
  try {
    if (!mounted) return;
    await ref.read(defaultTafsirSeedServiceProvider).ensureSeeded();
  } catch (error, stackTrace) {
    debugPrint('Startup pipeline: tafsir seed failed: $error');
    debugPrint('$stackTrace');
  }

  // الخطوة ج: تدفئة أسماء الله الحسنى
  try {
    if (!mounted) return;
    await ref.read(namesOfAllahLocalDataSourceProvider).warmUp();
  } catch (error, stackTrace) {
    debugPrint('Startup pipeline: Names of Allah warm-up failed: $error');
    debugPrint('$stackTrace');
  }

  // الخطوة د: تدفة الأربعين النووية
  try {
    if (!mounted) return;
    await ref.read(hadithNawawiLocalDataSourceProvider).warmUp();
  } catch (error, stackTrace) {
    debugPrint('Startup pipeline: Hadith Nawawi warm-up failed: $error');
    debugPrint('$stackTrace');
  }
}
```

### تغييرات حذف في `AppBootstrap`:
- حذف `_startupTimers` (قائمة Timer)
- حذف `_scheduleStartupTimer()` helper
- حذف `_scheduleDefaultTafsirSeed()`
- حذف `_schedulePendingDownloadRecovery()`
- حذف `_scheduleNamesOfAllahWarmUp()`
- حذف `_scheduleHadithNawawiWarmUp()`
- حذف `dispose()` (لم يعد هناك timers)
- حذف `_startupScheduled` guard (يُستبدل بمنطق أبسط — الدالة تسمّى مرة واحدة فقط من `addPostFrameCallback`)

---

## ملخص التغييرات المتوقعة

| الملف | قبل | بعد |
|-------|------|------|
| `tafsir_muyassar_asset_data_source.dart` | `rootBundle.loadString` على Main → `compute` | `Isolate.run(() async { rootBundle + parse })` |
| `default_tafsir_seed_service.dart` | حلقة 114 فصل + 114 transaction + 16ms delay | تحميل واحد + batch واحد |
| `tafsir_local_data_source.dart` | `saveTafsirTexts` (per chapter) | + `saveAllTafsirTexts` (all chapters, single batch) |
| `names_of_allah_local_data_source.dart` | `rootBundle.loadString` على Main → `compute` | `Isolate.run(() async { rootBundle + parse })` |
| `hadith_nawawi_local_data_source.dart` | `rootBundle.loadString` على Main → `compute` | `Isolate.run(() async { rootBundle + parse })` |
| `app_bootstrap.dart` | 4 مؤقتات عشوائية + `dispose()` | خط متسلسل `async/await` مع try-catch لكل مرحلة |
| `_QuranLaunchShell` | `QuranPageReader` مباشرة مع FadeTransition | placeholder 150ms → `QuranPageReader` |

---

## التسلسل الزمني المتوقع بعد التعديل

```
t=0.0s  AppConfig.load() + runApp()
t=0.1s  AppDatabase() + AppUserPreferences.read()
t=0.2s  عرض _InitialLoading
t=0.3s  التفضيلات جاهزة
        ├── first run → OnboardingScreen
        │   └── (خلفية) لا شيء — المستخدم يتصفح الترحيب
        └── returning → _QuranLaunchShell
            t=0.3s  placeholder (parchment + spinner)
            t=0.45s QuranPageReader يُبنى (بعد 150ms)
            t=0.5s  الصفحة جاهزة + FadeTransition

t=2.0s  [Pipeline] استرداد التنزيلات المعلقة
t=3.0s  [Pipeline] ensureSeeded:
        t=3.0s  Isolate.run: قراءة 3 MB + تحليل JSON (في Isolate منفصل)
        t=3.2s  batch: إدخال ~6236 سطر في transaction واحدة (< 200ms)
        t=3.4s  حفظ سجل التفسيرات
t=3.5s  [Pipeline] warmUp Names of Allah:
        t=3.5s  Isolate.run: قراءة + تحليل (في Isolate منفصل)
t=3.6s  [Pipeline] warmUp Hadith Nawawi:
        t=3.6s  Isolate.run: قراءة + تحليل (في Isolate منفصل)
t=3.7s  [Pipeline] مكتمل ✓
```

> **التحسن**: بدلاً من ~15 ثانية (تجمد على Main Isolve)، أصبح ~3.7 ثانية **بدون أي تجمد** لأن جميع العمليات الثقيلة في Isolates منفصلة.

---

## معايير التحقق

1. `flutter analyze` — يجب أن يُرجع 0 أخطاء
2. تشغيل أول (Clean Install) — يجب أن يظهر `OnboardingScreen` فوراً بدون تأخير
3. بعد الترحيب — يجب أن يظهر القرآن في < 1 ثانية
4. `ensureSeeded()` — يجب أن يستغرق < 500ms بدلاً من 3-5 ثوانٍ
5. لا يوجد freeze أثناء التمرير في القرآن بعد التشغيل الأول
6. جميع المهام الثقيلة تتنفذ في الخلفية دون تأثير على الـ UI
