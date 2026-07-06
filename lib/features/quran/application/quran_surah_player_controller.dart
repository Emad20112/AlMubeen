import 'dart:async';

import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
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
  final Duration position; // موقع التشغيل الحالي داخل الآية
  final Duration duration; // مدة الآية الحالية (يتم جلبها تلقائياً من المشغل)
  final List<QuranAudioFile> currentSurahAudios;
  final SurahRepeatMode repeatMode;
  final SleepTimerSettings sleepTimerSettings;
  final Duration? sleepTimerRemaining;

  int get totalAyahs => getVerseCount(currentSurah);

  /// Backward-compatible aliases used by the UI.
  Duration get totalDuration => duration;
  Duration get totalPosition => position;

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
      currentSurahAudios: currentSurahAudios ?? this.currentSurahAudios,
      repeatMode: repeatMode ?? this.repeatMode,
      sleepTimerSettings: sleepTimerSettings ?? this.sleepTimerSettings,
      sleepTimerRemaining: clearSleepRemaining
          ? null
          : (sleepTimerRemaining ?? this.sleepTimerRemaining),
    );
  }
}

// ──
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
  final List<int> _ayahIndices = [];

  @override
  SurahPlayerState build() {
    _player = AudioPlayer();
    unawaited(_configureSession());

    // 1. الاستماع لحالة المشغل (تحميل، تشغيل، إيقاف)
    _playerStateSub = _player.playerStateStream.listen(_onPlayerState);

    // 2. الاستماع لتغير الآية الحالية (تحديث رقم الآية في الواجهة تلقائياً)
    _indexSub = _player.currentIndexStream.listen((index) {
      if (index != null && index < _ayahIndices.length) {
        final ayahNum = _ayahIndices[index];
        state = state.copyWith(
          currentAyah: ayahNum,
          position: Duration.zero,
        );
      }
    });

    // 3. الاستماع لتغير الوقت الحالي للتشغيل (لتحديث شريط التقدم بسلاسة)
    _positionSub = _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // 4. جلب مدة الملف الصوتي الحقيقي فور توفره من المشغل مباشرة (حل مشكلة عدم توفره من الـ API)
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

  /// بدء تشغيل السورة من آية معينة
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

  /// تشغيل / إيقاف مؤقت
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

  /// تقديم التشغيل بمقدار 10 ثوانٍ
  Future<void> seekForward10() async {
    final currentPosition = _player.position;
    final targetPosition = currentPosition + const Duration(seconds: 10);
    final currentDuration = _player.duration;

    if (currentDuration != null && targetPosition < currentDuration) {
      // التقديم داخل نفس الآية
      await _player.seek(targetPosition);
    } else {
      // إذا تجاوزت الـ 10 ثوانٍ مدة الآية الحالية، ننتقل للآية التالية إن وجدت
      if (_player.hasNext) {
        await _player.seekToNext();
      }
    }
  }

  /// تأخير التشغيل بمقدار 10 ثوانٍ
  Future<void> seekBackward10() async {
    final currentPosition = _player.position;
    final targetPosition = currentPosition - const Duration(seconds: 10);

    if (targetPosition.isNegative) {
      // إذا كان الرجوع للخلف سيتجاوز بداية الآية الحالية
      if (_player.hasPrevious) {
        // ننتقل للآية السابقة
        await _player.seekToPrevious();
      } else {
        // إذا كانت هذه أول آية في السورة، نعود لنقطة الصفر
        await _player.seek(Duration.zero);
      }
    } else {
      // التأخير داخل نفس الآية
      await _player.seek(targetPosition);
    }
  }

  /// الرجوع للآية السابقة (ضمن السورة الحالية)
  Future<void> previousAyah() async {
    final prev = state.currentAyah - 1;
    if (prev < 1) return;
    await jumpToAyah(prev);
  }

  /// التقدم للآية التالية (ضمن السورة الحالية)
  Future<void> nextAyah() async {
    final next = state.currentAyah + 1;
    if (next > state.totalAyahs) return;
    await jumpToAyah(next);
  }

  /// القفز المباشر لآية معينة في السورة الحالية
  Future<void> jumpToAyah(int ayahNumber) async {
    if (ayahNumber < 1 || ayahNumber > state.totalAyahs) return;

    final recId = state.recitationId;
    if (recId == null) return;

    if (_loadedKey == '$recId:${state.currentSurah}') {
      final playlistIndex = _ayahIndices.indexOf(ayahNumber);
      if (playlistIndex < 0) return;
      await _player.seek(Duration.zero, index: playlistIndex);
    } else {
      await _loadAndPlay(state.currentSurah, ayahNumber, recId);
    }
  }

  /// التحكم اليدوي من خلال شريط التقدم (Slider) الخاص بالآية
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// تبديل وضع التكرار: off → ayah → surah → off
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

  void _updateLoopMode(SurahRepeatMode mode) {
    if (_loadedKey == null) return;
    switch (mode) {
      case SurahRepeatMode.off:
        _player.setLoopMode(LoopMode.off);
      case SurahRepeatMode.ayah:
        _player.setLoopMode(LoopMode.one); // تكرار الملف الحالي (الآية الحالية)
      case SurahRepeatMode.surah:
        _player.setLoopMode(
          LoopMode.all,
        ); // تكرار القائمة بالكامل (السورة كاملة)
    }
  }

  /// مؤقت النوم
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
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    await _player.stop();
    _loadedKey = null;
    state = const SurahPlayerState();
  }

  Future<QuranAudioFile?> _fetchSurahAyah(
    int surah,
    int ayah,
    int recitationId,
  ) async {
    final result = await ref
        .read(quranAudioRepositoryProvider)
        .getAyahAudio(
          verseKey: QuranVerseKey(surah: surah, ayah: ayah),
          recitationId: recitationId,
        );
    return result.valueOrNull;
  }

  // ── Private helpers ──────────────────────────────────────────

  Future<void> _loadAndPlay(int surah, int ayah, int recitationId) async {
    final key = '$recitationId:$surah';

    if (_loadedKey == key) {
      final playlistIndex = _ayahIndices.indexOf(ayah);
      if (playlistIndex < 0) return;
      if (!_player.playing) {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero, index: playlistIndex);
        } else if (_player.currentIndex != playlistIndex) {
          await _player.seek(Duration.zero, index: playlistIndex);
        }
        await _player.play();
      } else if (_player.currentIndex != playlistIndex) {
        await _player.seek(Duration.zero, index: playlistIndex);
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

    try {
      final totalAyahs = getVerseCount(surah);
      final fetchedFiles = List<QuranAudioFile?>.filled(totalAyahs, null);
      const batchSize = 10;

      for (var batchStart = 1; batchStart <= totalAyahs; batchStart += batchSize) {
        if (reqId != _requestId) return;

        final batchEnd = (batchStart + batchSize - 1).clamp(1, totalAyahs);
        final batchFutures = <Future<QuranAudioFile?>>[];

        for (var a = batchStart; a <= batchEnd; a++) {
          batchFutures.add(_fetchSurahAyah(surah, a, recitationId));
        }

        final batchResults = await Future.wait(batchFutures);
        for (var i = 0; i < batchResults.length; i++) {
          final idx = batchStart + i - 1;
          if (batchResults[i] != null) {
            fetchedFiles[idx] = batchResults[i];
          }
        }
      }

      final validSources = <AudioSource>[];
      final ayahIndices = <int>[];
      for (var i = 0; i < fetchedFiles.length; i++) {
        final file = fetchedFiles[i];
        if (file != null) {
          final scheme = file.url.scheme;
          if (scheme == 'https' || scheme == 'http') {
            validSources.add(AudioSource.uri(file.url));
            ayahIndices.add(i + 1);
          } else {
            debugPrint('SurahPlayer: skipping invalid URL for ayah ${i + 1}: ${file.url}');
          }
        } else {
          debugPrint('SurahPlayer: no audio for ayah ${i + 1}, skipping');
        }
      }

      if (validSources.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'لا يوجد روابط تشغيل متاحة لهذه السورة.',
        );
        return;
      }

      _ayahIndices
        ..clear()
        ..addAll(ayahIndices);

      final nonNullFiles = fetchedFiles.whereType<QuranAudioFile>().toList();
      state = state.copyWith(currentSurahAudios: nonNullFiles);

      final initialIndex = ayahIndices.indexOf(ayah);
      await _player.setAudioSources(
        validSources,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
      );
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
