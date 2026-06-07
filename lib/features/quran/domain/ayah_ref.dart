import 'package:flutter/foundation.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

@immutable
class AyahRef {
  const AyahRef({required this.surah, required this.ayah, required this.page});

  factory AyahRef.fromSurahAyah({required int surah, required int ayah}) {
    return AyahRef(surah: surah, ayah: ayah, page: getPageNumber(surah, ayah));
  }

  final int surah;
  final int ayah;
  final int page;
}
