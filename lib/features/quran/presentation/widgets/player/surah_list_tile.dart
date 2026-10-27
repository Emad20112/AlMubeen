import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_provider.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_buttons.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_header.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_state_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran/qcf_quran.dart';

class SurahListTile extends StatelessWidget {
  const SurahListTile({
    super.key,
    required this.surahNumber,
    required this.isActive,
    required this.isPlaying,
    required this.activeRecitation,
    required this.downloadState,
    required this.isDark,
    required this.accentColor,
    required this.onPlay,
    required this.onDownload,
    required this.onPauseDownload,
    required this.onResumeDownload,
    required this.onCancelDownload,
    required this.isDownloadingThis,
    required this.isPausedThis,
    required this.hasOtherActiveDownload,
  });

  final int surahNumber;
  final bool isActive;
  final bool isPlaying;
  final QuranRecitation? activeRecitation;
  final QuranAudioDownloadState downloadState;
  final bool isDark;
  final Color accentColor;
  final VoidCallback? onPlay;
  final VoidCallback? onDownload;
  final VoidCallback? onPauseDownload;
  final VoidCallback? onResumeDownload;
  final VoidCallback? onCancelDownload;
  final bool isDownloadingThis;
  final bool isPausedThis;
  final bool hasOtherActiveDownload;

  @override
  Widget build(BuildContext context) {
    final isFullyDownloaded =
        activeRecitation != null &&
        downloadState.isSurahFullyDownloaded(surahNumber);
    final showDownloadBar = isDownloadingThis || isPausedThis;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isActive
                ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08)
                : accentColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isActive
                  ? accentColor.withValues(alpha: 0.3)
                  : accentColor.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: onPlay,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.lg),
                  bottom: Radius.circular(AppRadii.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Number badge
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isActive
                              ? LinearGradient(
                                  colors: isDark
                                      ? ListeningPalette.goldGradient
                                      : [
                                          AppColors.maroon700,
                                          AppColors.maroon900,
                                        ],
                                )
                              : null,
                          color: isActive
                              ? null
                              : accentColor.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Text(
                            toArabicNum(surahNumber),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Names
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سورة ${getSurahNameArabic(surahNumber)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.parchmentLight
                                    : AppColors.maroon800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${getSurahName(surahNumber)}  •  ${toArabicNum(getVerseCount(surahNumber))} آيات',
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
                      // Download button
                      if (onDownload != null)
                        SurahDownloadButton(
                          isDownloading: isDownloadingThis,
                          isPaused: isPausedThis,
                          isFullyDownloaded: isFullyDownloaded,
                          hasOtherActiveDownload: hasOtherActiveDownload,
                          accentColor: accentColor,
                          isDark: isDark,
                          onPressed: isFullyDownloaded ? null : onDownload,
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      // Play button
                      SurahPlayButton(
                        isPlaying: isPlaying,
                        accentColor: accentColor,
                        isDark: isDark,
                        onPressed: onPlay,
                      ),
                    ],
                  ),
                ),
              ),
              if (showDownloadBar)
                SurahDownloadActionBar(
                  isDark: isDark,
                  accentColor: accentColor,
                  progress: downloadState.progress,
                  onPause: onPauseDownload,
                  onResume: onResumeDownload,
                  onCancel: onCancelDownload,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurahListView extends ConsumerWidget {
  const SurahListView({
    super.key,
    required this.currentSurah,
    required this.isPlaying,
    required this.activeRecitation,
    required this.downloadState,
    required this.isDark,
    required this.accentColor,
  });

  final int currentSurah;
  final bool isPlaying;
  final QuranRecitation? activeRecitation;
  final QuranAudioDownloadState downloadState;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: totalSurahCount,
      itemBuilder: (context, index) {
        final surahNumber = index + 1;
        final isMatchingReciter =
            activeRecitation != null &&
            downloadState.recitationId == activeRecitation!.id;
        final isDownloadingThis =
            isMatchingReciter &&
            downloadState.downloadingSurahNumber == surahNumber &&
            downloadState.isDownloading;
        final isPausedThis =
            isMatchingReciter &&
            downloadState.downloadingSurahNumber == surahNumber &&
            downloadState.isPaused;
        final hasOtherActiveDownload =
            downloadState.isActiveDownload &&
            !(isDownloadingThis || isPausedThis);

        return SurahListTile(
          surahNumber: surahNumber,
          isActive: currentSurah == surahNumber,
          isPlaying: isPlaying && currentSurah == surahNumber,
          activeRecitation: activeRecitation,
          downloadState: downloadState,
          isDark: isDark,
          accentColor: accentColor,
          onPlay: activeRecitation != null
              ? () => ref
                    .read(quranSurahPlayerProvider.notifier)
                    .playSurah(
                      surahNumber: surahNumber,
                      recitationId: activeRecitation!.id,
                    )
              : null,
          onDownload: activeRecitation != null
              ? () {
                  final controller = ref.read(
                    quranAudioDownloadProvider.notifier,
                  );
                  final state = ref.read(quranAudioDownloadProvider);
                  final recitation = activeRecitation!;
                  final isSameDownload =
                      state.recitationId == recitation.id &&
                      state.downloadingSurahNumber == surahNumber;

                  if (state.isPaused && isSameDownload) {
                    controller.resumeDownload();
                    return;
                  }

                  if (state.isActiveDownload) {
                    if (!isSameDownload) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يوجد تنزيل صوتي جارٍ بالفعل.'),
                        ),
                      );
                    }
                    return;
                  }

                  controller.downloadSurah(
                    surahNumber: surahNumber,
                    recitation: recitation,
                  );
                }
              : null,
          onPauseDownload: isDownloadingThis
              ? () => ref
                    .read(quranAudioDownloadProvider.notifier)
                    .pauseDownload()
              : null,
          onResumeDownload: isPausedThis
              ? () => ref
                    .read(quranAudioDownloadProvider.notifier)
                    .resumeDownload()
              : null,
          onCancelDownload: (isDownloadingThis || isPausedThis)
              ? () => ref
                    .read(quranAudioDownloadProvider.notifier)
                    .cancelDownload()
              : null,
          isDownloadingThis: isDownloadingThis,
          isPausedThis: isPausedThis,
          hasOtherActiveDownload: hasOtherActiveDownload,
        );
      },
    );
  }
}
