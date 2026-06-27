# Quran.com / Quran Foundation API — تنفيذ عملي لتطبيق Flutter

## الهدف
إنشاء   لتطبيق Flutter بحيث يجلب التطبيق:
- الترجمات
- التفاسير
- الكلمات كلمة بكلمة
- التلاوات
- صوت الآية أو السورة عند الحاجة

Flutter  يتصل مباشرة بالخدمة الخارجية، بل يستهلك API محلي فقط.

---

## مبدأ العمل
1. Flutter يطلب من Backend المحلي.
2. Backend يحصل على Access Token من OAuth2.
3. Backend يمرر الطلب إلى Quran Foundation Content API.
4. Backend يرجع JSON منظم للتطبيق.

---

## المتطلبات البيئية
أنشئ ملف `.env`:

```env
QF_ENV=prelive
QF_CLIENT_ID=your_client_id
QF_CLIENT_SECRET=your_client_secret
QF_OAUTH_BASE_URL=https://prelive-oauth2.quran.foundation
QF_API_BASE_URL=https://apis-prelive.quran.foundation
PORT=3000
```

للإنتاج:

```env
QF_ENV=production
QF_OAUTH_BASE_URL=https://oauth2.quran.foundation
QF_API_BASE_URL=https://apis.quran.foundation
```

---

## التوثيق الرسمي المهم
Quran Foundation يوضح أن Content APIs تحتاج:
- OAuth2 `client_credentials`
- scope = `content`
- ثم إرسال:
  - `x-auth-token`
  - `x-client-id`

المصدر الخارجي والخادمي فقط، وليس Flutter مباشرة.

---

## ما الذي توفره الخدمة رسميًا؟
حسب التوثيق الرسمي:
- Content APIs تشمل: chapters, verses, translations, tafsir, audio, recitations, pages, juz, hizb, ruku, manzil resources.
- الموارد الخاصة تشمل: translations, tafsirs, languages, chapterInfos، وغيرها.
- آيات القرآن تدعم:
  - `words=true`
  - `word_fields`
  - `translation_fields`
  - `tafsir_fields`
  - `fields`
- صفحة الترجمات الخاصة بسورة معينة تدعم `resource_id` و `chapter_number`.
- صفحة التفاسير الخاصة بسورة معينة تدعم `tafsir_id` / `resource_id` مع `chapter_number` أو `verse_key`.
- توجد بيانات word-by-word translation/transliteration ضمن استجابة الآية نفسها.

---

## ملاحظة عن أسباب النزول
لم أجد في التوثيق الرسمي الذي راجعته endpoint صريحًا ومؤكدًا باسم "asbab al-nuzul" أو "reasons for revelation".  
لذلك لا تبنه كجزء مؤكد إلا إذا ظهر endpoint آخر في وثائقهم أو زودك المزود بمصدر خاص له.

---

## الـ endpoints المحلية التي سيقدمها backend

### 1) Health
`GET /health`

الاستجابة:
```json
{ "ok": true, "env": "prelive" }
```

---

### 2) اختبار الاتصال
`GET /api/qf-check`

ينفذ داخليًا:
- `GET /content/api/v4/chapters`

الغرض:
- التأكد من أن OAuth والهيدرات وbase URL تعمل.

---

### 3) قائمة الترجمات
`GET /api/translations`

#### أمثلة query params
- `language=en`
- `chapterNumber=1`
- `resourceId=131`
- `page=1`
- `per_page=10`

#### المسار الخارجي الرسمي
- `GET /content/api/v4/resources/translations`
- ثم:
- `GET /content/api/v4/translations/{translation_id}`
- أو:
- `GET /content/api/v4/translations/{resource_id}/{chapter_number}`

#### المطلوب
- جلب قائمة الموارد المتاحة
- جلب ترجمة سورة محددة حسب `resourceId`
- دعم `fields`
- دعم pagination

---

### 4) قائمة التفاسير
`GET /api/tafsirs`

#### query params
- `language=en`

#### المسار الخارجي الرسمي
- `GET /content/api/v4/resources/tafsirs`

#### المطلوب
- إرجاع قائمة التفاسير
- مع `id`, `name`, `author_name`, `slug`, `language_name`

---

### 5) تفسير سورة محددة
`GET /api/tafsirs/:resourceId/chapter/:chapterNumber`

#### مثال
`/api/tafsirs/169/chapter/1`

#### المسار الخارجي الرسمي
- `GET /content/api/v4/tafsirs/{tafsir_id}`
- أو حسب الوضع:
- `GET /content/api/v4/tafsirs/{tafsir_id}/{chapter_number}`

#### المطلوب
- إرجاع التفسير الخاص بالسورة
- دعم `verse_key` أو `chapter_number` أو `fields`
- دعم pagination إذا لزم

---

### 6) آية واحدة مع الترجمة والتفسير والكلمات
`GET /api/verses/:verseKey`

#### مثال
`/api/verses/2:255`

#### المسار الخارجي الرسمي
- `GET /content/api/v4/verses/{verse_key}`

#### Query params المهمة
- `language=en`
- `words=true`
- `translations=131,169` حسب resource ids
- `tafsirs=169`
- `word_fields=text_uthmani,text_imlaei,code_v1,code_v2,translation,transliteration,location,line_number`
- `translation_fields=chapter_id,verse_number,verse_key,resource_name,language_name,id`
- `tafsir_fields=chapter_id,verse_number,verse_key,resource_name,language_name,id`
- `fields=text_uthmani,text_indopak`

#### المطلوب
هذا هو endpoint الأفضل لصفحة تفاصيل آية واحدة لأنه يمكن أن يعيد:
- النص العربي
- words
- translation
- tafsir
- audio

---

### 7) آيات سورة كاملة
`GET /api/chapters/:chapterNumber/verses`

#### مثال
`/api/chapters/2/verses`

#### المسار الخارجي الرسمي
- `GET /content/api/v4/verses/by_chapter/{chapter_number}`

#### Query params المقترحة
- `language=en`
- `words=true`
- `translations=131`
- `tafsirs=169`
- `audio=7`
- `word_fields=...`
- `translation_fields=...`
- `tafsir_fields=...`
- `fields=text_uthmani,text_indopak`
- `page=1`
- `per_page=50`

#### المطلوب
إرجاع كل آيات السورة مع البيانات الإضافية اللازمة للعرض.

---

### 8) قائمة القراء / recitations
`GET /api/recitations`

#### المسار الخارجي الرسمي
- `GET /content/api/v4/resources/recitations`

#### المطلوب
- إرجاع قائمة recitations
- هذه مخصصة للـ ayah-by-ayah audio

---

### 9) قائمة chapter reciters
`GET /api/chapter-reciters`

#### المسار الخارجي الرسمي
- `GET /content/api/v4/resources/chapter_reciters`

#### المطلوب
- إرجاع قائمة قراء السور الكاملة
- هذه ليست نفس recitations

---

### 10) صوت سورة محددة لقارئ محدد
`GET /api/chapter-reciters/:reciterId/chapter/:chapterNumber`

#### المسار الخارجي الرسمي
- `GET /content/api/v4/chapter_recitations/{reciter_id}/{chapter_number}`

#### المطلوب
- إرجاع ملف الصوت أو رابط الصوت
- مناسب لتشغيل السورة كاملة

---

## الهيدرات المطلوبة لكل طلب خارجي
كل طلب إلى Content API يجب أن يحمل:

```http
x-auth-token: <access_token>
x-client-id: <client_id>
```

---

## OAuth2 token flow
### الطلب
```http
POST /oauth2/token
```

### Body
```txt
grant_type=client_credentials
scope=content
```

### المصادقة
Basic Auth باستخدام:
- `client_id`
- `client_secret`

### منطق التخزين
- cache token في الذاكرة
- تخزين expiry
- التجديد قبل الانتهاء بدقيقة
- إذا رجع 401، أعد طلب token مرة واحدة ثم أعد المحاولة مرة واحدة فقط

---

## بنية المشروع المقترحة
```text
backend/
  src/
    config/
      env.ts
    lib/
      tokenManager.ts
      qfClient.ts
    services/
      oauth.service.ts
      qf.service.ts
      verses.service.ts
      translations.service.ts
      tafsirs.service.ts
      recitations.service.ts
      chapterReciters.service.ts
    routes/
      health.ts
      qf-check.ts
      translations.ts
      tafsirs.ts
      verses.ts
      recitations.ts
      chapter-reciters.ts
    server.ts
  .env
  .env.example
  package.json
  tsconfig.json
```

---

## قواعد التنفيذ للذكاء الاصطناعي
1. لا تضع `client_secret` داخل Flutter.
2. اجعل كل الاتصالات الخارجية في backend فقط.
3. استخدم service layer مشتركة لكل نداء خارجي.
4. استخدم validation للمدخلات.
5. أضف caching للموارد العامة:
   - translations
   - tafsirs
   - recitations
   - chapter reciters
6. أضف handling للأخطاء:
   - 401
   - 403
   - 429
   - 5xx
7. لا تغيّر أسماء المتطلبات التي يفرضها المزود في OAuth أو Content API.
8. اجعل الردود JSON ثابتة وواضحة.

---

## ما الذي يستهلكه Flutter فقط؟
Flutter يجب أن يستهلك فقط:
- `/health`
- `/api/qf-check`
- `/api/translations`
- `/api/tafsirs`
- `/api/verses/:verseKey`
- `/api/chapters/:chapterNumber/verses`
- `/api/recitations`
- `/api/chapter-reciters`

---

## مخرجات التنفيذ المطلوبة
- Backend محلي يعمل
- OAuth token management
- Endpoints جاهزة
- JSON responses منظمة
- دعم الترجمات والتفاسير والمعاني كلمة بكلمة
- دعم التلاوات
- عدم كشف `client_secret`
- جاهزية الربط مع تطبيق Flutter الموجود
