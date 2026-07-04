import 'dart:async';

import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

// ─── Repeat mode ───────────────────────────────────────────────

enum SurahRepeatMode {
  /// No repeat – stop after last ayah of the surah.
  off,

  /// Repeat the current ayah continuously.
  ayah,

  /// Repeat the entire surah after the last ayah.
  surah,
}

// ─── Sleep timer ───────────────────────────────────────────────

@immutable
class SleepTimerSettings {
  const SleepTimerSettings({
    this.isActive = false,
    this.duration,
    this.name,
    this.action = SleepTimerAction.stopAudio,
  });

  final bool isActive;
  final Duration? duration;
  final String? name;
  final SleepTimerAction action;
}

enum SleepTimerAction { stopAudio }

// ─── State ──────────────────────────────────────────────────────

@immutable
final class SurahPlayerState {
  const SurahPlayerState({
    this.currentSurah = 1,
    this.currentAyah = 1,
    this.recitationId,
    this.isPlaying = false,
    this.isLoading = false,
    this.errorMessage,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.totalPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.currentSurahAudios = const [],
    this.repeatMode = SurahRepeatMode.off,
    this.sleepTimerSettings = const SleepTimerSettings(),
    this.sleepTimerRemaining,
  });

  final int currentSurah;
  final int currentAyah;
  final int? recitationId;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;
  final Duration position;
  final Duration duration;
  final Duration totalPosition;
  final Duration totalDuration;
  final List<QuranAudioFile> currentSurahAudios;
  final SurahRepeatMode repeatMode;
  final SleepTimerSettings sleepTimerSettings;
  final Duration? sleepTimerRemaining;

  int get totalAyahs => getVerseCount(currentSurah);
  String get surahName => getSurahNameArabic(currentSurah);

  SurahPlayerState copyWith({
    int? currentSurah,
    int? currentAyah,
    int? recitationId,
    bool? isPlaying,
    bool? isLoading,
    String? errorMessage,
    Duration? position,
    Duration? duration,
    Duration? totalPosition,
    Duration? totalDuration,
    List<QuranAudioFile>? currentSurahAudios,
    SurahRepeatMode? repeatMode,
    SleepTimerSettings? sleepTimerSettings,
    Duration? sleepTimerRemaining,
    bool clearError = false,
    bool clearSleepRemaining = false,
  }) {
    return SurahPlayerState(
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      recitationId: recitationId ?? this.recitationId,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      position: position ?? this.position,
      duration: duration ?? this.duration,
      totalPosition: totalPosition ?? this.totalPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentSurahAudios: currentSurahAudios ?? this.currentSurahAudios,
      repeatMode: repeatMode ?? this.repeatMode,
      sleepTimerSettings: sleepTimerSettings ?? this.sleepTimerSettings,
      sleepTimerRemaining: clearSleepRemaining
          ? null
          : (sleepTimerRemaining ?? this.sleepTimerRemaining),
    );
  }
}

// ─── Provider ───────────────────────────────────────────────────

final quranSurahPlayerProvider =
    NotifierProvider<QuranSurahPlayerController, SurahPlayerState>(
      QuranSurahPlayerController.new,
    );

// ─── Controller ─────────────────────────────────────────────────

final class QuranSurahPlayerController extends Notifier<SurahPlayerState> {
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<int?>? _indexSub;
  Timer? _sleepTimer;
  Timer? _sleepTickTimer;
  String? _loadedKey;
  int _requestId = 0;

  @override
  SurahPlayerState build() {
    _player = AudioPlayer();
    unawaited(_configureSession());

    _playerStateSub = _player.playerStateStream.listen(_onPlayerState);
    _indexSub = _player.currentIndexStream.listen((index) {
      if (index != null && state.currentSurahAudios.isNotEmpty) {
        final ayahNum = index + 1;
        state = state.copyWith(currentAyah: ayahNum);
        _syncPlaybackProgress();
      }
    });
    _positionSub = _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
      _syncPlaybackProgress(localPosition: pos);
    });
    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    ref.onDispose(() {
      _playerStateSub?.cancel();
      _positionSub?.cancel();
      _durationSub?.cancel();
      _indexSub?.cancel();
      _sleepTimer?.cancel();
      _sleepTickTimer?.cancel();
      _player.dispose();
    });

    return const SurahPlayerState();
  }

  // ── Public API ──────────────────────────────────────────────

  /// Start playing a surah from [ayah] (defaults to 1).
  Future<void> playSurah({
    required int surahNumber,
    required int recitationId,
    int ayah = 1,
  }) async {
    state = state.copyWith(
      currentSurah: surahNumber,
      currentAyah: ayah,
      recitationId: recitationId,
      clearError: true,
    );
    await _loadAndPlay(surahNumber, ayah, recitationId);
  }

  /// Toggle play / pause for current ayah.
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero, index: 0);
      }
      await _player.play();
    }
  }

  /// Skip to next ayah.
  Future<void> nextAyah() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (state.repeatMode == SurahRepeatMode.surah) {
      await _player.seek(Duration.zero, index: 0);
    }
  }

  /// Skip to previous ayah.
  Future<void> previousAyah() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  /// Jump to a specific ayah number within the current surah.
  Future<void> jumpToAyah(int ayahNumber) async {
    if (ayahNumber < 1 || ayahNumber > state.totalAyahs) return;

    final recId = state.recitationId;
    if (recId == null) return;

    if (_loadedKey == '$recId:${state.currentSurah}') {
      await _player.seek(Duration.zero, index: ayahNumber - 1);
    } else {
      await _loadAndPlay(state.currentSurah, ayahNumber, recId);
    }
  }

  /// Seek within the surah globally (across all ayahs).
  Future<void> seekTo(Duration globalPosition) async {
    if (state.currentSurahAudios.isEmpty) return;

    Duration accumulated = Duration.zero;
    for (int i = 0; i < state.currentSurahAudios.length; i++) {
      final fileDuration = Duration(
        seconds: state.currentSurahAudios[i].duration ?? 0,
      );
      if (globalPosition < accumulated + fileDuration) {
        final localOffset = globalPosition - accumulated;
        await _player.seek(localOffset, index: i);
        return;
      }
      accumulated += fileDuration;
    }

    await _player.seek(
      Duration(seconds: state.currentSurahAudios.last.duration ?? 0),
      index: state.currentSurahAudios.length - 1,
    );
  }

  /// Cycle repeat mode: off → ayah → surah → off.
  void cycleRepeatMode() {
    final next = switch (state.repeatMode) {
      SurahRepeatMode.off => SurahRepeatMode.ayah,
      SurahRepeatMode.ayah => SurahRepeatMode.surah,
      SurahRepeatMode.surah => SurahRepeatMode.off,
    };
    state = state.copyWith(repeatMode: next);
    _updateLoopMode(next);
  }

  /// Set a specific repeat mode.
  void setRepeatMode(SurahRepeatMode mode) {
    state = state.copyWith(repeatMode: mode);
    _updateLoopMode(mode);
  }

  void _updateLoopMode(SurahRepeatMode mode) {
    if (_loadedKey == null) return;
    switch (mode) {
      case SurahRepeatMode.off:
        _player.setLoopMode(LoopMode.off);
      case SurahRepeatMode.ayah:
        _player.setLoopMode(LoopMode.one);
      case SurahRepeatMode.surah:
        _player.setLoopMode(LoopMode.all);
    }
  }

  /// Set sleep timer.
  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();

    if (duration == Duration.zero) {
      state = state.copyWith(
        sleepTimerSettings: const SleepTimerSettings(),
        clearSleepRemaining: true,
      );
      return;
    }

    final deadline = DateTime.now().add(duration);
    state = state.copyWith(
      sleepTimerSettings: SleepTimerSettings(
        isActive: true,
        duration: duration,
      ),
      sleepTimerRemaining: duration,
    );

    _sleepTickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining.isNegative) {
        _sleepTickTimer?.cancel();
        return;
      }
      state = state.copyWith(sleepTimerRemaining: remaining);
    });

    _sleepTimer = Timer(duration, () {
      _sleepTickTimer?.cancel();
      _player.pause();
      state = state.copyWith(
        isPlaying: false,
        sleepTimerSettings: const SleepTimerSettings(),
        clearSleepRemaining: true,
      );
    });
  }

  /// Cancel sleep timer.
  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    state = state.copyWith(
      sleepTimerSettings: const SleepTimerSettings(),
      clearSleepRemaining: true,
    );
  }

  /// Stop playback completely.
  Future<void> stop() async {
    _requestId++;
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    await _player.stop();
    _loadedKey = null;
    state = const SurahPlayerState();
  }

  // ── Private helpers ──────────────────────────────────────────

  Future<void> _loadAndPlay(int surah, int ayah, int recitationId) async {
    final key = '$recitationId:$surah';

    if (_loadedKey == key) {
      if (!_player.playing) {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero, index: ayah - 1);
        } else if (_player.currentIndex != ayah - 1) {
          await _player.seek(Duration.zero, index: ayah - 1);
        }
        await _player.play();
      } else if (_player.currentIndex != ayah - 1) {
        await _player.seek(Duration.zero, index: ayah - 1);
      }
      return;
    }

    final reqId = ++_requestId;

    state = state.copyWith(
      currentSurah: surah,
      currentAyah: ayah,
      recitationId: recitationId,
      isLoading: true,
      clearError: true,
    );

    await _player.stop();
    _loadedKey = null;

    final result = await ref
        .read(quranAudioRepositoryProvider)
        .getSurahAudioFiles(chapterNumber: surah, recitationId: recitationId);

    if (reqId != _requestId) return;

    final audioFiles = result.valueOrNull;
    if (audioFiles == null || audioFiles.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            result.failureOrNull?.message ?? 'تعذر تجهيز تلاوة هذه السورة.',
      );
      return;
    }

    try {
      final totalSecs = audioFiles.fold<int>(
        0,
        (sum, file) => sum + (file.duration ?? 0),
      );
      final totalDur = Duration(seconds: totalSecs);

      state = state.copyWith(
        currentSurahAudios: audioFiles,
        totalDuration: totalDur,
      );

      final audioSources = audioFiles.map((file) {
        return AudioSource.uri(file.url);
      }).toList();

      final playlist = ConcatenatingAudioSource(children: audioSources);

      await _player.setAudioSource(playlist, initialIndex: ayah - 1);
      _updateLoopMode(state.repeatMode);

      if (reqId != _requestId) return;

      _loadedKey = key;
      await _player.play();
    } on Object catch (error) {
      debugPrint('SurahPlayer error: $error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تشغيل تلاوة هذه السورة.',
      );
    }
  }

  void _recalculateTotalPosition() {
    _syncPlaybackProgress();
  }

  void _syncPlaybackProgress({Duration? localPosition}) {
    if (state.currentSurahAudios.isEmpty) return;

    final currentIndex = _player.currentIndex ?? 0;
    var accumulated = Duration.zero;
    for (int i = 0; i < currentIndex; i++) {
      if (i < state.currentSurahAudios.length) {
        accumulated += Duration(
          seconds: state.currentSurahAudios[i].duration ?? 0,
        );
      }
    }

    final resolvedPosition = localPosition ?? state.position;
    final total = accumulated + resolvedPosition;
    final totalDuration = state.currentSurahAudios.fold<Duration>(
      Duration.zero,
      (sum, file) => sum + Duration(seconds: file.duration ?? 0),
    );

    state = state.copyWith(totalPosition: total, totalDuration: totalDuration);
  }

  void _onPlayerState(PlayerState playerState) {
    final isLoading =
        playerState.processingState == ProcessingState.loading ||
        playerState.processingState == ProcessingState.buffering;
    final completed = playerState.processingState == ProcessingState.completed;

    state = state.copyWith(
      isLoading: isLoading,
      isPlaying: playerState.playing && !completed,
    );
  }

  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } on Object catch (error) {
      debugPrint('SurahPlayer session error: $error');
    }
  }
}
