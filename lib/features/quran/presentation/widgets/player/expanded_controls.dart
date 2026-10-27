import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_provider.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_buttons.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_state_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpandedControls extends ConsumerWidget {
  const ExpandedControls({
    super.key,
    required this.activeRecitation,
    required this.isDark,
    required this.accentColor,
  });

  final QuranRecitation? activeRecitation;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🛡️ PERF: يراقب ما يحتاجه بنفسه — لا يستقبل الحالة كاملة من الأعلى.
    final playerState = ref.watch(
      quranSurahPlayerProvider.select(ExpandedControlsState.from),
    );
    final controller = ref.read(quranSurahPlayerProvider.notifier);
    final iconColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    // ── حماية الأرقام ضد الـ NaN والـ Infinity التي قد تنتج عند انقطاع الشبكة ──
    final rawTotal = playerState.totalDuration.inSeconds.toDouble();
    final rawCurrent = playerState.totalPosition.inSeconds.toDouble();
    final rawBuffered = playerState.bufferedPosition.inSeconds.toDouble();

    final total = (rawTotal > 0 && rawTotal.isFinite && !rawTotal.isNaN)
        ? rawTotal
        : 1.0;
    final buffered = (rawBuffered.isFinite && !rawBuffered.isNaN)
        ? rawBuffered.clamp(0.0, total)
        : 0.0;
    final current = (rawCurrent.isFinite && !rawCurrent.isNaN)
        ? rawCurrent.clamp(0.0, total)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Slider with buffered track
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: 0.15),
              thumbColor: accentColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              trackHeight: 3,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: accentColor.withValues(alpha: 0.35),
                inactiveTrackColor: Colors.transparent,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                trackHeight: 3,
                overlayColor: Colors.transparent,
              ),
              child: Slider(value: buffered, max: total, onChanged: null),
            ),
          ),
          // Actual slider (interactive) overlaid
          Transform.translate(
            offset: const Offset(0, -16),
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: accentColor,
                inactiveTrackColor: Colors.transparent,
                thumbColor: accentColor,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                trackHeight: 3,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: current,
                max: total,
                onChanged: (v) =>
                    controller.seekTo(Duration(seconds: v.toInt())),
              ),
            ),
          ),
          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(playerState.position),
                  style: TextStyle(
                    fontSize: 11,
                    color: iconColor.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  formatDuration(playerState.duration),
                  style: TextStyle(
                    fontSize: 11,
                    color: iconColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ControlIconButton(
                icon: _repeatIcon(playerState.repeatMode),
                label: 'تكرار',
                iconColor: playerState.repeatMode != SurahRepeatMode.off
                    ? accentColor
                    : iconColor,
                onTap: () => controller.cycleRepeatMode(),
              ),
              SeekButton(
                icon: Icons.replay_rounded,
                label: '10',
                iconColor: iconColor,
                onTap: () => controller.seekBackward10(),
              ),
              // Play/Pause with Retry support
              FloatingPlayPauseButton(
                isPlaying: playerState.isPlaying,
                isLoading: playerState.isLoading,
                accentColor: accentColor,
                isDark: isDark,
                onTap: () {
                  final controller = ref.read(
                    quranSurahPlayerProvider.notifier,
                  );
                  // إذا كان هناك خطأ في الشبكة، اضغط على زر البلاي ليعمل كـ "إعادة محاولة"
                  if (playerState.errorMessage != null &&
                      activeRecitation != null) {
                    controller.playSurah(
                      surahNumber: playerState.currentSurah,
                      recitationId: activeRecitation!.id,
                    );
                  } else if (playerState.recitationId != null &&
                      playerState.errorMessage == null) {
                    controller.togglePlayPause();
                  } else if (activeRecitation != null) {
                    controller.playSurah(
                      surahNumber: playerState.currentSurah,
                      recitationId: activeRecitation!.id,
                    );
                  }
                },
              ),
              SeekButton(
                icon: Icons.forward_rounded,
                label: '10',
                iconColor: iconColor,
                onTap: () => controller.seekForward10(),
              ),
              ControlIconButton(
                icon: Icons.skip_next_rounded,
                label: 'التالية',
                iconColor: iconColor,
                onTap: () => controller.seekForward10(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _repeatIcon(SurahRepeatMode mode) => switch (mode) {
    SurahRepeatMode.off => Icons.repeat_rounded,
    SurahRepeatMode.ayah => Icons.repeat_one_rounded,
    SurahRepeatMode.surah => Icons.repeat_rounded,
  };
}
