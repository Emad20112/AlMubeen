import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_controller.dart';
import 'package:flutter/material.dart';

@immutable
class PlayerShell {
  const PlayerShell({
    required this.recitationId,
    required this.currentSurah,
    required this.isPlaying,
    required this.isLoading,
    required this.hasError,
  });

  factory PlayerShell.from(SurahPlayerState state) {
    return PlayerShell(
      recitationId: state.recitationId,
      currentSurah: state.currentSurah,
      isPlaying: state.isPlaying,
      isLoading: state.isLoading,
      hasError: state.errorMessage != null,
    );
  }

  final int? recitationId;
  final int currentSurah;
  final bool isPlaying;
  final bool isLoading;
  final bool hasError;

  @override
  bool operator ==(Object other) {
    return other is PlayerShell &&
        other.recitationId == recitationId &&
        other.currentSurah == currentSurah &&
        other.isPlaying == isPlaying &&
        other.isLoading == isLoading &&
        other.hasError == hasError;
  }

  @override
  int get hashCode {
    return Object.hash(
      recitationId,
      currentSurah,
      isPlaying,
      isLoading,
      hasError,
    );
  }
}

@immutable
class PlayerBarState {
  const PlayerBarState({
    required this.recitationId,
    required this.currentSurah,
    required this.surahName,
    required this.isPlaying,
    required this.isLoading,
    required this.errorMessage,
    required this.canRetry,
    required this.position,
  });

  factory PlayerBarState.from(SurahPlayerState s) {
    return PlayerBarState(
      recitationId: s.recitationId,
      currentSurah: s.currentSurah,
      surahName: s.surahName,
      isPlaying: s.isPlaying,
      isLoading: s.isLoading,
      errorMessage: s.errorMessage,
      canRetry: s.canRetry,
      position: s.position,
    );
  }

  final int? recitationId;
  final int currentSurah;
  final String? surahName;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;
  final bool canRetry;
  final Duration position;

  @override
  bool operator ==(Object other) {
    return other is PlayerBarState &&
        other.recitationId == recitationId &&
        other.currentSurah == currentSurah &&
        other.surahName == surahName &&
        other.isPlaying == isPlaying &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.canRetry == canRetry &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(
    recitationId,
    currentSurah,
    surahName,
    isPlaying,
    isLoading,
    errorMessage,
    canRetry,
    position,
  );
}

@immutable
class ExpandedControlsState {
  const ExpandedControlsState({
    required this.recitationId,
    required this.currentSurah,
    required this.isPlaying,
    required this.isLoading,
    required this.errorMessage,
    required this.repeatMode,
    required this.duration,
    required this.position,
    required this.totalDuration,
    required this.totalPosition,
    required this.bufferedPosition,
  });

  factory ExpandedControlsState.from(SurahPlayerState s) {
    return ExpandedControlsState(
      recitationId: s.recitationId,
      currentSurah: s.currentSurah,
      isPlaying: s.isPlaying,
      isLoading: s.isLoading,
      errorMessage: s.errorMessage,
      repeatMode: s.repeatMode,
      duration: s.duration,
      position: s.position,
      totalDuration: s.totalDuration,
      totalPosition: s.totalPosition,
      bufferedPosition: s.bufferedPosition,
    );
  }

  final int? recitationId;
  final int currentSurah;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;
  final SurahRepeatMode repeatMode;
  final Duration duration;
  final Duration position;
  final Duration totalDuration;
  final Duration totalPosition;
  final Duration bufferedPosition;

  @override
  bool operator ==(Object other) {
    return other is ExpandedControlsState &&
        other.recitationId == recitationId &&
        other.currentSurah == currentSurah &&
        other.isPlaying == isPlaying &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.repeatMode == repeatMode &&
        other.duration == duration &&
        other.position == position &&
        other.totalDuration == totalDuration &&
        other.totalPosition == totalPosition &&
        other.bufferedPosition == bufferedPosition;
  }

  @override
  int get hashCode => Object.hash(
    recitationId,
    currentSurah,
    isPlaying,
    isLoading,
    errorMessage,
    repeatMode,
    duration,
    position,
    totalDuration,
    totalPosition,
    bufferedPosition,
  );
}

abstract final class ListeningPalette {
  const ListeningPalette._();

  static const List<Color> goldGradient = <Color>[
    AppColors.goldDeep,
    AppColors.goldDeepEnd,
  ];

  static const List<Color> darkPageGradient = <Color>[
    Color(0xFF1A1210),
    Color(0xFF241815),
    Color(0xFF1A1210),
  ];

  static const List<Color> lightPageGradient = <Color>[
    Color(0xFFF6F0E5),
    Color(0xFFFFFCF3),
    Color(0xFFF6F0E5),
  ];

  static LinearGradient pageGradientFor(Brightness brightness) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: brightness == Brightness.dark
          ? darkPageGradient
          : lightPageGradient,
    );
  }
}

String formatDuration(Duration d) {
  if (d.isNegative || d.inSeconds.isNaN) return '00:00';
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String toArabicNum(int number) {
  const digits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return number.toString().split('').map((d) => digits[d] ?? d).join();
}
