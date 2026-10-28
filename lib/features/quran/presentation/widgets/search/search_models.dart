/// خيارات ونطاقات تصفية البحث القرآني.
enum SearchFilter {
  all('الكل'),
  surahNames('السور'),
  quranText('الآيات'),
  tafsir('التفاسير'),
  translations('الترجمات'),
  reciters('القراء');

  const SearchFilter(this.label);
  final String label;
}
