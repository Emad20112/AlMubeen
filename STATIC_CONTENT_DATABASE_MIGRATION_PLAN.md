# خطة ترحيل المحتوى الثابت من ملفات JSON إلى قاعدة البيانات المحلية وتحسين الأداء

# (STATIC_CONTENT_DATABASE_MIGRATION_PLAN)

## 1. الملخص التنفيذي والهدف

يهدف هذا المشروع إلى التخلص التام من قراءة وتحليل ملفات JSON الثابتة أثناء تشغيل تطبيق **Al-Mubeen (المبين)**، ونقل كافة البيانات الثابتة إلى قاعدة البيانات المحلية الحالية (**Drift / SQLite**)، مع ضمان:

1. **انعدام زمن التحليل والقراءة في مسار بدء التشغيل (Startup Path):** إزالة قراءة وتفسير ملفات JSON وتفريغها في الذاكرة أو كتابتها في ملفات كاش مؤقتة.
2. **الحفاظ الكامل والدقيق على سلامة بيانات المستخدم:** عدم مساس أو استبدال قاعدة البيانات الحالية بملف عشوائي، بل إجراء ترحيل Schema Migrations آمن ومنظم، يحافظ على علامات القراءة، والأوراد اليومية، والمفضلة، وتتبع الإنجاز، والتفاسير والتراجم المحملة مسبقًا.
3. **تجهيز البيانات مسبقًا (Pre-seeded Data Pipeline):** توليد ملف قاعدة البيانات وتضمينه أو ترحيل البيانات آليًا ومضمنًا برمجياً في بيئة التطوير، بحيث تُحقن البيانات في قاعدة البيانات دون أي استيراد لملفات JSON على جهاز المستخدم في الإنتاج.
4. **الاعتماد الصارم على قاعدة البيانات:** تصبح جداول SQLite في Drift هي المصدر الوحيد، وتُحذف ملفات JSON القديمة ومراجعها من مسار الإنتاج.

---

## 2. تحليل الوضع الراهن (Current State Analysis)

### 2.1. ملفات JSON الثلاثة المستهدفة

بناءً على الفحص الفعلي لمجلد `assets/data/`:

1. **`assets/data/Names_Of_Allah.json`**:
   - الحجم: **24,735 بايت** (~24.7 KB).
   - عدد السجلات: **99 سجلاً**.
   - البنية: قائمة عناصر JSON تحتوي على:
     - `id` (int: 1 إلى 99).
     - `name` (String: اسم الله الحسنى بالرسم القرآني والتشكيل، مثل "اللَّهُ"، "الرَّحْمَنُ").
     - `text` (String: شرح ومعنى الاسم).
2. **`assets/data/40-hadith-nawawi.json`**:
   - الحجم: **164,148 بايت** (~160.3 KB).
   - عدد السجلات: **42 حديثاً**.
   - البنية: قائمة كائنات JSON تحتوي على:
     - `hadith` (String: نص الحديث الشريف وسنده وتخريجه).
     - `description` (String: شرح وفوائد الحديث).
3. **`assets/data/hisn_almuslim.json`**:
   - الحجم: **133,837 بايت** (~130.7 KB).
   - عدد السجلات: **132 فئة** (أذكار وأدعية) بإجمالي **261 ذكراً ودعاءً**.
   - البنية: كائن خريطة مفتاحية (Map<String, {text: List<String>, footnote: List<String>}>).
   - _ملاحظة:_ يوجد بالفعل جدولان في Drift تم إنشاؤهما في الإصدار 10: `hisn_content_cache` و `hisn_content_item_cache`، ولكن يتم ملؤهما عند التشغيل الأول بقراءة `hisn_almuslim.json` عبر `rootBundle` وتفكيكها ثم إدخالها في قاعدة البيانات!

### 2.2. أماكن الاستدعاء والتحميل الحالية في الكود

- **`lib/features/names_of_allah/data/names_of_allah_local_data_source.dart`**:
  - يقرأ `assets/data/Names_Of_Allah.json` عبر `rootBundle.loadString()`.
  - يفكك JSON عبر `Isolate.run(_parseAllahNamesAsset)`.
  - يكتب نسخة كاش على القرص في `getApplicationSupportDirectory()/names_of_allah/names_of_allah_v1.json`!
  - يُستدعى دالة `warmUp()` من `AppBootstrap._scheduleDeferredWarmUps()` ومن شاشة `NamesOfAllahScreen.initState()`.
- **`lib/features/hadith_nawawi/data/hadith_nawawi_local_data_source.dart`**:
  - يقرأ `assets/data/40-hadith-nawawi.json` عبر `rootBundle.loadString()`.
  - يفكك JSON عبر `Isolate.run(_parseHadithNawawi)`.
  - يُستدعى دالة `warmUp()` من `AppBootstrap._scheduleDeferredWarmUps()` ومن شاشة `HadithNawawiScreen.initState()`.
- **`lib/core/data/hisn_content_shared_store.dart`**:
  - يفحص إذا كانت جداول `hisn_content_cache` فارغة. إذا كانت فارغة، يقرأ `assets/data/hisn_almuslim.json` عبر `rootBundle.loadString()`، ثم يُفككها بـ `compute(_parseHisnContent)`، ثم يدخلها جماعياً في `_db.hisnContentCache` و `_db.hisnContentItemCache`.
- **`pubspec.yaml`**:
  - يحتوي على تضمين المجلد كاملاً: `- assets/data/`.

### 2.3. بنية قاعدة البيانات المحلية الحالية

- **التقنية المستخدمة:** مكتبة **Drift** (`drift: ^2.33.0` مع `drift_flutter: ^0.3.0` و `sqlite3_flutter_libs: ^0.6.0+eol`).
- **الموقع والكلاس:** `lib/core/database/app_database.dart` الكلاس الرئيسي `AppDatabase extends _$AppDatabase`.
- **إصدار المخطط الحالي:** `schemaVersion => 13`.
- **الجداول الحالية (18 جدولاً):**
  - جداول القرآن والتلاوات: `quran_chapter_cache`, `quran_verse_cache`, `quran_recitation_cache`, `quran_cache_metadata`.
  - جداول بيانات المستخدم الحساسة (يجب الحفاظ عليها بنسبة 100%):
    - `adhkar_progress_cache`: تتبع تكرار كل ذكر وإتمامه وتاريخ التحديث اليومي.
    - `adhkar_favorites`: مفضلة الأذكار الفردية.
    - `category_favorites`: مفضلة فئات الأذكار والأدعية.
    - `quran_reading_progress_cache`: آخر صفحة وسورة وصل إليها القارئ.
    - `quran_bookmarks`: علامات القراءة المرجعية.
    - `wirds_table`, `wird_daily_progress_table`, `wird_cycle_history_table`, `wird_achievements_table`: نظام خطط الأوراد والختمات اليومية وتاريخها.
    - `downloaded_tafsirs`, `downloaded_translations`, `tafsir_text_cache`, `translation_text_cache`: التفاسير والتراجم المحملة ونصوصها.
  - جداول حصن المسلم: `hisn_content_cache`, `hisn_content_item_cache`.

### 2.4. تشخيص بطء بدء التطبيق (Root Cause Analysis)

1. **السبب المؤكد 1:** عند بدء التطبيق، جدول خط البدء في `AppBootstrap` يطلق مهام متعددة متتالية (`ensureSeeded()` للتفسير الميسر، ثم استعادة التحميلات، ثم warm-up لأسماء الله، ثم warm-up للأحاديث النبوية).
2. **السبب المؤكد 2:** قراءة وفك ملفات JSON من مسار الأصول (`rootBundle`) ثم معالجتها في الذاكرة وكتابة كاش مؤقت على القرص لأسماء الله، وقراءة وحفظ جداول حصن المسلم عند أول فتح لقسم الأذكار أو الأدعية.
3. **السبب المؤكد 3:** استهلاك موارد المعالج والذاكرة وإشغال خيط الأحداث والـ I/O عند فتح الشاشات لأول مرة لأن مصادر البيانات كانت تُعيد فك السلاسل النصية ومسح الكاش.

---

## 3. القرار المعماري واستراتيجية التخزين (Storage Strategy Decision)

### التقييم والاختيار:

- **الخيار المرفوض (استبدال ملف قاعدة البيانات بالكامل بملف جاهز Pre-populated SQLite DB):**
  - **مرفوض قطعاً وبشدة:** لأن التطبيق قيد التشغيل بالفعل لدى مستخدمين ويحتوي على سجلات حيوية (أوراد، تقدم قراءة القرآن، مفضلة، إنجازات، تفاسير منزلة). استبدال ملف `al_mubeen.sqlite` سيمحو كافة بيانات المستخدمين!
  - كما أن محاولة دمج ملفين عبر `ATTACH DATABASE` في أجهزة مختلفة مع تشفير sandbox قد تفشل أو تتطلب صلاحيات ومسارات معقدة.
- **الخيار المعتمد والأمثل هندسياً (Schema Migration V14 مع توليد البيانات الثابتة في الكود كـ Pre-compiled In-Code Statements):**
  - رفع `schemaVersion` من **13** إلى **14** داخل `AppDatabase`.
  - إضافة جدولين جديدين في Drift:
    1. `NamesOfAllahEntries`: يحوي الحقول (`id`, `name`, `meaning`, `search_index`).
    2. `HadithNawawiEntries`: يحوي الحقول (`id`, `hadith_number`, `title`, `preview`, `full_text`, `source`, `description`, `search_index`).
  - الاستفادة من جدولي `HisnContentCache` و `HisnContentItemCache` الموجودين أصلاً في المخطط (الإصدار 10).
  - كتابة كود ترحيل آمن وتوليد بيانات ثابتة مسبقة الحساب (Pre-compiled Static Dataset / Seed Generator) يتم إدراجها ضمن Transaction أثناء ترقية المخطط أو عند `onCreate`.
  - عند الترقية من `from < 14`:
    - يتم إنشاء جدولي أسماء الله الحسنى والأحاديث النبوية.
    - يتم إدخال بيانات الـ 99 اسماً والـ 42 حديثاً وبيانات حصن المسلم الـ 132 فئة والـ 261 ذكراً مباشرة دفعة واحدة في معاملة SQLite ذرية وسريعة جداً (تستغرق < 50ms لجميع الجداول).
    - لا يتم استدعاء `rootBundle` ولا تحليل JSON نهائياً، لا في أول تشغيل ولا في أي تشغيل تالٍ!
  - لمستخدمي التثبيت الجديد (`onCreate`): يتم استدعاء `migrator.createAll()` ثم تعبئة البيانات الثابتة الأولية تلقائياً.

---

## 4. تصميم الجداول الجديدة في Drift

### 4.1. جدول أسماء الله الحسنى (`NamesOfAllahEntries`)

```dart
@DataClassName('NamesOfAllahTableData')
class NamesOfAllahEntries extends Table {
  IntColumn get id => integer()(); // 1..99
  TextColumn get name => text()(); // الاسم بالتشكيل الكامل
  TextColumn get meaning => text()(); // الشرح والمعنى
  TextColumn get searchIndex => text()(); // نص مطبّع للبحث الفوري بدون تشكيل

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

### 4.2. جدول الأربعين النووية (`HadithNawawiEntries`)

```dart
@DataClassName('HadithNawawiTableData')
class HadithNawawiEntries extends Table {
  IntColumn get id => integer()(); // 1..42
  IntColumn get hadithNumber => integer()(); // رقم الحديث المستخرج
  TextColumn get title => text()(); // عنوان الحديث
  TextColumn get preview => text()(); // معاينة مختصرة
  TextColumn get fullText => text()(); // نص الحديث الكامل وسنده
  TextColumn get source => text()(); // مصدر الحديث وتخريجه
  TextColumn get description => text()(); // الشرح والفوائد
  TextColumn get searchIndex => text()(); // نص مطبّع للبحث

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

### 4.3. جدولا حصن المسلم (`HisnContentCache` و `HisnContentItemCache`)

- موجودان مسبقاً في `AppDatabase` (من الإصدار 10).
- جدول الفئات `hisn_content_cache`:
  - `id`: المفتاح الأساسي (مثل `cat_0`, `dua_cat_0`).
  - `title`: العنوان المعروض.
  - `subtitle`: الوصف الفرعي (مثل "3 أذكار").
  - `iconKey`: أيقونة الفئة.
  - `count`: عدد العناصر.
  - `arabicTitle`: العنوان العربي الأصلي.
  - `priority`: الأولوية في العرض.
  - `type`: نوع الفئة (`adhkar` أو `dua`).
- جدول العناصر `hisn_content_item_cache`:
  - `id`: المفتاح الأساسي (مثل `cat_0_item_0`).
  - `categoryId`: معرف الفئة الأب.
  - `content_text`: متن الذكر أو الدعاء بتشكيله الكامل.
  - `source`: المصدر / التخريج.
  - `repeatCount`: عدد مرات التكرار.
  - `fadl`, `reference`, `translation`: حقول إضافية اختيارية.
  - `type`: النوع (`adhkar` أو `dua`).

---

## 5. خطة ترحيل البيانات وسلامة المستخدم (Migration & Safety Strategy)

### 5.1. حماية بيانات المستخدم

- لن يتم لمس جداول `adhkar_progress_cache`, `adhkar_favorites`, `category_favorites`, `quran_bookmarks`, `quran_reading_progress_cache`, `wirds_table`, إلخ.
- عمليات الإدراج للجداول الثابتة تستخدم `InsertMode.insertOrReplace` أو `insertOnConflictUpdate` حتى إذا أعيد تشغيل الترحيل لأي سبب لا يحدث استثناء `UNIQUE constraint failed`.
- تُنفّذ خطوة الترحيل بالكامل داخل `db.transaction()` لضمان الذرية (Atomic Transaction).

### 5.2. أداة توليد البيانات الثابتة (Code Pre-seeding Generator)

- لضمان عدم وجود أي JSON parsing في كود الإنتاج أو أثناء إقلاع التطبيق، يتم تشغيل سكربت توليد في بيئة التطوير يُخرج ملف بيانات Dart ثابتة (`lib/core/database/static_data_seeds.dart`) يحتوي على السجلات الجاهزة ككائنات Companion أو كصفوف إدخال جاهزة.
- حجم السجلات الثابتة بعد التحويل إلى Dart حوالي 400 كيلوبايت كود مجمّع، يُخزّن مباشرة في مساحة الـ code text في التطبيق، ويُكتب في SQLite في أول تشغيل فقط في أجزاء من الثانية.

---

## 6. تحديث طبقة الوصول للبيانات (Repositories & Data Sources)

### 6.1. أسماء الله الحسنى:

- تعديل `NamesOfAllahLocalDataSource` ليعتمد على `AppDatabase`.
- الاستعلام: `select(db.namesOfAllahEntries).get()` مرتبة حسب `id`.
- دعم البحث المباشر في قاعدة البيانات أو التخزين المؤقت في الذاكرة (Memory cache) أثناء الجلسة فقط.
- إزالة قراءة ملف JSON، وإزالة كتابة ملف الكاش على القرص في `getApplicationSupportDirectory()`.

### 6.2. الأحاديث النبوية:

- تعديل `HadithNawawiLocalDataSource` ليعتمد على `AppDatabase`.
- الاستعلام: `select(db.hadithNawawiEntries).get()` مرتبة حسب `id`.
- إزالة قراءة ملف JSON و `Isolate.run`.

### 6.3. حصن المسلم:

- تعديل `HisnContentSharedStore` للاعتماد الحصري على `_loadFromDatabase()`.
- إزالة كود القراءة من `rootBundle.loadString(_jsonPath)` وتفكيك JSON في الخلفية عند الفراغ؛ لأن قاعدة البيانات ستكون محقونة ومحدثة مسبقاً من خلال الـ Seed في المخطط V14.
- في حال كان الجدول فارغاً لسبب غير متوقع، استدعاء دالة الـ Seed المباشرة من `static_data_seeds.dart`.

---

## 7. إزالة ملفات JSON وتنظيف المشروع

بعد اكتمال بناء وتوليد ملفات Drift واجتياز كافة الاختبارات:

1. إثبات مطابقة عدد وسجلات البيانات بنسبة 100% بين ملفات JSON وقاعدة البيانات.
2. حذف ملفات:
   - `assets/data/Names_Of_Allah.json`
   - `assets/data/40-hadith-nawawi.json`
   - `assets/data/hisn_almuslim.json`
3. تنظيف أي مراجع تشغيلية لهذه الملفات في الكود التوثيقي ومسارات الأصول.
4. الإبقاء على ملفات الخطوط والصور والتفسير التي لم تكن ضمن الملفات الثلاثة المطلوبة (مع الحفاظ على `ar_muyassar.json` إذا كان قيد العمل لحين ترحيل خاص به، وأيقونات التطبيق).

---

## 8. خطة الاختبار والتحقق (Verification & Rollback)

1. **فحص صحة البيانات (Data Integrity Test):**
   - اختبار مقارنة دقيق يتأكد أن:
     - عدد أسماء الله الحسنى = 99، وجميع الحقول مطابقة بالحرف.
     - عدد الأحاديث = 42، وجميع النصوص والشروح مطابقة بالحرف.
     - عدد فئات حصن المسلم = 132 فئة، والعناصر = 261 عنصراً، والربط صحيح ومطابق.
2. **فحص الترحيل (Migration Test):**
   - اختبار إنشاء قاعدة بيانات من الإصدار 13 وترقيتها إلى 14 والتحقق من بقاء بيانات المستخدم واكتمال البيانات الثابتة.
3. **فحص التحليل الساكن واختبارات الوحدة:**
   - تشغيل `dart run build_runner build --delete-conflicting-outputs`.
   - تشغيل `flutter test`.
   - تشغيل `flutter analyze`.
4. **خطة التراجع (Rollback Strategy):**
   - تم التحقق من Git status والتأكد من نظافة الفرع `refactor/ui-ux-performance`.
   - إذا حدث أي طارئ، يمكن التراجع عبر Git Commit، مع الحفاظ على قاعدة بيانات نظيفة بزيادة الإصدار.
