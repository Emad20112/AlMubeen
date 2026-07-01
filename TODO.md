# TODO

## HomePage UI / متابعة القراءة
- [ ] تعديل `lib/features/home/presentation/home_page.dart` ليصبح: (HomeHeader + بطاقة متابعة القراءة متصلة بصريًا أسفل الهيدر).
- [ ] إنشاء Widget لبطاقة `متابعة القراءة` داخل `lib/features/home/presentation/widgets/` (حسب الهوية، Card/InkWell/BoxShadow/BorderRadius وبدعم TextScaler).
- [ ] ربط البطاقة بآخر موضع محفوظ عبر `quranReadingProgressServiceProvider`.
- [ ] إظهار "بدء التلاوة" بدل "متابعة القراءة" إذا لم تتوفر بيانات (مثلاً عند عدم وجود entry أو قيمة أولية).

## تجربة المستخدم الجديد (Onboarding / First run)
- [ ] إنشاء شاشة ترحيب بسيطة: اسم التطبيق + رسالة + زر "ابدأ الآن".
- [ ] إنشاء صفحة/حالة إعدادات أولية: نمط العرض (فاتح/داكن) + حجم الخط + قارئ افتراضي + تفعيل المتابعة التلقائية + تفعيل وضع الاستماع السهل.
- [ ] تجهيز منطق تحديد "مستخدم جديد" بناءً على توفر بيانات محفوظة (آخر صفحة/تفضيلات/قارئ/سجل متابعة).
- [ ] إضافة مسارات (routes) لـ onboarding والانتقال من HomePage.

## تحقق/اختبار
- [ ] التأكد من عدم حدوث Overflow ويدعم TextScaling.
- [ ] تشغيل `flutter analyze` و `flutter test` (أو `flutter run` إذا متاح).

