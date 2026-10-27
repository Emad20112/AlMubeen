import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/widgets/network_error_banner.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_provider.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/expanded_controls.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_buttons.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_state_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloatingPlayerBar extends ConsumerWidget {
  const FloatingPlayerBar({
    super.key,
    required this.activeRecitation,
    required this.isDark,
    required this.accentColor,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onClose,
  });

  final QuranRecitation? activeRecitation;
  final bool isDark;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(
      quranSurahPlayerProvider.select(PlayerBarState.from),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceHigh : AppColors.parchmentLight,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Collapsed row: surah name + controls + close
          InkWell(
            onTap: onExpandToggle,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Surah info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سورة ${playerState.surahName}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.parchmentLight
                                : AppColors.maroon800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (playerState.errorMessage != null)
                          Text(
                            playerState.errorMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        else
                          Text(
                            playerState.isLoading
                                ? 'جاري التحميل...'
                                : formatDuration(playerState.position),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  (isDark
                                          ? AppColors.parchmentMuted
                                          : AppColors.maroon700)
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Play/Pause
                  FloatingPlayPauseButton(
                    isPlaying: playerState.isPlaying,
                    isLoading: playerState.isLoading,
                    accentColor: accentColor,
                    isDark: isDark,
                    onTap: () {
                      final controller = ref.read(
                        quranSurahPlayerProvider.notifier,
                      );
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
                  const SizedBox(width: AppSpacing.xs),
                  // Close
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: accentColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error banner (shown when there's an error)
          if (playerState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: NetworkErrorBanner(
                compact: true,
                message: playerState.errorMessage,
                onRetry: playerState.canRetry
                    ? () {
                        final controller = ref.read(
                          quranSurahPlayerProvider.notifier,
                        );
                        controller.retry();
                      }
                    : null,
              ),
            ),

          // Expanded controls
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: ExpandedControls(
              activeRecitation: activeRecitation,
              isDark: isDark,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
