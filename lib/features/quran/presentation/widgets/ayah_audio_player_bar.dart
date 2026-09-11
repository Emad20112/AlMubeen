import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
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

// _RecitersBottomSheet removed — now handled by showReciterPickerSheet() in quran_reciters_list_view.dart
