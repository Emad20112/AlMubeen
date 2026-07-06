import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quran_surah_player_controller.dart';

/// Riverpod provider used by the UI widgets for the Surah player.
final quranSurahPlayerProvider =
    NotifierProvider<QuranSurahPlayerController, SurahPlayerState>(
      QuranSurahPlayerController.new,
    );
