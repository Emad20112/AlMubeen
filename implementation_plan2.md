# خطة تطوير الأذكار + السبحة الرقمية + تحديد القبلة

## تحليل الوضع الحالي (Current State Analysis)

### الأذكار - ما هو موجود حالياً:

| الجانب | الوضع الحالي | التقييم |
|---|---|---|
| **مصدر البيانات** | ملف `hisn_almuslim.json` محلي (~20KB) يحتوي على 10 تصنيفات فقط | ⚠️ ناقص جداً - الكتاب الأصلي فيه 130+ باباً |
| **بنية البيانات** | `AdhkarItem` (text, source, repeatCount) | ⚠️ ينقصه: الترجمة، الصوت، الفضل، رقم الحديث |
| **التصنيفات** | 10 فئات ثابتة في `MockAdhkarRepository` | ⚠️ Categories hardcoded ولا تتطابق مع الملف |
| **العرض** | شاشة Grid + شاشة تفاصيل بقائمة طولية | ⚠️ عرض بدائي - لا يوجد Swipe بين الأذكار |
| **العداد** | موجود ويعمل مع DB (Drift) + تصفير يومي | ✅ جيد |
| **المفضلة** | DB مهيأ لكن الواجهة غير متصلة | ⚠️ Backend جاهز بلا Frontend |
| **Quick Actions** | 4 أزرار (بحث، تسبيح، تم قراءته، المفضلة) كلها `onTap: () {}` | ❌ غير فعّالة |
| **السبحة** | لا توجد | ❌ مفقودة |
| **القبلة** | لا توجد | ❌ مفقودة |

### الملفات الحالية:
```
lib/features/adhkar/
├── data/
│   ├── adhkar_providers.dart         ← Riverpod providers
│   ├── data_sources/
│   │   ├── adhkar_db_data_source.dart ← Drift DB (progress + favorites)
│   │   └── adhkar_local_data_source.dart ← JSON loader
│   ├── islam_house_adhkar_repository.dart ← Cache + fallback
│   └── mock_adhkar_repository.dart    ← Hardcoded 10 categories + 4 items
├── domain/
│   ├── models/
│   │   ├── adhkar_category.dart
│   │   ├── adhkar_item.dart
│   │   └── adhkar_user_progress.dart
│   └── repositories/
│       └── adhkar_repository.dart
└── presentation/
    ├── controllers/
    │   └── adhkar_progress_controller.dart
    ├── screens/
    │   ├── adhkar_details_screen.dart  ← 535 سطر
    │   └── adhkar_grid_screen.dart     ← 199 سطر
    └── widgets/
        ├── adhkar_icon_mapper.dart
        ├── adhkar_navigation_bar.dart  ← 407 سطر (counter + nav)
        └── adhkar_text_settings.dart
```

---

## مقارنة الخدمات المتاحة

### 1. مصادر بيانات الأذكار (حصن المسلم)

| الخدمة | المميزات | العيوب | التوصية |
|---|---|---|---|
| **[rn0x/hisn_almuslim_json](https://github.com/rn0x/hisn_almuslim_json)** | ✅ 130+ باب كامل، ✅ عربي + إنجليزي، ✅ JSON نظيف | ❌ لا يحتوي صوت | ⭐ **الأفضل للبيانات** |
| **[muslim_data_flutter](https://pub.dev/packages/muslim_data_flutter)** | ✅ Package جاهز لـ Flutter، ✅ أذكار + مواقيت صلاة + أسماء الله | ❌ تبعية خارجية كبيرة | جيد لكن ثقيل |
| **الملف الحالي `hisn_almuslim.json`** | ✅ موجود فعلاً | ❌ 10 تصنيفات فقط، ❌ ناقص جداً | ❌ غير كافي |

> [!IMPORTANT]
> **التوصية:** تحميل ملف JSON كامل من مستودع `rn0x/hisn_almuslim_json` (130+ باب) وتضمينه محلياً في `assets/data/`. هذا يضمن عمل التطبيق **بدون إنترنت** ويوفر المحتوى الكامل لحصن المسلم.

### 2. تحديد اتجاه القبلة

| الخدمة | المميزات | العيوب | التوصية |
|---|---|---|---|
| **[flutter_qiblah ^3.2.0](https://pub.dev/packages/flutter_qiblah)** | ✅ جاهز، ✅ يدعم Android+iOS، ✅ يعطي اتجاه القبلة + الشمال + Offset | ❌ لا يعمل على iOS Simulator | ⭐ **الأفضل** |
| **حساب يدوي (Great Circle)** | ✅ بدون تبعيات، ✅ إحداثيات الكعبة ثابتة (21.4225°N, 39.8262°E) | ❌ يحتاج `flutter_compass` + `geolocator` يدوياً | جيد لكن أكثر عملاً |
| **[adhan](https://pub.dev/packages/adhan)** | ✅ **موجود فعلاً في `pubspec.yaml`!** يحتوي `Qibla.qibla(coordinates)` | ❌ يعطي الزاوية فقط بدون بوصلة | **استخدامه مع `flutter_compass`** |

> [!TIP]
> التطبيق يستخدم فعلاً حزمة `adhan: ^2.0.0+1` و `geolocator: ^14.0.2`! فقط نحتاج إضافة `flutter_compass` للحصول على اتجاه الجهاز، ثم دمجه مع `Qibla.qibla()` من `adhan` للحصول على بوصلة قبلة دقيقة بدون أي API خارجي.

---

## Proposed Changes (التغييرات المقترحة)

### المرحلة 1: ترقية بيانات الأذكار (Data Upgrade)

#### [MODIFY] [adhkar_item.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/adhkar/domain/models/adhkar_item.dart)
- إضافة حقول جديدة: `fadl` (فضل الذكر)، `reference` (رقم الحديث)، `translation` (ترجمة إنجليزية اختيارية)

#### [MODIFY] [adhkar_category.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/adhkar/domain/models/adhkar_category.dart)
- إضافة حقل `arabicTitle` منفصل عن `title` لدعم اللغتين

#### [NEW] `assets/data/hisn_almuslim_full.json`
- تحميل ملف JSON كامل (130+ باب) من مستودع `rn0x/hisn_almuslim_json` ومعالجته ليتوافق مع بنية النماذج الحالية

#### [MODIFY] [adhkar_local_data_source.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/adhkar/data/data_sources/adhkar_local_data_source.dart)
- تحديث المسار للملف الجديد وتحديث التحويل (parsing) ليناسب البنية الجديدة

#### [DELETE] [mock_adhkar_repository.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/adhkar/data/mock_adhkar_repository.dart)
- لم يعد مطلوباً بعد وجود البيانات الكاملة

---

### المرحلة 2: إعادة تصميم عرض الأذكار (UI Overhaul)

#### [MODIFY] [adhkar_details_screen.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/adhkar/presentation/screens/adhkar_details_screen.dart)
- **تغيير جذري في طريقة العرض:** استبدال القائمة الطولية (`SingleChildScrollView + Column`) بـ **PageView عمودي (Vertical PageView)** حيث يعرض كل ذكر في صفحة كاملة الشاشة
- تصميم بطاقة الذكر بشكل احترافي: النص العربي في المنتصف بخط كبير، المصدر والفضل في الأسفل
- **زر عداد دائري كبير** في منتصف الشاشة السفلي يعمل بالنقر مع `HapticFeedback.lightImpact()` + اهتزاز أقوى عند الاكتمال
- انتقال تلقائي للذكر التالي عند اكتمال العداد مع أنيميشن سلس

#### [MODIFY] [adhkar_grid_screen.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/adhkar/presentation/screens/adhkar_grid_screen.dart)
- تفعيل أزرار Quick Actions (بحث، تسبيح، تم قراءته، المفضلة)
- إضافة شريط تقدم يومي (Daily Progress) يُظهر نسبة الأذكار المكتملة اليوم
- تحسين بطاقات التصنيفات لعرض عدد الأذكار المكتملة من الإجمالي

#### [MODIFY] [adhkar_navigation_bar.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/adhkar/presentation/widgets/adhkar_navigation_bar.dart)
- تبسيط شريط التنقل ليكون أخف وزناً مع PageView الجديد

---

### المرحلة 3: السبحة الرقمية (Digital Tasbih)

#### [NEW] `lib/features/adhkar/presentation/screens/tasbih_screen.dart`
- شاشة سبحة رقمية كاملة الشاشة بتصميم مظلم هادئ (Dark Mode)
- **عداد دائري كبير** في المنتصف مع أنيميشن نبضي عند كل نقرة
- أزرار ثابتة: سبحان الله (33)، الحمد لله (33)، الله أكبر (33)، لا إله إلا الله (1) = **100 إجمالي**
- إمكانية إضافة ذكر مخصص بعدد مخصص
- `HapticFeedback.lightImpact()` عند كل نقرة + `HapticFeedback.heavyImpact()` عند كل 33
- حفظ العدد في `SharedPreferences` أو Drift DB
- زر إعادة التعيين

#### [NEW] `lib/features/adhkar/presentation/controllers/tasbih_controller.dart`
- Riverpod Notifier لإدارة حالة السبحة (العدد الحالي، الذكر المحدد، الهدف)

---

### المرحلة 4: بوصلة القبلة (Qibla Compass)

#### [NEW] `lib/features/qibla/` (Feature جديد بالكامل)
```
lib/features/qibla/
├── data/
│   └── qibla_service.dart         ← يستخدم adhan + flutter_compass
├── presentation/
│   ├── screens/
│   │   └── qibla_compass_screen.dart
│   └── widgets/
│       ├── compass_widget.dart     ← البوصلة المتحركة (CustomPainter)
│       └── calibration_dialog.dart ← تعليمات المعايرة
```

#### التقنيات المستخدمة:
- **`adhan` (موجود فعلاً):** `Qibla.qibla(Coordinates(lat, lng))` لحساب زاوية القبلة
- **`geolocator` (موجود فعلاً):** للحصول على إحداثيات المستخدم
- **`flutter_compass` (جديد):** للحصول على اتجاه الجهاز الفعلي عبر المغناطيسومتر
- **المعادلة:** `rotation = qiblaAngle - deviceHeading` → تدوير إبرة البوصلة

#### [MODIFY] [app_router.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/app/routing/app_router.dart)
- إضافة مسارات: `/tasbih`، `/qibla`

#### [MODIFY] [home_feature_grid.dart](file:///c:/Users/Emad/AndroidStudioProjects/Al-Mubeen/lib/features/home/presentation/widgets/home_feature_grid.dart)
- إضافة بطاقتين جديدتين: "السبحة" و "اتجاه القبلة"

#### [MODIFY] `pubspec.yaml`
- إضافة: `flutter_compass: ^0.8.0`

---

## Open Questions

> [!IMPORTANT]
> **1. بيانات الأذكار:** هل تريد تحميل ملف JSON كامل من GitHub وتضمينه في التطبيق محلياً؟ أم تفضل استخدام حزمة `muslim_data_flutter` الجاهزة (أسهل لكن تبعية أكبر)؟

> [!IMPORTANT]
> **2. تصميم صفحة الذكر:** هل تفضل عرض الأذكار بنظام **Swipe عمودي (كل ذكر صفحة كاملة)** مثل تطبيقات TikTok/Reels؟ أم تفضل تصميم بطاقات أفقية مثل Stories؟

> [!IMPORTANT]
> **3. بوصلة القبلة:** هل تريد بوصلة بسيطة (سهم يشير للقبلة)؟ أم بوصلة متقدمة (دائرة بوصلة كاملة مع درجات ورسم متحرك)؟

---

## Verification Plan

### المرحلة 1 (البيانات):
- التأكد من أن عدد التصنيفات أكثر من 100 بعد التحديث
- التأكد من أن كل ذكر يحتوي على النص والمصدر والعدد

### المرحلة 2 (الواجهة):
- فحص PageView للأذكار بالتمرير السريع
- التأكد من عمل العداد وحفظ التقدم اليومي
- التأكد من عمل المفضلة

### المرحلة 3 (السبحة):
- اختبار العداد والاهتزاز
- التأكد من حفظ العدد عند إغلاق التطبيق

### المرحلة 4 (القبلة):
- اختبار على جهاز حقيقي (المغناطيسومتر لا يعمل على المحاكي)
- مقارنة اتجاه القبلة مع تطبيقات معروفة (مثل تطبيق القبلة من Google)
  طيب بما أن لدينا الآن شاشتين شاشة للقراءة مع تشغيل الصوت للآيات بعد أن يحدد المستخدم الآية المعينة لتشغيلها وفي شاشة لاستماع السورة كاملة. أريد أن أخطط معك لتغيير وتعديل طريقة ظهور الشاشات الخاصه بمسار الاستماع الى القران الكريم وتشغيلها وتحميل المقاطع فيها. أولاً أريد إنشاء شاشة في البداية تعرض للمستخدم القراء بشكل عمودي كأنها شاشة جهة الاتصال مع خيارين في أقصى شمال البطاقة. الخيار الأول لتنزيل التلاوة لسور القرآن الكريم كامل والخيار الثاني لتنزيل تلاوة سورة معينة. عند الضغط على الخيار الأول اللي هو تنزيل التلاوة للقرآن الكريم كامل يتم استخدام widget وعمليات تحميل التلاوة الموجود حالياً في المشروع. وإذا تم اختيار تنزيل  تلاوة لسوره معينة يتم نقله إلى شاشة جديدة سوف نقوم بإنشائها وهي التي تعرض سور القرآن الكريم كاملة بتلاوة القارئ الذي أختاره بنفس الطريقة كأنها شاشة جهة الاتصال أسماء الصور مع زر في أقصى الشمال لتنزيل تلاوة هذه الصورة. عند اكتمال تحميل التلاوة لهذه الصورة يتم تشغيلها. وأيضاً أريد إذا في طريقة لتحميل وتخزين الملف الصوتي أو الملفات الصوتية محلياً ويكون حجمها أصغر وجودتها جيدة وتشتغل بسلاسة. وأضف إلى ذلك التحسينات للسلاسة في الـ UI. الآن بعد أن قرأت تعليماتي هذا وما أريده بالضبط، أنشئ خطة تنفيذية لتغيير الوضع الحالي إلى الخطة هذه.