import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/data/models/highlight_verse.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

/// 🛡️ PERF: صفحة قرآن واحدة (Mushaf) مُغلَّفة بـ [RepaintBoundary] مستقل.
///
/// تم فصلها إلى widget مستقل (StatelessWidget بسيط) لسببين:
/// 1. **عزل إعادة الرسم (Repaint Isolation):** كل طبقة — نص المصحف، الـ header،
///    الـ footer — داخل `RepaintBoundary` خاصة بها، فلا يُعاد رسم صفحة QCF
///    (الأغلى في التطبيق) عند تغيّر نص الـ header/footer أو التظليل فقط.
/// 2. **التحسين عبر `const`/مقارنة الحقول:** الـ widget يُقارَن بالحقول
///    (props) في `canUpdate`, فلا يُعاد بناؤه إلا عند تغيّر فعلي في بياناته.
class QuranPageView extends StatelessWidget {
  const QuranPageView({
    required this.pageNumber,
    required this.juzHizbText,
    required this.surahNameArabic,
    required this.theme,
    required this.fontScale,
    required this.headerJuzStyle,
    required this.headerSurahStyle,
    required this.footerPageStyle,
    required this.getVerseHighlight,
    required this.onLongPressDown,
    super.key,
  });

  static const double headerHeight = 44.0;
  static const double footerHeight = 32.0;

  final int pageNumber;
  final String juzHizbText;
  final String surahNameArabic;
  final QcfThemeData theme;
  final double fontScale;
  final TextStyle headerJuzStyle;
  final TextStyle headerSurahStyle;
  final TextStyle footerPageStyle;

  /// دالة تُعيد لون خلفية الآية إن كانت مُظلَّلة، وإلا `null`.
  final Color? Function(int surah, int verse) getVerseHighlight;

  final void Function(int surah, int verse, LongPressStartDetails details)
  onLongPressDown;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          child: QcfPage(
            pageNumber: pageNumber,
            verseBackgroundColor: getVerseHighlight,
            onLongPressDown: onLongPressDown,
            theme: theme,
            sp: fontScale,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: RepaintBoundary(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(juzHizbText, style: headerJuzStyle),
                    const Spacer(),
                    Text(surahNameArabic, style: headerSurahStyle),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: footerHeight,
          child: RepaintBoundary(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      convertToArabicDigits(pageNumber),
                      style: footerPageStyle,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// بيانات الـ header/footer الثابتة لصفحة معيّنة.
class QuranPageMeta {
  const QuranPageMeta({
    required this.juzHizbText,
    required this.surahNameArabic,
  });

  final String juzHizbText;
  final String surahNameArabic;
}

/// 🛡️ PERF: ذاكرة مؤقتة لبيانات الـ header/footer لكل صفحة.
///
/// بناء النصوص العربية (juz/hizb/surah) يتضمن عمليات معالجة نصية؛
/// تخزينها مرة واحدة يجعلها O(1) عند إعادة بناء الصفحة.
class QuranPageMetaCache {
  QuranPageMetaCache._();

  static final QuranPageMetaCache instance = QuranPageMetaCache._();

  static final QuranPageMetadataCache _pageMeta =
      QuranPageMetadataCache.instance;

  final Map<int, QuranPageMeta> _cache = <int, QuranPageMeta>{};

  QuranPageMeta forPage(int pageNumber) {
    final cached = _cache[pageNumber];
    if (cached != null) {
      return cached;
    }

    final meta = _pageMeta.forPage(pageNumber);
    final result = QuranPageMeta(
      juzHizbText: meta.juzHizbText,
      surahNameArabic: meta.surahNameArabic,
    );
    _cache[pageNumber] = result;
    return result;
  }
}

/// يجمع [HighlightVerse] في خريطة (سورة، آية) → لون لأداء بحث O(1).
Map<(int, int), Color> buildHighlightMap(List<HighlightVerse> highlights) {
  if (highlights.isEmpty) {
    return const <(int, int), Color>{};
  }
  return <(int, int), Color>{
    for (final highlight in highlights)
      (highlight.surah, highlight.verseNumber): highlight.color,
  };
}
