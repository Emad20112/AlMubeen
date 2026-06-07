import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:flutter/foundation.dart';

abstract interface class QuranAudioRepository {
  Future<DataResult<QuranAudioFile>> getAyahAudio({
    required QuranVerseKey verseKey,
    required int recitationId,
  });
}

@immutable
final class QuranAudioFile {
  const QuranAudioFile({
    required this.verseKey,
    required this.url,
    this.duration,
    this.format,
    this.id,
  });

  final QuranVerseKey verseKey;
  final Uri url;
  final int? duration;
  final String? format;
  final int? id;
}
