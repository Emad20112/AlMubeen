# تحسين تجربة قراءة القرآن الكريم - الدخول المباشر + هيدر تفاعلي

## الوصف العام

تغيير تدفق الدخول لقراءة القرآن بحيث لا يظهر اختيار السورة عند الضغط على "قراءة القرآن" من الصفحة الرئيسية، بل يُدخل المستخدم مباشرة إلى صفحة القراءة. عند أول استخدام يبدأ من سورة الفاتحة (صفحة 1)، وفي المرات التالية يستأنف من آخر صفحة كان يقرأها. أيضاً إضافة هيدر أنيق يظهر/يختفي عند النقر مرة واحدة على الشاشة.

---

## التغييرات المطلوبة

### 1. حفظ واسترجاع آخر صفحة — خدمة `QuranReadingProgress`

#### [NEW] [quran_reading_progress.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/data/local/quran_reading_progress.dart)

- استخدام `drift` (الموجود بالفعل) لحفظ آخر صفحة في قاعدة البيانات المحلية.
- إضافة جدول `QuranReadingProgressCache` في `app_database.dart` يحتوي على:
  - `id` (ثابت = 1، مفتاح أساسي)
  - `lastPage` (آخر صفحة)
  - `lastSurahNumber` (آخر سورة)
  - `updatedAt` (تاريخ التحديث)
- إنشاء كلاس `QuranReadingProgress` للقراءة والكتابة من/إلى الجدول.
- إنشاء Riverpod providers:
  - `quranReadingProgressProvider` لقراءة آخر صفحة محفوظة
  - `saveQuranReadingProgressProvider` لحفظ الصفحة الحالية

> [!IMPORTANT]
> سيتطلب إضافة الجدول الجديد رفع `schemaVersion` من 3 إلى 4 وإضافة migration.

---

### 2. تعديل تدفق الدخول — من الصفحة الرئيسية مباشرة للقارئ

#### [MODIFY] [home_feature.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/home/presentation/widgets/home_feature.dart)

- تغيير `HomeFeatureAction.openSurahPicker` إلى `HomeFeatureAction.openQuranReader`

#### [MODIFY] [home_feature_grid.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/home/presentation/widgets/home_feature_grid.dart)

- تحديث action القرآن من `openSurahPicker` إلى `openQuranReader`

#### [MODIFY] [home_feature_card.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/home/presentation/widgets/home_feature_card.dart)

- استبدال استدعاء `openSurahPickerAndReader(context)` بالنقل المباشر إلى `QuranPageReader`
- يقرأ آخر صفحة محفوظة (عبر provider)، وإذا لم توجد يبدأ من صفحة 1 (الفاتحة)

---

### 3. إعادة تصميم صفحة القارئ — إزالة AppBar/BottomBar الثابتين + هيدر تفاعلي

#### [MODIFY] [quran_page_reader.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/presentation/pages/quran_page_reader.dart)

**التغييرات الرئيسية:**

1. **إزالة `AppBar` و `bottomNavigationBar` الثابتين** — تصبح الصفحة بوضع ملء الشاشة (immersive).
2. **إضافة `GestureDetector` للنقرة الواحدة** — عند النقر (tap) على الشاشة يتم toggle إظهار/إخفاء الهيدر والفوتر.
3. **إضافة `ValueNotifier<bool> _isOverlayVisible`** للتحكم بالإظهار/الإخفاء.
4. **حفظ الصفحة الحالية تلقائياً** — عند تغيير الصفحة يتم حفظها عبر `saveQuranReadingProgressProvider`.

#### [NEW] [quran_reader_header.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/quran/presentation/widgets/quran_reader_header.dart)

هيدر أنيق بتصميم glassmorphism متوافق مع ثيم التطبيق:

```
┌──────────────────────────────────────────────┐
│  ←(رجوع)    [أيقونات الأدوات]    ☰(drawer)  │
└──────────────────────────────────────────────┘
```

**من اليمين (RTL):**
- أيقونة **Drawer** (☰) — تفتح قائمة السور `SurahPicker` (القائمة الموجودة حالياً)
- أيقونة **عرض الآية مع الصورة** (`FlutterIslamicIcons.quran2`) — ستُبنى لاحقاً
- أيقونة **تشغيل الصوت** (`Icons.play_arrow_rounded`) — ستُبنى لاحقاً
- أيقونة **مشاركة** (`Icons.share_rounded`) — ستُبنى لاحقاً

**من الشمال (RTL):**
- زر **رجوع** (`Icons.arrow_back`) — للعودة إلى القائمة الرئيسية

**التصميم:**
- تأثير `BackdropFilter` (glassmorphism) مع ألوان `AppColors`
- أنيميشن `SlideTransition` من الأعلى عند الإظهار/الإخفاء
- أيقونات إسلامية من `flutter_islamic_icons`
- دعم الوضع الداكن والفاتح

---

## User Review Required

> [!IMPORTANT]
> **رفع إصدار قاعدة البيانات**: سيتم رفع `schemaVersion` من 3 إلى 4 لإضافة جدول حفظ التقدم. هل يوجد أي concerns بخصوص migration للمستخدمين الحاليين؟

> [!IMPORTANT]
> **الفوتر**: حسب طلبك، الفوتر سيُبنى لاحقاً. هل تريد مكان محجوز (placeholder) له في الكود أم نتركه تماماً للمرحلة القادمة؟

## Open Questions

1. **هل تريد إضافة أنيميشن انتقالية** (Hero/Fade) عند الدخول من الصفحة الرئيسية إلى صفحة القراءة؟
2. **بالنسبة لأيقونة Drawer** — هل تريدها تفتح `SurahPicker` الموجود حالياً (bottom sheet/dialog)، أم تريد Drawer كامل على الجانب؟

---

## خطة التنفيذ

| # | المهمة | الملفات |
|---|--------|---------|
| 1 | إضافة جدول `QuranReadingProgressCache` في الـ database + migration | `app_database.dart` |
| 2 | إنشاء `QuranReadingProgress` service + providers | `quran_reading_progress.dart`, `quran_providers.dart` |
| 3 | تحديث `HomeFeature` و`HomeFeatureCard` للدخول المباشر | `home_feature.dart`, `home_feature_grid.dart`, `home_feature_card.dart` |
| 4 | إنشاء `QuranReaderHeader` widget | `quran_reader_header.dart` |
| 5 | إعادة بناء `QuranPageReader` — fullscreen + tap overlay + حفظ تلقائي | `quran_page_reader.dart` |
| 6 | تشغيل `build_runner` لتوليد كود drift | أمر terminal |

---

## خطة التحقق

### Automated
```bash
flutter analyze
flutter build apk --debug
```

### Manual
- التحقق من أن الدخول الأول يبدأ من الفاتحة
- التحقق من حفظ واسترجاع آخر صفحة
- التحقق من ظهور/إخفاء الهيدر عند النقر
- التحقق من عمل أيقونة Drawer لفتح قائمة السور
- التحقق من عمل زر الرجوع
- التحقق من التوافق مع الوضع الداكن والفاتح
