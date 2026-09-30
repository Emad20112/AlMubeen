# خطة تحسين طبقة التخزين المحلي

## 1. جرد التخزين الحالي

| النظام              | المواقع                                                            | البيانات                                     | الحجم/النمط              | الاستخدام                                         | القرار                                                        |
| ------------------- | ------------------------------------------------------------------ | -------------------------------------------- | ------------------------ | ------------------------------------------------- | ------------------------------------------------------------- |
| `SharedPreferences` | `lib/features/tasbih/application/tasbih_controller.dart`           | `tasbih_dhikr_list` كقائمة نصوص عربية        | صغيرة                    | قراءة عند إنشاء notifier وكتابة عند كل تعديل      | نقله إلى MMKV كسلسلة JSON صغيرة عبر abstraction               |
| `SharedPreferences` | `lib/features/quran/application/quran_download_session_store.dart` | أربع جلسات تنزيل                             | JSON صغير لكل جلسة       | قراءة/كتابة عند بدء أو إيقاف أو استئناف التنزيل   | نقله إلى MMKV كسلاسل JSON؛ لا ينقل محتوى التنزيل              |
| JSON + File I/O     | `lib/core/preferences/app_user_preferences.dart`                   | تفضيلات المستخدم primitives وقائمة مؤقتات    | صغيرة                    | قراءة مرة عند بناء التطبيق وكتابة عند تغيير تفضيل | إعادة بناء `AppUserPreferencesStore` فوق MMKV typed key/value |
| Drift/SQLite        | `lib/core/database/app_database.dart` والمصادر المحلية             | Quran/cache/progress/favorites وبيانات منظمة | كبيرة أو قابلة للاستعلام | عمليات cache وقراءات relational                   | يبقى Drift كما هو                                             |
| ملفات التطبيق       | مصادر أسماء الله/الحديث/التفسير، كتالوج التنزيل، وملفات الصوت      | assets/cache/datasets وملفات تنزيل           | كبيرة أو ملفات فعلية     | تحميل/تخزين بيانات وليست preferences              | لا تنقل إلى MMKV                                              |

## 2. استخدامات SharedPreferences المكتشفة

تم العثور على **استخدامين برمجيين فعليين**:

1. Tasbih: `getStringList` و`setStringList` للمفتاح `tasbih_dhikr_list`.
2. Quran download sessions: `getString` و`setString` و`remove` للجلسات الأربع.

كما وُجد اعتماد اختبار مباشر في `test/features/quran/quran_download_session_store_test.dart`، وسيستبدل باختبار `MemoryKvStorage`.

ملفات التسجيل المولدة في Android ستتغير تلقائياً بعد `flutter pub get`.

## 3. جرد تفضيلات JSON

`AppUserPreferencesStore` كان يقرأ ويكتب ملف `app_user_preferences.json` في `ApplicationSupportDirectory`، ويعيد كتابة object كامل عند تغيير حقل واحد. الحقول هي:

- `hasCompletedWelcome`: bool
- `themePreference`: enum محفوظ كنص
- `fontScale`: double
- `preferredReciterId`: int nullable
- `preferredReciterName`: String nullable
- `autoContinueFromLastPosition`: bool
- `easyListeningMode`: bool
- `recentSleepTimers`: قائمة int صغيرة ستُحفظ JSON string داخل MMKV
- `lastQuranPage`: int nullable
  لن توجد قراءة أو كتابة ملف preferences بعد التغيير، ولن تُبنى migration legacy للملف القديم.

## 4. مسؤوليات Drift

يبقى Drift مسؤولاً عن الجداول المنظمة، cache القرآن والآيات، metadata، favorites، progress، tafsir/translation النصية، ومحتوى Hisn. كما تبقى ملفات الصوت وملفات datasets في أنظمة الملفات لأنها ليست key/value صغيرة.

## 5. البنية المقترحة

```text
Feature controller/repository
        ↓
KvStorage (typed synchronous API)
        ↓
SharedKvStorage singleton
   ├── Native: MMKV instance واحدة
   └── Web/unsupported: MemoryKvStorage غير دائم
Structured data / queries → Drift
```

سيكون `KvStorage` قابلاً للحقن عبر Riverpod. لا يصل UI أو controller إلى MMKV مباشرة. على native تتم تهيئة MMKV مرة واحدة قبل `runApp`; على Web يستخدم fallback ذاكرة واضح بأنه غير دائم.

## 6. تغييرات ملف-بملف

- إنشاء `lib/core/storage/kv_storage.dart` للعقد typed.
- إنشاء `lib/core/storage_keys.dart` للمفاتيح المركزية.
- إنشاء تنفيذ MMKV/fallback وprovider مشترك في `lib/core/storage/`.
- إعادة بناء `lib/core/preferences/app_user_preferences.dart` لإزالة `dart:io` و`path_provider` وJSON file I/O مع الحفاظ على model/controller والسلوك.
- إعادة ربط `tasbih_controller.dart` بـ `KvStorage` مع JSON string للقائمة الصغيرة فقط.
- إعادة ربط `quran_download_session_store.dart` بـ `KvStorage`، مع إبقاء JSON serialization للجلسة الصغيرة وواجهات القراءة متزامنة داخلياً قدر الإمكان.
- تهيئة MMKV في `lib/main.dart` قبل `AppConfig.load` و`runApp`.
- تحديث `pubspec.yaml` وحذف `shared_preferences`، ثم تجديد `pubspec.lock` والملفات المولدة ذات الصلة عبر Pub.
- استبدال اختبارات SharedPreferences باختبارات abstraction وذاكرة، وإضافة اختبارات preferences وTasbih وdownload sessions.
- إنشاء `docs/local_storage_architecture.md` بعد التنفيذ.

## 7. خريطة المفاتيح

| المفتاح الحالي/الجديد                     | النوع                    | المالك          |
| ----------------------------------------- | ------------------------ | --------------- |
| `tasbih_dhikr_list`                       | JSON string لقائمة صغيرة | Tasbih          |
| `quran_text_download_session_tafsir`      | JSON string              | Quran downloads |
| `quran_text_download_session_translation` | JSON string              | Quran downloads |
| `quran_audio_download_session_full_quran` | JSON string              | Quran audio     |
| `quran_audio_download_session_surah`      | JSON string              | Quran audio     |
| `app_preferences_has_completed_welcome`   | bool                     | App preferences |
| `app_preferences_theme`                   | String                   | App preferences |
| `app_preferences_font_scale`              | double                   | App preferences |
| `app_preferences_preferred_reciter_id`    | int                      | App preferences |
| `app_preferences_preferred_reciter_name`  | String                   | App preferences |
| `app_preferences_auto_continue`           | bool                     | App preferences |
| `app_preferences_easy_listening`          | bool                     | App preferences |
| `app_preferences_recent_sleep_timers`     | JSON string لقائمة صغيرة | App preferences |
| `app_preferences_last_quran_page`         | int                      | App preferences |

القيم nullable تمثل بغياب المفتاح، بدلاً من كتابة null إلى MMKV.

## 8. استراتيجية المنصات

MMKV native مطلوب للمنصات المدعومة. Web لا يستورد MMKV في مسار compilation الخاص به؛ يستخدم fallback in-memory غير دائم لحماية compilation، مع توثيق أن offline persistence للويب خارج نطاق هذه المهمة. يجب التحقق من دعم desktop الفعلي للحزمة قبل ادعاء persistence هناك.

## 9. Android وminSdk

`android/app/build.gradle.kts` يستخدم `flutter.minSdkVersion`، بينما `pubspec.yaml` يحدد `flutter_launcher_icons.min_sdk_android: 21` وليس minSdk التطبيق. سيتم فحص القيمة الفعلية بأداة Flutter/Gradle قبل البناء. لن يتم رفع minSdk تلقائياً؛ إذا فرض MMKV native حد API أعلى من القيمة الفعلية، سيُذكر التعارض ويُستخدم fallback/قرار متوافق بدلاً من تغيير غير مطلوب.

## 10. المخاطر

- اختلاف API الفعلي لحزمة `mmkv` بين الإصدارات؛ سيُتحقق من التوقيعات بعد جلب dependencies.
- دعم Web/Desktop قد لا يكون native؛ يعالج abstraction ذلك دون استيراد غير مشروط.
- لا توجد migration legacy متعمدة، وبالتالي لا تُقرأ ملفات JSON أو SharedPreferences القديمة.
- JSON sessions تبقى JSON strings عمداً لأنها state صغيرة وليست datasets.

## 11. خطة التحقق

- `flutter pub get`
- `dart format .`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug` إذا كانت بيئة Android متاحة
- فحص grep للتأكد من اختفاء `SharedPreferences` و`shared_preferences` من الكود والاختبارات.
- اختبار حفظ theme/font/reciter والـ onboarding وTasbih والجلسات، مع malformed JSON وUnicode وempty/missing values.

## 12. خطة قياس الأداء

سيتم التحقق بنيوياً من إزالة file I/O والـ async initialization المتكرر. لن تُذكر أرقام startup أو latency إلا إذا نتجت من benchmark فعلي في البيئة الحالية. عند عدم توفر benchmark release/profile موثوق، سيكون التقرير صريحاً بأن التحسين المعماري تحقق دون قياس رقمي.
