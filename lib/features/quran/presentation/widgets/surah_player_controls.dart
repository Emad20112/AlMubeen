import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_provider.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Player controls widget for Surah Player screen
/// Includes playback controls (forward/backward 10s, play/pause, repeat)
class SurahPlayerControls extends ConsumerWidget {
  const SurahPlayerControls({
    required this.playerState,
    required this.activeRecitation,
    required this.isDark,
    required this.accentColor,
    super.key,
  });

  final SurahPlayerState playerState;
  final QuranRecitation? activeRecitation;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(quranSurahPlayerProvider.notifier);
    final iconColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Column(
      children: [
        const SizedBox(height: 24),

        // ── Control buttons row ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rewind 10s button
              _SeekButton(
                icon: Icons.replay_rounded,
                label: '10',
                iconColor: iconColor,
                onTap: () => controller.seekBackward10(),
              ),

              // Play/Pause button (large circular)
              _PlayPauseButton(
                isPlaying: playerState.isPlaying,
                isLoading: playerState.isLoading,
                accentColor: accentColor,
                isDark: isDark,
                onTap: () {
                  if (playerState.recitationId != null) {
                    controller.togglePlayPause();
                  } else if (activeRecitation != null) {
                    controller.playSurah(
                      surahNumber: playerState.currentSurah,
                      recitationId: activeRecitation!.id,
                    );
                  }
                },
              ),

              // Forward 10s button
              _SeekButton(
                icon: Icons.forward_rounded,
                label: '10',
                iconColor: iconColor,
                onTap: () => controller.seekForward10(),
              ),

              // Repeat button
              _ControlIconButton(
                icon: _repeatIcon(playerState.repeatMode),
                label: 'تكرار',
                iconColor: playerState.repeatMode != SurahRepeatMode.off
                    ? accentColor
                    : iconColor,
                onTap: () => controller.cycleRepeatMode(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _repeatIcon(SurahRepeatMode mode) => switch (mode) {
    SurahRepeatMode.off => Icons.repeat_rounded,
    SurahRepeatMode.ayah => Icons.repeat_one_rounded,
    SurahRepeatMode.surah => Icons.repeat_rounded,
  };
}

// ─── Control button widgets ─────────────────────────────────────

class _ControlIconButton extends StatelessWidget {
  const _ControlIconButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 24, color: iconColor),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: iconColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SeekButton extends StatelessWidget {
  const _SeekButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: iconColor.withValues(alpha: 0.3),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final bool isPlaying;
  final bool isLoading;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFFD8B457), const Color(0xFFB8943A)]
                : [AppColors.maroon700, AppColors.maroon900],
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 38,
                color: Colors.white,
              ),
      ),
    );
  }
}

