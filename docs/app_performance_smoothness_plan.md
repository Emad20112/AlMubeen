# خطة رفع أداء وسلاسة التطبيق

هذه الوثيقة تلخص تحليل الوضع الحالي للتطبيق، وتحوّله إلى خطة تنفيذية لتقليل التجميد عند أول تشغيل وأثناء الاستخدام. الهدف ليس “تخفيف بسيط”، بل بناء مسار أداء قابل للقياس: أول إطار سريع، قارئ قرآن ثابت 60fps قدر الإمكان، وعمليات تحميل/فهرسة لا تخنق واجهة المستخدم.

## الملخص التنفيذي

أكثر نقاط الخطر الحالية ليست شاشة واحدة بعينها، بل تزاحم أعمال ثقيلة بعد الإقلاع مباشرة:

1. `AppBootstrap` يعرض قارئ القرآن ثم يطلق مهام خلفية متتالية: seed للتفسير، استعادة التنزيلات، warm-up للأسماء والحديث.
2. seed التفسير الافتراضي يقرأ أصلًا حجمه نحو `3MB` (`assets/data/ar_muyassar.json`) ويفك JSON في isolate، ثم يبني كائنات كثيرة ويكتب 114 فصلًا في قاعدة البيانات.
3. استعادة التنزيلات بعد `800ms` قد تعيد تشغيل تنزيل تفسير/ترجمة كاملين، مع طلبات شبكة وكتابات قاعدة بيانات بينما المستخدم بدأ القراءة.
4. مشغلات الصوت تحدّث حالة Riverpod من `positionStream` و`bufferedPositionStream` بتردد عالٍ، ما قد يعيد بناء Widgets لا تحتاج إلى كل تحديث.
5. واجهة قارئ القرآن تستخدم `BackdropFilter` فوق صفحة Mushaf، وهذا مكلف على GPU خصوصًا مع الحركة أو إعادة البناء.
6. بعض الشاشات تبني قوائم كاملة داخل `Column` بدل بناء كسول، خاصة قوائم القراء والنتائج داخل bottom sheets.

القاعدة الذهبية للخطة: **لا يبدأ أي عمل كبير في أول 3 ثوانٍ إلا إذا كان لازمًا لرسم الشاشة الحالية**. كل شيء آخر يدخل في طابور خلفي قابل للإيقاف والتأجيل.

## أهداف الأداء

- وقت أول إطار تفاعلي: أقل من `1200ms` على جهاز متوسط.
- عدم وجود frame أعلى من `32ms` أثناء فتح قارئ القرآن أو تقليب الصفحات.
- عدم تشغيل seed/restore/download تلقائي بشكل يزاحم أول جلسة قراءة.
- تحديثات الصوت لا تعيد بناء القارئ الكامل، بل عناصر الوقت/الزر فقط.
- عمليات JSON/DB الكبيرة تتم على دفعات صغيرة مع yield واضح بين الدفعات.
- أي تحميل طويل يظهر كتقدم اختياري وواضح، وليس عملًا خفيًا يسبب “تعليق غامض”.

## تشخيص الوضع الحالي

### 1. مسار الإقلاع

الملفات المعنية:

- `lib/main.dart`
- `lib/app/bootstrap/app_bootstrap.dart`
- `lib/core/preferences/app_user_preferences.dart`
- `lib/features/quran/application/default_tafsir_seed_service.dart`
- `lib/features/quran/application/quran_download_recovery_service.dart`

الملاحظات:

- `main` ينتظر `AppConfig.load()` قبل `runApp`. هذا صغير غالبًا، لكنه جزء من critical path.
- `AlMubeenApp` و`AppBootstrap` يراقبان `appUserPreferencesProvider`، لذلك قراءة ملف التفضيلات تحدد أول شاشة.
- `AppBootstrap` يشغّل seed التفسير مباشرة بعد أول frame، ثم download recovery بعد `800ms`.
- القراءة الأولى للتفضيلات تستخدم ملف JSON داخل support directory؛ هذا مناسب، لكن يفضّل ألا تتكرر الكتابة بكثافة مع تقليب الصفحات.

الخطر:

- أول تشغيل نظيف قد يجمع: فتح قاعدة البيانات + migration + قراءة `ar_muyassar.json` + كتابة آلاف أسطر التفسير + بناء `QcfPage`.
- على أجهزة ضعيفة سيظهر هذا كـ jank أو freeze بعد ظهور الشاشة بثوانٍ قليلة.

### 2. seed التفسير الافتراضي

الملفات المعنية:

- `lib/features/quran/application/default_tafsir_seed_service.dart`
- `lib/features/quran/data/local/tafsir_muyassar_asset_data_source.dart`
- `lib/features/quran/data/local/tafsir_local_data_source.dart`
- `assets/data/ar_muyassar.json`

الملاحظات:

- فك JSON يتم بـ `compute`، وهذا جيد.
- بعد فك JSON يتم تحويل السجلات إلى `TafsirText` على main isolate.
- الكتابة تتم فصلًا فصلًا، مع `Future.delayed(Duration.zero)` كل 6 فصول.
- كل فصل يستخدم `batch.insertAllOnConflictUpdate`.

الخطر:

- التحويل بعد `compute` قد يبني آلاف الكائنات على main isolate.
- الكتابة الكثيفة بعد أول frame مباشرة قد تنافس الرسم واللمس.
- `onSeedCompleted` يعمل invalidate لـ `downloadedTafsirsProvider`، وقد يسبب إعادة تحميل/بناء في وقت غير مناسب.

### 3. استعادة التنزيلات

الملفات المعنية:

- `lib/features/quran/application/quran_download_recovery_service.dart`
- `lib/features/quran/application/tafsir_download_controller.dart`
- `lib/features/quran/application/translation_download_controller.dart`
- `lib/features/quran/application/quran_audio_download_controller.dart`
- `lib/features/quran/application/quran_download_session_store.dart`

الملاحظات:

- recovery يقرأ جلسات SharedPreferences ثم يستأنف التفسير والترجمة تلقائيًا.
- تنزيل التفسير/الترجمة يمر على 114 سورة، ويحدّث state عند كل سورة.
- تنزيل الصوت الكامل يمر على كل الآيات، ويحدّث state كثيرًا، ويستمع إلى progress/status streams.

الخطر:

- الاستئناف التلقائي بعد الإقلاع قد يكون مفاجئًا ومكلفًا.
- تحديثات state المتكررة قد تسبب rebuilds واسعة في شاشات التنزيل.
- `SharedPreferences.getInstance()` يُستدعى داخل كل قراءة/كتابة session، ويفضل حقنه/caching عبر provider.

### 4. قارئ القرآن

الملفات المعنية:

- `lib/features/quran/presentation/pages/quran_page_reader.dart`
- `lib/features/quran/presentation/widgets/quran_reader_header.dart`
- `lib/features/quran/presentation/widgets/quran_reader_bottom_panel.dart`
- `lib/features/quran/presentation/widgets/ayah_audio_player_bar.dart`
- `lib/features/quran/presentation/widgets/quran_page_carousel.dart`

الملاحظات:

- `PageView.builder` مناسب لأنه لا يبني 604 صفحة دفعة واحدة.
- cache بيانات الصفحة والسور موجود، وهذا جيد.
- `QcfPage` مع `verseBackgroundColor` داخل `Stack` هو العنصر الأغلى في الصفحة.
- يوجد `BackdropFilter` في الهيدر، اللوحة السفلية، شريط الصوت، وبعض overlays.
- حفظ آخر صفحة يحدث بعد debounce `220ms`، وقد يظل كثيرًا أثناء التنقل السريع.

الخطر:

- blur فوق نص Mushaf عالي التفاصيل قد يضغط GPU.
- إذا تغيّرت highlights أو audio state بطريقة واسعة، يمكن أن يعاد بناء أجزاء أكبر من اللازم.
- الكتابة المتكررة للتفضيلات عند التنقل قد تضيف I/O خفيف لكنه محسوس عند أجهزة أضعف.

### 5. الصوت

الملفات المعنية:

- `lib/features/quran/application/quran_audio_controller.dart`
- `lib/features/quran/application/quran_surah_player_controller.dart`
- `lib/features/quran/presentation/widgets/ayah_audio_player_bar.dart`
- `lib/features/quran/presentation/pages/quran_surah_player_screen.dart`

الملاحظات:

- `quranAudioControllerProvider` يحدّث `position` من `positionStream`.
- `AyahAudioPlayerBar` يراقب الحالة كاملة رغم أنه لا يعرض تقدم الزمن حاليًا.
- مشغل السورة يحدّث `position` و`bufferedPosition` باستمرار.
- prefetch للآيات يستخدم نافذة صغيرة، وهذا جيد، لكنه قد يطلق عدة طلبات بالتوازي عند التشغيل.

الخطر:

- تحديثات position المتكررة تمر عبر state عام؛ أي Widget يراقب الحالة كاملة يعاد بناؤه دون داعٍ.
- `BackdropFilter` داخل شريط الصوت يجعل كل rebuild أغلى.

### 6. البيانات والكاش

الملفات المعنية:

- `lib/core/database/app_database.dart`
- `lib/core/database/app_database_provider.dart`
- `lib/features/quran/data/local/quran_resource_catalog_storage.dart`
- `lib/features/quran/data/quran_providers.dart`

الملاحظات:

- Drift مستخدم مع فهارس مناسبة لجداول القرآن والتفسير والترجمة.
- catalog storage يقرأ JSON من الملفات ويفكها على main isolate.
- provider لقوائم التفاسير/الترجمات يطلب العربية والإنجليزية بالتوازي إذا لم يجد cache.

الخطر:

- فتح قاعدة البيانات وترقية schema يحصل عند أول استخدام؛ إذا تزامن مع seed ستكون التكلفة ظاهرة.
- قراءة catalog JSON غالبًا صغيرة، لكن يفضّل نقل parsing إلى `compute` إذا كبرت القوائم.
- بعض `customSelect` يستخدم interpolation لأرقام آمنة، لكنه أقل قابلية للتخطيط والتحسين من variables.

## خطة التنفيذ المقترحة

### المرحلة 0: قياس قبل التعديل

الهدف: نعرف أين يتجمد التطبيق بالضبط قبل أن نغيّر كثيرًا.

- أضف `PerformanceProbe` بسيطًا في debug فقط يستخدم `SchedulerBinding.instance.addTimingsCallback` لتسجيل frames التي تتجاوز `32ms`.
- أضف markers بـ `TimelineTask` حول:
  - تحميل التفضيلات.
  - أول بناء لـ `QuranPageReader`.
  - `DefaultTafsirSeedService.ensureSeeded`.
  - `QuranDownloadRecoveryService.restorePendingDownloads`.
  - فتح قاعدة البيانات أول مرة.
- شغّل سيناريوهات ثابتة:
  - أول تثبيت نظيف.
  - فتح التطبيق بعد وجود DB.
  - فتح التطبيق مع session تنزيل معلقة.
  - تقليب 20 صفحة بسرعة.
  - تشغيل آية ثم فتح/إغلاق overlays.
- وثّق أرقام baseline داخل `docs/performance_baseline.md`.

معيار القبول:

- يوجد log واضح يقول: أي مهمة بدأت، كم أخذت، وكم frame بطيء حدث أثناءها.

### المرحلة 1: تخفيف أول تشغيل

الهدف: أول شاشة تظهر بسلاسة، ولا يبدأ seed/recovery إلا بعد استقرار أول تفاعل.

المهام:

- اجعل `AppConfig.load()` غير حاجز قدر الإمكان:
  - استخدم default backend فورًا.
  - حمّل env override بعد `runApp` إن لم يكن ضروريًا لأول frame.
- افصل startup tasks في `AppBootstrap` إلى `StartupTaskQueue`:
  - priority `critical`: لا شيء تقريبًا بعد التفضيلات.
  - priority `idle`: seed التفسير، warm-ups.
  - priority `userVisible`: recovery، لكن بعد موافقة أو إشعار.
- لا تشغل `ensureSeeded()` مباشرة بعد أول frame.
  - أجّله حتى `5-8s` أو حتى يفتح المستخدم التفسير أول مرة.
  - إن كان التفسير الافتراضي مطلوبًا، seed أول 3 سور فقط، ثم أكمل بالباقي idle.
- غيّر recovery من auto-resume إلى “اكتشف واستأذن”:
  - اقرأ sessions في الخلفية.
  - اعرض banner: `يوجد تنزيل غير مكتمل - استئناف`.
  - لا تبدأ 114 طلبًا تلقائيًا أثناء القراءة.
- أضف backoff إذا كان الجهاز في أول دقيقة تشغيل أو البطارية/الشبكة ضعيفة.

معيار القبول:

- في أول تشغيل نظيف لا يبدأ seed كامل ولا تنزيل كامل قبل تفاعل المستخدم أو مرور نافذة idle.
- لا يوجد frame بطيء متكرر بعد أول ظهور للقارئ بسبب seed/recovery.

### المرحلة 2: seed تدريجي وآمن

الهدف: التفسير الافتراضي يصبح محليًا دون ضغط مفاجئ على UI.

المهام:

- غيّر parsing في `TafsirMuyassarAssetDataSource` ليعيد `Map<int, List<RawTafsirRecord>>` جاهزًا من isolate بدل List ضخمة ثم grouping على main isolate.
- اجعل `DefaultTafsirSeedService` يدعم:
  - `ensureChapterSeeded(chapterNumber)`.
  - `seedAllInBackground({int batchSize = 1})`.
  - `cancel` أو `pause` عند انتقال التطبيق للخلفية أو بدء scroll كثيف.
- اجعل seed يكتب فصلًا واحدًا في كل دورة idle:
  - بعد كل فصل: `await Future<void>.delayed(const Duration(milliseconds: 16));`
  - بعد السور الكبيرة: delay أطول أو تقسيم batch إلى أجزاء.
- خزّن marker مستقل: `default_tafsir_seed_version`.
  - لا تفحص كل الفصول دائمًا عند كل startup.
  - افحص `version` أولًا، ثم fallback إلى DB فقط عند الحاجة.
- قلّل invalidate:
  - لا تعمل invalidate عند كل seed داخلي.
  - اعمل invalidate واحدًا عند نهاية seed أو عند فتح شاشة المكتبة.

معيار القبول:

- seed كامل لا يمنع تقليب الصفحات.
- فتح تفسير آية لأول مرة يضمن فصلها فقط بسرعة، ثم يكمل الباقي لاحقًا.

### المرحلة 3: عزل rebuilds في قارئ القرآن

الهدف: صفحة Mushaf تبقى مستقرة، ولا يعاد بناؤها إلا عند تغيير الصفحة أو highlight.

المهام:

- أضف `RepaintBoundary` حول:
  - `QcfPage`.
  - header/footer داخل الصفحة.
  - overlays ذات blur.
- افصل `QuranPageReader` إلى Widgets أصغر:
  - `QuranMushafPager` يراقب highlights/font فقط.
  - `QuranReaderChrome` يراقب overlay/currentPage فقط.
  - `QuranAudioOverlay` يراقب subset من الصوت.
- استخدم `ref.watch(provider.select(...))` في widgets:
  - شريط الصوت يراقب `currentAyah`, `isPlaying`, `isLoading`, `errorMessage`, `recitationId` فقط.
  - لا يراقب `position` إذا لا يعرضها.
- اجعل حفظ آخر صفحة أقل إزعاجًا:
  - debounce من `220ms` إلى `750-1200ms`.
  - لا تكتب إذا الصفحة نفسها محفوظة.
  - اكتب فورًا فقط عند pause/inactive/dispose.
- خفف `BackdropFilter`:
  - في الأجهزة الضعيفة أو عند الحركة استخدم لون شبه شفاف بدل blur.
  - اجعل blur ثابتًا لا يتغير مع كل tick.
- أزل `debugPrint` غير الضروري من `initState` و`dispose` في المسارات الساخنة.

معيار القبول:

- تقليب 20 صفحة لا ينتج bursts من writes للتفضيلات.
- تشغيل الصوت لا يعيد بناء `QcfPage` بسبب position updates.
- overlays لا تسبب drop واضح عند الفتح/الإغلاق.

### المرحلة 4: ضبط الصوت والتنزيلات

الهدف: الصوت والتنزيلات طويلة المدى لا تتحول إلى مصدر rebuild أو ضغط I/O.

المهام:

- افصل state عالي التردد عن state العام:
  - `PlaybackPositionProvider` مستقل ومخنوق إلى `250-500ms`.
  - `QuranAudioState` يحتفظ فقط بالحالة المنطقية: playing/loading/current/error.
- في `QuranSurahPlayerController`:
  - throttle لـ `positionStream` و`bufferedPositionStream`.
  - استخدم `select` في الشاشة لفصل أزرار التشغيل عن progress bar.
- في `QuranAudioDownloadController`:
  - throttle لتحديثات progress/status.
  - لا تنشئ `Map.of(_surahProgressMap)` لكل آية إلا عند تغير مرئي مهم.
  - cache لـ `baseDir` خارج loops.
  - اعرض التنزيل الكامل كعمل background واضح يمكن إيقافه، لا كعملية واجهة كثيفة.
- في `QuranDownloadSessionStore`:
  - حقن `SharedPreferences` عبر provider.
  - لا تستدعي `getInstance()` في كل method.
- افصل recovery عن controllers الثقيلة:
  - recovery يحدد فقط “ماذا يمكن استئنافه”.
  - controller يبدأ عند اختيار المستخدم.

معيار القبول:

- تشغيل آية لا يسبب rebuild شامل للشاشة.
- صفحة تنزيل الصوت لا تحدث state أكثر من 4 مرات في الثانية إلا عند اكتمال task.
- استعادة session لا تبدأ تنزيلًا طويلًا دون أمر واضح.

### المرحلة 5: تحسين data layer

الهدف: تقليل زمن قاعدة البيانات والـ JSON وتفادي عمل متكرر.

المهام:

- أضف provider لتهيئة قاعدة البيانات بعد أول frame لكن قبل أول عملية ثقيلة:
  - warm open DB فقط، بدون seed.
  - سجل زمن migration.
- استخدم query variables في `customSelect` بدل interpolation:
  - `WHERE resource_id = ? AND chapter_id = ?`
  - هذا أفضل للتخطيط، وأوضح أمانًا.
- أضف جداول metadata صغيرة:
  - `seed_status`
  - `resource_cache_versions`
  - `last_successful_recovery_check`
- انقل parsing لأي JSON أكبر من `200KB` إلى `compute`.
- راجع `flush: true` في writes غير الحرجة:
  - استخدمها فقط للجلسات المهمة جدًا.
  - catalog writes يمكن أن تكون بدون flush لتقليل التوقف.

معيار القبول:

- فتح DB لا يتزامن مع seed كامل.
- لا يوجد JSON كبير يفك على main isolate.

### المرحلة 6: تحسين الواجهات والقوائم

الهدف: فتح bottom sheets والقوائم لا يسبب hitch.

المهام:

- استبدل القوائم المبنية بـ `Column + for` إلى `ListView.builder` عندما تزيد عن 20 عنصرًا:
  - قائمة القراء في `ayah_audio_player_bar.dart`.
  - نتائج البحث في `quran_reader_search_sheet.dart`.
  - أي قائمة موارد في شاشات التحميل.
- استخدم `const` حيث يمكن، خاصة العناصر الثابتة في overlays.
- أضف `AutomaticKeepAliveClientMixin` فقط حيث يفيد ولا يزيد الذاكرة.
- قلل shadows والblur على العناصر المتحركة.
- أضف empty/loading skeleton خفيف بدل spinner مركزي طويل.

معيار القبول:

- فتح sheet القراء/البحث أقل من `100ms` على جهاز متوسط.
- لا يوجد hitch عند الكتابة في البحث.

## ترتيب التنفيذ العملي

1. **قياس الأداء**: أضف instrumentation و baseline.
2. **منع التزاحم عند الإقلاع**: أوقف seed/recovery التلقائي الثقيل.
3. **seed تدريجي**: اجعل التفسير يعمل on-demand + background idle.
4. **عزل القارئ**: `select`, `RepaintBoundary`, تخفيف blur.
5. **خنق تحديثات الصوت**: position/progress providers منفصلة ومحدودة.
6. **تحسين التنزيلات**: throttle progress، cache paths، recovery بإذن المستخدم.
7. **تنظيف data layer**: variables في queries، metadata versioning، parsing isolate.
8. **تحسين القوائم**: builders وكسل في bottom sheets.

## قائمة تحقق تفصيلية

### إقلاع التطبيق

- [ ] إنشاء `StartupTaskQueue` بمهام ذات أولوية وتأجيل.
- [ ] تأجيل `DefaultTafsirSeedService.ensureSeeded` عن أول 5 ثوانٍ أو حتى فتح التفسير.
- [ ] تغيير download recovery إلى prompt بدل auto-resume.
- [ ] تسجيل زمن `AppConfig.load`, preferences read, DB open.
- [ ] منع أي عملية شبكة كبيرة قبل استقرار أول شاشة.

### التفسير الافتراضي

- [ ] إضافة `ensureChapterSeeded`.
- [ ] إضافة seed marker/version.
- [ ] تحويل grouping إلى isolate.
- [ ] تقليل batch size للسور الكبيرة.
- [ ] invalidate مرة واحدة في نهاية seed.

### قارئ القرآن

- [ ] فصل `QuranMushafPager` عن chrome/audio.
- [ ] استخدام `select` بدل watch كامل للصوت والتفضيلات.
- [ ] إضافة `RepaintBoundary` حول `QcfPage`.
- [ ] زيادة debounce حفظ الصفحة.
- [ ] تعطيل أو تخفيف blur أثناء animation أو على الأجهزة الضعيفة.

### الصوت

- [ ] فصل `position` إلى provider مخنوق.
- [ ] منع `AyahAudioPlayerBar` من مراقبة `position` إن لم تعرضه.
- [ ] throttle لـ `QuranSurahPlayerController` streams.
- [ ] حد أقصى للكاش الصوتي/prefetch map أو تنظيفه عند تغير القارئ.

### التنزيلات

- [ ] throttle لتحديث progress.
- [ ] cache لمسار التنزيل الأساسي خارج loops.
- [ ] جعل full Quran download قابل للإيقاف والاستئناف بوضوح.
- [ ] session store يستخدم SharedPreferences provider واحد.
- [ ] recovery لا يبدأ controller طويل تلقائيًا.

### قاعدة البيانات والملفات

- [ ] warm open DB منفصل عن seed.
- [ ] استخدام query variables في custom queries.
- [ ] نقل JSON parsing الكبير إلى compute.
- [ ] تقليل `flush: true` للكتابات غير الحرجة.
- [ ] إضافة metadata لتجنب فحص 114 فصلًا دائمًا.

## مخاطر يجب الانتباه لها أثناء التنفيذ

- لا تؤجل seed التفسير بطريقة تكسر فتح التفسير بدون إنترنت؛ الحل هو `ensureChapterSeeded` عند الطلب.
- لا تجعل recovery صامتًا بالكامل؛ المستخدم يحتاج معرفة أن لديه تنزيلًا غير مكتمل.
- لا تفرط في `RepaintBoundary` حول كل شيء؛ استخدمه حول المناطق الثقيلة فقط.
- لا تزيل `position` من state قبل تعديل widgets التي تعتمد عليه.
- لا تجعل throttling يخفي التقدم الحقيقي في شاشات التنزيل؛ التحديث المرئي كل `250ms` كافٍ غالبًا.

## مؤشرات نجاح نهائية

- فتح التطبيق أول مرة لا يشعر المستخدم معه بتجميد بعد ظهور القارئ.
- تقليب الصفحات سلس حتى أثناء وجود أعمال خلفية مؤجلة.
- تشغيل الصوت لا يحرك rebuilds خارج شريط الصوت/highlight.
- بدء تنزيل كبير لا يؤثر على القراءة إلا بقدر بسيط ومفهوم.
- logs في debug تكشف فورًا أي مهمة تتجاوز ميزانية الأداء.

## اقتراحات ملفات للتعديل أولًا

- `lib/app/bootstrap/app_bootstrap.dart`: إدخال task queue وتأجيل seed/recovery.
- `lib/features/quran/application/default_tafsir_seed_service.dart`: تحويل seed إلى تدريجي/on-demand.
- `lib/features/quran/data/local/tafsir_muyassar_asset_data_source.dart`: نقل grouping/parse الثقيل إلى isolate.
- `lib/features/quran/presentation/pages/quran_page_reader.dart`: فصل rebuilds وتخفيف حفظ الصفحة.
- `lib/features/quran/application/quran_audio_controller.dart`: فصل/throttle position state.
- `lib/features/quran/application/quran_surah_player_controller.dart`: throttle streams.
- `lib/features/quran/application/quran_download_recovery_service.dart`: recovery بإذن المستخدم.
- `lib/features/quran/application/quran_audio_download_controller.dart`: throttle progress وتحسين loops.

## سجل التنفيذ

### حزمة 1: إقلاع واستعادة أكثر هدوءًا

- تم تأجيل مهام الإقلاع غير الحرجة في `AppBootstrap` بدل تشغيلها مباشرة بعد أول frame.
- تم إبقاء استعادة التنزيلات تلقائية، لكنها صارت تفحص وجود جلسة معلقة أولًا ثم تنتظر قليلًا وحالة app resumed قبل الاستئناف.
- تم تأجيل seed التفسير الافتراضي وجعله منخفض الأولوية في الخلفية، مع إبقاء seed المباشر سريعًا عند طلب المستخدم للتفسير.
- تم تخفيف تنزيل التفسير/الترجمة بإضافة yield قصير بين الفصول.
- تم جعل حفظ آخر صفحة في القارئ صامتًا ومؤجلًا، حتى لا يعيد بناء الواجهة أثناء التقليب.

### حزمة 2: عزل rebuilds وتحديثات الصوت

- تم جعل `AyahAudioPlayerBar` يراقب حقول الصوت المرئية فقط بدل حالة الصوت كاملة.
- تم جعل `QuranPageReader` يستمع فقط إلى `currentAyah/isPlaying/errorMessage` بدل نبضات `position`.
- تم خنق تحديثات `positionStream` في `QuranAudioController` إلى وتيرة مرئية كافية.
- تم خنق تحديثات `positionStream` و`bufferedPositionStream` في `QuranSurahPlayerController`.
- تم إضافة `RepaintBoundary` حول `QcfPage` وشريط الصوت والـ header/bottom panel لتقليل انتشار إعادة الرسم.

### حزمة 3: تنزيل الصوت بدون ضغط زائد

- تم خنق تحديثات حالة تنزيل الصوت المرئية بدل تحديث واجهة التنزيل عند كل آية.
- تم إبقاء تقدم التنزيل والآية الحالية والسرعة ظاهرة، لكن بوتيرة أخف على الواجهة.
- تم تخزين مسار التنزيل الأساسي مرة واحدة في بداية الجلسة بدل طلبه داخل كل آية.
- تم بناء كاش مؤقت للآيات الموجودة محليًا في بداية الجلسة بدل فحص مجلدات التخزين لكل آية.
- تم تقليل نسخ `surahDownloadProgress` إلى لحظات التحديث المرئي بدل كل دورة loop.

### حزمة 4: تفسير ميسّر أخف على main isolate

- تم نقل parsing والتجميع والترتيب الخاص بـ `ar_muyassar.json` إلى isolate بدل تنفيذ التجميع على main isolate.
- تم إبقاء `loadChapterTextsMap` متوافقًا مع الاستخدام القديم.
- تم إضافة `getAvailableChapterNumbers` حتى يستطيع seed الخلفي المرور على السور دون تحويل كل التفسير إلى كائنات دفعة واحدة.
- تم جعل `getChapterTexts` يحول السورة المطلوبة فقط إلى `TafsirText` عند الحاجة، مع caching للفصل المحوّل.
- تم تعديل seed التفسير الافتراضي ليحفظ سورة بسورة بدل تحميل خريطة كائنات كاملة أولًا.
- تم إضافة اختبار دخان يثبت أن asset التفسير الافتراضي ما زال يقرأ السور والنصوص.

### التالي المقترح

- إضافة instrumentation في debug لقياس frames البطيئة وأزمنة seed/recovery.
- تحويل قوائم القراء الطويلة في bottom sheets إلى بناء كسول عند الحاجة.
