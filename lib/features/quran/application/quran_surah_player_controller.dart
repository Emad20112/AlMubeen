import 'dart:async';

import 'package:al_mubeen/core/audio/audio_providers.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qcf_quran/qcf_quran.dart';

// ─── Repeat mode ───────────────────────────────────────────────

enum SurahRepeatMode { off, ayah, surah }

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
    this.recitationId,
    this.isPlaying = false,
    this.isLoading = false,
    this.errorMessage,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.repeatMode = SurahRepeatMode.off,
    this.sleepTimerSettings = const SleepTimerSettings(),
    this.sleepTimerRemaining,
    this.isLocalSource = false,
    this.retryCount = 0,
  });

  final int currentSurah;
  final int? recitationId;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final SurahRepeatMode repeatMode;
  final SleepTimerSettings sleepTimerSettings;
  final Duration? sleepTimerRemaining;
  final bool isLocalSource;
  final int retryCount;

  int get totalAyahs => getVerseCount(currentSurah);
  Duration get totalDuration => duration;
  Duration get totalPosition => position;
  String get surahName => getSurahNameArabic(currentSurah);

  bool get canRetry => errorMessage != null && !isLocalSource;

  SurahPlayerState copyWith({
    int? currentSurah,
    int? recitationId,
    bool? isPlaying,
    bool? isLoading,
    String? errorMessage,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    SurahRepeatMode? repeatMode,
    SleepTimerSettings? sleepTimerSettings,
    Duration? sleepTimerRemaining,
    bool? isLocalSource,
    int? retryCount,
    bool clearError = false,
    bool clearSleepRemaining = false,
  }) {
    return SurahPlayerState(
      currentSurah: currentSurah ?? this.currentSurah,
      recitationId: recitationId ?? this.recitationId,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      repeatMode: repeatMode ?? this.repeatMode,
      sleepTimerSettings: sleepTimerSettings ?? this.sleepTimerSettings,
      sleepTimerRemaining: clearSleepRemaining
          ? null
          : (sleepTimerRemaining ?? this.sleepTimerRemaining),
      isLocalSource: isLocalSource ?? this.isLocalSource,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

// ─── Constants ─────────────────────────────────────────────────

const _kStreamErrorTimeout = Duration(seconds: 15);
const _kBufferingWatchdogTimeout = Duration(seconds: 20);
const _kDebounceInterval = Duration(milliseconds: 500);
const _kPlaybackStateInterval = Duration(milliseconds: 350);

// ─── Controller ────────────────────────────────────────────────

final class QuranSurahPlayerController extends Notifier<SurahPlayerState> {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _bufferedSub;
  Timer? _sleepTimer;
  Timer? _sleepTickTimer;
  Timer? _bufferingWatchdog;

  int _requestId = 0;
  String? _loadedKey;
  DateTime _lastPlayAction = DateTime(0);
  DateTime? _lastPositionStateUpdate;
  DateTime? _lastBufferedStateUpdate;

  @override
  SurahPlayerState build() {
    _initPlayer();
    unawaited(_configureSession());
    ref.onDispose(_dispose);
    return const SurahPlayerState();
  }

  void _initPlayer() {
    _player = AudioPlayer();
    _attachStreamListeners();
  }

  // ── Public API ──────────────────────────────────────────────

  Future<void> playSurah({
    required int surahNumber,
    required int recitationId,
    int? position,
  }) async {
    if (!_debounce()) return;

    state = state.copyWith(
      currentSurah: surahNumber,
      recitationId: recitationId,
      clearError: true,
    );
    await _loadAndPlayChapter(surahNumber, recitationId, position: position);
  }

  Future<void> togglePlayPause() async {
    if (!_debounce()) return;

    if (state.errorMessage != null) {
      final rid = state.recitationId;
      if (rid != null) {
        await playSurah(surahNumber: state.currentSurah, recitationId: rid);
      }
      return;
    }

    try {
      if (_player == null) return;
      if (_player!.playing) {
        await _player!.pause();
      } else {
        if (_player!.processingState == ProcessingState.completed) {
          await _player!.seek(Duration.zero);
        }
        await _player!.play();
      }
    } catch (e) {
      debugPrint('togglePlayPause error: $e');
      _handleNetworkError(_requestId);
    }
  }

  Future<void> seekForward10() async {
    try {
      if (_player == null) return;
      final pos = _player!.position;
      final dur = _player!.duration;
      final target = pos + const Duration(seconds: 10);
      if (dur != null && target < dur) {
        await _player!.seek(target);
      }
    } catch (_) {}
  }

  Future<void> seekBackward10() async {
    try {
      if (_player == null) return;
      final pos = _player!.position;
      final target = pos - const Duration(seconds: 10);
      await _player!.seek(target.isNegative ? Duration.zero : target);
    } catch (_) {}
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _player?.seek(position);
    } catch (_) {}
  }

  void cycleRepeatMode() {
    final next = switch (state.repeatMode) {
      SurahRepeatMode.off => SurahRepeatMode.ayah,
      SurahRepeatMode.ayah => SurahRepeatMode.surah,
      SurahRepeatMode.surah => SurahRepeatMode.off,
    };
    state = state.copyWith(repeatMode: next);
    _updateLoopMode(next);
  }

  void setRepeatMode(SurahRepeatMode mode) {
    state = state.copyWith(repeatMode: mode);
    _updateLoopMode(mode);
  }

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
      try {
        _player?.pause();
      } catch (_) {}
      state = state.copyWith(
        isPlaying: false,
        sleepTimerSettings: const SleepTimerSettings(),
        clearSleepRemaining: true,
      );
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    state = state.copyWith(
      sleepTimerSettings: const SleepTimerSettings(),
      clearSleepRemaining: true,
    );
  }

  Future<void> stop() async {
    _requestId++;
    _cancelAllTimers();
    _loadedKey = null;
    _lastPositionStateUpdate = null;
    _lastBufferedStateUpdate = null;

    try {
      await _player?.stop();
    } catch (_) {}

    state = const SurahPlayerState();
  }

  Future<void> retry() async {
    final rid = state.recitationId;
    if (rid != null) {
      await playSurah(surahNumber: state.currentSurah, recitationId: rid);
    }
  }

  // ── Core: Load & Play ───────────────────────────────────────

  Future<void> _loadAndPlayChapter(
    int surah,
    int recitationId, {
    int? position,
  }) async {
    final key = '$recitationId:$surah';

    // Resume from loaded source
    if (_loadedKey == key && _player != null && !_player!.playing) {
      try {
        if (_player!.processingState == ProcessingState.completed) {
          await _player!.seek(Duration.zero);
        }
        await _player!.play();
      } catch (_) {
        _handleNetworkError(_requestId);
      }
      return;
    }

    final reqId = ++_requestId;

    state = state.copyWith(
      currentSurah: surah,
      recitationId: recitationId,
      isLoading: true,
      clearError: true,
    );

    try {
      await _player?.stop();
    } catch (_) {}
    _loadedKey = null;

    try {
      // 1. Fetch the audio URL from the API
      final urlResult = await ref
          .read(quranAudioRepositoryProvider)
          .getChapterAudioUrl(reciterId: recitationId, surahNumber: surah)
          .timeout(_kStreamErrorTimeout);

      if (reqId != _requestId) return;

      final networkUrl = urlResult.valueOrNull;
      if (networkUrl == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'تعذر جلب رابط تلاوة سورة ${getSurahNameArabic(surah)}.',
        );
        return;
      }

      // 2. Use AudioRepository to decide local vs network
      final audioRepo = ref.read(audioRepositoryProvider);
      final resolved = await audioRepo.resolveSurahSource(
        reciterId: recitationId,
        surahNumber: surah,
        networkUrl: networkUrl,
      );

      if (reqId != _requestId) return;

      // 3. Ensure player exists
      _ensurePlayer();

      // 4. Set the audio source — either local file or network URI
      //    NO LockCachingAudioSource. NO proxy. NO cache.
      final sourceFuture = _player!.setAudioSource(resolved.source);
      final completer = Completer<void>();
      late final StreamSubscription<void> sub;

      sub = sourceFuture.asStream().listen(
        (_) {
          if (!completer.isCompleted) completer.complete();
        },
        onError: (Object error) {
          if (!completer.isCompleted) completer.completeError(error);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete();
        },
      );

      try {
        await completer.future.timeout(_kStreamErrorTimeout);
      } on TimeoutException {
        debugPrint('setAudioSource timeout');
        try {
          await _player?.stop();
        } catch (_) {}
        if (reqId == _requestId) {
          _handleNetworkError(
            reqId,
            message: 'انتهت مهلة تحميل السورة. تحقق من اتصال الإنترنت.',
          );
        }
        return;
      } finally {
        sub.cancel();
      }

      _updateLoopMode(state.repeatMode);

      if (reqId != _requestId) return;

      _loadedKey = key;
      _startBufferingWatchdog(reqId);

      state = state.copyWith(isLocalSource: resolved.isLocal, retryCount: 0);

      if (position != null && position > 0) {
        await _player!.seek(Duration(seconds: position));
      }

      await _player!.play();
    } on TimeoutException catch (e, st) {
      debugPrint('SurahPlayer TimeoutException: $e\n$st');
      if (reqId == _requestId) {
        _handleNetworkError(
          reqId,
          message: 'انتهت مهلة الاتصال. تحقق من سرعة الإنترنت.',
        );
      }
    } on PlayerException catch (e, st) {
      debugPrint('SurahPlayer PlayerException: $e\n$st');
      if (reqId == _requestId) {
        final msg = _isSourceNotFound(e)
            ? 'صوت السورة غير متوفر حالياً لهذا القارئ.'
            : 'حدث خطأ أثناء تشغيل التلاوة.';
        _handleNetworkError(reqId, message: msg);
      }
    } on Object catch (e, st) {
      debugPrint('SurahPlayer unexpected error: $e\n$st');
      if (reqId == _requestId) {
        _handleNetworkError(reqId, message: 'تعذر تشغيل تلاوة هذه السورة.');
      }
    }
  }

  void _ensurePlayer() {
    if (_player == null) {
      _player = AudioPlayer();
      _attachStreamListeners();
    }
  }

  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      debugPrint('SurahPlayer session error: $e');
    }
  }

  // ── Error handling ──────────────────────────────────────────

  void _handleNetworkError(int reqId, {String? message}) {
    if (reqId != _requestId) return;

    _cancelAllTimers();
    _loadedKey = null;
    _lastPositionStateUpdate = null;
    _lastBufferedStateUpdate = null;

    try {
      _player?.stop();
    } catch (_) {}

    final newRetryCount = state.retryCount + 1;

    state = state.copyWith(
      isLoading: false,
      isPlaying: false,
      errorMessage: message ?? 'انقطع الاتصال بالإنترنت. يرجى المحاولة لاحقاً.',
      retryCount: newRetryCount,
    );
  }

  void _onStreamError(Object error) {
    debugPrint('SurahPlayer stream error: $error');

    String msg;
    if (error is TimeoutException) {
      msg = 'انتهت مهلة الاتصال.';
    } else if (error is PlayerException) {
      msg = _isSourceNotFound(error)
          ? 'صوت السورة غير متوفر حالياً لهذا القارئ.'
          : 'حدث خطأ في المشغل.';
    } else {
      msg = 'حدث خطأ في الاتصال أثناء التشغيل.';
    }

    _handleNetworkError(_requestId, message: msg);
  }

  bool _isSourceNotFound(PlayerException e) {
    final text = '${e.message} ${e.code}'.toLowerCase();
    return text.contains('404') ||
        text.contains('source error') ||
        text.contains('response code');
  }

  // ── Debounce ────────────────────────────────────────────────

  bool _debounce() {
    final now = DateTime.now();
    if (now.difference(_lastPlayAction) < _kDebounceInterval) return false;
    _lastPlayAction = now;
    return true;
  }

  // ── Buffering watchdog ──────────────────────────────────────

  void _startBufferingWatchdog(int reqId) {
    _bufferingWatchdog?.cancel();
    _bufferingWatchdog = Timer(_kBufferingWatchdogTimeout, () {
      if (reqId != _requestId) return;
      if (state.isLoading && !state.isPlaying) {
        debugPrint('Buffering watchdog triggered — stream stalled');
        _handleNetworkError(
          reqId,
          message: 'تم تجميد التحميل. تحقق من اتصال الإنترنت وأعد المحاولة.',
        );
      }
    });
  }

  // ── Stream listeners ────────────────────────────────────────

  void _attachStreamListeners() {
    if (_player == null) return;

    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _bufferedSub?.cancel();

    _playerStateSub = _player!.playerStateStream.listen(
      _onPlayerState,
      onError: _onStreamError,
    );

    _positionSub = _player!.positionStream.listen(
      _handlePositionChanged,
      onError: _onStreamError,
    );

    _durationSub = _player!.durationStream.listen((dur) {
      if (dur != null && dur != state.duration) {
        state = state.copyWith(duration: dur);
      }
    }, onError: _onStreamError);

    _bufferedSub = _player!.bufferedPositionStream.listen(
      _handleBufferedPositionChanged,
      onError: _onStreamError,
    );
  }

  void _handlePositionChanged(Duration position) {
    final now = DateTime.now();
    final lastUpdate = _lastPositionStateUpdate;
    final positionDeltaMs = (position - state.position).inMilliseconds.abs();

    if (lastUpdate != null &&
        now.difference(lastUpdate) < _kPlaybackStateInterval &&
        positionDeltaMs < 1000) {
      return;
    }

    if (position != state.position) {
      _lastPositionStateUpdate = now;
      state = state.copyWith(position: position);
    }
  }

  void _handleBufferedPositionChanged(Duration bufferedPosition) {
    final now = DateTime.now();
    final lastUpdate = _lastBufferedStateUpdate;
    final positionDeltaMs = (bufferedPosition - state.bufferedPosition)
        .inMilliseconds
        .abs();

    if (lastUpdate != null &&
        now.difference(lastUpdate) < _kPlaybackStateInterval &&
        positionDeltaMs < 1000) {
      return;
    }

    if (bufferedPosition != state.bufferedPosition) {
      _lastBufferedStateUpdate = now;
      state = state.copyWith(bufferedPosition: bufferedPosition);
    }
  }

  void _onPlayerState(PlayerState playerState) {
    final processingState = playerState.processingState;
    final isLoadingState =
        processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;
    final completed = processingState == ProcessingState.completed;

    // If idle while we expected loading → playback failed silently
    if (processingState == ProcessingState.idle && state.isLoading) {
      _bufferingWatchdog?.cancel();
      state = state.copyWith(isLoading: false, isPlaying: false);
      if (!state.isLocalSource) {
        _handleNetworkError(
          _requestId,
          message: 'فشل تحميل التلاوة. يرجى المحاولة مرة أخرى.',
        );
      }
      return;
    }

    if (completed) {
      _bufferingWatchdog?.cancel();
    }

    state = state.copyWith(
      isLoading: isLoadingState,
      isPlaying: playerState.playing && !completed,
    );
  }

  void _updateLoopMode(SurahRepeatMode mode) {
    if (_loadedKey == null || _player == null) return;
    try {
      switch (mode) {
        case SurahRepeatMode.off:
          _player!.setLoopMode(LoopMode.off);
        case SurahRepeatMode.ayah:
          _player!.setLoopMode(LoopMode.one);
        case SurahRepeatMode.surah:
          _player!.setLoopMode(LoopMode.all);
      }
    } catch (_) {}
  }

  // ── Timer helpers ───────────────────────────────────────────

  void _cancelAllTimers() {
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    _bufferingWatchdog?.cancel();
  }

  // ── Dispose ─────────────────────────────────────────────────

  void _dispose() {
    _requestId++;
    _cancelAllTimers();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _bufferedSub?.cancel();
    _loadedKey = null;
    _lastPositionStateUpdate = null;
    _lastBufferedStateUpdate = null;
    _player?.dispose();
    _player = null;
  }
}
