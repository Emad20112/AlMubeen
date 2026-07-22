import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Pure audio playback service — no downloading, no caching, no file management.
///
/// Responsibilities:
/// - play / pause / stop / seek
/// - expose position, duration, buffered position, player state
/// - configure audio session for speech
class AudioPlayerService {
  AudioPlayerService() {
    _player = AudioPlayer();
    _attachListeners();
    unawaited(_configureSession());
  }

  late final AudioPlayer _player;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _bufferedSub;
  StreamSubscription<int?>? _currentIndexSub;

  // ── Public streams ──

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream =>
      _player.bufferedPositionStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  // ── Sync getters ──

  bool get playing => _player.playing;
  ProcessingState get processingState => _player.processingState;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  Duration get bufferedPosition => _player.bufferedPosition;
  int? get currentIndex => _player.currentIndex;

  // ── Callbacks (set by controller) ──

  void Function(PlayerState)? onPlayerState;
  void Function(Duration)? onPositionChanged;
  void Function(Duration?)? onDurationChanged;
  void Function(Duration)? onBufferedChanged;
  void Function(int?)? onCurrentIndexChanged;

  // ── Playback controls ──

  Future<void> setAudioSource(
    AudioSource source, {
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    await _player.setAudioSource(
      source,
      initialIndex: initialIndex ?? 0,
      initialPosition: initialPosition,
    );
  }

  Future<void> play() async {
    try {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    } catch (e) {
      debugPrint('AudioPlayerService.play error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('AudioPlayerService.pause error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('AudioPlayerService.stop error: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('AudioPlayerService.seek error: $e');
    }
  }

  Future<void> setLoopMode(LoopMode mode) async {
    try {
      await _player.setLoopMode(mode);
    } catch (_) {}
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed);
    } catch (_) {}
  }

  // ── Internal ──

  void _attachListeners() {
    _playerStateSub = _player.playerStateStream.listen(
      (state) => onPlayerState?.call(state),
    );
    _positionSub = _player.positionStream.listen(
      (pos) => onPositionChanged?.call(pos),
    );
    _durationSub = _player.durationStream.listen(
      (dur) => onDurationChanged?.call(dur),
    );
    _bufferedSub = _player.bufferedPositionStream.listen(
      (buf) => onBufferedChanged?.call(buf),
    );
    _currentIndexSub = _player.currentIndexStream.listen(
      (idx) => onCurrentIndexChanged?.call(idx),
    );
  }

  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      debugPrint('AudioPlayerService session error: $e');
    }
  }

  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _bufferedSub?.cancel();
    _currentIndexSub?.cancel();
    _player.dispose();
  }
}
