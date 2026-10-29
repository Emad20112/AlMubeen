# خطة معمارية شاملة: نقل كافة طلبات Quran.com و Islamic.app للباك إند مع تقنية الاتصال المفتوح (Persistent Streaming)

## 1. الملخص التنفيذي والإجابة على السؤال الرئيسي

### هل يتم الطلب حالياً من تطبيق Flutter مباشرة أم من خادم Node.js؟

**النتيجة المؤكدة بعد الفحص الميداني للشفرة البرمجية:**
الطلبات في الوضع الراهن **مختلطة ومشتتة**، وهناك طلبات استراتيجية وحساسة تخرج **مباشرة من تطبيق Flutter إلى الخوادم والـ CDNs الخارجية دون المرور بالباك إند نهائياً**:

1. **طلبات خدمة Islamic.app بالكامل مباشرة من فلاتر:**
   - في `lib/features/quran/data/quran_data_providers.dart` (سطر 48)، يتم توجيه العميل مباشرة:
     `HttpQuranComApiClient(baseUri: Uri.parse('https://api.islamic.app/v1/audio'))`.
   - في `lib/features/quran/data/remote/islamic_app_remote_data_source.dart`، يتم جلب قائمة القراء مباشرة من: `https://api.islamic.app/v1/audio/reciters`.
   - **المفاجأة التقنية في الباك إند:** ملف الراوتر `backend/src/routes/islamic-reciters.ts` تم إنشاؤه مسبقاً ولكنه **متروك ومُهمل (Unmounted)** وغير مربوط داخل `backend/src/server.ts` إطلاقاً!
2. **طلب تلاوة السور الكاملة من Quran.com مباشر من فلاتر:**
   - في `lib/features/quran/data/remote/quran_com_remote_data_source.dart` (سطر 285):
     دالة `getChapterRecitation()` تقوم بإنشاء `HttpClient()` مستقل وتطلب الرابط العام القديم مباشرة:
     `https://api.quran.com/api/v4/chapter_recitations/$reciterId/$surahNumber` متجاوزة خادم الباك إند كلياً!
3. **تدفق الصوت وتشغيله وتنزيله (Audio Streaming & Downloading):**
   - في `lib/features/quran/data/repositories/quran_audio_repository_impl.dart` و `lib/features/quran/data/models/quran_audio_file_dto.dart`:
     يتم إنشاء روابط الصوت إما لـ `https://cdn.islamic.app/quran/audio/...` أو `https://verses.quran.foundation/...` ويقوم مشغل الصوت `just_audio` ومحرك التنزيل بفتح اتصالات فردية مباشرة مع تلك الـ CDNs الخارجية.
4. **المسارات التي تمر بالباك إند حالياً (جزئياً):**
   - السور (`/api/chapters`)، الآيات (`/api/verses`)، التفاسير (`/api/tafsirs`)، التراجم (`/api/translations`)، وقراء الآيات لـ Quran.com (`/api/recitations`).

---

## 2. مراجعة أحدث توثيقات الخدمات (Official Documentation Audit)

### 2.1. خدمة قرآن دوت كوم / مؤسسة القرآن (Quran Foundation API v4)

- **المعمارية الحديثة:** أوقفت منصة Quran Foundation الاعتماد على الواجهة العامة القديمة المفتوحة `api.quran.com/api/v4`، وأطلقت البوابة الرسمية الحديثة:
  - الإنتاج (Production Gateway): `https://apis.quran.foundation/content/api/v4`
  - بيئة التطوير (Pre-live Gateway): `https://apis-prelive.quran.foundation/content/api/v4`
- **نظام المصادقة الإلزامي (OAuth2 Client Credentials Flow):**
  - يتم طلب رمز وصول (Access Token) عبر طلب `POST` إلى:
    `https://oauth2.quran.foundation/oauth2/token`
    باستخدام `client_id` و `client_secret` (Grant Type: `client_credentials`, Scope: `content`).
  - صلاحية التوكن ساعة واحدة (3600 ثانية).
  - **قاعدة الأمان القصوى:** التوثيقات تشدد على أن `client_secret` **يجب ألا يخرج من الخادم أبداً**، ولا يجوز تضمينه داخل تطبيق الموبايل (Reverse Engineering Risk).
  - كل طلب للخدمة يجب أن يحمل الترويسات التالية:
    - `x-auth-token: <ACCESS_TOKEN>`
    - `x-client-id: <CLIENT_ID>`
- **نقاط النهاية الرسمية في v4:**
  - `GET /content/api/v4/chapters`: جلب قائمة السور.
  - `GET /content/api/v4/verses/by_chapter/{chapter_number}`: جلب الآيات ونصوصها وتفاسيرها وترجماتها.
  - `GET /content/api/v4/resources/recitations`: قائمة قراء الآيات.
  - `GET /content/api/v4/resources/chapter_reciters`: قائمة قراء السور الكاملة.
  - `GET /content/api/v4/chapter_recitations/{reciter_id}/{chapter_number}`: رابط تلاوة سورة كاملة.
  - `GET /content/api/v4/recitations/{recitation_id}/by_ayah/{verse_key}`: رابط تلاوة آية محددة.

### 2.2. خدمة إسلامك (Islamic.app API v1)

- **واجهة البيانات الوصفية:**
  - `GET https://api.islamic.app/v1/audio/reciters`: جلب قائمة القراء ومعلومات الجودة والأنماط المتاحة (`audioLevels: ["ayah", "surah"]`).
- **واجهة البث والتوزيع (CDN Endpoints):**
  - تلاوات الآيات الفردية:
    `https://cdn.islamic.app/quran/audio/{identifier}/{globalAyahNumber}.mp3`
    _(حيث globalAyahNumber هو الترقيم التسلسلي التراكمي من 1 إلى 6236)_.
  - تلاوات السور الكاملة:
    `https://cdn.islamic.app/quran/audio-surah/{identifier}/{surahNumber}.mp3`
    _(بدون أصفار بادئة، مثل `1.mp3` وليس `001.mp3`)_.

---

## 3. معمارية الوسيط الكامل (Unified Reverse Proxy Gateway)

الهدف هو تحويل خادم Node.js إلى **البوابة الحصرية والوحيدة** لكل ما يحتاجه التطبيق، بحيث:

1. **يعمل الباك إند كـ Reverse Proxy شفاف ومحصن:**
   - تطبيق Flutter يتصل فقط بـ `https://quan-packend.vercel.app` (أو `http://10.0.2.2:3000` محلياً).
   - لا يحتوي تطبيق الموبايل على أي مسار أو عنوان لخوادم `quran.com` أو `islamic.app`.
2. **تخزين مؤقت ذكي في الذاكرة (In-Memory Micro-Caching):**
   - تقليل طلبات المنبع (Upstream Requests)، وتوفير استجابة شبه فورية للعميل (`< 15ms`).
3. **معالجة وتوحيد البيانات (Unified Data Envelope):**
   - توحيد شكل الاستجابة `{ ok: true, data: ... }` بين Quran Foundation و Islamic.app.

```
┌────────────────────────────────────────────────────────┐
│               تطبيق المبين (Flutter Mobile)            │
│   (لا يعرف سوى https://quan-packend.vercel.app)         │
└───────────────────────────┬────────────────────────────┘
                            │
               HTTP Persistent (Keep-Alive)
                            │
┌───────────────────────────▼────────────────────────────┐
│              خادم الباك إند (Node.js Gateway)          │
│  - إدارة مفاتيح OAuth2 الآمنة (Client Credentials)     │
│  - Connection Pool دائم مع السيرفرات الخارجية         │
│  - وسيط بث المقاطع الصوتية (Audio Stream Proxy)        │
│  - التخزين المؤقت للبيانات الوصفية (Resource Cache)    │
└───┬────────────────────────────────────────────────┬───┘
    │                                                │
    │ HTTPS (Keep-Alive Pool)                        │ HTTPS (Keep-Alive Pool)
    ▼                                                ▼
┌───────────────────────────────┐      ┌─────────────────────────────┐
│  Quran Foundation API (v4)    │      │  Islamic.app API & CDNs     │
│  (OAuth2 Token + Content)     │      │  (Reciters Metadata & Audio)│
└───────────────────────────────┘      └─────────────────────────────┘
```

---

## 4. تطبيق "الاتصال المفتوح" (Persistent Connection) وتدفق الصوت عالي الأداء

لمنع أي تقطيع (Audio Chopping/Stuttering) أو تأخير في التبديل بين الآيات، سنعتمد حزمة تقنيات هندسية متكاملة للاتصال المفتوح:

### 4.1. على مستوى خادم Node.js:

1. **HTTP/HTTPS Keep-Alive Connection Pooling:**
   - تخصيص عملاء `http.Agent` و `https.Agent` عامّين بإعدادات:
     ```typescript
     export const keepAliveAgent = new https.Agent({
       keepAlive: true,
       maxSockets: 100,
       maxFreeSockets: 20,
       timeout: 60000,
       freeSocketTimeout: 30000,
     });
     ```
   - إعادة استخدام مصافحات TLS/SSL وعدم إغلاق الاتصال بعد كل طلب، مما يختصر 150-300ms في كل آية.
2. **وسيط بث الصوت مع دعم استئناف النطاق (Audio Streaming Proxy with Range Support):**
   - إنشاء مسار وسيط للصوتيات:
     - `/api/audio/stream/qf?url=...`
     - `/api/audio/stream/islamic?url=...`
   - دعم ترويسة `Range: bytes=start-end` لتوفير استجابة **`206 Partial Content`**.
   - تمرير تدفق الصوت كـ Stream (`res.pipe()`) مباشرة دون تجميع الملف في ذاكرة الخادم، مما يضمن تدفقاً فورياً وبداية تشغيل في أقل من **50ms**.
   - إرسال ترويسات:
     - `Connection: keep-alive`
     - `Accept-Ranges: bytes`
     - `Content-Type: audio/mpeg`
     - `Cache-Control: public, max-age=604800, immutable` (تخزين 7 أيام في كاش الوكيل).

### 4.2. على مستوى تطبيق Flutter:

1. **استبقاء اتصال شبكة دائم (Persistent HttpClient):**
   - تعديل `HttpQuranComApiClient` ليعمل بنسخة `HttpClient` وحيدة ودائمة طوال دورة حياة التطبيق، مع ضبط:
     ```dart
     client.idleTimeout = const Duration(seconds: 45);
     client.connectionTimeout = const Duration(seconds: 15);
     ```
2. **استغلال التخزين المسبق الذكي (Audio Prefetch Sliding Window):**
   - المحرك المُنشأ مسبقاً في `QuranAudioController` يقوم بتحميل روابط وملفات 3-5 آيات قادمة عبر نفس الاتصال المفتوح قبل وصول مؤشر القراءة إليها، مما يجعل الانتقال بين الآيات **لحظياً وصفر تأخير (0ms latency)**.

---

## 5. خطة التنفيذ التفصيلية مرحلة بمرحلة (Implementation Plan)

### المرحلة الأولى: تحديث وتجهيز الباك إند (Node.js Backend)

#### الخطوة 1.1: تفعيل وتكامل قراء Islamic.app

- **الملف:** `backend/src/server.ts`
- **الإجراء:**
  - استيراد `islamicRecitersRouter` من `./routes/islamic-reciters.js`.
  - تفعيل الراوتر رسمياً: `app.use(islamicRecitersRouter);`.
  - التأكد من تطابق الـ Endpoint: `GET /api/islamic/reciters`.

#### الخطوة 1.2: إضافة مسار تلاوة السور الكاملة في Quran Foundation

- **الملف:** `backend/src/routes/chapter-reciters.ts` و `backend/src/server.ts`
- **المشكلة الحالية:** `chapter-reciters.ts` معرّف حالياً على جذور غير متسقة، وتطبيق Flutter يبحث عن مسار قراءة السور.
- **الإجراء:**
  - توحيد المسارات تحت البادئة القياسية:
    - `GET /api/chapter-reciters`: قائمة قراء السور.
    - `GET /api/chapter-reciters/:reciterId/chapter/:chapterNumber`: رابط تلاوة السورة للقارئ.
  - ربط الراوتر بشكل صحيح مع ترويسات الاستجابة `{ ok: true, data: ... }`.

#### الخطوة 1.3: إنشاء مسار وكيل البث الصوتي المفتوح (Audio Stream Proxy)

- **الملف الجديد:** `backend/src/routes/audio-stream.ts`
- **المحتوى:**
  - مسار: `GET /api/audio/stream`
  - يستقبل `url` (رابط التلاوة المباشر من Quran Foundation أو Islamic CDN).
  - يتحقق من النطاقات المسموحة أمنياً (`verses.quran.foundation`, `cdn.islamic.app`, `audio.qurancdn.com`, `mirrors.quranicaudio.com`).
  - يرسل طلب المنبع مستخدماً `keepAliveAgent` مع تمرير ترويسة `Range` إن وجدت.
  - يرسل ترويسات `200 OK` أو `206 Partial Content` مع `Accept-Ranges: bytes` و `Connection: keep-alive`.
  - يربط المنبع بالمصب عبر `upstreamResponse.body.pipe(res)`.

---

### المرحلة الثانية: تحديث عميل Flutter (Client Migration)

#### الخطوة 2.1: تعديل مزود خدمة Islamic.app ليعتمد على الباك إند

- **الملف:** `lib/features/quran/data/quran_data_providers.dart`
- **الإجراء:**
  - تعديل `islamicAppApiClientProvider` ليوجه إلى الباك إند بدلاً من الرابط المباشر الخارجي:
    ```dart
    final islamicAppApiClientProvider = Provider<QuranComApiClient>((ref) {
      final client = HttpQuranComApiClient(
        baseUri: AppConfig.quranBackendUrl,
      );
      ref.onDispose(client.dispose);
      return client;
    });
    ```
- **الملف:** `lib/features/quran/data/remote/islamic_app_remote_data_source.dart`
- **الإجراء:**
  - تعديل استدعاء المسار من `reciters` إلى `api/islamic/reciters`.

#### الخطوة 2.2: إزالة طلب `api.quran.com` المباشر وتوجيهه للباك إند

- **الملف:** `lib/features/quran/data/remote/quran_com_remote_data_source.dart`
- **المشكلة:** دالة `getChapterRecitation()` تستخدم رابط `https://api.quran.com/api/v4/chapter_recitations/...` مباشرة عبر `HttpClient`.
- **الإجراء:**
  - استبدال الكود بطلب مباشر من عميل الباك إند:
    ```dart
    return await _apiClient.getJson(
      'api/chapter-reciters/$reciterId/chapter/$surahNumber',
    );
    ```
  - حذف أي استدعاء خارجي مستقل.

#### الخطوة 2.3: توجيه روابط الصوت عبر الباك إند مع الاتصال المفتوح

- **الملف:** `lib/features/quran/data/repositories/quran_audio_repository_impl.dart`
- **الإجراء:**
  - إنشاء دالة مساعدة لتحويل روابط الصوت الخارجية إلى روابط وكيل الباك إند:
    `AppConfig.quranBackendUrl.replace(path: '/api/audio/stream', queryParameters: {'url': targetUrl})`.
  - توجيه روابط آيات وسور Islamic.app وروابط Quran Foundation عبر وكيل الباك إند لضمان استمرار الاتصال المفتوح ومرور كافة الحزم عبر وسيطك المعتمد.

#### الخطوة 2.4: تحسين إدارة الاتصال المفتوح في عميل Flutter

- **الملف:** `lib/features/quran/data/remote/quran_com_api_client.dart`
- **الإجراء:**
  - تمكين خاصية إعادة استخدام اتصالات HTTP بقوة:
    - `_httpClient.idleTimeout = const Duration(seconds: 45);`
    - ترويسة `Connection: keep-alive` في كل طلب.

---

### المرحلة الثالثة: التحقق والاختبار (Verification & Testing)

1. **فحص عدم خروج أي طلب خارجي (Zero External Requests Check):**
   - تشغيل اختبار شبكي ومراقبة حركة الاتصالات للتأكد من أن 100% من اتصالات التطبيق تذهب حصرياً إلى نطاق الباك إند `AppConfig.quranBackendUrl`.
2. **فحص تشغيل التلاوات وسلاسة البث (Audio Streaming Smoothness):**
   - اختبار الاستماع لسورة كاملة ولآيات متتالية لقراء من Quran.com وقراء من Islamic.app.
   - التأكد من دعم الـ Seek والقفز الزمني السريع (استجابة 206 Partial Content).
   - قياس زمن استجابة بدء الصوت (الهدف: `< 80ms`).
3. **فحص الفحص الساكن والاختبارات:**
   - تشغيل `flutter test` لكافة وحدات الصوت وقاعدة البيانات.
   - تشغيل `flutter analyze lib test`.
   - اختبار تشغيل الباك إند `npm run build` و `npm run dev`.

---

## 6. جدول مقارنة الوضع الحالي مقابل المستهدف

| الميزة / المسار                 | الوضع الحالي (Current)                | الوضع المستهدف (Target)                             |
| :------------------------------ | :------------------------------------ | :-------------------------------------------------- |
| **قراء Quran Foundation**       | عبر الباك إند                         | عبر الباك إند مع Caching                            |
| **قراء Islamic.app**            | مباشر من التطبيق لـ `api.islamic.app` | عبر الباك إند (`/api/islamic/reciters`)             |
| **تلاوات السور (Quran.com)**    | مباشر من التطبيق لـ `api.quran.com`   | عبر الباك إند (`/api/chapter-reciters/...`)         |
| **تلاوات السور (Islamic.app)**  | مباشر من التطبيق لـ `cdn.islamic.app` | عبر وكيل البث الصوتي بالباك إند                     |
| **تلاوات الآيات (جميع القراء)** | اتصالات منفصلة متفرقة للـ CDNs        | عبر وكيل البث بالباك إند مع Keep-Alive              |
| **أمان المفاتيح (Secrets)**     | سليم في الباك إند                     | استمرار الأمان الكامل وعدم كشف أي مفتاح             |
| **استقرار الاتصال والصوت**      | معرض للتقطيع عند فتح اتصالات جديدة    | اتصال مفتوح دائم (Persistent Keep-Alive) مع 0ms Lag |
