# خطة التطوير الشاملة لمحرك تلاوات القرآن الكريم (Quran Audio Engine) في تطبيق الكوثر

## 1. تحليل النظام الحالي (Current System Audit)

يتضمن نظام التلاوات الحالي في تطبيق الكوثر المكونات التالية:
1. **`QuranAudioController`** (`lib/features/quran/application/quran_audio_controller.dart`):
   - يدير تشغيل تلاوات الآيات باستخدام `just_audio.AudioPlayer`.
   - يعتمد حصرياً على نظام قوائم التشغيل الديناميكية المتتابعة للآيات (`ConcatenatingAudioSource` / `setAudioSources` و `addAudioSources`).
   - ينفذ نافذة تحميل مسبق (`prefetchWindowSize = 6`, `prefetchTriggerIndex = 3`) مع كاش محلي للعناوين `LruCache`.
   - يعالج انقطاع الإنترنت وحالة الـ AudioSession.
2. **`QuranSurahPlayerController`** (`lib/features/quran/application/quran_surah_player_controller.dart`):
   - يمثل شاشة مستقلة لتشغيل السورة كاملة بمشغل منفصل غير مرتبط بصفحات المصحف وقارئ الصفحات (`QuranPageReader`).
   - يؤدي هذا الانفصال إلى وجود نسختين من منطق تشغيل السور دون توحيد مع نظام التظليل في المصحف.
3. **`QuranHighlightController`** (`lib/features/quran/application/quran_highlight_controller.dart`):
   - يفصل بين التظليل اليدوي والتظليل الصوتي، ولكنه كان يحتفظ بالتظليل الصوتي عند الإيقاف المؤقت (Pause) بحسب الكود السابق، وهو ما يخالف السلوك المطلوب الجديد بإخفاء التظليل الصوتي فوراً عند Pause وإظهاره فقط عند Resume.
4. **`QuranPageReader`** (`lib/features/quran/presentation/pages/quran_page_reader.dart`):
   - يستمع إلى تغيرات `quranAudioControllerProvider`.
   - ينسق بين موضع الآية الحالية وتحديث الصفحة وتمرير التظليلات إلى الصفحات المعروضة.
5. **الباك إند Node.js / Express Gateway**:
   - يحتوي على مسار بروكسي الصوت التدريجي `/api/audio/stream` يدعم تمرير ترويسات `Range` واستجابات `206 Partial Content`.
   - مسار `/api/chapter-reciters/:reciterId/chapter/:chapterNumber` يجلب بيانات تلاوة السورة وتوقيتات الآيات من Quran Foundation (`chapter_recitations/:reciterId/:chapterNumber`).

---

## 2. المعمارية الحالية لتشغيل الصوت

```
[UI: QuranPageReader / AyahAudioPlayerBar]
          │
          ▼
[QuranAudioController (Riverpod Notifier)]
          │ (Ayah-by-Ayah only)
          ├──► AudioRepository ──► Local SQLite / File Cache
          └──► QuranAudioRepository ──► Backend Gateway ──► Quran Foundation
          │
          ▼
   [just_audio.AudioPlayer]
          │
          └──► ConcatenatingAudioSource [Ayah 1, Ayah 2, ... Ayah N]
```

### نقاط القصور في المعمارية الحالية:
1. **غياب تشغيل السورة الكاملة كملف واحد في المصحف**: حتى لو توفر ملف صوتي كامل للسورة مع توقيتات دقيقة، يتم طلب ملفات مستقلة لكل آية، مما يزيد من عدد اتصالات الشبكة واستهلاك البيانات.
2. **شريط التحكم بالتشغيل مقيد بالآية الواحدة**: لا يعرض مدة السورة الكلية أو موضع التقدم الإجمالي داخل السورة في واجهة القراءة.
3. **التظليل الصوتي لا يختفي عند Pause**: السلوك الحالي يبقي التظليل أثناء التوقف المؤقت.
4. **تحديثات موضع الصوت تسبب ضغطاً على الحالة**: على الرغم من وجود throttle، فإن تكرار تحديثات الـ position داخل الـ State الأساسي يؤثر على Widgets التي لا تستخدم `select` بدقة.

---

## 3. المشكلات الفعلية وأسبابها الجذرية

1. **ازدواجية المشغلات وتشتت تجربة المستخدم**:
   - وجود مشغل في شاشة السورة المستقلة ومشغل آخر في شاشة قراءة المصحف دون توحيد إدارة الحالة.
2. **استهلاك زائد لبيانات الإنترنت عند عدم توفر Range Streaming**:
   - تحميل آيات كثيرة عبر ملفات متعددة مع تكرار ترويسات HTTP والمصافحة لكل ملف بدلاً من اتصال HTTP مستمر لملف السورة.
3. **عدم التحقق الصارم من توقيتات الآيات**:
   - الاعتماد على وجود `audio_url` دون فحص اكتمال وترتيب التوقيتات وتطابقها مع عدد آيات السورة يؤدي إلى مشاكل عدم تزامن التظليل.
4. **خلط معرفات القراء**:
   - اختلاف معرفات قراء السور (`chapter_reciters`) عن معرفات قراء الآيات (`recitations`) في Quran Foundation، ومحاولة تمرير معرف أحدهما للآخر.

---

## 4. التصميم الجديد المقترح (Hybrid Quran Audio Engine)

```
                       ┌────────────────────────────────────────┐
                       │       QuranAudioController (Unified)   │
                       └───────────────────┬────────────────────┘
                                           │
                        ┌──────────────────┴──────────────────┐
                        │ Decide Playback Mode (Auto-select) │
                        └──────────────────┬──────────────────┘
                                           │
                  ┌────────────────────────┴────────────────────────┐
                  ▼                                                 ▼
     [Chapter Playback Mode]                             [Ayah Playback Mode]
  (Full Chapter MP3 + Timestamps)                    (Per-Ayah Audio Sources Window)
  - Progressive HTTP Range Streaming                 - Adaptive Dynamic Window (5 ayahs)
  - Timestamps Validation (1..N continuous)          - Local file check first
  - Binary Search for Position -> Ayah               - Trigger-based batch expansion
  - Single Chapter AudioSource                       - Fallback for missing/invalid data
                  │                                                 │
                  └────────────────────────┬────────────────────────┘
                                           │
                                           ▼
                        ┌─────────────────────────────────────┐
                        │        State Decoupling & UI        │
                        ├─────────────────────────────────────┤
                        │ • QuranHighlightState (Pure Audio   │
                        │   hidden on Pause/Stop)             │
                        │ • Chapter Progress Stream (Isolated)│
                        │ • Page Navigation on Page Change    │
                        └─────────────────────────────────────┘
```

### معمارية الاختيار الذكي (Smart Decision Flow):
```text
Request Surah Playback
        │
        ▼
Fetch Chapter Data & Timestamps from Gateway
        │
        ▼
Validate Chapter Audio & Timestamps:
  [1] Valid audio URL?
  [2] Timestamps present & count == surahVerseCount?
  [3] Sequential (1..N), ascending, startMs < endMs, non-negative?
  [4] No unreasonable overlap, endMs aligns with duration?
        │
        ├───────── Yes (All Valid) ──────► Chapter Playback Mode
        │
        └───────── No (Any Failure) ─────► Ayah Playback Mode (Adaptive 5-Ayah Window)
```

---

## 5. الملفات التي سيتم تعديلها أو إنشاؤها

### أ. الباك إند (Backend Node.js / Express):
1. **`backend/src/routes/chapter-reciters.ts`**:
   - تعزيز endpoint السور الكاملة مع إرجاع بيانات التوقيتات مفحوصة وموحدة.
   - كاش ذاكرة LRU مع In-flight deduplication.
2. **`backend/src/services/qf.service.ts`**:
   - دعم جلب وفحص بيانات السورة وتوقيتات الآيات.
3. **`backend/src/routes/audio-stream.ts`**:
   - التحقق من دعم Range Requests و206 Partial Content.

### ب. طبقة البيانات والنماذج في Flutter:
4. **`lib/features/quran/data/models/chapter_audio_model.dart`** (جديد):
   - نموذج السورة الكاملة `ChapterAudioData` و `ChapterVerseTiming`.
   - دوال التحقق الصارم من التوقيتات `validateTimestamps()`.
5. **`lib/features/quran/domain/repositories/quran_audio_repository.dart`**:
   - إضافة عقد جلب بيانات السورة الكاملة مع التوقيتات: `getChapterAudioData()`.
6. **`lib/features/quran/data/repositories/quran_audio_repository_impl.dart`**:
   - تنفيذ `getChapterAudioData` عبر استدعاء الباك إند ومعالجة الاستجابة.

### ج. طبقة المشغل والتحكم (Application & Controllers):
7. **`lib/features/quran/application/quran_audio_controller.dart`**:
   - دعم الوضعين `AudioPlaybackMode.chapter` و `AudioPlaybackMode.ayah`.
   - التحقق والتبديل التلقائي الذكي.
   - المزامنة الزمنية للآيات باستخدام Binary Search على التوقيتات.
   - نافذة التحميل التكيفي لـ 5 آيات في وضع الآيات المستقلة.
   - إدارة دقيقة للموارد والتخلص من Subscriptions.
8. **`lib/features/quran/application/quran_highlight_controller.dart`**:
   - تحديث السلوك لضمان إخفاء التظليل الصوتي عند الإيقاف المؤقت (Pause) وإعادته عند Resume.
   - الفصل التام عن التظليل اليدوي.

### د. طبقة الواجهة وعرض المصحف (Presentation):
9. **`lib/features/quran/presentation/pages/quran_page_reader.dart`**:
   - تحديث المزامنة مع الآيات بدون إعادة بناء ثقيلة للصفحات.
   - إخفاء التظليل الصوتي عند `!isPlaying`.
10. **`lib/features/quran/presentation/widgets/ayah_audio_player_bar.dart`**:
    - تطوير شريط التحكم ليدعم عرض المدة الكاملة للسورة والوقت المنقضي والمتبقي، والسحب الذكي دون Seek متكرر.

### هـ. الاختبارات (Tests):
11. **`test/features/quran/chapter_audio_validation_test.dart`** (جديد).
12. **`test/features/quran/hybrid_audio_controller_test.dart`** (جديد).
13. **`test/features/quran/quran_highlight_controller_test.dart`** (تحديث).

---

## 6. خطة الانتقال دون كسر الوظائف الحالية

- الحفاظ على جميع توقيعات الدوال الحالية في `QuranAudioController` مثل `playOrToggleAyah` و `playAyahFromBeginning` و `switchReciter` و `stop` و `seekForward` و `seekBackward`.
- عند طلب آية، يقوم المشغل تلقائياً بمحاولة جلب السورة كاملة وتوقيتاتها، فإن نجح التحقق عمل في وضع `chapter`، وإن لم يتوفر أو فشل التحقق، يعمل فوراً بسلاسة في وضع `ayah` الحالي المطور.
- عدم حذف أي شاشات قائمة، وضمان بقاء جميع اختبارات المشروع الحالية ناجحة بنسبة 100%.

---

## 7. استراتيجية التحميل التدريجي (Streaming & Prefetch Strategy)

1. **في وضع ملف السورة الكامل (Chapter Mode)**:
   - تشغيل تدريجي مباشر عبر مشغل `just_audio` مستفيداً من بروكسي الباك إند الذي يدعم `Range` و `206 Partial Content`.
   - عدم تنزيل الملف كاملاً دفعة واحدة إلى القرص إلا إذا طلب المستخدم التنزيل صراحة للمكتبة المحلية.
   - تقليل استهلاك الذاكرة والشبكة.

2. **في وضع ملفات الآيات (Ayah Mode)**:
   - نافذة تحميل أولي بحجم 5 آيات (`prefetchBatchSize = 5`).
   - فحص الملفات المخزنة محلياً أولاً قبل طلب الشبكة.
   - بدء تجهيز الدفعة التالية عند وصول المؤشر إلى الآية 3 من الدفعة الحالية (`triggerIndex = 3`).
   - إيقاف التحميل المسبق فوراً عند `Pause` أو `Stop`.
   - إلغاء وتجاهل أي طلبات متأخرة عند تغيير السورة أو القارئ.

---

## 8. خطة الاختبارات ومعايير الأداء (Testing & Benchmarks)

- **فحص صحة التوقيتات**:
  - اختبار حالات التوقيتات الصالحة، التوقيتات الفارغة، الناقصة، غير المرتبة، المتداخلة، والسالبة.
- **فحص التحويل التلقائي**:
  - التحقق من الانتقال السلس إلى وضع الآيات عند أي خلل في بيانات السورة.
- **فحص التظليل**:
  - التأكد من ثبات التظليل اليدوي واختفاء التظليل الصوتي عند Pause وظهوره عند Resume واختفائه عند Stop.
- **فحص شريط التقدم**:
  - التأكد من عدم إعادة ضبط المؤشر عند الانتقال بين الآيات في وضع السورة الكاملة.
- **معايير الأداء**:
  - `flutter analyze` خالي من أي أخطاء أو تحذيرات.
  - جميع اختبارات المشروع تمر بنجاح تام.
