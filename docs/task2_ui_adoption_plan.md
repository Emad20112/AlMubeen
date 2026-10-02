# Task 2 — UI Adoption Plan

**Status:** في التنفيذ — Task 2A جارية
**Scope:** 198 ملف Dart في `lib/`، موزّعة على **مهمتين**.

---

## 0. تمهيد: ما هو موجود وما هو غير موجود

| البند | الحالة |
|---|---|
| Design tokens (Task 1) | ✅ موجودة في `lib/app/theme/` |
| Core components (Task 1) | ✅ موجودة في `lib/core/design/` (7 مكوّنات) |
| MMKV عبر `KvStorage` abstraction | ✅ منجز — **لا يُمس** |
| `shared_preferences` | ❌ غير موجود في `pubspec.yaml` |
| **تبنّي الـDesign System داخل features** | **0 من 198 ملف** |

### الأرقام التي تحكم الخطة

| القياس | القيمة |
|---|---|
| مراجع لـDesign System في `lib/features/` | **0** |
| `Color(0xFF...)` خام | **194** (منها 39 في `app_colors.dart` نفسه = تعريف الرموز) |
| → أي خام فعلي داخل الواجهة | **~155** |
| `Duration(milliseconds: N)` خام | كثير، غير معتمد على `AppMotion` |
| `BackdropFilter` في الواجهة | **5 مواضع** (بقية في `app_shadows`/`app_surface`/`app_skeleton`) |
| `AppLoadingView` / `AppErrorView` | نسخ من `AppStateView`، مستخدمة في **ملف واحد فقط** |

**الخلاصة:** الـFoundation موجود وسليم، لكنه **غير مُتبنّى**. أمامنا مهمة تبنٍّ لا مهمة بناء.

---

## 1. تقسيم العمل

المشروع 198 ملفًا. التغيير الشامل دفعة واحدة مستحيل التحقق منه، لذا قُسّم إلى مهمتين متسلسلتين.

### 🅰️ Task 2A — Shared Layer + Correctness

**الطبقة التي تعتمد عليها كل الشاشات + كل بugs حقيقية.**تُنفَّذ أولًا لأنها شرط precondition لـ2B: لا فائدة من تبنّي نظام فوق طبقة فيها تكرار ووعود كاذبة.

1. **إزالة التكرار في طبقة الحالة**
   - حذف `core/widgets/app_loading_view.dart` و`core/widgets/app_error_view.dart`.
   - تهجير `core/screens/content_details_screen.dart` (6 مواضع) إلى `AppStateView` / `AppAsyncView`.
   - **النتيجة:** ‑190 سطر تكرار، ومصدر واحد واحد لحالات loading/error/empty/offline.
2. **إصلاح `AppErrorBoundary`** — يَعِد بالتقاط أخطاء الودجت ولا يفعل (باين أدناه).
3. **توحيد `ShimmerGroup` مع `AppSkeleton`** — تكرار في Mechanism.
4. **تبنّي الرموز في `core/widgets/` + `core/screens/`**
   - `network_error_banner.dart` (18 لون خام + `BackdropFilter`)
   - `custom_bottom_nav.dart`, `section_title.dart`, `decorative_card.dart`, `decorative_badge.dart`, `app_loading_overlay.dart`, البقية.
5. **إصلاح الـbugs التي رصدها التدقيق** (صحيحة، صغيرة، جراحية):
   - `quran_sleep_timer_sheet.dart` — لوحة ألوان سوداء مُثبّتة تكسر الوضع الفاتح.
   - `tafsir/translation_download_screen` — عرض `error.toString()` للمستخدم.
   - `barrierLabel: 'Dismiss'` إنجليزي في dialogs.
   - `AppPageHeader`/touch targets في `custom_bottom_nav`.

**شرط الإنجاز:** `analyze` + `test` أخضر، ولا نسخ مكرر في `core/`.

### 🅱️ Task 2B — Feature Adoption + Performance

1. **P0 — مسار الأداء الساخن** (أولوية `Correctness > Performance`)
   - `quran_surah_player_screen.dart` — إعادة بناء الشاشة كاملة كل ~350ms.
   - `quran_audio_download_screen.dart` — كل ~300ms + `ListView` متحمّس.
   - `quran_page_reader.dart` — closure جديد كل build يُبطل `RepaintBoundary`.
   - `quran_page_carousel.dart` — `setState` كل frame سحب.
2. **تبنّي الرموز في features** (Quran, Audio, Adhkar, Tasbih, Settings, Home, Qibla, Hadith, Names of Allah).
3. **RTL sweep** — أسهم، progress، paddings، `Directionality` زائد.
4. **Responsive sweep** — measures ثابتة (340/380/88)، تباعد مع تكبير الخط.
5. **Accessibility sweep** — `Semantics`، tooltips، لا `TextScaler.noScaling` إلا بسبب محدد.
6. **State unification** — استبدال الحالات اليدوية بـ`AppAsyncView`.
7. **MMKV performance verification** — لا قراءة تخزين داخل `build`/`itemBuilder`/scroll/animation.

---

## 2. قواعد ملزمة طوال التنفيذ

| # | القاعدة |
|---|---|
| 1 | **لا إنشاء** Tokens أو مكوّنات جديدة إذا البديل موجود. |
| 2 | **لا لمس** MMKV / `KvStorage` / `AppUserPreferencesStore`. |
| 3 | **لا** إضافة `shared_preferences` أو `dart:io` لتخزين تفضيلات. |
| 4 | **لا تغيير** business logic، Quran content، audio behavior، routing، data models. |
| 5 | **لا المس** خط المصحف / line-height / letter-spacing / `TextScaler.linear(1.0)` في صفحة المصحف. |
| 6 | بعد كل دفعة: `dart analyze` + `flutter test`. |
| 7 | بلا إعادة كتابة التخزين. |
| 8 | **لا تشغّل `dart format .` على المشروع.** ⛔ |

### ⛔ قاعدة 8 — لماذا ممنوع `dart format` على هذا المشروع

الأسطر في `lib/` تُكتب بعرض ~100 (وأطول سطر حاليًا **265** حرفًا، و**392** سطرًا
تتجاوز 100). المشروع **ليس** نظيفًا تحت `dart format` الافتراضي (80).

عند تشغيل `dart format lib` أعاد لفّ **46 ملفًا** لم ألمسها. المثال الأوضح:
`tasbih_screen.dart` وحده تحوّل من 55 سطرًا معدّلًا إلى 208 سطرًا.

**القاعدة العملية:**
- نسّق **الملف المُعدَّل فقط** بـ`dart format <file>`، ولا تشغّل الأمر على مجلد.
- الأفضل: اضبط محرّرك على عرض 100 ولا تعتمد `dart format` الجماعي.
- بند `dart format .` في PHASE 28 **معدَّل لهذه المرحلة**، لأن تنفيذه الآن
  يفسد الـdiff بالكامل. التحقق سيكون بـ`analyze` + `test` + `build`.
- بعد كل دفعة: راجع `git diff --stat` وتأكد أن عدد الملفات المعدَّلة ضمن
  النطاق المُعلن في الخطة.


### ترتيب الأولوية عند التعارض

```
Correctness → Performance → Accessibility → UX → Visual effects
```

---

## 3. قرار معماري: `AppErrorBoundary`

**المشكلة:** `AppErrorBoundary` (Task 1) يخزّن `_error` و`_stackTrace`، **ولا يوجد أي كود يعيّنهما**. Flutter لا يتيح لودجت التقاط استثناءات `build` في وودجت ابن (نمط React غير موجود). النتيجة:

- `_error == null` دائمًا → `build` يُرجع `widget.child` دائمًا.
- مسار `AppStateView.error` و`_reset()` **كود ميت**.
- في الإنتاج يبقى `ErrorWidget` يعرض الاستثناء الخام.

**القرار:** لا نُحاكي وعدًا مستحيلًا. نُعيد المكوّن لصدق وظيفته:

1. حذف الحقول الميتة والتظاهر بالتقاط `build` errors.
2. توثيق الحدّ بوضوح: الاستثناءات تُلتقط عبر `AsyncValue` → `AppAsyncView`، لا عبر boundary.
3. تحويل `installReleaseErrorWidget()` لتعرض `AppStateView.error` بدل `ErrorWidget` الخام، فيصبح فشل الإنتاج رسالة عربية قابلة للفهم بدل شاشة سوداء/نص استثناء.

---

## 4. سجل الدفعات

| # | الدفعة | الحالة |
|---|---|---|
| 1 | 2A‑1: حذف `AppLoadingView`/`AppErrorView` + تهجير `content_details_screen` | ✅ |
| 2 | 2A‑2: إصلاح `AppErrorBoundary` | ✅ |
| 3 | 2A‑3: إصلاح bugs الـcorrectness (5) | ✅ |
| 4 | 2A‑4: تبنّي الرموز في `core/widgets` + `core/screens` | ⏳ |
| 5 | 2A‑5: توحيد `ShimmerGroup` ↔ `AppSkeleton` | ⏳ |
| 6 | 2B‑1: P0 hot paths | ⏳ |
| 7+ | 2B‑2…: تبنّي features | ⏳ |

### تفاصيل ما أُنجز في 2A‑1 → 2A‑3

**2A‑1 — إزالة تكرار طبقة الحالة**
- حُذف `core/widgets/app_loading_view.dart` و`core/widgets/app_error_view.dart`
  (‏‑190 سطر). كانا نسخة يدوية من `AppStateView`، ومستخدَمان في **ملف واحد**.
- `core/screens/content_details_screen.dart`: 6 حالات → `AppStateView`.
  تمييز دقيق دلاليًا: «لا يوجد محتوى» و«لم يُعثر على القسم» صارا
  `AppStateView.empty` لا `error` — حالة فارغة ليست خطأ.
- 7 تكرارات لـ`isDark ? darkScaffold : parchment` → `AppColorScheme.canvas`
  (قيم متطابقة: `#F5F1E8` / `#0B1018`، لكن صارت تتبع الثيم).

**2A‑2 — `AppErrorBoundary`**
- حُذف الصنف (`_error`/`_stackTrace` كود ميت + وعد غير قابل للتحقيق).
- `installReleaseErrorWidget()` **مُستدعى الآن فعليًا** من `main.dart`
  (كان معرّفًا وغير مستدعٍ)، ويعرض `AppStateView.error` عربية مع RTL
  بدل `ErrorWidget` الخام. بلا زر "إعادة المحاولة" الميت.
- 4 اختبارات جديدة في `test/design/design_error_net_test.dart`.

**2A‑3 — إصلاحات الـcorrectness (أولوية `Correctness > Visual`)**
| # | الملف | الإصلاح |
|---|---|---|
| 1 | `quran_sleep_timer_sheet.dart:103` | زر «تعديل» كان `onPressed: () {}` — زر ميت. صار `onPressed: null` (معطّل صريح). |
| 2 | `quran_sleep_timer_sheet.dart` `_CircleButton` | `GestureDetector` خام → `Material`+`InkWell`+`Semantics`: ripple + لقارئ الشاشة + لوحة المفاتيح. |
| 3 | `quran_sleep_timer_sheet.dart:74` | `ref.watch(player)` كامل → `.select(isActive)`. المؤقّت ينبض كل ثانية، فكان يُعيد بناء `CupertinoTimerPicker` كل ثانية. |
| 4 | `quran_sleep_timer_sheet.dart:272` | `fontSize: 32` في `ListTile` → `26` + `maxLines: 1` (فيض + تجاوز 64 مع `textScaler`). |
| 5 | 3 ملفات (ayah overlay / search sheet / wird dialog) | `barrierLabel: 'Dismiss'/'Search'/'Wird Dialog'` → `MaterialLocalizations...modalBarrierDismissLabel`. كان يُنطق إنجليزيًا لقارئ الشاشة. |
| 6 | 4 مواضع في شاشتي التفسير/الترجمة | `error.toString()` كان يُعرض للمستخدم في الإنتاج (`SocketException: Failed host lookup`). صار debug‑gated + رسالة عربية — نفس سلوك `AppAsyncView`. |

**إضافة للنظام:** `AppIcon.forwardFor(context)` / `AppIcon.backFor(context)`.
**الأسباب الجذرية:** `Icons.arrow_forward_*` **لا ينعكس** مع
`Directionality`، فسهم «إلى الأمام» يشير لليمين داخل تطبيق RTL. هذا أصل
صنف خطأ متكرر عبر الشاشات، لا إصلاح موضعي في ملف واحد.
+ 2 اختبارات في `design_system_test.dart`.

---

## 5. سجل التحقق

| نقطة | النتيجة |
|---|---|
| Baseline قبل Task 2 | `analyze` نظيف · `test` **57 ناجح / 2 فاشل** (فشلان سابقان لتغيير Baseline) |
