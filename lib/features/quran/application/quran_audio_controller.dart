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
  static const int _prefetchWindowSize = 5;

  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  String? _loadedKey;
  final Set<String> _prefetchingKeys = <String>{};
  final Map<String, Uri> _prefetchCache = <String, Uri>{};
  final List<AyahRef> _bufferedAyahs = <AyahRef>[];
  int _requestId = 0;
  bool _isAdvancing = false; // حارس منع التخطي المزدوج أثناء الانتقال التلقائي

  @override
  QuranAudioState build() {
    _audioPlayer = AudioPlayer();
    _isAdvancing = false;
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
      debugPrint('🧹 AudioPlayer disposed.');
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
        debugPrint('⏸️ Pausing audio playback.');
        await _audioPlayer.pause();
      } else {
        debugPrint('▶️ Resuming audio playback.');
        if (_audioPlayer.processingState == ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.play();
        unawaited(_prefetchWindowFor(ayahRef, recitationId));
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

    debugPrint(
      '🔍 Building a small audio window for Surah: ${ayahRef.surah}, Ayah: ${ayahRef.ayah}',
    );

    try {
      await _playWindow(ayahRef, recitationId);
      if (reqId != _requestId) return;
    } on Object catch (error) {
      debugPrint('🚨 Quran audio playback error: $error');
      state = QuranAudioState(
        currentAyah: ayahRef,
        recitationId: recitationId,
        errorMessage: 'تعذر تشغيل تلاوة هذه الآية.',
      );
    }
  }

  Future<void> _prefetchWindowFor(AyahRef startFrom, int recitationId) async {
    final window = buildPrefetchWindow(
      start: startFrom,
      count: _prefetchWindowSize,
      nextAyah: _nextAyah,
    );

    if (window.isEmpty) {
      return;
    }

    await Future.wait(
      window.map((ayahRef) => _fetchAyahUri(ayahRef, recitationId)),
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
      debugPrint(
        '📥 Prefetching next ayah -> Surah: ${ayahRef.surah}, Ayah: ${ayahRef.ayah}',
      );
      return await _loadAyahUri(ayahRef, recitationId);
    } finally {
      _prefetchingKeys.remove(key);
    }
  }

  Future<Uri> _loadAyahUri(AyahRef ayahRef, int recitationId) async {
    final result = await ref
        .read(quranAudioRepositoryProvider)
        .getAyahAudio(
          verseKey: QuranVerseKey(surah: ayahRef.surah, ayah: ayahRef.ayah),
          recitationId: recitationId,
        );

    final audioFile = result.valueOrNull;
    if (audioFile == null) {
      throw StateError(
        result.failureOrNull?.message ??
            'Unable to fetch audio for ayah ${ayahRef.ayah}.',
      );
    }

    final key = _keyFor(ayahRef, recitationId);
    _prefetchCache[key] = audioFile.url;
    debugPrint(
      '💾 Prefetched and cached -> Surah: ${ayahRef.surah}, Ayah: ${ayahRef.ayah}',
    );
    return audioFile.url;
  }

  Future<void> stop() async {
    _requestId++;
    debugPrint('⏹️ Stopping audio completely.');
    await _audioPlayer.stop();
    _loadedKey = null;
    state = const QuranAudioState();
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } on Object catch (error) {
      debugPrint('🚨 Quran audio session error: $error');
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
      if (_isAdvancing) {
        debugPrint('⏳ Blocked duplicate completion event.');
        return;
      }

      _isAdvancing = true;

      debugPrint('🏁 Audio playback completed. Advancing to next Ayah.');
      final current = state.currentAyah;
      final recId = state.recitationId;

      if (current != null && recId != null) {
        final nextWindowStart = _bufferedAyahs.isNotEmpty
            ? _nextAyah(_bufferedAyahs.last)
            : _nextAyah(current);
        if (nextWindowStart != null) {
          unawaited(
            _playWindow(nextWindowStart, recId).then((_) {
              _isAdvancing = false;
            }),
          );
        } else {
          stop().then((_) => _isAdvancing = false);
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

    if (window.isEmpty) {
      return;
    }

    final uris = await Future.wait(
      window.map((ayahRef) => _fetchAyahUri(ayahRef, recitationId)),
    );

    final sources = uris.map((uri) => AudioSource.uri(uri)).toList();
    await _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: 0,
    );

    _bufferedAyahs
      ..clear()
      ..addAll(window);

    _loadedKey = _keyFor(startAyah, recitationId);
    state = state.copyWith(
      currentAyah: startAyah,
      recitationId: recitationId,
      isLoading: false,
    );
    await _audioPlayer.play();

    final nextWindowStart = _nextAyah(window.last);
    if (nextWindowStart != null) {
      unawaited(_prefetchWindowFor(nextWindowStart, recitationId));
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

List<AyahRef> buildPrefetchWindow({
  required AyahRef start,
  required int count,
  required AyahRef? Function(AyahRef) nextAyah,
}) {
  final window = <AyahRef>[];
  AyahRef? current = start;

  for (int i = 0; i < count; i++) {
    final next = nextAyah(current!);
    if (next == null) {
      break;
    }
    window.add(next);
    current = next;
  }

  return window;
}
