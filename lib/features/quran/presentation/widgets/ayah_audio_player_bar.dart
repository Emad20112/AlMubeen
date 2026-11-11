import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/core/widgets/network_error_banner.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reciters_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran/qcf_quran.dart';

class AyahAudioErrorBanner extends ConsumerWidget {
  const AyahAudioErrorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(
      quranAudioControllerProvider.select(
        (state) => (
          currentAyah: state.currentAyah,
          recitationId: state.recitationId,
          errorMessage: state.errorMessage,
        ),
      ),
    );

    if (audioState.currentAyah == null || audioState.errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: NetworkErrorBanner(
        compact: true,
        message: audioState.errorMessage,
        onRetry: () {
          if (audioState.recitationId != null) {
            ref
                .read(quranAudioControllerProvider.notifier)
                .playOrToggleAyah(
                  ayahRef: audioState.currentAyah!,
                  recitationId: audioState.recitationId!,
                );
          }
        },
      ),
    );
  }
}

class AyahRightAudioControls extends ConsumerWidget {
  const AyahRightAudioControls({required this.currentPage, super.key});

  final int currentPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(
      quranAudioControllerProvider.select(
        (state) =>
            (currentAyah: state.currentAyah, recitationId: state.recitationId),
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final firstAyahOnPage = getFirstAyahOnPage(currentPage);
    final hasActiveAyah = audioState.currentAyah != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactIconButton(
          icon: Icons.play_arrow_rounded,
          tooltip: hasActiveAyah
              ? 'أوقف التلاوة الحالية أولاً'
              : 'تشغيل من بداية الصفحة',
          primaryColor: primaryColor,
          onTap: hasActiveAyah
              ? null
              : () {
                  unawaited(_playFromPageStart(context, ref, firstAyahOnPage));
                },
        ),
        const SizedBox(width: 2),
        _CompactIconButton(
          icon: Icons.stop_rounded,
          tooltip: 'إيقاف',
          primaryColor: primaryColor,
          onTap: hasActiveAyah
              ? () {
                  ref.read(quranAudioControllerProvider.notifier).stop();
                }
              : null,
        ),
        const SizedBox(width: 2),
        _CompactIconButton(
          icon: Icons.forward_10_rounded,
          tooltip: 'تقديم',
          primaryColor: primaryColor,
          onTap: hasActiveAyah
              ? () {
                  ref
                      .read(quranAudioControllerProvider.notifier)
                      .seekForward(seconds: 10);
                }
              : null,
        ),
      ],
    );
  }
}

class AyahLeftAudioControls extends ConsumerWidget {
  const AyahLeftAudioControls({required this.currentPage, super.key});

  final int currentPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(
      quranAudioControllerProvider.select(
        (state) =>
            (currentAyah: state.currentAyah, recitationId: state.recitationId),
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final pickerAyah =
        audioState.currentAyah ?? getFirstAyahOnPage(currentPage);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactIconButton(
          icon: Icons.replay_10_rounded,
          tooltip: 'تأخير',
          primaryColor: primaryColor,
          onTap: audioState.currentAyah != null
              ? () {
                  ref
                      .read(quranAudioControllerProvider.notifier)
                      .seekBackward(seconds: 10);
                }
              : null,
        ),
        const SizedBox(width: 2),
        _CompactIconButton(
          icon: Icons.headphones_rounded,
          tooltip: 'القارئ',
          primaryColor: primaryColor,
          onTap: () => _showListeningOptionsSheet(
            context,
            currentAyah: pickerAyah,
            recitationId: audioState.recitationId,
          ),
        ),
      ],
    );
  }

  static Future<void> _showListeningOptionsSheet(
    BuildContext context, {
    required AyahRef currentAyah,
    required int? recitationId,
  }) {
    return showReciterPickerSheet(
      context: context,
      currentAyah: currentAyah,
      currentRecitationId: recitationId,
      playOnSelect: false,
    );
  }
}

class _CompactLoadingPlayButton extends StatefulWidget {
  const _CompactLoadingPlayButton({
    required this.primaryColor,
    required this.isLoading,
  });

  final Color primaryColor;
  final bool isLoading;

  @override
  State<_CompactLoadingPlayButton> createState() =>
      _CompactLoadingPlayButtonState();
}

class _CompactLoadingPlayButtonState extends State<_CompactLoadingPlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void didUpdateWidget(_CompactLoadingPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'جاري تحميل التلاوة',
      child: SizedBox(
        width: 26,
        height: 26,
        child: Center(
          child: RotationTransition(
            turns: _controller,
            child: Icon(
              Icons.play_arrow_rounded,
              color: widget.primaryColor,
              size: 17,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({
    required this.icon,
    required this.tooltip,
    required this.primaryColor,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color primaryColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = onTap == null
        ? primaryColor.withValues(alpha: 0.35)
        : primaryColor;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(icon, color: effectiveColor, size: 17),
          ),
        ),
      ),
    );
  }
}

Future<void> _playFromPageStart(
  BuildContext context,
  WidgetRef ref,
  AyahRef firstAyahOnPage,
) async {
  final recitationId = await _resolveActiveRecitationId(ref);
  if (recitationId == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر تحميل قائمة القراء.')));
    }
    return;
  }

  await ref
      .read(quranAudioControllerProvider.notifier)
      .playAyahFromBeginning(
        ayahRef: firstAyahOnPage,
        recitationId: recitationId,
      );
}

Future<int?> _resolveActiveRecitationId(WidgetRef ref) async {
  final selectedRecitation = ref.read(selectedQuranRecitationProvider);
  if (selectedRecitation != null && selectedRecitation.hasAyahAudio) {
    return selectedRecitation.id;
  }

  final preferredReciterId = ref
      .read(appUserPreferencesProvider)
      .maybeWhen(data: (value) => value.preferredReciterId, orElse: () => null);
  if (preferredReciterId != null) {
    final preferredSupportsAyah = ref
        .read(quranRecitationsProvider)
        .maybeWhen(
          data: (recitations) {
            for (final recitation in recitations) {
              if (recitation.id == preferredReciterId) {
                return recitation.hasAyahAudio;
              }
            }
            return false;
          },
          orElse: () => true,
        );
    if (preferredSupportsAyah) {
      return preferredReciterId;
    }
  }

  try {
    final recitations = await ref.read(quranRecitationsProvider.future);
    return _firstAyahRecitation(recitations)?.id;
  } on Object {
    return null;
  }
}

QuranRecitation? _firstAyahRecitation(List<QuranRecitation> recitations) {
  for (final recitation in recitations) {
    if (recitation.hasAyahAudio) return recitation;
  }
  return null;
}

/// شريط تحكم ذكي ومتكامل بتلاوة السورة والآيات
class SmartQuranPlayerBar extends ConsumerStatefulWidget {
  const SmartQuranPlayerBar({super.key});

  @override
  ConsumerState<SmartQuranPlayerBar> createState() =>
      _SmartQuranPlayerBarState();
}

class _SmartQuranPlayerBarState extends ConsumerState<SmartQuranPlayerBar> {
  double? _dragValue;

  String _formatDuration(Duration d) {
    if (d.isNegative || d == Duration.zero) return '00:00';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentAyah = ref.watch(
      quranAudioControllerProvider.select((s) => s.currentAyah),
    );
    if (currentAyah == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = ref.watch(
      quranAudioControllerProvider.select((s) => s.isPlaying),
    );
    final isLoading = ref.watch(
      quranAudioControllerProvider.select((s) => s.isLoading),
    );
    final position = ref.watch(
      quranAudioControllerProvider.select((s) => s.position),
    );
    final duration = ref.watch(
      quranAudioControllerProvider.select((s) => s.duration),
    );
    final recitationId = ref.watch(
      quranAudioControllerProvider.select((s) => s.recitationId),
    );
    final mode = ref.watch(
      quranAudioControllerProvider.select((s) => s.playbackMode),
    );

    final reciters =
        ref.watch(quranRecitationsProvider).asData?.value ?? const [];
    final activeReciter =
        reciters.where((r) => r.id == recitationId).firstOrNull;
    final reciterName = activeReciter?.reciterName ?? 'القارئ';
    final surahName = getSurahNameArabic(currentAyah.surah);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final backgroundColor = isDark
        ? const Color(0xFF1E1916).withValues(alpha: 0.92)
        : const Color(0xFFF9F5EC).withValues(alpha: 0.95);
    final borderColor = primaryColor.withValues(alpha: isDark ? 0.22 : 0.15);

    final maxMs = duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;
    final currentPosMs = position.inMilliseconds.toDouble().clamp(0.0, maxMs);
    final effectiveSliderVal =
        (_dragValue ?? currentPosMs).clamp(0.0, maxMs);

    final remaining =
        (duration > position) ? (duration - position) : Duration.zero;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // رأس الشريط: اسم السورة والآية + اسم القارئ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        mode == AudioPlaybackMode.chapter
                            ? Icons.album_rounded
                            : Icons.audiotrack_rounded,
                        size: 16,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'سورة $surahName (الآية ${currentAyah.ayah})',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    reciterName,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // شريط التقدم الزمني الحقيقي مع المدة المنقضية والمتبقية
              Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 10,
                        ),
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: primaryColor.withValues(
                          alpha: 0.2,
                        ),
                        thumbColor: primaryColor,
                      ),
                      child: Slider(
                        value: effectiveSliderVal,
                        min: 0.0,
                        max: maxMs,
                        onChangeStart: (val) {
                          setState(() => _dragValue = val);
                        },
                        onChanged: (val) {
                          setState(() => _dragValue = val);
                        },
                        onChangeEnd: (val) {
                          setState(() => _dragValue = null);
                          ref
                              .read(quranAudioControllerProvider.notifier)
                              .seekTo(Duration(milliseconds: val.toInt()));
                        },
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(remaining),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),

              // أزرار التحكم بالتشغيل
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.replay_10_rounded, color: primaryColor),
                    tooltip: 'تأخير 10 ثوانٍ',
                    onPressed: () {
                      ref
                          .read(quranAudioControllerProvider.notifier)
                          .seekBackward(seconds: 10);
                    },
                  ),
                  isLoading
                      ? SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        )
                      : IconButton(
                          iconSize: 32,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: primaryColor,
                          ),
                          tooltip: isPlaying ? 'إيقاف مؤقت' : 'استئناف',
                          onPressed: () {
                            if (recitationId != null) {
                              ref
                                  .read(quranAudioControllerProvider.notifier)
                                  .playOrToggleAyah(
                                    ayahRef: currentAyah,
                                    recitationId: recitationId,
                                  );
                            }
                          },
                        ),
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.forward_10_rounded, color: primaryColor),
                    tooltip: 'تقديم 10 ثوانٍ',
                    onPressed: () {
                      ref
                          .read(quranAudioControllerProvider.notifier)
                          .seekForward(seconds: 10);
                    },
                  ),
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.stop_circle_outlined, color: primaryColor),
                    tooltip: 'إيقاف التلاوة',
                    onPressed: () {
                      ref.read(quranAudioControllerProvider.notifier).stop();
                    },
                  ),
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.headphones_rounded, color: primaryColor),
                    tooltip: 'تغيير القارئ',
                    onPressed: () {
                      showReciterPickerSheet(
                        context: context,
                        currentAyah: currentAyah,
                        currentRecitationId: recitationId,
                        playOnSelect: true,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// _RecitersBottomSheet removed — now handled by showReciterPickerSheet() in quran_reciters_list_view.dart
