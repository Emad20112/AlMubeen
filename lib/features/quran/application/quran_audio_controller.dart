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
  static const int _prefetchWindowSize = 6;
  static const int _prefetchTriggerIndex = 3;

  late final AudioPlayer _audioPlayer;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  String? _loadedKey;
  final Set<String> _prefetchingKeys = <String>{};
  final Map<String, Uri> _prefetchCache = <String, Uri>{};
  final List<AyahRef> _playlistAyahs = <AyahRef>[];

  int _requestId = 0;
  bool _isAppendingNextWindow = false;
  int _lastSignalledIndex = -1;
  DateTime? _lastPositionStateUpdate;

  @override
  QuranAudioState build() {
    _audioPlayer = AudioPlayer();
    unawaited(_configureAudioSession());

    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      _handlePlayerState,
      onError: _handlePlayerStreamError,
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
      onError: _handlePlayerStreamError,
    );
    _playbackEventSubscription = _audioPlayer.playbackEventStream.listen(
      (_) {},
      onError: _handlePlayerStreamError,
    );

    final connectivityService = ref.read(connectivityServiceProvider);
    _connectivitySubscription = connectivityService.connectionStream.listen((
      isConnected,
    ) {
      final currentAyah = state.currentAyah;
      final recitationId = state.recitationId;
      final isNetworkPlaybackActive =
          _audioPlayer.playing ||
          state.isLoading ||
          _audioPlayer.processingState == ProcessingState.buffering ||
          _audioPlayer.processingState == ProcessingState.loading;

      // Local files keep playing even without internet.
      if (!isConnected &&
          !state.isLocalSource &&
          isNetworkPlaybackActive &&
          currentAyah != null &&
          recitationId != null) {
        _setErrorState(
          currentAyah,
          recitationId,
          'انقطع الاتصال بالإنترنت أثناء التشغيل.',
        );
      }
    });

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _currentIndexSubscription?.cancel();
      _playbackEventSubscription?.cancel();
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

    if (_loadedKey == key && state.recitationId == recitationId) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.processingState == ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero, index: 0);
        }
        await _audioPlayer.play();
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
    _playlistAyahs.clear();
    _lastSignalledIndex = -1;

    try {
      await _startNewPlaylistWindow(ayahRef, recitationId, reqId);
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

  Future<void> playAyahFromBeginning({
    required AyahRef ayahRef,
    required int recitationId,
  }) async {
    final key = _keyFor(ayahRef, recitationId);

    if (_loadedKey == key && state.recitationId == recitationId) {
      await _audioPlayer.seek(Duration.zero, index: 0);
      await _audioPlayer.play();
      state = state.copyWith(
        currentAyah: ayahRef,
        recitationId: recitationId,
        isPlaying: true,
        isLoading: false,
      );
      return;
    }

    await playOrToggleAyah(ayahRef: ayahRef, recitationId: recitationId);
  }

  Future<void> _startNewPlaylistWindow(
    AyahRef startAyah,
    int recitationId,
    int requestId,
  ) async {
    final windowAyahs = _buildWindow(startAyah, _prefetchWindowSize);
    if (windowAyahs.isEmpty) return;

    final initialBatchCount = 1;
    final initialAyahs = windowAyahs.sublist(0, initialBatchCount);

    final resolvedInitial = await Future.wait(
      initialAyahs.map(
        (ayah) => _resolveAyahSourceForPlayback(ayah, recitationId),
      ),
    );

    if (requestId != _requestId) return;

    _playlistAyahs.addAll(initialAyahs);

    await _audioPlayer.setAudioSources([
      for (final r in resolvedInitial) r.source,
    ], initialIndex: 0);

    if (requestId != _requestId) return;

    _loadedKey = _keyFor(startAyah, recitationId);
    state = state.copyWith(
      currentAyah: startAyah,
      recitationId: recitationId,
      isLoading: false,
      isPlaying: true,
      isLocalSource: resolvedInitial.first.isLocal,
    );

    await _audioPlayer.play();

    if (windowAyahs.length > initialBatchCount) {
      final remainingAyahs = windowAyahs.sublist(initialBatchCount);
      unawaited(
        _appendAyahsToPlaylist(remainingAyahs, recitationId, requestId),
      );
    }
  }

  Future<void> _appendAyahsToPlaylist(
    List<AyahRef> ayahs,
    int recitationId,
    int requestId,
  ) async {
    if (ayahs.isEmpty) return;

    try {
      final resolvedSources = await Future.wait(
        ayahs.map((a) => _resolveAyahSourceForPlayback(a, recitationId)),
      );

      if (requestId != _requestId) return;

      await _audioPlayer.addAudioSources([
        for (final r in resolvedSources) r.source,
      ]);
      _playlistAyahs.addAll(ayahs);
    } on Object catch (e) {
      debugPrint('Error appending ayahs to playlist: $e');
    }
  }

  void _handleCurrentIndexChanged(int? index) {
    if (index == null || _playlistAyahs.isEmpty) return;
    if (index < 0 || index >= _playlistAyahs.length) return;

    final ayah = _playlistAyahs[index];
    final current = state.currentAyah;

    if (current != null &&
        current.surah == ayah.surah &&
        current.ayah == ayah.ayah) {
      return;
    }

    _loadedKey = _keyFor(ayah, state.recitationId!);
    state = state.copyWith(currentAyah: ayah);

    if (index >= _prefetchTriggerIndex &&
        index > _lastSignalledIndex &&
        !_isAppendingNextWindow) {
      _lastSignalledIndex = index;
      final lastBuffered = _playlistAyahs.last;
      final nextStart = _nextAyah(lastBuffered);

      if (nextStart != null) {
        _isAppendingNextWindow = true;
        final nextBatch = _buildWindow(nextStart, _prefetchWindowSize);

        unawaited(
          _appendAyahsToPlaylist(
            nextBatch,
            state.recitationId!,
            _requestId,
          ).whenComplete(() {
            _isAppendingNextWindow = false;
          }),
        );
      }
    }
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
  }

  Future<_ResolvedAyahSource> _resolveAyahSourceForPlayback(
    AyahRef ayahRef,
    int recitationId,
  ) async {
    final audioRepo = ref.read(audioRepositoryProvider);

    // 1. Check if the ayah is already downloaded locally first —
    //    this enables offline playback from the local audio library.
    final isLocal = await audioRepo.isAyahDownloaded(
      reciterId: recitationId,
      surahNumber: ayahRef.surah,
      ayahNumber: ayahRef.ayah,
    );

    Uri? networkUrl;
    if (!isLocal) {
      // 2. Only fetch the network URL when the file is NOT available locally.
      final key = _keyFor(ayahRef, recitationId);
      if (!_prefetchCache.containsKey(key)) {
        await _fetchAyahUri(ayahRef, recitationId);
      }

      networkUrl = _prefetchCache[key];
      if (networkUrl == null) {
        throw NoInternetException(
          'تعذر تحميل بيانات الصوت للآية ${ayahRef.ayah}.',
        );
      }
    }

    final resolved = await audioRepo.resolveAyahSource(
      reciterId: recitationId,
      surahNumber: ayahRef.surah,
      ayahNumber: ayahRef.ayah,
      networkUrl: networkUrl,
    );

    return _ResolvedAyahSource(
      source: resolved.source,
      isLocal: resolved.isLocal,
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

    final key = _keyFor(ayahRef, recitationId);
    _prefetchCache[key] = audioFile.url;
    return audioFile.url;
  }

  Future<void> stop() async {
    _requestId++;
    await _audioPlayer.stop();
    _loadedKey = null;
    _playlistAyahs.clear();
    _lastPositionStateUpdate = null;
    _prefetchCache.clear(); // تفريغ كاش العناوين لمنع تراكم المقابض
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

    // 🛡️ تجميع وتخفيف التحديثات لمنع إغراق الـ JNI بـ Allocations متكررة
    if (lastUpdate != null &&
        now.difference(lastUpdate) < const Duration(milliseconds: 400)) {
      return;
    }

    _lastPositionStateUpdate = now;
    state = state.copyWith(position: position);
  }

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
    _playlistAyahs.clear();
    _lastPositionStateUpdate = null;
    state = QuranAudioState(
      currentAyah: ayahRef,
      recitationId: recitationId,
      errorMessage: message,
    );
  }

  void _handlePlayerStreamError(Object error, StackTrace stackTrace) {
    debugPrint('Quran audio stream error: $error');

    final currentAyah = state.currentAyah;
    final recitationId = state.recitationId;
    if (currentAyah == null || recitationId == null) {
      return;
    }

    _setErrorState(
      currentAyah,
      recitationId,
      _isNetworkRelated(error)
          ? 'انقطع الاتصال أثناء التلاوة. تحقق من الإنترنت وأعد المحاولة.'
          : 'حدث خطأ أثناء تشغيل التلاوة.',
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

  List<AyahRef> _buildWindow(AyahRef start, int count) {
    return buildPrefetchWindow(start: start, count: count, nextAyah: _nextAyah);
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

/// 🛡️ Top-Level Helper Function للمحافظة على مواصفات الاختبارات والبدء بالآية المحددة
List<AyahRef> buildPrefetchWindow({
  required AyahRef start,
  required int count,
  required AyahRef? Function(AyahRef) nextAyah,
}) {
  final window = <AyahRef>[start];
  AyahRef current = start;

  for (int i = 1; i < count; i++) {
    final next = nextAyah(current);
    if (next == null) break;
    window.add(next);
    current = next;
  }

  return window;
}

@immutable
final class _ResolvedAyahSource {
  const _ResolvedAyahSource({required this.source, required this.isLocal});

  final AudioSource source;
  final bool isLocal;
}
