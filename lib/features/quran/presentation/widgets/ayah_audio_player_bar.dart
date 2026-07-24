import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/network_error_banner.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
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
            ref.read(quranAudioControllerProvider.notifier).playOrToggleAyah(
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
  const AyahRightAudioControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAudio = ref.watch(
      quranAudioControllerProvider.select(
        (state) => state.currentAyah != null,
      ),
    );

    if (!hasAudio) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactIconButton(
          icon: Icons.stop_rounded,
          tooltip: 'إيقاف',
          primaryColor: primaryColor,
          onTap: () {
            ref.read(quranAudioControllerProvider.notifier).stop();
          },
        ),
        const SizedBox(width: 2),
        _CompactIconButton(
          icon: Icons.forward_10_rounded,
          tooltip: 'تقديم',
          primaryColor: primaryColor,
          onTap: () {
            ref
                .read(quranAudioControllerProvider.notifier)
                .seekForward(seconds: 10);
          },
        ),
      ],
    );
  }
}

class AyahLeftAudioControls extends ConsumerWidget {
  const AyahLeftAudioControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(
      quranAudioControllerProvider.select(
        (state) => (
          currentAyah: state.currentAyah,
          recitationId: state.recitationId,
        ),
      ),
    );

    if (audioState.currentAyah == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactIconButton(
          icon: Icons.replay_10_rounded,
          tooltip: 'تأخير',
          primaryColor: primaryColor,
          onTap: () {
            ref
                .read(quranAudioControllerProvider.notifier)
                .seekBackward(seconds: 10);
          },
        ),
        const SizedBox(width: 2),
        _CompactIconButton(
          icon: Icons.headphones_rounded,
          tooltip: 'القارئ',
          primaryColor: primaryColor,
          onTap: () => _showListeningOptionsSheet(
            context,
            currentAyah: audioState.currentAyah!,
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
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecitersBottomSheet(
        currentAyah: currentAyah,
        recitationId: recitationId,
      ),
    );
  }
}

class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({
    required this.icon,
    required this.tooltip,
    required this.primaryColor,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, color: primaryColor, size: 17),
          ),
        ),
      ),
    );
  }
}

class _RecitersBottomSheet extends StatelessWidget {
  const _RecitersBottomSheet({
    required this.currentAyah,
    required this.recitationId,
  });

  final AyahRef currentAyah;
  final int? recitationId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.58,
          minChildSize: 0.38,
          maxChildSize: 0.86,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.maroon800.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.maroon800.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.headphones_rounded,
                          color: AppColors.maroon800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'اختر القارئ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'اختر القارئ المفضل لديك.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  QuranRecitersListView(
                    currentAyah: currentAyah,
                    recitationId: recitationId,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
