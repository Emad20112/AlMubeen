import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';

@immutable
class AdhkarAudioState {
  const AdhkarAudioState({
    this.currentItemId,
    this.isPlaying = false,
    this.isLoading = false,
    this.isAutoRepeat = false,
    this.errorMessage,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  final String? currentItemId;
  final bool isPlaying;
  final bool isLoading;
  final bool isAutoRepeat; // تكرار نفس الذكر الحالي
  final String? errorMessage;
  final Duration position;
  final Duration duration;

  AdhkarAudioState copyWith({
    String? currentItemId,
    bool? isPlaying,
    bool? isLoading,
    bool? isAutoRepeat,
    String? errorMessage,
    Duration? position,
    Duration? duration,
  }) {
    return AdhkarAudioState(
      currentItemId: currentItemId ?? this.currentItemId,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isAutoRepeat: isAutoRepeat ?? this.isAutoRepeat,
      errorMessage: errorMessage,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class AdhkarAudioController extends Notifier<AdhkarAudioState> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  List<AdhkarItem> _playlist = [];
  int _currentIndex = -1;
  String? _loadedAudioUrl;

  @override
  AdhkarAudioState build() {
    _audioPlayer = AudioPlayer();
    _initAudioSession();
    
    // مراقبة وتحديث الحالات البرمجية لمشغل الصوت
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(_handlePlayerState);
    _positionSubscription = _audioPlayer.positionStream.listen(_handlePositionChange);
    _durationSubscription = _audioPlayer.durationStream.listen(_handleDurationChange);

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _audioPlayer.dispose();
    });

    return const AdhkarAudioState();
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      debugPrint('Error initializing audio session: $e');
    }
  }

  // تعيين قائمة تشغيل الأذكار الحالية
  void setPlaylist(List<AdhkarItem> items, {int initialIndex = 0}) {
    _playlist = items;
    _currentIndex = initialIndex;
    if (_playlist.isNotEmpty && _currentIndex >= 0 && _currentIndex < _playlist.length) {
      state = state.copyWith(
        currentItemId: _playlist[_currentIndex].id,
      );
    }
  }

  // تشغيل أو إيقاف مؤقت للذكر الحالي
  Future<void> togglePlay(AdhkarItem item) async {
    final audioUrl = item.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      state = state.copyWith(errorMessage: 'لا يوجد ملف صوتي لهذا الذكر');
      return;
    }

    if (state.isLoading) return;

    try {
      if (_loadedAudioUrl == audioUrl) {
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

      state = state.copyWith(isLoading: true, currentItemId: item.id);
      
      // التخزين المؤقت التلقائي باستخدام LockCachingAudioSource
      final uri = Uri.parse(audioUrl);
      // ignore: experimental_member_use
      final audioSource = LockCachingAudioSource(uri);
      
      await _audioPlayer.setAudioSource(audioSource);
      _loadedAudioUrl = audioUrl;
      
      await _audioPlayer.setLoopMode(state.isAutoRepeat ? LoopMode.one : LoopMode.off);
      await _audioPlayer.play();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        errorMessage: 'خطأ أثناء تشغيل الملف الصوتي',
      );
      debugPrint('Audio playback error: $e');
    }
  }

  // التبديل بين التكرار التلقائي للذكر الواحد
  Future<void> toggleAutoRepeat() async {
    final newValue = !state.isAutoRepeat;
    state = state.copyWith(isAutoRepeat: newValue);
    await _audioPlayer.setLoopMode(newValue ? LoopMode.one : LoopMode.off);
  }

  // الانتقال التلقائي للذكر التالي
  Future<void> next() async {
    if (_playlist.isEmpty) return;
    final nextIndex = (_currentIndex + 1) % _playlist.length;
    await selectItem(nextIndex);
  }

  // الانتقال للذكر السابق
  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    final prevIndex = _currentIndex > 0 ? _currentIndex - 1 : _playlist.length - 1;
    await selectItem(prevIndex);
  }

  // تحديد ذكر معين للتشغيل المباشر
  Future<void> selectItem(int index) async {
    if (_playlist.isEmpty || index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    final item = _playlist[_currentIndex];
    
    await _audioPlayer.stop();
    _loadedAudioUrl = null;
    state = state.copyWith(
      currentItemId: item.id,
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
      isLoading: false,
    );

    if (item.audioUrl != null && item.audioUrl!.isNotEmpty) {
      await togglePlay(item);
    }
  }

  // معالجة تحديثات حالة المشغل
  void _handlePlayerState(PlayerState playerState) {
    final isLoading = playerState.processingState == ProcessingState.loading ||
        playerState.processingState == ProcessingState.buffering;
    final completed = playerState.processingState == ProcessingState.completed;

    state = state.copyWith(
      isLoading: isLoading,
      isPlaying: playerState.playing && !completed,
    );

    // إذا انتهى الصوت ولم يكن التكرار مفعلاً، يتم الانتقال للذكر التالي تلقائياً
    if (completed && !state.isAutoRepeat) {
      _audioPlayer.pause();
      _audioPlayer.seek(Duration.zero);
      next();
    }
  }

  void _handlePositionChange(Duration pos) {
    state = state.copyWith(position: pos);
  }

  void _handleDurationChange(Duration? dur) {
    if (dur != null) {
      state = state.copyWith(duration: dur);
    }
  }

  // إيقاف تشغيل الصوت بالكامل وتصفير المؤشرات
  Future<void> stop() async {
    await _audioPlayer.stop();
    _loadedAudioUrl = null;
    state = state.copyWith(
      isPlaying: false,
      position: Duration.zero,
    );
  }
}
