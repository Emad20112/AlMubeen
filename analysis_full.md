# تحليل تطبيق Al-Mubeen (الـكـوثر) — تحليل شامل ومفصّل

> تاريخ التحليل: 2026-09-01
> هذا الملف يوثق تحليلاً هندسياً شاملاً لمشروع تطبيق **Al-Mubeen** (المعروف أيضاً باسم "الـكـوثر").

---

## 1. نظرة عامة

**Al-Mubeen** هو تطبيق إسلامي شامل (قرآن كريم، أذكار، أدعية، تفسير، ترجمات، تسبيح، أسماء الله الحسنى، أربعون حديثاً نووياً، القبلة، وغيرها) مكتوب بإطار العمل **Flutter (Dart)** مع **مكوّن خلفي (Backend) منفصل** مكتوب بـ **Node.js / TypeScript** يعمل كوسيط (Proxy) لخدمة **مؤسسة القرآن الكريم (Quran Foundation) Content API**.

**الأسماء:** اسم الحزمة في `pubspec.yaml` هو `al_mubeen`، لكن اسم التطبيق المعروض على نظام Android هو **"الـكـوثر" (Al-Kawthar)**، و `applicationId` هو `com.almubeen.al_mubeen`.

| خاصية | القيمة |
|---|---|
| نوع التطبيق | Flutter (Dart) |
| الإصدار | `1.0.0+1` |
| Dart SDK | `^3.11.5` |
| Flutter | Stable channel (revision `00b0c91f` — Flutter 3.41.9) |
| Android | AGP `8.11.1`، Kotlin `2.2.20`، Gradle `8.14`، Java 17 |
| Backend | Node 24.x + TypeScript + Express + Vercel |
| حالة/لغة الواجهة | العربية (RTL) |

---

## 2. بنية المشروع (Project Structure)

```
Al-Mubeen/
├── android/                  # مشروع أندرويد الأصلي (Gradle/Kotlin)
├── ios/                      # مشروع iOS الأصلي (Xcode/Swift)
├── web/                      # دعم Flutter Web (PWA)
├── lib/                      # كود تطبيق Flutter الرئيسي (155 ملف Dart)
│   ├── app/                  # جذر التطبيق: bootstrap، routing، theme
│   ├── core/                 # البنية التحتية المشتركة
│   └── features/             # الميزات (Feature-first architecture)
├── backend/                  # الخادم الخلفي (Node/TypeScript/Express)
├── assets/                   # بيانات + SVG (fonts/data)
├── docs/                     # مستندات التصميم والتحليل
├── plins/                    # أصول التصميم (خطوط، SVG)
├── test/                     # اختبارات Flutter (13 ملف)
├── env/                      # ملفات البيئة العامة (app.env)
├── .agents/AGENTS.md         # إرشادات الوكلاء
├── .windsurf/                # مهارات/أدوات تصميم Windsurf
│
├── pubspec.yaml              # التبعيات والمصادر
├── analysis_options.yaml     # إعدادات المُحلِّل (flutter_lints)
├── backendsrc                # (كود الخادم — انظر backend/src)
└── مستندات الجذر: README.md, TODO.md,
    implementation_plan.md, qurancom_api_execution_plan.md,
    network_handling_analysis.md, performance_cleanliness_analysis.md, ...
```

---

## 3. بنية المعمارية (Architecture)

### 3.1 نمط المعمارية
يتبع المشروع **معمارية نظيفة موجهة بالباقة (Feature-first Clean Architecture)** مع تنظيم الطبقات التالية داخل كل ميزة:

```
lib/features/<feature>/
├── data/          # مصادر البيانات (local/remote) + مستودعات (repositories)
│   ├── data_sources/
│   ├── local/
│   ├── remote/
│   └── repositories/
├── domain/        # نماذج + واجهات المستودعات (abstract interfaces)
│   ├── models/
│   └── repositories/
├── presentation/  # الواجهة: صفحات، ويدجت، وحدات تحكم
│   ├── controllers/
│   ├── pages/
│   └── widgets/
└── application/   # حالات/خدمات حالة التطبيق (controllers/services)
```

### 3.2 إدارة الحالة — Riverpod 3 (flutter_riverpod)
- تُستخدم **`Riverpod 3`** لإدارة الحالة بشكلٍ صريح وآمن.
- الأنماط المستخدمة تشمل:
  - **`NotifierProvider` / `Notifier`** لوحدات التحكم (مثل `QcfFontBootstrapController`).
  - **`FutureProvider` / `AsyncNotifier`** لجلب البيانات غير المتزامنة (مثل `adhkarCategoriesProvider`).
  - **`Provider`** للخدمات والمستودعات (dependency injection عبر Riverpod).
- **حقن التبعية (DI)** يتم عبر Riverpod Providers بدلاً من مكتبة DI منفصلة.

### 3.3 التوجيه — go_router
- يستخدم **`go_router: ^17.2.3`** للتوجيه مع تعريف المسارات في `app_router.dart`.
- المسار الجذر `/` ينقل إلى `AppBootstrap` الذي يقرر إظهار شاشة الترحيب (Onboarding) أو واجهة المصحف مباشرة.
- تُمرَّر المعاملات عبر `state.pathParameters` و `state.extra`.

### 3.4 معالجة البيانات
- نظام **`DataResult<T>`** (نجاح/خطأ) من `core/data/` يغلف كل نتائج مصادر البيانات، بدلاً من رمي الاستثناءات.
- **`DataFailure`** يصف أنواع الأخطاء (network, timeout, parsing, unauthorized, rateLimited, cancelled, ...).
- **`DataFetchPolicy`** يتحكم بسياسة الجلب (cache-first، network-only، إلخ).
- **`RequestAbortHandle`** يدعم إلغاء الطلبات (abort) عند الحاجة.

---

## 4. قاعدة البيانات المحلية — Drift (SQLite)

تستخدم قاعدة البيانات المحلية **`drift: ^2.33.0`** (SQLite ORM) مع `drift_flutter` و `sqlite3_flutter_libs`.

**جدول `AppDatabase` (المخطط version 12)** يحتوي على الجداول التالية:

| الجدول | الغرض |
|---|---|
| `QuranChapterCache` | كاش معلومات السور |
| `QuranVerseCache` | كاش الآيات (نص عثماني) |
| `QuranRecitationCache` | كاش قائمة القرّاء |
| `QuranCacheMetadata` | بيانات وصفية عن آخر جلب |
| `AdhkarProgressCache` | تقدّم المستخدم في الأذكار |
| `AdhkarFavorites` | المفضّلة في الأذكار |
| `CategoryFavorites` | مفضّلة الفئات |
| `QuranReadingProgressCache` | آخر صفحة/سورة قُرئت |
| `QuranBookmarks` | علامات مرجعية في المصحف |
| `WirdsTable` | بيانات الوِرد اليومي |
| `DownloadedTafsirs` | التفاسير المحمّلة |
| `DownloadedTranslations` | الترجمات المحمّلة |
| `TafsirTextCache` | كاش نصوص التفسير |
| `TranslationTextCache` | كاش نصوص الترجمة |
| `HisnContentCache` / `HisnContentItemCache` | محتوى حصن المسلم |

يتم توليد الأكواد تلقائياً عبر **`drift_dev` + `build_runner`** (ملف `app_database.g.dart`)، مع وجود استراتيجية **ترحيل (Migration)** واضحة لكل إصدار مخطط.

---

## 5. التخزين المحلي الآخر

- **`shared_preferences`** — تخزين مفاتيح/قيم (مثل تفضيلات المستخدم: الوضع الليلي، حجم الخط، آخر صفحة).
- **`flutter_dotenv`** — تحميل ملفات البيئة العامة من `env/app.env` (لا يحتوي أبداً على أسرار OAuth؛ الأسرار في `backend/.env` فقط).

---

## 6. الشبكة والخدمات الخارجية

### 6.1 الخادم الخلفي (Backend) — Node.js/TypeScript
هو **وسيط (Proxy)** بين التطبيق وخدمة **مؤسسة القرآن الكريم**. المبرر له: **مؤسسة القرآن تحتاج مصادقة OAuth2 مع client_id/client_secret** لا يجوز كشفها في التطبيق.

**التقنيات:**
- `express ^4.21.2` — إطار HTTP
- `dotenv ^16.4.7` — تحميل المتغيرات
- TypeScript `^5.8.2` + `tsx` — لغة وأداة تشغيل

**المسارات (routes)** في `backend/src/routes/`:
- `health.ts` — فحص الصحة
- `qf-check.ts` — فحص الاتصال بخدمة القُرآن
- `chapters.ts` — السور
- `translations.ts` — الترجمات
- `tafsirs.ts` — التفاسير
- `topics.ts` — المواضيع
- `verses.ts` — الآيات
- `recitations.ts` — التلاوات
- `chapter-reciters.ts` — قرّاء السور

**مكونات رئيسية:**
- `lib/qfClient.ts` — عميل HTTP للاتصال بفاندشن، مع إعادة محاولة عند 401.
- `lib/tokenManager.ts` — إدارة **OAuth2 client_credentials** مع كاش للتوكن وتجديد تلقائي (بهامش 60 ثانية) ومنع التزامن (in-flight).
- `lib/cache.ts` — كاش في الذاكرة للموارد (TTL من المتغيرات).
- `services/qf.service.ts` — طبقة خدمات تغلف استدعاءات API.
- `vercel.json` — تكوين النشر على **Vercel** (يشمل خدمة الملفات الثابتة للمسار `/qcf_tajweed`).

**ملاحظة البنية:** المعمارية على شكل `config / lib / middleware / routes / services` وهي نمط متعارف عليه في تطبيقات Express.

### 6.2 خدمة مؤسسة القرآن الكريم (Quran Foundation) — الوجهة الخارجية
- مبنية على **OAuth2** (`client_credentials` + scope `content`).
- نطاقات OAuth: `https://oauth2.quran.foundation` (إنتاج) أو `https://prelive-oauth2.quran.foundation` (اختيار/تطوير).
- نطاق المحتوى: `https://apis.quran.foundation/content/api/v4`.
- يتّبع الخادم نمط **`{ ok, data }`** أو **`{ ok: false, error: { message } }`** في الاستجابات، وهو ما يفسّره عميل Flutter في `quran_com_api_client.dart`.

### 6.3 عميل Flutter للشبكة
- `HttpQuranComApiClient` يستخدم `dart:io HttpClient` مباشرة مع:
  - مهلة (timeout) 15 ثانية لكل طلب.
  - دعم **إلغاء الطلبات** عبر `RequestAbortHandle`.
  - معالجة كاملة لحالات: timeout, parsing, network, status codes (401/403/404/429).
- التعامل مع `DataResult` يمنع انهيار التطبيق عند فشل الشبكة.

### 6.4 ملفات الخط Tavلريدة QCF (القرآنية)
- الخادم يقدّم **604 ملف ZIP لخط QCF Tajweed** (من `QCF4_tajweed_001.zip` إلى `QCF4_tajweed_604.zip`) من `backend/public/qcf_tajweed/` لتُحمّل من التطبيق وتُستخدم لعرض المصحف بخط الرسم العثماني مع التجويد.
- يُستخدم إصدار محلي عبر مكتبة `qcf_quran: ^0.0.5`.

---

## 7. الصوت والتلاوة والتحميل

### 7.1 تشغيل الصوت
- **`just_audio: ^0.10.5`** — محرك تشغيل الصوت.
- **`audio_service: ^0.18.18`** — تشغيل الصوت في الخلفية مع تحكّم من شريط الإشعارات.
- **`audio_session: ^0.2.3`** — إدارة جلسة الصوت (فقدان/استعادة التركيز).
- **`marquee: ^2.3.0`** — نص متحرك (مثل اسم القارئ).

### 7.2 التحميل في الخلفية
- **`background_downloader: ^9.5.6`** — تحميل ملفات الصوت/التفاسير/الترجمات في الخلفية (مع دعم `FOREGROUND_SERVICE_DATA_SYNC`).
- **`DownloadManager` / `DownloadRepository`** في `core/audio/`.
- **`QuranDownloadRecoveryService`** — يعيد تشغيل التحميلات المعلّقة عند بدء التشغيل.
- **`QuranSurahPlayerController` / `SurahPlayerProvider`** — مشغّل كامل للسورة.
- **`WirdController`** — التحكم بالوِرد اليومي.

---

## 8. الميزات (Features)

| الميزة | المسار | الوصف |
|---|---|---|
| **المصحف** (Quran Reader) | `features/quran/` | قراءة المصحف صفحةً بصفحة بخط QCF العثماني مع التجويد، قرّاء، تحميل صوت، تفسير، ترجمة، إشارات مرجعية، بحث، مؤقّت نوم |
| **التفسير** | `features/quran/` (tafsir) | تفاسير قابلة للتحميل، مع تفسير **الميسر** مضمن كأصل محلي (`ar_muyassar.json`) |
| **الترجمة** | `features/quran/` (translation) | ترجمات قابلة للتحميل |
| **الأذكار** | `features/adhkar/` | أذكار + عدّاد تقدم، مصدر: `hisn_almuslim.json` والإسلام هاوس |
| **الأدعية** | `features/dua/` | أدعية من `hisn_almuslim.json` |
| **أسماء الله الحسنى** | `features/names_of_allah/` | من `Names_Of_Allah.json` مع ورقة تفاصيل |
| **الأربعون نووية** | `features/hadith_nawawi/` | من `40-hadith-nawawi.json` |
| **التسبيح** | `features/tasbih/` | عدّاد تسبيح (`TasbihController`) |
| **القبلة** | `features/qibla/` | بوصلة القبلة (GPS + بوصلة الجهاز) |
| **الوِرد اليومي** | `features/quran/` (wird) | خطط قراءة يومية |
| **الترحيب** | `features/onboarding/` | شاشة تعريفية عند أول استخدام |
| **حول التطبيق** | `features/about/` | معلومات عن التطبيق |

---

## 9. خدمة القبلة والموقع

- **`geolocator: ^14.0.2`** — تحديد الموقع الجغرافي (GPS) لحساب اتجاه القبلة.
- **`flutter_compass: ^0.8.1`** — قراءة البوصلة المغناطيسية.
- **`adhan: ^2.0.0+1`** — حساب أوقات الصلاة (تبعية لكنها موجودة في الملف).
- **`permission_handler: ^12.0.2`** — طلب أذونات الوصول (الموقع، إلخ).
- الأذونات في البيان: `ACCESS_FINE_LOCATION` و `ACCESS_COARSE_LOCATION`.

---

## 10. الواجهة والتصميم

- **Material 3** عبر `ColorScheme.fromSeed` مع ألوان إسلامية دافئة (ذهبي/بني/رصاصي/ورقي).
- اتجاه **RTL** إجباري عبر `Directionality(textDirection: TextDirection.rtl)` في جذر التطبيق.
- **تكبير نص قابل للضبط** عبر `MediaQuery.copyWith(textScaler)` (نطاق 0.8–1.45).
- **`flutter_svg`** لعرض الإطارات الزخرفية من `assets/svg/`.
- **`flutter_islamic_icons: ^1.0.2`** — أيقونات إسلامية.
- **`qcf_quran`** — عرض المصحف بالرسم العثماني.
- **`flutter_widget_from_html`** — عرض محتوى HTML (خاصة نصوص التفسير).
- **وضع ليلي/نهاري** مدعوم (System/Light/Dark).
- **خط ديواني بنت** (من `plins/arfonts-diwani-bent/`) للتصميم.

**أصول التصميم:** يوجد دليل كامل في `.windsurf/skills/` (تصميم UI/UX، نظام تصميم، علامة تجارية، بانرات).

---

## 11. وحدات التحكم والعمليات عند بدء التشغيل

`AppBootstrap` ينفّذ **خط أنابيب إقلاع متسلسل** لتحسين الأداء:
1. **استرداد التحميلات المعلّقة** بعد 2 ثانية (DownloadRecoveryService).
2. **تأمين التفسير الافتراضي** (الأثقل) عبر `DefaultTafsirSeedService`.
3. **إحماءات مؤجلة (idle priority)** لـ: القرّاء، أسماء الله، الأربعون نووية.
4. **إحماء خط QCF** قبل عرض المصحف، مع **مسبار عرض** خارج الشاشة (`QcfPage`) وجهاز توقيت امتياز (grace timer 900ms).

يُدار الخطأ العالمي في `main.dart` عبر `PlatformDispatcher.onError` و `FlutterError.onError` لمنع الانهيارات.

---

## 12. التطبيقات الأصلية (قشرة المنصة)

- **Android:** `MainActivity.kt` (فئة `FlutterActivity` بسيطة). تم تسجيل 15 إضافة أصلية تلقائياً في `GeneratedPluginRegistrant.java`.
- **iOS:** `AppDelegate.swift` + `SceneDelegate.swift` + `Runner-Bridging-Header.h`.
- **Web:** دعم PWA (`manifest.json`، أيقونات، `index.html`).

---

## 13. المصادر والأصول المضمّنة (Assets)

| الملف | المحتوى |
|---|---|
| `assets/data/quran-uthmani.xml` | نص القرآن بالرسم العثماني |
| `assets/data/ar_muyassar.json` | تفسير الميسر |
| `assets/data/hisn_almuslim.json` | حصن المسلم (أذكار+أدعية) |
| `assets/data/Names_Of_Allah.json` | أسماء الله الحسنى |
| `assets/data/40-hadith-nawawi.json` | الأربعون النووية |
| `assets/data/al_kawthar_app_icon.png` | أيقونة التطبيق |
| `assets/svg/*.svg` | إطارات/زخارف واجهة |
| `env/app.env` | متغيرات عامة (URL الخادم) |

---

## 14. أدوات البناء والتطوير

- **`flutter_launcher_icons: ^0.14.4`** — توليد أيقونات Android/iOS.
- **`build_runner` + `drift_dev`** — توليد كود قاعدة البيانات.
- **`flutter_lints: ^6.0.0`** — معايير الفحص/الجودة.
- **اختبارات:** 13 ملف اختبار في `test/` تغطي الويدجت، مصادر البيانات، المستودعات، مكتبة quran API.

---

## 15. النشر والبيئات

- **الخادم الخلفي** ينشر على **Vercel** (`vercel.json`).
- عنوان الخادم الافتراضي في التطبيق: `https://quan-packend-qgl5ro509-inma-soft.vercel.app` (قابل للتجاوز عبر `env/app.env` أو متغيرات النظام).
- **فصل الأسرار:** `env/app.env` للعموم، `backend/.env` للأسرار (client_secret إلخ).

---

## 16. التبعيات الأساسية (ملخّص)

### تعتمد في التشغيل (public):
`adhan`, `audio_service`, `audio_session`, `cupertino_icons`, `drift`, `drift_flutter`, `flutter_islamic_icons`, `flutter_riverpod`, `flutter_svg`, `geolocator`, `go_router`, `intl`, `just_audio`, `marquee`, `path`, `path_provider`, `permission_handler`, `scrollable_positioned_list`, `shared_preferences`, `sqlite3_flutter_libs`, `flutter_dotenv`, `flutter_widget_from_html`, `qcf_quran`, `flutter_compass`, `background_downloader`, `connectivity_plus`, `flutter_launcher_icons`

### تبعيات مهمة غير مباشرة (transitive):
`rxdart`, `chewie`, `video_player`, `webview_flutter`, `url_launcher`, `wakelock_plus`, `cached_network_image`, `sqflite`, `sqlcipher_flutter_libs`, `jni/jni_flutter`, `package_info_plus`, `uuid`, `xml`, `html`, `ffi`

### إضافات أندرويد الأصلية المسجّلة (15):
`audio_service`, `audio_session`, `background_downloader`, `connectivity_plus`, `flutter_compass`, `geolocator_android`, `jni`, `jni_flutter`, `just_audio`, `package_info_plus`, `permission_handler_android`, `shared_preferences_android`, `sqflite_android`, `url_launcher_android`, `video_player_android`, `wakelock_plus`, `webview_flutter_android`

---

## 17. ملاحظات بنيوية وتقنية بارزة

1. **فصل الأسرار:** تصميم جيد — عميل OAuth2 يبقى في الخادم ولا يُكشف للتطبيق.
2. **معالجة أخطاء موحّدة:** نظام `DataResult/DataFailure` يمنع انهيارات الشبكة.
3. **أداء الإقلاع:** خط أنابيب إقلاع متسلسل + إحماءات مؤجلة + مسبار عرض افتراضي يحسّن تجربة بدء المصحف.
4. **البيانات المحلية أولاً:** استخدام واسع لـ SQLite للكاش والتقدم والتفسير المضمّن يسمح بالعمل دون اتصال جزئياً.
5. **تضمين محتوى إسلامي كامل** (حصن، أسماء، أربعون، تفسير ميسر) كأصول محلية لتقليل الاعتماد على الشبكة.

---

## 18. نقاط قوة محتملة / مناطق للمراجعة

- **الإسم:** اسم التطبيق الظاهر للنظام هو "الـكـوثر" بينما الحزمة `al_mubeen` — تأكد من اتساق الهوية.
- **مكتبة أثناء العرض HTML** وطريقة عرض التفاسير أحياناً تتطلب معالجة تحديثات أمان.
- **`backend/public/qcf_tajweed`** يحتوي 604 ملف ZIP ثابتة — يجب إدارتها (حجم/تحديث) بحذر على Vercel.
- يوجد بعض الملفات الشاردة/التجريبية في الجذر: `find_package.dart`, `test_gesture.dart`, `pag.md`, `r.pdf`, `r2.pdf`, `r3.pdf`, `lib.zip`, و `backendsrc` يشير ربما لملف لا وجود له. يُنصح بتنظيفها.
- `Untitled-1.txt` داخل `features/quran/data/repositories/` ملف غير مرغوب.
- مكتبات `video_player`/`webview_flutter`/`chewie` ظاهرة كتبعيات غير مباشرة وقد لا تكون مستخدمة فعلياً.

---

## 19. خلاصة

**Al-Mubeen** هو تطبيق إسلامي متكامل وغنيّ بالميزات مبني بتقنيات حديثة:
- **الواجهة:** Flutter (Material 3، RTL، دعم وضع ليلي، تحجيم نص).
- **المعمارية:** Clean Architecture + Riverpod 3 + go_router + Drift/SQLite.
- **الخدمات الخارجية:** وسيط Node/Express على Vercel يتصل بمؤسسة القرآن الكريم عبر OAuth2، مع كاش وتحميلات في الخلفية وملفات خط QCF للرسم العثماني.
- **المنصات:** Android و iOS و Web (PWA).

يمثل المشروع تطبيقاً إنتاجياً شديد البنية، جيد التنظيم حول الميزات، مع اهتمام واضح بالأداء (الإقلاع، الكاش، التحميل الخلفي) وفصل الأمان (الأسرار).
