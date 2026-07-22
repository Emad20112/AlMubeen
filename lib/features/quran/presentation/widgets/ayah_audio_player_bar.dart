import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/network_error_banner.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
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
      builder: (_) => _ListeningOptionsSheet(
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

class _ListeningOptionsSheet extends ConsumerWidget {
  const _ListeningOptionsSheet({
    required this.currentAyah,
    required this.recitationId,
  });

  final AyahRef currentAyah;
  final int? recitationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final preferencesAsync = ref.watch(appUserPreferencesProvider);

    final preferredReciterId = preferencesAsync.maybeWhen(
      data: (preferences) => preferences.preferredReciterId,
      orElse: () => null,
    );
    final easyListeningMode = preferencesAsync.maybeWhen(
      data: (preferences) => preferences.easyListeningMode,
      orElse: () => true,
    );

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
                              'خيارات الاستماع',
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
                              'اختر القارئ وفعّل وضع الاستماع السهل.',
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
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'وضع الاستماع السهل',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    subtitle: Text(
                      'يحافظ على إبقاء التشغيل مريحًا وبسيطًا.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: mutedColor),
                    ),
                    value: easyListeningMode,
                    onChanged: (value) {
                      ref
                          .read(appUserPreferencesProvider.notifier)
                          .setEasyListeningMode(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'القراء',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ref.watch(quranRecitationsProvider).when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                            ),
                          ),
                        ),
                        error: (error, stackTrace) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'تعذر تحميل قائمة القراء.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: mutedColor),
                          ),
                        ),
                        data: (recitations) {
                          if (recitations.isEmpty) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'لا توجد قراءات متاحة الآن.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: mutedColor),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              for (final recitation in recitations) ...[
                                _ListeningRecitationTile(
                                  recitation: recitation,
                                  isSelected: recitationId == recitation.id ||
                                      (recitationId == null &&
                                          preferredReciterId ==
                                              recitation.id),
                                  onTap: () async {
                                    ref
                                            .read(
                                              selectedQuranRecitationProvider
                                                  .notifier,
                                            )
                                            .state = recitation;
                                    await ref
                                        .read(
                                          appUserPreferencesProvider.notifier,
                                        )
                                        .setPreferredReciter(recitation);

                                    await ref
                                        .read(
                                          quranAudioControllerProvider.notifier,
                                        )
                                        .playOrToggleAyah(
                                          ayahRef: currentAyah,
                                          recitationId: recitation.id,
                                        );

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          );
                        },
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

class _ListeningRecitationTile extends StatelessWidget {
  const _ListeningRecitationTile({
    required this.recitation,
    required this.isSelected,
    required this.onTap,
  });

  final QuranRecitation recitation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final accentColor = AppColors.maroon800;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: isDark ? 0.14 : 0.08)
                : accentColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.28)
                  : accentColor.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.maroon800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _recitationLabel(recitation),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      recitation.style?.trim().isNotEmpty == true
                          ? recitation.style!
                          : 'مناسب للتشغيل السريع والهادئ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 18,
                color: isSelected ? accentColor : mutedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _recitationLabel(QuranRecitation recitation) {
  final translatedName = recitation.translatedName;
  final style = recitation.style;
  if (translatedName != null && translatedName != recitation.reciterName) {
    return '$translatedName - ${recitation.reciterName}';
  }
  if (style != null && style.trim().isNotEmpty) {
    return '${recitation.reciterName} - $style';
  }
  return recitation.reciterName;
}
