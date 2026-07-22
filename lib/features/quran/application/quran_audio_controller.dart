import 'dart:async';

import 'package:al_mubeen/core/audio/audio_providers.dart';
import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/network/connectivity_providers.dart';
import 'package:al_mubeen/core/network/no_internet_exception.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qcf_quran/qcf_quran.dart';

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
    this.isLocalSource = false,
  });

  final AyahRef? currentAyah;
  final int? recitationId;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;
  final Duration position;
  final Duration duration;
  final bool isLocalSource;

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
    bool? isLocalSource,
  }) {
    return QuranAudioState(
      currentAyah: currentAyah ?? this.currentAyah,
      recitationId: recitationId ?? this.recitationId,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLocalSource: isLocalSource ?? this.isLocalSource,
    );
  }
}

final class QuranAudioController extends Notifier<QuranAudioState> {
  static const int _prefetchWindowSize = 5;
  static const Duration _positionStateInterval = Duration(milliseconds: 350);

  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  String? _loadedKey;
  final Set<String> _prefetchingKeys = <String>{};
  final Map<String, Uri> _prefetchCache = <String, Uri>{};
  final Map<String, bool> _localSourceCache = <String, bool>{};
  final List<AyahRef> _bufferedAyahs = <AyahRef>[];
  int _requestId = 0;
  bool _isAdvancing = false;
  DateTime? _lastPositionStateUpdate;

  @override
  QuranAudioState build() {
    _audioPlayer = AudioPlayer();
    _isAdvancing = false;
    unawaited(_configureAudioSession());

    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      _handlePlayerState,
    );
    _positionSubscription = _audioPlayer.positionStream.listen(
      _handlePositionChanged,
    );
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen(
      _handleCurrentIndexChanged,
    );

    // Listen for connectivity changes — pause playback and show error
    // when the device goes offline mid-session.
    final connectivityService = ref.read(connectivityServiceProvider);
    _connectivitySubscription = connectivityService.connectionStream.listen((
      isConnected,
    ) {
      if (!isConnected && _audioPlayer.playing) {
        _audioPlayer.pause();
        state = state.copyWith(
          isPlaying: false,
          errorMessage: 'انقطع الاتصال بالإنترنت أثناء التشغيل.',
        );
      }
    });

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _currentIndexSubscription?.cancel();
      _connectivitySubscription?.cancel();
      _audioPlayer.dispose();
      debugPrint('AudioPlayer disposed.');
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
        _safePrefetch(ayahRef, recitationId);
      }
      return;
    }

    final reqId = ++_requestId;

    state = QuranAudioState(
      currentAyah: ayahRef,
      recitationId: recitationId,
      isLoading: true,
    );

    await _audioPlayer.stop();
    _loadedKey = null;

    try {
      await _playWindow(ayahRef, recitationId);
      if (reqId != _requestId) return;
    } on NoInternetException catch (error) {
      debugPrint('Quran audio offline: $error');
      _setErrorState(ayahRef, recitationId, error.message);
    } on TimeoutException {
      debugPrint('Quran audio timeout');
      await _recheckConnectivityOrError(ayahRef, recitationId);
    } on Object catch (error) {
      debugPrint('Quran audio playback error: $error');
      _setErrorState(
        ayahRef,
        recitationId,
        _isNetworkRelated(error)
            ? 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.'
            : 'تعذر تشغيل تلاوة هذه الآية.',
      );
    }
  }

  Future<void> _prefetchWindowFor(AyahRef startFrom, int recitationId) async {
    final window = buildPrefetchWindow(
      start: startFrom,
      count: _prefetchWindowSize,
      nextAyah: _nextAyah,
    );

    if (window.isEmpty) return;

    await Future.wait(
      window.map((ayahRef) => _fetchAyahUri(ayahRef, recitationId)),
    );
  }

  /// Wraps [_prefetchWindowFor] so that any thrown error is logged
  /// instead of becoming an unhandled Future error.
  void _safePrefetch(AyahRef startFrom, int recitationId) {
    unawaited(
      _prefetchWindowFor(startFrom, recitationId).catchError((error) {
        debugPrint('Prefetch error (safe): $error');
      }),
    );
  }

  Future<Uri> _fetchAyahUri(AyahRef ayahRef, int recitationId) async {
    final key = _keyFor(ayahRef, recitationId);
    if (_prefetchCache.containsKey(key)) {
      return _prefetchCache[key]!;
    }

    if (_prefetchingKeys.contains(key)) {
      return _loadAyahUri(ayahRef, recitationId);
    }

    _prefetchingKeys.add(key);
    try {
      return await _loadAyahUri(ayahRef, recitationId);
    } finally {
      _prefetchingKeys.remove(key);
    }
  }

  Future<Uri> _loadAyahUri(AyahRef ayahRef, int recitationId) async {
    final connectivityService = ref.read(connectivityServiceProvider);
    final online = await connectivityService.checkConnection();
    if (!online) {
      throw const NoInternetException();
    }

    final audioRepo = ref.read(audioRepositoryProvider);
    final result = await ref
        .read(quranAudioRepositoryProvider)
        .getAyahAudio(
          verseKey: QuranVerseKey(surah: ayahRef.surah, ayah: ayahRef.ayah),
          recitationId: recitationId,
        );

    final audioFile = result.valueOrNull;
    if (audioFile == null) {
      final failure = result.failureOrNull;
      if (failure != null &&
          (failure.kind == DataFailureKind.network ||
              failure.kind == DataFailureKind.timeout)) {
        throw const NoInternetException();
      }
      throw StateError(
        failure?.message ?? 'Unable to fetch audio for ayah ${ayahRef.ayah}.',
      );
    }

    // Check if local file exists
    final resolved = await audioRepo.resolveAyahSource(
      reciterId: recitationId,
      surahNumber: ayahRef.surah,
      ayahNumber: ayahRef.ayah,
      networkUrl: audioFile.url,
    );

    final key = _keyFor(ayahRef, recitationId);
    _prefetchCache[key] = audioFile.url;
    _localSourceCache[key] = resolved.isLocal;
    return audioFile.url;
  }

  Future<void> stop() async {
    _requestId++;
    await _audioPlayer.stop();
    _loadedKey = null;
    _lastPositionStateUpdate = null;
    state = const QuranAudioState();
  }

  Future<void> seekForward({int seconds = 10}) async {
    final currentPosition = _audioPlayer.position;
    final newPosition = currentPosition + Duration(seconds: seconds);
    final duration = _audioPlayer.duration;

    if (duration != null && newPosition > duration) {
      await _audioPlayer.seek(duration);
    } else {
      await _audioPlayer.seek(newPosition);
    }
  }

  Future<void> seekBackward({int seconds = 10}) async {
    final currentPosition = _audioPlayer.position;
    final newPosition = currentPosition - Duration(seconds: seconds);

    if (newPosition < Duration.zero) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      await _audioPlayer.seek(newPosition);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } on Object catch (error) {
      debugPrint('Quran audio session error: $error');
    }
  }

  void _handlePositionChanged(Duration position) {
    final now = DateTime.now();
    final lastUpdate = _lastPositionStateUpdate;
    final positionDeltaMs = (position - state.position).inMilliseconds.abs();

    if (lastUpdate != null &&
        now.difference(lastUpdate) < _positionStateInterval &&
        positionDeltaMs < 1000) {
      return;
    }

    _lastPositionStateUpdate = now;
    state = state.copyWith(position: position);
  }

  void _handleCurrentIndexChanged(int? index) {
    if (index == null || _bufferedAyahs.isEmpty) return;
    if (index < 0 || index >= _bufferedAyahs.length) return;

    final ayah = _bufferedAyahs[index];
    final current = state.currentAyah;

    if (current != null &&
        current.surah == ayah.surah &&
        current.ayah == ayah.ayah) {
      return;
    }

    _loadedKey = _keyFor(ayah, state.recitationId!);
    state = state.copyWith(currentAyah: ayah);
  }

  void _handlePlayerState(PlayerState playerState) {
    final isLoading =
        playerState.processingState == ProcessingState.loading ||
        playerState.processingState == ProcessingState.buffering;
    final completed = playerState.processingState == ProcessingState.completed;

    final nextIsPlaying = playerState.playing && !completed;
    final nextPosition = completed ? Duration.zero : state.position;
    if (state.isLoading != isLoading ||
        state.isPlaying != nextIsPlaying ||
        state.position != nextPosition) {
      state = state.copyWith(
        isLoading: isLoading,
        isPlaying: nextIsPlaying,
        position: nextPosition,
      );
    }

    if (completed) {
      if (_isAdvancing) return;
      _isAdvancing = true;

      final current = state.currentAyah;
      final recId = state.recitationId;

      if (current != null && recId != null) {
        final nextWindowStart = _bufferedAyahs.isNotEmpty
            ? _nextAyah(_bufferedAyahs.last)
            : _nextAyah(current);
        if (nextWindowStart != null) {
          unawaited(
            _playWindow(nextWindowStart, recId)
                .catchError((Object error) {
                  debugPrint('Auto-advance error: $error');
                  _setErrorState(
                    nextWindowStart,
                    recId,
                    _isNetworkRelated(error)
                        ? 'انقطع الاتصال أثناء التلاوة. تحقق من الإنترنت وأعد المحاولة.'
                        : 'تعذر تحميل الآيات التالية.',
                  );
                })
                .whenComplete(() {
                  _isAdvancing = false;
                }),
          );
        } else {
          stop().whenComplete(() => _isAdvancing = false);
        }
      } else {
        _isAdvancing = false;
      }
    }
  }

  Future<void> _playWindow(AyahRef startAyah, int recitationId) async {
    final window =
        <AyahRef>[startAyah] +
        buildPrefetchWindow(
          start: startAyah,
          count: _prefetchWindowSize - 1,
          nextAyah: _nextAyah,
        );

    if (window.isEmpty) return;

    final audioRepo = ref.read(audioRepositoryProvider);
    final sources = <AudioSource>[];
    bool anyLocal = false;

    for (final ayahRef in window) {
      final key = _keyFor(ayahRef, recitationId);

      // Fetch the URI if not cached
      if (!_prefetchCache.containsKey(key)) {
        await _fetchAyahUri(ayahRef, recitationId);
      }

      final networkUrl = _prefetchCache[key];
      if (networkUrl == null) {
        throw NoInternetException(
          'تعذر تحميل بيانات الصوت للآية ${ayahRef.ayah}.',
        );
      }

      // Use AudioRepository to resolve local vs network
      final resolved = await audioRepo.resolveAyahSource(
        reciterId: recitationId,
        surahNumber: ayahRef.surah,
        ayahNumber: ayahRef.ayah,
        networkUrl: networkUrl,
      );

      sources.add(resolved.source);
      if (resolved.isLocal) anyLocal = true;
    }

    await _audioPlayer.setAudioSources(sources, initialIndex: 0);

    _bufferedAyahs
      ..clear()
      ..addAll(window);

    _loadedKey = _keyFor(startAyah, recitationId);
    state = state.copyWith(
      currentAyah: startAyah,
      recitationId: recitationId,
      isLoading: false,
      isLocalSource: anyLocal,
    );
    await _audioPlayer.play();

    final nextWindowStart = _nextAyah(window.last);
    if (nextWindowStart != null) {
      _safePrefetch(nextWindowStart, recitationId);
    }
  }

  /// After a timeout, re-check connectivity. If the device is truly offline,
  /// show a clean [NoInternetException] message. Otherwise, show a generic
  /// server error.
  Future<void> _recheckConnectivityOrError(
    AyahRef ayahRef,
    int recitationId,
  ) async {
    final connectivityService = ref.read(connectivityServiceProvider);
    final online = await connectivityService.checkConnection();
    if (!online) {
      _setErrorState(ayahRef, recitationId, 'لا يوجد اتصال بالإنترنت.');
    } else {
      _setErrorState(
        ayahRef,
        recitationId,
        'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.',
      );
    }
  }

  void _setErrorState(AyahRef ayahRef, int recitationId, String message) {
    _requestId++;
    try {
      _audioPlayer.stop();
    } catch (_) {}
    _loadedKey = null;
    _lastPositionStateUpdate = null;
    state = QuranAudioState(
      currentAyah: ayahRef,
      recitationId: recitationId,
      errorMessage: message,
    );
  }

  bool _isNetworkRelated(Object error) {
    if (error is NoInternetException) return true;
    if (error is TimeoutException) return true;
    final text = error.toString().toLowerCase();
    return text.contains('timeout') ||
        text.contains('socket') ||
        text.contains('connection') ||
        text.contains('network') ||
        text.contains('internet') ||
        text.contains('backend request');
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

List<AyahRef> buildPrefetchWindow({
  required AyahRef start,
  required int count,
  required AyahRef? Function(AyahRef) nextAyah,
}) {
  final window = <AyahRef>[];
  AyahRef? current = start;

  for (int i = 0; i < count; i++) {
    final next = nextAyah(current!);
    if (next == null) break;
    window.add(next);
    current = next;
  }

  return window;
}
