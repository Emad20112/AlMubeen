import 'package:flutter/foundation.dart';

@immutable
final class QuranVerseKey implements Comparable<QuranVerseKey> {
  const QuranVerseKey({required this.surah, required this.ayah});

  factory QuranVerseKey.parse(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      throw FormatException(
        'Expected Quran verse key in surah:ayah format.',
        value,
      );
    }

    return QuranVerseKey(surah: int.parse(parts[0]), ayah: int.parse(parts[1]));
  }

  final int surah;
  final int ayah;

  String get value => '$surah:$ayah';

  @override
  int compareTo(QuranVerseKey other) {
    final surahComparison = surah.compareTo(other.surah);
    if (surahComparison != 0) {
      return surahComparison;
    }

    return ayah.compareTo(other.ayah);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuranVerseKey && other.surah == surah && other.ayah == ayah;
  }

  @override
  int get hashCode => Object.hash(surah, ayah);
}
