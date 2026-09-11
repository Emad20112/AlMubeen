import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';

int stableNegativeReciterId(String identifier) {
  var hash = 5381;
  for (var i = 0; i < identifier.length; i++) {
    hash = ((hash << 5) + hash) + identifier.codeUnitAt(i);
  }
  return -100000 - (hash.abs() % 800000);
}

String normalizeReciterName(String name) {
  var normalized = name.trim().toLowerCase();
  normalized = normalized.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
  normalized = normalized.replaceAll(RegExp(r'[إأآا]'), 'ا');
  normalized = normalized.replaceAll('ة', 'ه');
  normalized = normalized
      .replaceAll('الشيخ', '')
      .replaceAll('القارئ', '')
      .replaceAll('الدكتور', '')
      .trim();
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
  return normalized;
}

String assignReciterCategory(
  QuranRecitation recitation, {
  required bool isIslamicApp,
}) {
  final name = recitation.reciterName.toLowerCase();
  final style = (recitation.style ?? '').toLowerCase();
  final id = (recitation.identifier ?? '').toLowerCase();

  const haramainKeywords = [
    'السديس',
    'الشريم',
    'الحذيفي',
    'المعيقلي',
    'البدير',
    'الثبيتي',
    'الجهني',
    'بليلة',
    'المحيسني',
    'الغامدي',
    'sudais',
    'shuraym',
    'hudaify',
    'muaiqly',
    'budeir',
    'juhany',
    'balilah',
  ];
  if (haramainKeywords.any(
    (keyword) => name.contains(keyword) || id.contains(keyword),
  )) {
    return 'قراء الحرمين الشريفين';
  }

  if (style.contains('تراويح') ||
      style.contains('taraweeh') ||
      id.contains('taraweeh')) {
    return 'تلاوات التراويح والصلوات';
  }

  if (style.contains('معلم') ||
      style.contains('muallim') ||
      style.contains('مجو') ||
      style.contains('mujawwad') ||
      style.contains('تجويد')) {
    return 'قراء للتعلم والتجويد';
  }

  return isIslamicApp ? 'قراء خدمة Islamic.app' : 'قراء خدمة Quran.com';
}
