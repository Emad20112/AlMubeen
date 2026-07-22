# تحليل عمليات التشغيل الأولي للتطبيق (App Startup Analysis)

## ملخص

التطبيق يتجمد/يعلق عند أول تشغيل بسبب تنفيذ عدة عمليات ثقيلة متتالية على الـ Main Isolate، خاصة:
1. تحميل ملف JSON ضخم (3 MB) كاملاً في الذاكرة
2. إدخال ~6236 سطر في قاعدة البيانات SQLite واحداً تلو الآخر
3. تحميل ملفات JSON إضافية وتحليلها وتخزينها محلياً

---

## تسلسل العمليات عند التشغيل

### المرحلة 0: قبل `runApp()` (الخطوة الأولى)

| # | العملية | الملف المسؤول | التفاصيل |
|---|---------|---------------|----------|
| 1 | `WidgetsFlutterBinding.ensureInitialized()` | `lib/main.dart:8` | تهيئة Flutter framework |
| 2 | تسجيل معالجات الأخطاء | `lib/main.dart:12-21` | `PlatformDispatcher.onError` و `FlutterError.onError` |
| 3 | **`AppConfig.load()`** | `lib/core/config/app_config.dart:18` | تحميل ملف `env/app.env` عبر `flutter_dotenv` + قراءة env vars |
| 4 | `runApp(ProviderScope(child: AlMubeenApp()))` | `lib/main.dart:25` | بدء التطبيق |

> **ملاحظة**: `AppConfig.load()` خفيفة عادةً لكنها `await` وتمتد على Main Isolve.

---

### المرحلة 1: بناء الشجرة الأولى (أول ثانية)

| # | العملية | الملف المسؤول | التفاصيل |
|---|---------|---------------|----------|
| 5 | **إنشاء `AppDatabase`** | `lib/core/database/app_database_provider.dart:5` | `AppDatabase()` → `driftDatabase(name: 'al_mubeen')`. يفتح/يُنشئ قاعدة SQLite تحتوي **15 جدول** مع 10 إصدارات schema. عند التشغيل الأولي: `onCreate` يستدعي `migrator.createAll()` لإنشاء كل الجداول والـ indexes |
| 6 | **قراءة `AppUserPreferences`** | `lib/core/preferences/app_user_preferences.dart:228` | `appUserPreferencesProvider` يستدعي `_store.read()` → يقرأ/يفتح ملف `app_user_preferences.json` من `getApplicationSupportDirectory()`. المجلد قد لا يكون قد أُنشئ بعد في أول تشغيل |
| 7 | عرض `_InitialLoading` | `lib/app/bootstrap/app_bootstrap.dart:39` | شاشة تحميل بسيطة (أيقونة + ProgressIndicator) تظهر أثناء انتظار تحميل التفضيلات |
| 8 | **بناء `AlMubeenApp`** | `lib/app/al_mubeen_app.dart:18` | `MaterialApp.router` مع `go_router` — بناء شجرة الـ Router |
| 9 | **عرض `_QuranLaunchShell`** | `lib/app/bootstrap/app_bootstrap.dart:54` | يلف `QuranPageReader` مع `FadeTransition` (500ms) |

---

### المرحلة 2: بناء قارئ القرآن (أول 2-3 ثوانٍ)

| # | العملية | الملف المسؤول | التفاصيل |
|---|---------|---------------|----------|
| 10 | **إنشاء `QuranPageReader`** | `lib/features/quran/presentation/pages/quran_page_reader.dart:60-91` | إنشاء `PageController`، `QuranHighlightController`، `AnimationController` |
| 11 | **بناء `QuranReaderHeader`** | `lib/features/quran/presentation/widgets/quran_reader_header.dart` | شريط بحث علوي مع `BackdropFilter` |
| 12 | **بناء `QuranReaderIconNavBar`** | `lib/features/quran/presentation/widgets/quran_reader_icon_nav_bar.dart` | الشريط السفلي الجديد بأربع أيقونات |
| 13 | **بناء `QuranReaderBottomPanel`** | `lib/features/quran/presentation/widgets/quran_reader_bottom_panel.dart` | شريط الصفحات مع `QuranPageCarousel` |
| 14 | **بناء `QcfPage`** (أول صفحة) | `lib/features/quran/presentation/pages/quran_page_reader.dart:252` | رسم صفحة القرآن — **يحمّل خطوط QCF** عبر `qcf_quran` package |
| 15 | **`QuranPageMetadataCache.forPage()`** | `lib/features/quran/data/local/quran_page_helpers.dart:61-63` | حساب معلومات الصفحة (اسم السورة، الجزء، الحزب) عبر دوال `qcf_quran` |

---

### المرحلة 3: المهام المتأخرة (Timers)

هذه المهام مجدولة عبر `_scheduleStartupTasks()` في `AppBootstrap` بعد `addPostFrameCallback`:

#### 3.1 - بعد ثانيتين: استرداد التنزيلات المعلقة

| # | العملية | الملف المسؤول | التفاصيل |
|---|---------|---------------|----------|
| 16 | `QuranDownloadRecoveryService.restorePendingDownloads()` | `lib/features/quran/application/quran_download_recovery_service.dart:25` | يقرأ ملفات JSON من `getApplicationSupportDirectory()` عبر `QuranDownloadSessionStore` |
| 17 | `_waitUntilAppIsResumed()` | `lib/features/quran/application/quran_download_recovery_service.dart:55` | ينتظر حتى 30 ثانية أن يصبح التطبيق `resumed` |
| 18 | استرداد تفسير معلق | `lib/features/quran/application/quran_download_recovery_service.dart:67` | إذا كان هناك تفسير يُحمَّل، يستعيده |
| 19 | استرداد ترجمة معلقة | `lib/features/quran/application/quran_download_recovery_service.dart:89` | إذا كانت هناك ترجمة تُحمَّل، يستعيدها |

#### 3.2 - بعد 7 ثوانٍ: تدفئة أسماء الله الحسنى (ثقيلة!)

| # | العملية | الملف المسؤول | التفاصيل |
|---|---------|---------------|----------|
| 20 | `NamesOfAllahLocalDataSource.warmUp()` | `lib/features/names_of_allah/data/names_of_allah_local_data_source.dart:50` | تستدعي `getEntries()` |
| 21 | **`rootBundle.loadString('assets/data/Names_Of_Allah.json')`** | `lib/features/names_of_allah/data/names_of_allah_local_data_source.dart:64` | **قراءة ملف JSON كاملاً في الذاكرة** |
| 22 | **`compute(_parseAllahNamesAsset, jsonString)`** | `lib/features/names_of_allah/data/names_of_allah_local_data_source.dart:65` | تحليل JSON في **Isolate منفصل** (جيد!) |
| 23 | تحويل لـ `AllahNameEntry` | `lib/features/names_of_allah/data/names_of_allah_local_data_source.dart:66-69` | **على Main Isolate** — تحويل 99 عنصر |
| 24 | **`_writeCache(entries)`** | `lib/features/names_of_allah/data/names_of_allah_local_data_source.dart:71` | كتابة ملف JSON مُخزّن في `getApplicationSupportDirectory()/names_of_allah/names_of_allah_v1.json` |

> **⚠️ مشكلة**: `rootBundle.loadString()` يعمل على Main Isolate ويحمّل الملف كاملاً في الذاكرة.

#### 3.3 - بعد 9 ثوانٍ: تدفة الحديث النبوي

| # | العملية | الملف المسؤول | التفاصيل |
|---|---------|---------------|----------|
| 25 | `HadithNawawiLocalDataSource.warmUp()` | `lib/features/hadith_nawawi/data/hadith_nawawi_local_data_source.dart:40` | تستدعي `getEntries()` |
| 26 | **`rootBundle.loadString('assets/data/40-hadith-nawawi.json')`** | `lib/features/hadith_nawawi/data/hadith_nawawi_local_data_source.dart:45` | **قراءة ملف JSON في الذاكرة** |
| 27 | **`compute(_parseHadithNawawi, jsonString)`** | `lib/features/hadith_nawawi/data/hadith_nawawi_local_data_source.dart:46` | تحليل JSON في **Isolate منفصل** |

> **ملاحظة**: ملف صغير نسبياً (40 حديث)، الأثر الأقل.

#### 3.4 - بعد 12 ثانية: زراعة التفسير الميسر ⚠️ (الأثقل!)

| # | العملية | الملف المسؤول | التفاصيل |
|---|---------|---------------|----------|
| 28 | `DefaultTafsirSeedService.ensureSeeded()` | `lib/features/quran/application/default_tafsir_seed_service.dart:24` | يتحقق هل تم زراعة التفسير بالكامل |
| 29 | **`getCachedTafsirChapterIds(16)`** | `lib/features/quran/application/default_tafsir_seed_service.dart:36` | **استعلام SQLite** — يحسب عدد الفصول المُخزّنة |
| 30 | **`rootBundle.loadString('assets/data/ar_muyassar.json')`** | `lib/features/quran/data/local/tafsir_muyassar_asset_data_source.dart:114` | **قراءة ملف JSON ضخم (3,060,212 بايت ≈ 3 MB) كاملاً في الذاكرة** على Main Isolate |
| 31 | **`compute(_parseAndGroupMuyassarAsset, jsonString)`** | `lib/features/quran/data/local/tafsir_muyassar_asset_data_source.dart:115` | تحليل 6236 تفسير وتصنيفها حسب الفصل في **Isolate منفصل** |
| 32 | **حلقة تكرارية على 114 فصل** | `lib/features/quran/application/default_tafsir_seed_service.dart:42-66` | لكل فصل غير مُخزّن: |
| 32a | `_assetDataSource.getChapterTexts(chapterNumber)` | `lib/features/quran/data/local/tafsir_muyassar_asset_data_source.dart:62` | استخراج تفسيرات الفصل من البيانات المُحلّلة |
| 32b | **`_localDataSource.saveTafsirTexts(...)`** | `lib/features/quran/data/local/default_tafsir_seed_service.dart:54` | **إدخال تفسيرات الفصل في SQLite** —undreds to thousands of rows per chapter |
| 32c | `await Future.delayed(Duration(milliseconds: 16))` | `lib/features/quran/application/default_tafsir_seed_service.dart:62` | تأخير 16ms بين كل فصل (lowPriority) |
| 33 | **`isTafsirDownloaded(16)`** + **`saveDownloadedTafsir(defaultBuiltInTafsir)`** | `lib/features/quran/application/default_tafsir_seed_service.dart:69-72` | تحديث سجل التفسيرات المُحمّلة |

> **⚠️⚠️⚠️ المشكلة الرئيسية**:
> - ملف `ar_muyassar.json` حجمه **3 ميجابايت** ويُقرأ بالكامل في الذاكرة عبر `rootBundle.loadString()` على **Main Isolate**
> - الحلقة تُدخّل **~6236 سطر** في SQLite عبر 114 استدعاء `saveTafsirTexts`
> - كل استدعاء `saveTafsirTexts` يفتح transaction جديد في SQLite
> - حتى مع التأخير 16ms، هذا يستغرق **114 × 16ms ≈ 1.8 ثانية** فقط من التأخير، بالإضافة لوقت إدخال البيانات الفعلي
> - SQLite قد يصبح **ملفاً زاحفاً** أثناء إدخال这么多 من البيانات، مما يعيق أي قراءات أخرى

---

## خرائط الأصول المستخدمة

| الأصل | الحجم | الاستخدام |
|-------|-------|-----------|
| `assets/data/ar_muyassar.json` | **3,060,212 بايت (≈ 3 MB)** | تفسير الميسر — 6236 تفسير |
| `assets/data/Names_Of_Allah.json` | صغير | أسماء الله الحسنى — 99 اسم |
| `assets/data/40-hadith-nawawi.json` | صغير جداً | الأربعون النووية — 42 حديث |
| `assets/data/hisn_almuslim.json` | **133,837 بايت (≈ 134 KB)** | أذكار + أدعية (يُحمَّل لاحقاً عند فتح شاشة الأذكار) |
| `assets/data/quran-uthmani.xml` | كبير | نص القرآن (يُحمَّل عبر qcf_quran) |

---

## قاعدة البيانات (SQLite/Drift)

- **الملف**: `al_mubeen` (يُنشأ في `getApplicationSupportDirectory()`)
- **15 جدول** مع indexes متعددة
- **10 إصدارات schema** مع `onUpgrade` متسلسل
- عند التشغيل الأولي: `onCreate` يستدعي `migrator.createAll()` لإنشاء كل الجداول

---

## مسار التشغيل الكامل (Timeline)

```
t=0.0s  AppConfig.load() — قراءة env vars
t=0.1s  runApp() — بناء شجرة الـ Widget
t=0.2s  AppDatabase() — فتح/إنشاء SQLite (15 جدول)
t=0.3s  AppUserPreferences.read() — قراءة JSON من ملف
t=0.4s  عرض _InitialLoading (شاشة تحميل)
t=0.5s  التفضيلات جاهزة → عرض OnboardingScreen أو _QuranLaunchShell
t=0.6s  بناء QuranPageReader + QcfPage (حمّل خطوط QCF)
t=0.8s  الصفحة الأولى جاهزة + FadeTransition
        ─── التطبيق الآن يُظهر القرآن ───
t=2.0s  [Timer] استرداد التنزيلات المعلقة
t=7.0s  [Timer] warmUp Names of Allah — قراءة JSON + تحليل + كتابة cache
t=9.0s  [Timer] warmUp Hadith Nawawi — قراءة JSON + تحليل
t=12.0s [Timer] ensureSeeded Tafsir:
        t=12.0s  استعلام SQLite — عدّ الفصول المُخزّنة
        t=12.1s  rootBundle.loadString('ar_muyassar.json') — قراءة 3 MB في الذاكرة ⚠️
        t=12.3s  compute() — تحليل JSON في Isolate منفصل
        t=12.5s  بدء الحلقة: إدخال 114 فصل في SQLite
        t=12.5s  حفظ فصل 1/114 + delay 16ms
        t=12.7s  حفظ فصل 2/114 + delay 16ms
        ...
        t=14.3s  حفظ فصل 114/114
        t=14.3s  حفظ سجل التفسيرات المُحمّلة
        ─── الزراعة مكتملة ───
```

---

## المشاكل الرئيسية المسببة للتجمد

### 1. `rootBundle.loadString()` على Main Isolve (3 مرات!)
- `ar_muyassar.json` — **3 MB** على Main Isolate
- `Names_Of_Allah.json` — صغير لكنه على Main Isolate
- `40-hadith-nawawi.json` — على Main Isolate

> **المشكلة**: `rootBundle.loadString()` تقرأ الأصل من الذاكرة المضغوطة، تفك الضغط، وتعيد `String` كاملة. كل هذا يحدث على **Main Isolate** ويحجز ذاكرة كبيرة دفعة واحدة.

### 2. إدخال SQLite متسلسل عبر Main Isolve
- `DefaultTafsirSeedService` يستدعي `_localDataSource.saveTafsirTexts()` على **Main Isolve**
- كل استدعاء يفتح transaction + inserts + commits
- 114 transaction متتالية قد تستغرق **2-5 ثوانٍ** حسب الجهاز

### 3. تداخل العمليات الثقيلة
- `warmUp Names of Allah` و `warmUp Hadith Nawawi` و `ensureSeeded Tafsir` كلها تتنافس على:
  - **Main Isolate** (لأن `rootBundle.loadString` و DB operations على Main)
  - **SQLite connection** (عمليات قراءة/كتابة متزامنة)

### 4. عدم وجود شاشة تحميل للمراحل المتأخرة
- التطبيق يُظهر القرآن فوراً ثم يتجمد تدريجياً بسبب المهام المتأخرة
- المستخدم يرى الصفحة لكن التمرير/التنقل يصبح بطيئاً

---

## ملفات المسؤولة عن كل عملية

| العملية | الملف الرئيسي | الملفات المساعدة |
|---------|---------------|------------------|
| تحميل env vars | `lib/core/config/app_config.dart` | — |
| فتح قاعدة البيانات | `lib/core/database/app_database_provider.dart` | `lib/core/database/app_database.dart` |
| قراءة التفضيلات | `lib/core/preferences/app_user_preferences.dart` | — |
| بناء القارئ | `lib/features/quran/presentation/pages/quran_page_reader.dart` | `quran_reader_header.dart`, `quran_reader_icon_nav_bar.dart`, `quran_reader_bottom_panel.dart`, `quran_page_carousel.dart` |
| تدفئة أسماء الله | `lib/features/names_of_allah/data/names_of_allah_local_data_source.dart` | — |
| تدفة الحديث | `lib/features/hadith_nawawi/data/hadith_nawawi_local_data_source.dart` | — |
| زراعة التفسير | `lib/features/quran/application/default_tafsir_seed_service.dart` | `tafsir_muyassar_asset_data_source.dart`, `tafsir_local_data_source.dart` |
| استرداد التنزيلات | `lib/features/quran/application/quran_download_recovery_service.dart` | `quran_download_session_store.dart` |
| الأذكار (عند فتح) | `lib/features/adhkar/data/data_sources/adhkar_local_data_source.dart` | — |
| الأدعية (عند فتح) | `lib/features/dua/data/data_sources/dua_local_data_source.dart` | — |
| إدارة الجدولة | `lib/app/bootstrap/app_bootstrap.dart` | — |

---

## حجم الأصول

| الأصل | الحجم | عدد العناصر |
|-------|-------|-------------|
| `ar_muyassar.json` | 3,060,212 bytes (3.0 MB) | 6,236 تفسير (آية × سورة) |
| `hisn_almuslim.json` | 133,837 bytes (134 KB) | ~30 فئة (أذكار + أدعية) |
| `Names_Of_Allah.json` | صغير | 99 اسم |
| `40-hadith-nawawi.json` | صغير جداً | 42 حديث |
| `quran-uthmani.xml` | كبير | نص القرآن الكامل |
