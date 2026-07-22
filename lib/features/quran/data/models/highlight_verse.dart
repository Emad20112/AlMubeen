import 'dart:ui';

class HighlightVerse {
  final int verseNumber;
  final int surah;
  final int page;
  final Color color;

  const HighlightVerse({
    required this.verseNumber,
    required this.page,
    required this.surah,
    required this.color,
  });

  HighlightVerse copyWith({
    int? verseNumber,
    int? page,
    int? surah,
    Color? color,
  }) {
    return HighlightVerse(
      surah: surah ?? this.surah,
      verseNumber: verseNumber ?? this.verseNumber,
      page: page ?? this.page,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'verseNumber': verseNumber,
      'surah': surah,
      'page': page,
      'color': color.toARGB32(),
    };
  }

  factory HighlightVerse.fromMap(Map<String, dynamic> map) {
    return HighlightVerse(
      verseNumber: map['verseNumber'] as int,
      page: map['page'] as int,
      surah: map['surah'] as int,
      color: Color(map['color'] as int),
    );
  }

  @override
  String toString() =>
      'HighlightVerse(surah: $surah, verseNumber: $verseNumber, page: $page, color: ${color.toARGB32()})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HighlightVerse &&
        other.verseNumber == verseNumber &&
        other.surah == surah &&
        other.page == page &&
        other.color.toARGB32() == color.toARGB32();
  }

  @override
  int get hashCode =>
      verseNumber.hashCode ^ surah.hashCode ^ page.hashCode ^ color.toARGB32().hashCode;
}
