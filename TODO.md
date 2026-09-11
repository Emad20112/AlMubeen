# TODO — ميزة التخزين المحلي للتلاوات واستخدامها في شاشة القراءة

## الأهداف
- تحميل تلاوة سورة وقارئ معين من شاشة الاستماع.
- استخدام الملفات المحلية في شاشة قراءة القرآن لنفس السورة والقارئ.
- العمل دون اتصال عند توفر الملفات محلياً.

## الخطوات
- [x] 1. إضافة `isAyahDownloaded()` إلى `AudioRepository` وواجهة `AudioDownloadRepository` (الملف: `lib/core/audio/audio_repository.dart`)
- [x] 2. تنفيذ `isAyahDownloaded()` في `DownloadRepository` (الملف: `lib/core/audio/download_repository.dart`)
- [x] 3. تعديل `quran_audio_controller.dart`:
  - [x] 3.1 فحص الملف المحلي أولاً قبل جلب رابط الشبكة في `_resolveAyahSourceForPlayback`
  - [x] 3.2 تعديل منطق إيقاف التشغيل عند انقطاع الإنترنت ليعمل فقط مع المصدر الشبكي
- [x] 4. إضافة `refreshDownloadedSurahs()` إلى `quran_audio_download_controller.dart` لقراءة حالة التحميل من القرص
- [x] 5. ربط `refreshDownloadedSurahs()` في شاشة الاستماع `quran_surah_player_screen.dart`
- [x] 6. تشغيل `flutter analyze` على الملفات المعدّلة — **لا توجد أخطاء** ✅ (والتحليل الكامل للمشروع قيد التشغيل)
- [ ] 7. اختبار: تحميل سورة → تشغيلها في شاشة القراءة → وضع الطيران (Offline)

