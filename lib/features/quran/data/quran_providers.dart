/// ─────────────────────────────────────────────────────────────────────────────
/// Barrel موحّد لمعرّفات (providers) طبقة بيانات القرآن.
///
/// 🛡️ PERF/MAINTENANCE: كان هذا الملف يحتوي على **كل** المعرّفات (~1179 سطر)
/// مما يُبطئ الـ incremental compilation ويصعّب التتبع والاختبار. تم تقسيمه
/// إلى ملفات مركّزة حسب المسؤولية:
///
/// - `quran_data_providers.dart`     → العملاء، مصادر البيانات، المستودعات،
///                                      القرّاء، والعلامات المرجعية.
/// - `quran_catalog_providers.dart`  → التفسير والترجمة (جلب/دمج/أسماء/نصوص).
/// - `quran_search_providers.dart`   → البحث في التفسير/الترجمة/القرّاء.
///
/// هذا الملف يبقى نقطة الاستيراد الواحدة لكل المستهلكين، فلا حاجة لتعديل أي
/// ملف آخر، مع الاستفادة الكاملة من الفصل الداخلي.
/// ─────────────────────────────────────────────────────────────────────────────
library;

export 'package:al_mubeen/features/quran/data/quran_catalog_providers.dart';
export 'package:al_mubeen/features/quran/data/quran_data_providers.dart';
export 'package:al_mubeen/features/quran/data/quran_search_providers.dart';