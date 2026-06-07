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
  });

  final int id;
  final String reciterName;
  final String? style;
  final String? translatedName;
  final String? languageName;
}
