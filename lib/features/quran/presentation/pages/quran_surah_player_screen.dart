import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/network_error_banner.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_provider.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reciters_list_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';

// ==============================================================================
//  Quran Surah Listening Screen  ·  شاشة الاستماع
// ==============================================================================
//
//  Self-contained by design: state management, design tokens, pure logic and
//  every design component for this screen live in this one file, grouped into
//  the five sections below. Read the map before editing — the order is
//  intentional, not incidental.
//
//    §1  STATE MANAGEMENT   What each subtree subscribes to, and how wide.
//    §2  DESIGN TOKENS      Screen-local palette. Shared tokens are imported.
//    §3  LOGIC              Pure helpers only. No widgets, no side effects.
//    §4  DESIGN COMPONENTS  atoms → molecules → organisms.
//    §5  THE SCREEN         Composition root.
//
//  Invariants that must survive any edit here
//  ------------------------------------------
//  1. Every `ref.watch` on player state is narrowed with `.select` to a SINGLE
//     value object with a correct `==`. Selecting each field on its own is
//     worse than not selecting at all: it rebuilds on every field, and the
//     bookkeeping buys nothing.
//  2. The playback clock (`position`, `totalPosition`, `bufferedPosition`)
//     ticks every 350ms while playing. Only the player bar may subscribe to
//     it. The shell and the surah list must not — otherwise every tick
//     rebuilds the visible list for nothing.
//  3. A subtree that does not read player state must not receive
//     `SurahPlayerState` as a parameter. Narrow the parameter instead.
//  4. Playback and download state are owned by Riverpod controllers. This file
//     owns no timer and no audio handle. Local `setState` is for view state
//     only (e.g. whether the bar is expanded).
//  5. Storage is reached through providers only. No MMKV, no filesystem, no
//     SharedPreferences in this layer.
// ==============================================================================

// --------------------------------------------------------------------------
//  S1 - STATE MANAGEMENT
//  Playback state is a single object, but this screen needs three different
//  WIDTHS of it. Each width below is its own immutable view-state value with
//  `==` and `hashCode`, so `select` can collapse the updates that changed
//  nothing and skip the rebuild entirely.
// --------------------------------------------------------------------------

class _PlayerShell {
  const _PlayerShell({
    required this.recitationId,
    required this.currentSurah,
    required this.isPlaying,
    required this.isLoading,
    required this.hasError,
  });

  factory _PlayerShell.from(SurahPlayerState state) {
    return _PlayerShell(
      recitationId: state.recitationId,
      currentSurah: state.currentSurah,
      isPlaying: state.isPlaying,
      isLoading: state.isLoading,
      hasError: state.errorMessage != null,
    );
  }

  final int? recitationId;
  final int currentSurah;
  final bool isPlaying;
  final bool isLoading;
  final bool hasError;

  @override
  bool operator ==(Object other) {
    return other is _PlayerShell &&
        other.recitationId == recitationId &&
        other.currentSurah == currentSurah &&
        other.isPlaying == isPlaying &&
        other.isLoading == isLoading &&
        other.hasError == hasError;
  }

  @override
  int get hashCode {
    return Object.hash(
      recitationId,
      currentSurah,
      isPlaying,
      isLoading,
      hasError,
    );
  }
}

class _PlayerBarState {
  const _PlayerBarState({
    required this.recitationId,
    required this.currentSurah,
    required this.surahName,
    required this.isPlaying,
    required this.isLoading,
    required this.errorMessage,
    required this.canRetry,
    required this.position,
  });

  factory _PlayerBarState.from(SurahPlayerState s) {
    return _PlayerBarState(
      recitationId: s.recitationId,
      currentSurah: s.currentSurah,
      surahName: s.surahName,
      isPlaying: s.isPlaying,
      isLoading: s.isLoading,
      errorMessage: s.errorMessage,
      canRetry: s.canRetry,
      position: s.position,
    );
  }

  final int? recitationId;
  final int currentSurah;
  final String? surahName;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;
  final bool canRetry;
  final Duration position;

  @override
  bool operator ==(Object other) {
    return other is _PlayerBarState &&
        other.recitationId == recitationId &&
        other.currentSurah == currentSurah &&
        other.surahName == surahName &&
        other.isPlaying == isPlaying &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.canRetry == canRetry &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(
    recitationId,
    currentSurah,
    surahName,
    isPlaying,
    isLoading,
    errorMessage,
    canRetry,
    position,
  );
}

class _ExpandedControlsState {
  const _ExpandedControlsState({
    required this.recitationId,
    required this.currentSurah,
    required this.isPlaying,
    required this.isLoading,
    required this.errorMessage,
    required this.repeatMode,
    required this.duration,
    required this.position,
    required this.totalDuration,
    required this.totalPosition,
    required this.bufferedPosition,
  });

  factory _ExpandedControlsState.from(SurahPlayerState s) {
    return _ExpandedControlsState(
      recitationId: s.recitationId,
      currentSurah: s.currentSurah,
      isPlaying: s.isPlaying,
      isLoading: s.isLoading,
      errorMessage: s.errorMessage,
      repeatMode: s.repeatMode,
      duration: s.duration,
      position: s.position,
      totalDuration: s.totalDuration,
      totalPosition: s.totalPosition,
      bufferedPosition: s.bufferedPosition,
    );
  }

  final int? recitationId;
  final int currentSurah;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;
  final SurahRepeatMode repeatMode;
  final Duration duration;
  final Duration position;
  final Duration totalDuration;
  final Duration totalPosition;
  final Duration bufferedPosition;

  @override
  bool operator ==(Object other) {
    return other is _ExpandedControlsState &&
        other.recitationId == recitationId &&
        other.currentSurah == currentSurah &&
        other.isPlaying == isPlaying &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.repeatMode == repeatMode &&
        other.duration == duration &&
        other.position == position &&
        other.totalDuration == totalDuration &&
        other.totalPosition == totalPosition &&
        other.bufferedPosition == bufferedPosition;
  }

  @override
  int get hashCode => Object.hash(
    recitationId,
    currentSurah,
    isPlaying,
    isLoading,
    errorMessage,
    repeatMode,
    duration,
    position,
    totalDuration,
    totalPosition,
    bufferedPosition,
  );
}

// --------------------------------------------------------------------------
//  S2 - DESIGN TOKENS
//  Screen-local palette. Shared tokens are imported and reused as-is.
// --------------------------------------------------------------------------

/// Screen-local design tokens.
///
/// Everything shared is imported and reused untouched (`AppColors`,
/// `AppSpacing`, `AppRadii`, `AppMotion`). Only values that belong to *this*
/// screen are declared here, so changing them cannot ripple across the app --
/// today that is just the page gradient, which previously appeared as three
/// magic hex literals inline.
abstract final class _ListeningPalette {
  const _ListeningPalette._();

  /// Gold accent ramp for play buttons and the active surah tile.
  ///
  /// `goldDeep -> goldDeepEnd`, kept identical in both brightnesses because
  /// these controls sit on tinted surfaces in both themes. The shared
  /// `AppColorScheme.accentGradient` uses a different light-mode ramp, which
  /// would be a visual change rather than a cleanup.
  static const List<Color> goldGradient = <Color>[
    AppColors.goldDeep,
    AppColors.goldDeepEnd,
  ];

  /// Dark page gradient: deep warm ink, a slightly lifted centre, back again.
  static const List<Color> darkPageGradient = <Color>[
    Color(0xFF1A1210),
    Color(0xFF241815),
    Color(0xFF1A1210),
  ];

  /// Light page gradient: parchment wash with a brighter centre.
  static const List<Color> lightPageGradient = <Color>[
    Color(0xFFF6F0E5),
    Color(0xFFFFFCF3),
    Color(0xFFF6F0E5),
  ];

  /// Vertical page gradient for the given brightness.
  static LinearGradient pageGradientFor(Brightness brightness) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: brightness == Brightness.dark
          ? darkPageGradient
          : lightPageGradient,
    );
  }
}

// --------------------------------------------------------------------------
//  S3 - LOGIC
//  Pure functions only: no widgets, no provider reads, no side effects. The
//  easiest layer to unit test and the easiest to reuse inside this file.
// --------------------------------------------------------------------------

String _formatDuration(Duration d) {
  if (d.isNegative || d.inSeconds.isNaN) return '00:00';
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
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

// --------------------------------------------------------------------------
//  S4a - DESIGN COMPONENTS / ATOMS
//  Leaf controls. Each one is stateless, owns its own hit target and ripple, and
//  takes colours as parameters so it renders correctly on whatever surface it
//  lands on.
// --------------------------------------------------------------------------

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
          icon: Icon(icon, size: 22, color: iconColor),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: iconColor.withValues(alpha: 0.7),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 28, color: iconColor.withValues(alpha: 0.3)),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────

class _FloatingPlayPauseButton extends StatelessWidget {
  const _FloatingPlayPauseButton({
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: isDark
                  ? _ListeningPalette.goldGradient
                  : [AppColors.maroon700, AppColors.maroon900],
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 24,
                color: Colors.white,
              ),
      ),
    );
  }
}

// ─── Control button widgets ────────────────────────────────────

class _MiniDownloadIconButton extends StatelessWidget {
  const _MiniDownloadIconButton({
    required this.icon,
    required this.tooltip,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: accentColor),
        ),
      ),
    );
  }
}

// ─── Surah play button ────────────────────────────────────────

class _SurahPlayButton extends StatelessWidget {
  const _SurahPlayButton({
    required this.isPlaying,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  final bool isPlaying;
  final Color accentColor;
  final bool isDark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: isDark
                  ? _ListeningPalette.goldGradient
                  : [AppColors.maroon700, AppColors.maroon900],
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Floating player bar ──────────────────────────────────────

/// ما يحتاجه [_FloatingPlayerBar] بالضبط من حالة المشغّل.
///
/// الحقول الثمانية التالية هي كل ما يقرأه الشريط. استخراجها إلى قيمة
/// واحدة مساوية يجعل `select` فعّالًا: لو اخترنا الحقول على حدة ل|club
/// إعادة البناء عند تغيّر أي منها.
@immutable

class _SurahDownloadButton extends StatelessWidget {
  const _SurahDownloadButton({
    required this.isDownloading,
    required this.isPaused,
    required this.isFullyDownloaded,
    required this.hasOtherActiveDownload,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  final bool isDownloading;
  final bool isPaused;
  final bool isFullyDownloaded;
  final bool hasOtherActiveDownload;
  final Color accentColor;
  final bool isDark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = isFullyDownloaded
        ? Icons.download_done_rounded
        : isPaused
        ? Icons.play_arrow_rounded
        : isDownloading
        ? Icons.downloading_rounded
        : Icons.cloud_download_outlined;
    final iconColor = isFullyDownloaded
        ? accentColor.withValues(alpha: 0.5)
        : hasOtherActiveDownload
        ? accentColor.withValues(alpha: 0.35)
        : accentColor;

    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: hasOtherActiveDownload ? null : onPressed,
          customBorder: const CircleBorder(),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
//  S4b - DESIGN COMPONENTS / MOLECULES
//  Small compositions that combine atoms into one meaningful unit: a bar with a
//  title, a tile with badges, a dropdown with a label.
// --------------------------------------------------------------------------

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
            'استماع القرآن الكريم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ─── Reciter row: dropdown + download-all button ────────────────

class _ReciterRow extends StatelessWidget {
  const _ReciterRow({
    required this.recitationsAsync,
    required this.activeRecitation,
    required this.downloadState,
    required this.isDark,
    required this.accentColor,
    required this.onReciterChanged,
    required this.onDownloadAll,
  });

  final AsyncValue<List<QuranRecitation>> recitationsAsync;
  final QuranRecitation? activeRecitation;
  final QuranAudioDownloadState downloadState;
  final bool isDark;
  final Color accentColor;
  final ValueChanged<QuranRecitation> onReciterChanged;
  final VoidCallback? onDownloadAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Reciter dropdown
          Expanded(
            child: _ReciterDropdown(
              recitationsAsync: recitationsAsync,
              activeRecitation: activeRecitation,
              isDark: isDark,
              accentColor: accentColor,
              onChanged: onReciterChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Download all button
          _DownloadAllIconButton(
            downloadState: downloadState,
            isDark: isDark,
            accentColor: accentColor,
            onPressed: onDownloadAll,
          ),
        ],
      ),
    );
  }
}

// ─── Reciter selector chip ──────────────────────────────────────

class _ReciterDropdown extends StatelessWidget {
  const _ReciterDropdown({
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
        height: 44,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => Text(
        'تعذر تحميل قائمة القراء',
        style: TextStyle(
          color: accentColor.withValues(alpha: 0.7),
          fontSize: 13,
        ),
      ),
      data: (recitations) {
        if (recitations.isEmpty) return const SizedBox.shrink();

        final label = activeRecitation != null
            ? activeRecitation!.reciterName
            : 'اختر القارئ';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openPickerSheet(context),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Ink(
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.10 : 0.06),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: accentColor.withValues(alpha: 0.15)),
              ),
              child: SizedBox(
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        size: 16,
                        color: accentColor.withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.parchmentLight
                                : AppColors.maroon800,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.unfold_more_rounded,
                        color: accentColor,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openPickerSheet(BuildContext context) {
    // We need an AyahRef for the picker — use a placeholder (surah 1, ayah 1)
    // since this picker only changes the reciter preference, not playing a specific ayah.
    showReciterPickerForSurahPlayer(
      context: context,
      activeRecitation: activeRecitation,
      onChanged: onChanged,
    );
  }
}

// ─── Download-all icon button ──────────────────────────────────

class _DownloadAllIconButton extends StatelessWidget {
  const _DownloadAllIconButton({
    required this.downloadState,
    required this.isDark,
    required this.accentColor,
    required this.onPressed,
  });

  final QuranAudioDownloadState downloadState;
  final bool isDark;
  final Color accentColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isActive = downloadState.isActiveDownload;

    return Tooltip(
      message: 'المكتبة الصوتية',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: accentColor.withValues(alpha: isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: InkWell(
            onTap: isActive ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: isActive
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: downloadState.progress > 0
                          ? downloadState.progress
                          : null,
                      color: accentColor,
                    ),
                  )
                : Icon(
                    Icons.cloud_download_outlined,
                    color: accentColor,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Surah list view ──────────────────────────────────────────

class _SurahDownloadActionBar extends StatelessWidget {
  const _SurahDownloadActionBar({
    required this.isDark,
    required this.accentColor,
    required this.progress,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });

  final bool isDark;
  final Color accentColor;
  final double progress;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isDark ? 0.09 : 0.06),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: accentColor.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: LinearProgressIndicator(
                  value: clampedProgress > 0 ? clampedProgress : null,
                  minHeight: 4,
                  color: accentColor,
                  backgroundColor: accentColor.withValues(alpha: 0.14),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${(clampedProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 6),
            if (onPause != null)
              _MiniDownloadIconButton(
                icon: Icons.pause_rounded,
                tooltip: 'إيقاف مؤقت',
                accentColor: accentColor,
                onTap: onPause!,
              ),
            if (onResume != null)
              _MiniDownloadIconButton(
                icon: Icons.play_arrow_rounded,
                tooltip: 'استئناف',
                accentColor: accentColor,
                onTap: onResume!,
              ),
            if (onCancel != null)
              _MiniDownloadIconButton(
                icon: Icons.close_rounded,
                tooltip: 'إلغاء',
                accentColor: accentColor,
                onTap: onCancel!,
              ),
          ],
        ),
      ),
    );
  }
}

class _SurahListTile extends StatelessWidget {
  const _SurahListTile({
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
                                      ? _ListeningPalette.goldGradient
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
                            _toArabicNum(surahNumber),
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
                              '${getSurahName(surahNumber)}  •  ${_toArabicNum(getVerseCount(surahNumber))} آيات',
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
                        _SurahDownloadButton(
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
                      _SurahPlayButton(
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
                _SurahDownloadActionBar(
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

// ─── Surah download button ────────────────────────────────────

// --------------------------------------------------------------------------
//  S4c - DESIGN COMPONENTS / ORGANISMS
//  The three subtrees that own player state. This is where `select` earns its
//  keep -- see invariant 2 in the file header.
// --------------------------------------------------------------------------

class _SurahListView extends ConsumerWidget {
  const _SurahListView({
    required this.currentSurah,
    required this.isPlaying,
    required this.activeRecitation,
    required this.downloadState,
    required this.isDark,
    required this.accentColor,
  });

  /// 🛡️ PERF: كان يستقبل `SurahPlayerState` كاملةً من أجل حقلين فقط
  /// (`currentSurah`, `isPlaying`) — ولا حاجة له已于 `position` الذي
  /// يتغيّر كل 350ms. استبدال حالة كاملة بحقلين يمنع إعادة بناء القائمة
  /// مع كل نبضة تقدّم.
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

          return _SurahListTile(
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

// ─── Surah list tile ──────────────────────────────────────────

class _FloatingPlayerBar extends ConsumerWidget {
  const _FloatingPlayerBar({
    required this.activeRecitation,
    required this.isDark,
    required this.accentColor,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onClose,
  });

  /// 🛡️ PERF: يراقب ما يحتاجه من حالة المشغّل **بنفسه** عبر `.select`
  /// ([_PlayerBarState]) بدل استقبالها كاملةً من الأعلى. هكذا تبقى نبضة
  /// التقدّم — التي تنبض كل 350ms — محصورة في إعادة بناء هذا الشريط وحده،
  /// بدل إعادة بناء الشاشة كاملة والقائمة المرئية معها.
  final QuranRecitation? activeRecitation;
  final bool isDark;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(
      quranSurahPlayerProvider.select(_PlayerBarState.from),
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
                                : _formatDuration(playerState.position),
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
                  _FloatingPlayPauseButton(
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
            secondChild: _ExpandedControls(
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

// ─── Expanded player controls ─────────────────────────────────

// ─── Expanded player controls (Protected against NaN & Infinite values) ────

/// ما يحتاجه [_ExpandedControls] من حالة المشغّل — نفس منطق
/// [_PlayerBarState]: قيمة واحدة مساوية تجعل `select` فعّالًا، وتشمل حقول
/// التقدّم المتغيّرة (`position`, `totalPosition`, `bufferedPosition`) لأن
/// لوحة التحكم هي ما يعرضها.
@immutable

class _ExpandedControls extends ConsumerWidget {
  const _ExpandedControls({
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
      quranSurahPlayerProvider.select(_ExpandedControlsState.from),
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
                  _formatDuration(playerState.position),
                  style: TextStyle(
                    fontSize: 11,
                    color: iconColor.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  _formatDuration(playerState.duration),
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
              _ControlIconButton(
                icon: _repeatIcon(playerState.repeatMode),
                label: 'تكرار',
                iconColor: playerState.repeatMode != SurahRepeatMode.off
                    ? accentColor
                    : iconColor,
                onTap: () => controller.cycleRepeatMode(),
              ),
              _SeekButton(
                icon: Icons.replay_rounded,
                label: '10',
                iconColor: iconColor,
                onTap: () => controller.seekBackward10(),
              ),
              // Play/Pause with Retry support
              _FloatingPlayPauseButton(
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
              _SeekButton(
                icon: Icons.forward_rounded,
                label: '10',
                iconColor: iconColor,
                onTap: () => controller.seekForward10(),
              ),
              _ControlIconButton(
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

// ─── Floating play/pause button ───────────────────────────────

// --------------------------------------------------------------------------
//  S5 - THE SCREEN
//  The composition root: reads the shared shell state, derives the active
//  recitation, and lays out top bar, reciter row, surah list and player bar. It
//  holds no playback state of its own.
// --------------------------------------------------------------------------

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
  bool _isPlayerExpanded = false;

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
    // 🛡️ PERF: حقل محدود — انظر `_PlayerShell`. هذا يمنع إعادة بناء
    // القائمة كاملة مع كل نبضة تقدّم (350ms).
    final playerShell = ref.watch(
      quranSurahPlayerProvider.select(_PlayerShell.from),
    );
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final downloadState = ref.watch(quranAudioDownloadProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final preferredReciterId = ref.watch(
      appUserPreferencesProvider.select(
        (p) => p.maybeWhen(
          data: (value) => value.preferredReciterId,
          orElse: () => null,
        ),
      ),
    );

    // Restore download progress from disk whenever the reciter list is ready
    // or the preferred reciter changes (covers app restart + reciter switch).
    ref.listen(quranRecitationsProvider, (previous, next) {
      next.maybeWhen(
        data: (recitations) {
          if (recitations.isEmpty) return;
          final reciterId =
              playerShell.recitationId ??
              preferredReciterId ??
              recitations.first.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref
                  .read(quranAudioDownloadProvider.notifier)
                  .refreshDownloadedSurahs(reciterId: reciterId);
            }
          });
        },
        orElse: () {},
      );
    });

    final activeRecitation = recitationsAsync.maybeWhen(
      data: (recitations) {
        if (recitations.isEmpty) return null;
          if (playerShell.recitationId != null) {
            for (final r in recitations) {
              if (r.id == playerShell.recitationId) return r;
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

    // 🎨 DESIGN TOKENS — resolved once here and threaded down as plain
    // parameters, so the leaf components stay dumb and testable.
    final accentColor = isDark ? AppColors.goldDeep : AppColors.maroon800;
    final bgGradient = _ListeningPalette.pageGradientFor(brightness);

    final showPlayerBar =
        playerShell.isPlaying ||
        playerShell.isLoading ||
        playerShell.hasError ||
        playerShell.currentSurah != 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  // ── Top bar ──
                  _TopBar(isDark: isDark, accentColor: accentColor),

                  // ── Reciter row: dropdown + audio library button ──
                  _ReciterRow(
                    recitationsAsync: recitationsAsync,
                    activeRecitation: activeRecitation,
                    downloadState: downloadState,
                    isDark: isDark,
                    accentColor: accentColor,
                    onReciterChanged: (recitation) {
                      ref.read(selectedQuranRecitationProvider.notifier).state =
                          recitation;
                      ref
                          .read(appUserPreferencesProvider.notifier)
                          .setPreferredReciter(recitation);
                      // فحص الملفات المحلية للقارئ الجديد (islamic.app أو quran.com)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ref
                              .read(quranAudioDownloadProvider.notifier)
                              .refreshDownloadedSurahs(
                                reciterId: recitation.id,
                              );
                        }
                      });
                    },
                    onDownloadAll: activeRecitation != null
                        ? () => context.push(QuranAudioDownloadScreen.routePath)
                        : null,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // ── Surah list ──
                  Expanded(
                    child: _SurahListView(
                      currentSurah: playerShell.currentSurah,
                      isPlaying: playerShell.isPlaying,
                      activeRecitation: activeRecitation,
                      downloadState: downloadState,
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                  ),

                  // ── Floating player bar ──
                  if (showPlayerBar)
                    _FloatingPlayerBar(
                      activeRecitation: activeRecitation,
                      isDark: isDark,
                      accentColor: accentColor,
                      isExpanded: _isPlayerExpanded,
                      onExpandToggle: () => setState(
                        () => _isPlayerExpanded = !_isPlayerExpanded,
                      ),
                      onClose: () {
                        ref.read(quranSurahPlayerProvider.notifier).stop();
                        setState(() => _isPlayerExpanded = false);
                      },
                    ),
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

