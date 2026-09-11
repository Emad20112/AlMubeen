import 'package:al_mubeen/core/data/data_fetch_policy.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:flutter/foundation.dart';

abstract interface class QuranReciterRepository {
  Future<DataResult<List<QuranRecitation>>> getRecitations({
    String language = 'en',
    DataFetchPolicy fetchPolicy = DataFetchPolicy.cacheFirst,
  });
}

@immutable
final class QuranRecitation {
  const QuranRecitation({
    required this.id,
    required this.reciterName,
    this.style,
    this.translatedName,
    this.languageName,
    this.identifier,
    this.hasAyahAudio = true,
    this.hasSurahAudio = true,
    this.category,
  });

  final int id;
  final String reciterName;
  final String? style;
  final String? translatedName;
  final String? languageName;
  final String? identifier;
  final bool hasAyahAudio;
  final bool hasSurahAudio;
  final String? category;

  QuranRecitation copyWith({
    int? id,
    String? reciterName,
    String? style,
    String? translatedName,
    String? languageName,
    String? identifier,
    bool? hasAyahAudio,
    bool? hasSurahAudio,
    String? category,
  }) {
    return QuranRecitation(
      id: id ?? this.id,
      reciterName: reciterName ?? this.reciterName,
      style: style ?? this.style,
      translatedName: translatedName ?? this.translatedName,
      languageName: languageName ?? this.languageName,
      identifier: identifier ?? this.identifier,
      hasAyahAudio: hasAyahAudio ?? this.hasAyahAudio,
      hasSurahAudio: hasSurahAudio ?? this.hasSurahAudio,
      category: category ?? this.category,
    );
  }
}
