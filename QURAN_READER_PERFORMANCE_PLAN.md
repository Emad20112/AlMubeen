# خطة تحسين الأداء والذاكرة وإدارة التظليل في قارئ القرآن (QURAN_READER_PERFORMANCE_PLAN)

## 1. المعمارية الحالية ومسؤولية كل ملف

1. **`lib/features/quran/presentation/pages/quran_page_reader.dart`:**
   - هو المكون الرئيسي لعرض صفحات المصحف (`Scaffold`, `Stack`, `PageView.builder`).
   - يتحكم في دورة حياة `PageController`, `ValueNotifier<int> _currentPage`, `AnimationController _overlayAnimation`, و `QuranHighlightController`.
   - يستمع إلى حالة الصوت عبر `ref.listen` ويزامن تظليل الآية مع الصفحة المعروضة عبر `_syncAudioHighlight`.
   - يدير حفظ آخر صفحة تمت قراءتها عبر debounce timer (`_schedulePersistCurrentPage`).

2. **`lib/features/quran/application/quran_audio_controller.dart`:**
   - يدير مشغل الصوت `AudioPlayer`، وتحميل وتدفق تلاوات الآيات (Sliding Window Playlist)، ومعالجة أحداث الصوت والاتصال بالشبكة، وتغيير الآية الحالية `state.currentAyah`.

3. **`lib/features/quran/application/quran_highlight_controller.dart`:**
   - يرث من `ValueNotifier<List<HighlightVerse>>`.
   - مسؤول عن تخزين قائمة الآيات المظللة حالياً. يُستخدم حالياً لكل من التظليل الصوتي والتظليل اليدوي دون تمييز أو فصل للمصدر.

4. **`lib/features/quran/presentation/widgets/quran_page_view.dart`:**
   - يعرض صفحة المصحف الفردية عبر `QcfPage` مع طبقات الرأس والتذييل المستقلة داخل `RepaintBoundary`.
   - يحتوي على دالة `buildHighlightMap(highlights)` لتحويل القائمة إلى Map لسرعة O(1).

5. **`lib/features/quran/presentation/widgets/ayah_audio_player_bar.dart` و `ayah_interaction_overlay.dart`:**
   - شريط التحكم بالتشغيل وقائمة الإجراءات السريعة (تفسير، ترجمة، نسخ، استماع، تظليل يدوي).

---

## 2. المشكلات التي أثبتها فحص الكود الفعلي (Root Causes & Evidence)

### المشكلة 1: إنشاء كائنات `CurvedAnimation` في كل إطار بناء (Build Loop Allocation)

- **الموقع:** `quran_page_reader.dart`، الدالة `_buildAnimatedOverlay()` السطور 461-476:
  ```dart
  final animation = CurvedAnimation(
    parent: _overlayAnimation,
    curve: Curves.easeOutQuint,
  );
  final opacity = CurvedAnimation(
    parent: _overlayAnimation,
    curve: Curves.easeInOutCubic,
  ).value;
  ```
- **السبب الفني:** يتم استدعاء `_buildAnimatedOverlay` 4 مرات لكل إطار أنيميشن (في Header و 3 طبقات أسفل الشاشة). خلال حركة الفتح والإغلاق (280ms بـ 60-120fps)، يتم إنشاء مئات كائنات `CurvedAnimation` ومستمعيها في الذاكرة دون `dispose()`.
- **التأثير:** ضغط شديد على Garbage Collection وتقطيع في سلاسة الإطارات (Jank / Frame Drops).

### المشكلة 2: مسح تظليل الآية عند الإيقاف المؤقت (Pause wipes highlight)

- **الموقع:** `quran_page_reader.dart`، الدالة `_syncAudioHighlight()` السطور 347-354:
  ```dart
  if (currentAyah == null || !isPlaying) {
    if (_lastSyncedAyah != null) {
      _lastSyncedAyah = null;
      _highlightController.clear();
    }
    return;
  }
  ```
- **السبب الفني:** الدالة تعتمد حصرياً على `!isPlaying`؛ وعند الضغط على Pause، تصبح `isPlaying = false` بينما `currentAyah` ما زالت موجودة وموقوفة مؤقتاً. يقوم الكود فوراً بمسح التظليل (`_highlightController.clear()`) ومسح `_lastSyncedAyah`.
- **التأثير:** عند الإيقاف المؤقت يختفي التظليل من المصحف، وعند الاستئناف يضطر النظام لإعادة التهيئة.

### المشكلة 3: التداخل بين التظليل الصوتي والتظليل اليدوي

- **الموقع:** `quran_highlight_controller.dart` و `quran_page_reader.dart`:
  - دالة `_highlightController.clear()` تمسح كل شيء في القائمة دفعة واحدة.
- **السبب الفني:** لا يوجد تمييز بين ما إذا كان التظليل يدوياً (عبر الضغط المطول على آية لحفظها أو مراجعتها) أو ناتجاً عن تتبع القارئ الصوتي. فعند إيقاف الصوت أو تغير الآية، يُمسح التظليل اليدوي أيضاً!
- **التأثير:** إحباط تجربة المستخدم الذي يحدد آيات أثناء القراءة.

### المشكلة 4: إعادة بناء شاشة المصحف بالكامل عند تغير أي تظليل

- **الموقع:** `quran_page_reader.dart` السطر 569-581:
  - الـ `ValueListenableBuilder<List<HighlightVerse>>` يلتف حول كامل `_buildPageView` وكل الصفحات.
  - كلما تغيرت آية واحدة فقط، يُعاد استدعاء `_buildPageView` وإعادة بناء الـ `PageView.builder` بالكامل.

### المشكلة 5: حفظ الصفحة وإدارة الموارد غير المتزامنة

- **الموقع:** `_saveProgressDebounce` ومزامنة الصفحات:
  - عند الخروج السريع من الشاشة أو إغلاق التطبيق أثناء تشغيل التايمر، قد لا تكتمل عملية الحفظ إذا لم يتم استدعاؤها فوراً عند `dispose()` أو تغير حالة دورة الحياة.

---

## 3. التعديلات المقترحة والحلول الهندسية

1. **إصلاح دورة حياة وتخزين الأنيميشن (Task 1):**
   - إنشاء `CurvedAnimation` للـ Slide والـ Fade كـ `late final` في `initState()` وإعادة استخدام `Animation<Offset>` و `Animation<double>`، مع تحريرها الصريح في `dispose()`.
   - استخدام `SlideTransition` و `FadeTransition` وتمرير `child` ثابت لـ `_buildAnimatedOverlay` لمنع إعادة بناء القوائم والأزرار مع كل إطار حركة.

2. **الاحتفاظ بموضع الآية وتظليلها عند Pause فقط (Task 2):**
   - تعديل `_syncAudioHighlight`: التظليل الصوتي لا يُمسح طالما أن هناك `currentAyah` ولا يتم مسحه إلا إذا كان `currentAyah == null` أو توقف المشغل نهائياً (`stop()`).
   - عند الـ Pause، يبقى `_lastSyncedAyah` مظللاً كما هو.
   - عند الـ Resume، يستأنف المشغل ويتحرك التظليل تلقائياً مع أول تغير للمؤشر.

3. **فصل التظليل الصوتي عن التظليل اليدوي:**
   - تطوير `QuranHighlightController` ليدعم إما نوع التظليل (`HighlightSource.audio` مقابل `HighlightSource.manual`) أو قائمة منفصلة للتظليل الصوتي والتظليل اليدوي، بحيث:
     - مسح التظليل الصوتي لا يمس التظليلات اليدوية للمستخدم أبداً.
     - إضافة تظليل صوتي يستبدل الآية الصوتية السابقة فقط ويُبقي اليدوي.

4. **فصل المكونات والبيانات الثابتة عن المتغيرة (Task 3 & 4):**
   - عزل مناطق الشاشة:
     - استخراج وتغليف عناصر الرأس والقوائم لتقليل مسؤولية `_QuranPageReaderState`.
     - عزل `ValueListenableBuilder` الخاص بالتظليل ليمس الآيات فقط دون إعادة بناء حاوية الـ `PageView`.
     - تخزين نتائج `buildHighlightMap` بكفاءة.

5. **تحسين الانتقال وتزامن الصفحات (Task 5):**
   - فحص `_pageController.hasClients` والتأكد من عدم تكرار `jumpToPage` لنفس الصفحة.
   - الانتقال الصامت للصفحة عند تغير السورة أو الوصول لنهاية الصفحة دون تعطيل انسياب الصوت.

6. **سلامة الموارد وإدارة دورة الحياة (Task 6):**
   - إلغاء كافة الـ Timers وتفريغ الـ Controllers والتأكد من تنفيذ الحفظ الفوري المعلق عند التخلص من الشاشة.

---

## 4. خطة الاختبارات ومعايير القبول (Verification Criteria)

1. **اختبارات الأنيميشن والذاكرة:**
   - إظهار وإخفاء القوائم 50 مرة والتأكد من ثبات الذاكرة وعدم وجود أي استثناء تسرب.
2. **اختبارات Pause & Resume:**
   - تشغيل آية -> إيقاف مؤقت -> التحقق من بقاء التظليل وبقاء الآية -> استئناف -> التحقق من استمرار التتبع.
3. **اختبارات التظليل اليدوي:**
   - تحديد آية يدوياً -> تشغيل الصوت وإيقافه -> التأكد من بقاء التظليل اليدوي دون مسح.
4. **اختبارات التنقل:**
   - انتقال الصوت إلى آية في نفس الصفحة (لا يتم تقليب الصفحة).
   - انتقال الصوت إلى آية في صفحة تالية (يتم الانتقال السلس بدون تقطيع صوت).
5. **سلامة التحليل البرمجي:**
   - `flutter analyze lib test` بدون أي أخطاء.
   - `flutter test` لكافة الوحدات بنجاح.
