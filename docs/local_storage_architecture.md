# بنية التخزين المحلي

## الوضع السابق

كان المشروع يستخدم ثلاثة مسارات مختلفة للبيانات المحلية الصغيرة:

- `SharedPreferences` لقائمة Tasbih وجلسات تنزيل القرآن.
- `AppUserPreferencesStore` لملف JSON في `ApplicationSupportDirectory`، وكان يعيد كتابة object كامل عند تغيير preference واحدة.
- Drift للبيانات المنظمة والكاش، وهو الاستخدام الصحيح الذي بقي كما هو.

## الوضع الحالي

```text
Feature controller/repository
        ↓
KvStorage (typed, synchronous operations)
        ↓
MMKV singleton على native
MemoryKvStorage غير دائم على Web/مسار الاختبار
Structured/relational data → Drift
```

`KvStorage` هو الواجهة الوحيدة للـ key/value. لا تنشئ الميزات MMKV ولا تستدعي `MMKV.defaultMMKV()` مباشرة. تتم التهيئة مرة واحدة في `main` قبل `runApp`، والـ provider يعيد نفس الكائن المشترك.

## مسؤوليات MMKV

يخزن MMKV القيم الصغيرة فقط:

- تفضيلات التطبيق typed: theme، font scale، reciter، onboarding، modes، آخر صفحة.
- قائمة Tasbih الصغيرة كـ JSON string للحفاظ على الترتيب وUnicode.
- جلسات التنزيل الأربع كـ JSON strings صغيرة لأنها state للاستئناف وليست محتوى تنزيل.
- قوائم sleep timers الصغيرة كـ JSON string.

القيم nullable تمثل بغياب المفتاح. لا تُكتب preferences كـ JSON object كامل.

## مسؤوليات Drift والملفات

يبقى Drift مسؤولاً عن Quran/cache/progress/favorites/metadata والبيانات التي تحتاج queries أو علاقات أو حجماً كبيراً. لا تُنقل tafsir أو translation أو Quran datasets إلى MMKV. ملفات الصوت والتنزيلات وملفات cache dataset تظل في file storage لأنها ملفات فعلية وليست preferences.

## الأنظمة التي أزيلت

- أزيل `shared_preferences` من الكود والاختبارات والاعتماد المباشر.
- أزيل JSON file I/O من `AppUserPreferencesStore`، ولم يعد يستخدم `dart:io` أو `path_provider` لهذا الغرض.
- لا توجد legacy migration أو flags أو rollback؛ المشروع في مرحلة التطوير ولا توجد بيانات حقيقية يجب الحفاظ عليها.

## المنصات

MMKV يُستورد في ملفات native conditional imports فقط. على Web لا يُحمّل plugin native، ويستخدم `MemoryKvStorage` غير دائم لحماية compilation. هذا fallback ليس حلاً لـ Web offline persistence، وهو خارج نطاق هذا التغيير. يجب عدم تفسيره على أنه secure storage.

Android يستخدم `flutter.minSdkVersion` في Gradle. لم يُرفع minSdk تلقائياً؛ يجب تأكيد قيمة Flutter/Gradle الفعلية في بيئة البناء قبل اعتماد release. قيمة `min_sdk_android: 21` في إعداد launcher ليست بالضرورة minSdk التطبيق.

## الأداء

القراءة والكتابة typed ومتزامنة بعد تهيئة MMKV، فلا يوجد Future مصطنع في abstraction. تتم تهيئة plugin مرة واحدة، وتقرأ preferences كحقول مستقلة دون JSON decode أو file I/O عند startup. لا يوجد benchmark رقمي موثوق في هذه البيئة لأن Flutter CLI غير متاح، لذلك التقرير يثبت التحسين المعماري ولا يخترع أرقاماً.

## الاختبارات

توجد اختبارات `MemoryKvStorage` للقيم typed، missing keys، overwrite، remove، empty strings وUnicode. اختبارات جلسات التنزيل تستخدم `MemoryKvStorage` بدلاً من platform runtime. ينبغي تشغيل `flutter test` عند توفر Flutter SDK.

## القيود المتبقية

- لا توجد persistence للـ Web fallback.
- لم تُنقل ملفات cache الكبيرة أو البيانات المنظمة إلى MMKV.
- لم تُجرَ migration للبيانات القديمة عمداً حسب قرار المشروع.
