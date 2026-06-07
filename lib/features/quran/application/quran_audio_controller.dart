import 'dart:async';

import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

final quranAudioControllerProvider =
    NotifierProvider<QuranAudioController, QuranAudioState>(
      QuranAudioController.new,
    );

@immutable
final class QuranAudioState {
  const QuranAudioState({
    this.currentAyah,
    this.recitationId,
    this.isPlaying = false,
    this.isLoading = false,
    this.errorMessage,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  final AyahRef? currentAyah;
  final int? recitationId;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;
  final Duration position;
  final Duration duration;

  bool isCurrent({required AyahRef ayahRef, required int recitationId}) {
    final current = currentAyah;
    return current != null &&
        current.surah == ayahRef.surah &&
        current.ayah == ayahRef.ayah &&
        this.recitationId == recitationId;
  }

  QuranAudioState copyWith({
    AyahRef? currentAyah,
    int? recitationId,
    bool? isPlaying,
    bool? isLoading,
    String? errorMessage,
    Duration? position,
    Duration? duration,
  }) {
    return QuranAudioState(
      currentAyah: currentAyah ?? this.currentAyah,
      recitationId: recitationId ?? this.recitationId,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

final class QuranAudioController extends Notifier<QuranAudioState> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  String? _loadedKey;
  final Set<String> _prefetchingKeys = <String>{};

  @override
  QuranAudioState build() {
    _audioPlayer = AudioPlayer();
    unawaited(_configureAudioSession());

    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      _handlePlayerState,
    );
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _audioPlayer.dispose();
    });

    return const QuranAudioState();
  }

  Future<void> playOrToggleAyah({
    required AyahRef ayahRef,
    required int recitationId,
  }) async {
    final key = _keyFor(ayahRef, recitationId);

    if (_loadedKey == key) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.processingState == ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.play();
      }
      return;
    }

    state = QuranAudioState(
      currentAyah: ayahRef,
      recitationId: recitationId,
      isLoading: true,
    );

    final result = await ref
        .read(quranAudioRepositoryProvider)
        .getAyahAudio(
          verseKey: QuranVerseKey(surah: ayahRef.surah, ayah: ayahRef.ayah),
          recitationId: recitationId,
        );

    final audioFile = result.valueOrNull;
    if (audioFile == null) {
      state = QuranAudioState(
        currentAyah: ayahRef,
        recitationId: recitationId,
        errorMessage:
            result.failureOrNull?.message ?? 'تعذر تجهيز تلاوة هذه الآية.',
      );
      return;
    }

    try {
      final audioSource = LockCachingAudioSource(audioFile.url);
      await _audioPlayer.setAudioSource(audioSource);
      _loadedKey = key;
      await _audioPlayer.play();
    } on Object catch (error) {
      debugPrint('Quran audio playback error: $error');
      state = QuranAudioState(
        currentAyah: ayahRef,
        recitationId: recitationId,
        errorMessage: 'تعذر تشغيل تلاوة هذه الآية.',
      );
    }
  }

  /// Prefetch the audio for [ayahRef] and [recitationId] without starting playback.
  Future<void> prefetchAyah({
    required AyahRef ayahRef,
    required int recitationId,
  }) async {
    final key = _keyFor(ayahRef, recitationId);
    if (_loadedKey == key || _prefetchingKeys.contains(key)) {
      return;
    }

    _prefetchingKeys.add(key);
    try {
      final result = await ref
          .read(quranAudioRepositoryProvider)
          .getAyahAudio(
            verseKey: QuranVerseKey(surah: ayahRef.surah, ayah: ayahRef.ayah),
            recitationId: recitationId,
          );

      final audioFile = result.valueOrNull;
      if (audioFile == null) {
        return;
      }

      final audioSource = LockCachingAudioSource(audioFile.url);
      await _audioPlayer.setAudioSource(audioSource);
      _loadedKey = key;
    } on Object catch (_) {
      // Silently ignore prefetch failures; user can retry by tapping play.
    } finally {
      _prefetchingKeys.remove(key);
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _loadedKey = null;
    state = const QuranAudioState();
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } on Object catch (error) {
      debugPrint('Quran audio session error: $error');
    }
  }

  void _handlePlayerState(PlayerState playerState) {
    final isLoading =
        playerState.processingState == ProcessingState.loading ||
        playerState.processingState == ProcessingState.buffering;
    final completed = playerState.processingState == ProcessingState.completed;

    state = state.copyWith(
      isLoading: isLoading,
      isPlaying: playerState.playing && !completed,
      position: completed ? Duration.zero : state.position,
    );

    if (completed) {
      unawaited(_audioPlayer.seek(Duration.zero));

      final current = state.currentAyah;
      final recId = state.recitationId;

      if (current != null && recId != null) {
        final next = _nextAyah(current);
        if (next != null) {
          unawaited(playOrToggleAyah(ayahRef: next, recitationId: recId));
        } else {
          unawaited(stop());
        }
      }
    }
  }

  AyahRef? _nextAyah(AyahRef current) {
    final verseCount = getVerseCount(current.surah);

    if (current.ayah < verseCount) {
      return AyahRef.fromSurahAyah(
        surah: current.surah,
        ayah: current.ayah + 1,
      );
    } else if (current.surah < totalSurahCount) {
      return AyahRef.fromSurahAyah(surah: current.surah + 1, ayah: 1);
    }

    return null;
  }

  String _keyFor(AyahRef ayahRef, int recitationId) {
    return '$recitationId:${ayahRef.surah}:${ayahRef.ayah}';
  }
}
