import 'package:flutter/foundation.dart';
import 'package:qcf_quran/qcf_quran.dart';

@immutable
class AyahRef {
  const AyahRef({required this.surah, required this.ayah, required this.page});

  factory AyahRef.fromSurahAyah({required int surah, required int ayah}) {
    return AyahRef(surah: surah, ayah: ayah, page: getPageNumber(surah, ayah));
  }

  final int surah;
  final int ayah;
  final int page;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahRef &&
          runtimeType == other.runtimeType &&
          surah == other.surah &&
          ayah == other.ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => 'AyahRef($surah:$ayah, p.$page)';
}
