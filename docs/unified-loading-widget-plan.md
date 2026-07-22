# خطة إنشاء ويدجت انتظار موحد (Unified Loading Widget)

## 1. المشكلة

تنتشر `CircularProgressIndicator` البسيطة في 15+ مكاناً في الواجهة بدون هوية بصرية موحدة. عند تغيير القارئ أو تحميل ترجمة/تفسير، تظهر `CircularProgressIndicator` المجردة دون أي أيقونة أو رسالة، مما يعطي شعوراً بأن التطبيق "معلق" بدلاً من أنه "يعمل".

## 2. الهدف

إنشاء ويدجت واحد `AppLoadingOverlay` يكون:
- خفيفاً ومناسباً لعمليات **ثوانٍ معدودة** (لا يستبدل `AppLoadingView` المخصص للعمليات الطويلة)
- يستخدم أيقونة إسلامية من مكتبة `Icons.*` الموجودة حالياً
- يدعم رسالة مخصصة (مثل: "جاري تحميل التفسير")
- يدور بشكل دائري أنيق (ليس `CircularProgressIndicator` المجرد)
- يمكن عرضه كـ **overlay** (يغطي فقط المنطقة المتأثرة) أو **مركزي** (عرض كامل)

## 3. تحليل الأيقونات المتاحة حالياً

الأيقونات المستخدمة فعلاً في التطبيق (كلها من Material Icons):

| الاستخدام | الأيقونة | الموقع الحالي |
|-----------|----------|---------------|
| كتاب/مصحف عام | `auto_stories_outlined` | `app_loading_view.dart`، `_InitialLoading` |
| كتاب مفتوح | `menu_book_rounded` | غير مستخدم |
| سماعات/استماع | `headphones_rounded` | `quran_audio_download_screen.dart` (‎635) |
| صوت | `volume_up_rounded` | شاشة الاستماع |
| ترجمة | `translate_rounded` | `translation_bottom_sheet.dart` |
| تفسير | `menu_book_rounded` | `tafsir_bottom_sheet.dart` (‎70) |
| تلاوة | `mic_rounded` | `_reciterTile` |
| بحث | `search_rounded` | `quran_reader_search_sheet.dart` |
| علامة مرجعية | `bookmark_rounded` | `quran_bookmarks_sheet.dart` |
| هلال/نجمة | لا يوجد | يمكن إضافته لاحقاً |

**المقترح:** استخدام أيقونات موجودة فعلاً لكل حالة:
- تحميل التفسير → `menu_book_rounded`
- تحميل الترجمة → `translate_rounded`
- تغيير القارئ → `mic_rounded` أو `headphones_rounded`
- تحميل عام → `auto_stories_outlined`
- حفظ العلامات → `bookmark_rounded`

## 4. التصميم المقترح

```
┌─────────────────────────────┐
│    ┌─────────────────┐      │
│    │    🕌 أيقونة     │      │
│    │    دائرية        │      │
│    │    ← تدور        │      │
│    └─────────────────┘      │
│                             │
│    "جاري تغيير القارئ"      │
│    (نص صغير تحتها)          │
│                             │
└─────────────────────────────┘
```

**التفاصيل:**
- الأيقونة داخل دائرة متدرجة (تأخذ ألوان `maroon` الموجودة)
- دوران خفيف (AnimationController مع `Curves.easeInOutCubic`)
- منطقة شفافة خلفها (`Colors.black12`) تمنع التفاعل أثناء التحميل
- حجم صغير: 120×120 للـ overlay، أو 200×200 للوضع المركزي
- تناسب `SafeArea` على الحواف

## 5. نقاط الاستبدال (Priority 1)

| الموقع | العملية | الأيقونة المقترحة | الرسالة |
|--------|---------|-------------------|---------|
| `surah_player_controls.dart` (داخل زر التشغيل) | تشغيل السورة/تغيير القارئ | `headphones_rounded` | "جاري تجهيز التلاوة" |
| `ayah_audio_player_bar.dart` (داخل زر التشغيل) | تشغيل آية/تغيير القارئ | `headphones_rounded` | "جاري تجهيز التلاوة" |
| `translation_bottom_sheet.dart` (75, 119) | تحميل الترجمة | `translate_rounded` | "جاري تحميل الترجمة" |
| `tafsir_bottom_sheet.dart` (66, 210) | تحميل التفسير | `menu_book_rounded` | "جاري تحميل التفسير" |
| `tafsir_viewer_screen.dart` (51, 127) | تحميل التفسير | `menu_book_rounded` | "جاري تحميل التفسير" |
| `ayah_interaction_overlay.dart` (339) | تشغيل آية | `headphones_rounded` | "جاري التحميل" |

## 6. هيكل الكود المقترح

```
lib/core/widgets/app_loading_overlay.dart
```

```dart
@immutable
class AppLoadingOverlayData {
  final IconData icon;
  final String message;
  final bool isOverlay; // true = يغطي المنطقة فقط, false = عرض كامل
}

class AppLoadingOverlay extends StatefulWidget {
  // المعاملات: icon, message, isOverlay, child
}

// داخله:
// - AnimationController لدوران الأيقونة
// - Container دائري مع gradient (maroon700 → maroon900)
// - Icon بلون أبيض داخل الدائرة
// - Text للرسالة تحتها
// - if isOverlay → Stack(child + Positioned filled overlay)
// - if !isOverlay → Column center
```

## 7. الفرق بين `AppLoadingOverlay` (جديد) و `AppLoadingView` (موجود)

| الخاصية | `AppLoadingOverlay` | `AppLoadingView` |
|---------|-------------------|-----------------|
| الاستخدام | عمليات قصيرة (ثوانٍ) | عمليات طويلة (صفحات كاملة) |
| نوع المؤشر | دائري دوار بأيقونة | `LinearProgressIndicator` |
| الحجم | صغير (overlay) | كبير (full page) |
| نسبة التقدم | لا | نعم (اختياري) |
| منع التفاعل | نعم (امتلاء خلفي شفاف) | لا (لأنها الصفحة نفسها) |

## 8. خطة التنفيذ

1. إنشاء `lib/core/widgets/app_loading_overlay.dart`
2. اختبار الـ widget في standalone (معاينة سريعة)
3. استبدال `CircularProgressIndicator` في `translation_bottom_sheet.dart`
4. استبدال `CircularProgressIndicator` في `tafsir_bottom_sheet.dart`
5. استبدال `CircularProgressIndicator` في `tafsir_viewer_screen.dart`
6. إضافة overlay عند تغيير القارئ في `surah_player_controls.dart`
7. إضافة overlay عند تغيير القارئ في `ayah_audio_player_bar.dart`
8. تحليل الأداء والتأكد من عدم وجود تسريب للـ AnimationController

## 9. ملاحظات

- لا تستبدل `_QuranPageLoading` في `adaptive_quran_page_view.dart` لأنها عملية ديناميكية سريعة (<1 ثانية)
- لا تستبدل `CircularProgressIndicator` داخل أزرار التحميل/التنزيل (Download screens) لأنها عمليات طويلة
- الـ widget الجديد مخصص **فقط** للعمليات القصيرة التي تحتاج رسالة بصرية
