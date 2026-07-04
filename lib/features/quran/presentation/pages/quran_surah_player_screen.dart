import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_sleep_timer_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_list_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class QuranSurahPlayerScreen extends ConsumerStatefulWidget {
  const QuranSurahPlayerScreen({super.key});

  static const String routePath = '/quran/surah-player';

  @override
  ConsumerState<QuranSurahPlayerScreen> createState() =>
      _QuranSurahPlayerScreenState();
}

class _QuranSurahPlayerScreenState extends ConsumerState<QuranSurahPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(quranSurahPlayerProvider);
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final downloadState = ref.watch(quranAudioDownloadProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preferencesAsync = ref.watch(appUserPreferencesProvider);
    final preferredReciterId = preferencesAsync.maybeWhen(
      data: (p) => p.preferredReciterId,
      orElse: () => null,
    );

    // Determine the active recitation.
    final activeRecitation = recitationsAsync.maybeWhen(
      data: (recitations) {
        if (recitations.isEmpty) return null;
        if (playerState.recitationId != null) {
          for (final r in recitations) {
            if (r.id == playerState.recitationId) return r;
          }
        }
        if (preferredReciterId != null) {
          for (final r in recitations) {
            if (r.id == preferredReciterId) return r;
          }
        }
        return recitations.first;
      },
      orElse: () => null,
    );

    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final bgGradient = isDark
        ? const [Color(0xFF1A1210), Color(0xFF241815), Color(0xFF1A1210)]
        : const [Color(0xFFF6F0E5), Color(0xFFFFFCF3), Color(0xFFF6F0E5)];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: bgGradient,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  // ── Top bar ──
                  _TopBar(isDark: isDark, accentColor: accentColor),

                  // ── Surah artwork area ──
                  Expanded(
                    flex: 4,
                    child: _SurahArtwork(
                      surahNumber: playerState.currentSurah,
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                  ),

                  // ── Reciter chooser ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _ReciterChooser(
                      recitationsAsync: recitationsAsync,
                      activeRecitation: activeRecitation,
                      isDark: isDark,
                      accentColor: accentColor,
                      onChanged: (recitation) {
                        ref
                                .read(selectedQuranRecitationProvider.notifier)
                                .state =
                            recitation;
                        ref
                            .read(appUserPreferencesProvider.notifier)
                            .setPreferredReciter(recitation);
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Download button (if not playing yet) ──
                  if (!playerState.isPlaying &&
                      !playerState.isLoading &&
                      activeRecitation != null &&
                      !downloadState.isActiveDownload)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _DownloadReciterButton(
                        recitation: activeRecitation,
                        downloadState: downloadState,
                        isDark: isDark,
                        accentColor: accentColor,
                        onDownload: () {
                          ref
                              .read(quranAudioDownloadProvider.notifier)
                              .downloadFullQuran(recitation: activeRecitation);
                        },
                      ),
                    ),

                  // ── Progress / seek bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _AyahSeekBar(
                      playerState: playerState,
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Control buttons ──
                  _PlayerControls(
                    playerState: playerState,
                    activeRecitation: activeRecitation,
                    isDark: isDark,
                    accentColor: accentColor,
                  ),

                  const SizedBox(height: 8),

                  // ── Repeat & Sleep ──
                  _RepeatAndSleepRow(
                    playerState: playerState,
                    isDark: isDark,
                    accentColor: accentColor,
                  ),

                  const SizedBox(height: 14),

                  // ── Surah chooser button ──
                  _SurahChooserButton(
                    playerState: playerState,
                    activeRecitation: activeRecitation,
                    isDark: isDark,
                    accentColor: accentColor,
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Top bar ────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isDark, required this.accentColor});

  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
            ),
          ),
          const Spacer(),
          Text(
            'مشغّل القرآن',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }
}

// ─── Surah artwork ──────────────────────────────────────────────

class _SurahArtwork extends StatelessWidget {
  const _SurahArtwork({
    required this.surahNumber,
    required this.isDark,
    required this.accentColor,
  });

  final int surahNumber;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Surah number badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF3A2A1A), const Color(0xFF2A1A0E)]
                    : [AppColors.maroon700, AppColors.maroon900],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _toArabicNum(surahNumber),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? const Color(0xFFD8B457)
                      : AppColors.parchmentLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Surah name
          Text(
            'سورة ${getSurahNameArabic(surahNumber)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            getSurahName(surahNumber),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: (isDark ? AppColors.parchmentMuted : AppColors.maroon700)
                  .withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_toArabicNum(getVerseCount(surahNumber))} آيات',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: accentColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reciter chooser ────────────────────────────────────────────

class _ReciterChooser extends StatelessWidget {
  const _ReciterChooser({
    required this.recitationsAsync,
    required this.activeRecitation,
    required this.isDark,
    required this.accentColor,
    required this.onChanged,
  });

  final AsyncValue<List<QuranRecitation>> recitationsAsync;
  final QuranRecitation? activeRecitation;
  final bool isDark;
  final Color accentColor;
  final ValueChanged<QuranRecitation> onChanged;

  @override
  Widget build(BuildContext context) {
    return recitationsAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Text(
        'تعذر تحميل قائمة القراء',
        style: TextStyle(
          color: accentColor.withValues(alpha: 0.7),
          fontSize: 14,
        ),
      ),
      data: (recitations) {
        if (recitations.isEmpty) {
          return const SizedBox.shrink();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.1 : 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withValues(alpha: 0.15)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: activeRecitation?.id,
                  isExpanded: true,
                  icon: Icon(
                    Icons.unfold_more_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                  dropdownColor: isDark
                      ? AppColors.darkSurfaceHigh
                      : AppColors.parchmentLight,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.parchmentLight
                        : AppColors.maroon800,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  items: [
                    for (final r in recitations)
                      DropdownMenuItem<int>(
                        value: r.id,
                        child: Text(
                          _recitationLabel(r),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (id) {
                    if (id == null) return;
                    final r = recitations.firstWhere((r) => r.id == id);
                    onChanged(r);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Download reciter button ────────────────────────────────────

class _DownloadReciterButton extends StatelessWidget {
  const _DownloadReciterButton({
    required this.recitation,
    required this.downloadState,
    required this.isDark,
    required this.accentColor,
    required this.onDownload,
  });

  final QuranRecitation recitation;
  final QuranAudioDownloadState downloadState;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onDownload,
          icon: const Icon(Icons.cloud_download_outlined, size: 18),
          label: Text(
            'تحميل صوت ${recitation.reciterName} كاملاً',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: accentColor,
            side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ─── Seek bar ───────────────────────────────────────────────────

class _AyahSeekBar extends ConsumerWidget {
  const _AyahSeekBar({
    required this.playerState,
    required this.isDark,
    required this.accentColor,
  });

  final SurahPlayerState playerState;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posMs = playerState.totalPosition.inMilliseconds.toDouble();
    final durMs = playerState.totalDuration.inMilliseconds.toDouble();
    final maxVal = durMs > 0 ? durMs : 1.0;
    final remaining = durMs > 0
        ? (playerState.totalDuration - playerState.totalPosition).isNegative
              ? Duration.zero
              : (playerState.totalDuration - playerState.totalPosition)
        : Duration.zero;

    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: 0.18),
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: posMs.clamp(0, maxVal),
              max: maxVal,
              onChanged: (val) {
                ref
                    .read(quranSurahPlayerProvider.notifier)
                    .seekTo(Duration(milliseconds: val.toInt()));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(playerState.totalPosition),
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '-${_formatDuration(remaining)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Player controls ────────────────────────────────────────────

class _PlayerControls extends ConsumerWidget {
  const _PlayerControls({
    required this.playerState,
    required this.activeRecitation,
    required this.isDark,
    required this.accentColor,
  });

  final SurahPlayerState playerState;
  final QuranRecitation? activeRecitation;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(quranSurahPlayerProvider.notifier);
    final iconColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          onPressed: () => controller.previousAyah(),
          icon: Icon(Icons.skip_previous_rounded, size: 36, color: iconColor),
        ),
        const SizedBox(width: 16),
        // Play / Pause
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
        const SizedBox(width: 16),
        // Next
        IconButton(
          onPressed: () => controller.nextAyah(),
          icon: Icon(Icons.skip_next_rounded, size: 36, color: iconColor),
        ),
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

// ─── Repeat & Sleep row ─────────────────────────────────────────

class _RepeatAndSleepRow extends ConsumerWidget {
  const _RepeatAndSleepRow({
    required this.playerState,
    required this.isDark,
    required this.accentColor,
  });

  final SurahPlayerState playerState;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(quranSurahPlayerProvider.notifier);
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Repeat button
          _FeatureChip(
            icon: _repeatIcon(playerState.repeatMode),
            label: _repeatLabel(playerState.repeatMode),
            isActive: playerState.repeatMode != SurahRepeatMode.off,
            accentColor: accentColor,
            mutedColor: mutedColor,
            onTap: () => controller.cycleRepeatMode(),
          ),
          // Sleep timer
          _FeatureChip(
            icon: Icons.bedtime_outlined,
            label: playerState.sleepTimerSettings.isActive
                ? _formatRemaining(
                    playerState.sleepTimerRemaining ?? Duration.zero,
                  )
                : 'مؤقت',
            isActive: playerState.sleepTimerSettings.isActive,
            accentColor: accentColor,
            mutedColor: mutedColor,
            onTap: () => _showSleepTimerSheet(context, ref),
          ),
        ],
      ),
    );
  }

  String _formatRemaining(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void _showSleepTimerSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuranSleepTimerSheet(),
    );
  }

  IconData _repeatIcon(SurahRepeatMode mode) => switch (mode) {
    SurahRepeatMode.off => Icons.repeat_rounded,
    SurahRepeatMode.ayah => Icons.repeat_one_rounded,
    SurahRepeatMode.surah => Icons.repeat_rounded,
  };

  String _repeatLabel(SurahRepeatMode mode) => switch (mode) {
    SurahRepeatMode.off => 'تكرار',
    SurahRepeatMode.ayah => 'تكرار الآية',
    SurahRepeatMode.surah => 'تكرار السورة',
  };
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.accentColor,
    required this.mutedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color accentColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? accentColor : mutedColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Surah chooser button ───────────────────────────────────────

class _SurahChooserButton extends ConsumerWidget {
  const _SurahChooserButton({
    required this.playerState,
    required this.activeRecitation,
    required this.isDark,
    required this.accentColor,
  });

  final SurahPlayerState playerState;
  final QuranRecitation? activeRecitation;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: () => _openSurahList(context, ref),
          icon: const Icon(Icons.queue_music_rounded),
          label: const Text(
            'اختيار سورة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: isDark
                ? AppColors.maroon900
                : AppColors.parchmentLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  void _openSurahList(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SurahListSheet(currentSurah: playerState.currentSurah),
    ).then((surahNumber) {
      if (surahNumber != null && activeRecitation != null) {
        ref
            .read(quranSurahPlayerProvider.notifier)
            .playSurah(
              surahNumber: surahNumber,
              recitationId: activeRecitation!.id,
            );
      }
    });
  }
}

// ─── Helpers ────────────────────────────────────────────────────

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String _recitationLabel(QuranRecitation recitation) {
  final translatedName = recitation.translatedName;
  if (translatedName != null && translatedName != recitation.reciterName) {
    return '$translatedName - ${recitation.reciterName}';
  }
  return recitation.reciterName;
}

String _toArabicNum(int number) {
  const digits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return number.toString().split('').map((d) => digits[d] ?? d).join();
}
