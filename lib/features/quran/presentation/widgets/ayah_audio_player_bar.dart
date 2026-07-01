import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class AyahAudioPlayerBar extends ConsumerWidget {
  const AyahAudioPlayerBar({this.bottomInset = 60, super.key});

  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioControllerProvider);
    final currentAyah = audioState.currentAyah;

    if (currentAyah == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon700;
    final recitationLabel = _recitationLabelForState(ref, audioState);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset, left: 16, right: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF191513).withValues(alpha: 0.9)
                      : const Color(0xFFF7F4EB).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.48),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    _PlayButton(
                      isLoading: audioState.isLoading,
                      isPlaying: audioState.isPlaying,
                      primaryColor: primaryColor,
                      onTap: () {
                        if (audioState.recitationId != null) {
                          ref
                              .read(quranAudioControllerProvider.notifier)
                              .playOrToggleAyah(
                                ayahRef: currentAyah,
                                recitationId: audioState.recitationId!,
                              );
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showListeningOptionsSheet(
                          context,
                          ref,
                          audioState,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سورة ${getSurahNameArabic(currentAyah.surah)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      recitationLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.72),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.headphones_rounded,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () =>
                          _showListeningOptionsSheet(context, ref, audioState),
                      icon: Icon(
                        Icons.expand_less_rounded,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      tooltip: 'خيارات الاستماع',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _recitationLabelForState(WidgetRef ref, QuranAudioState audioState) {
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final preferredReciterId = ref
        .watch(appUserPreferencesProvider)
        .maybeWhen(
          data: (preferences) => preferences.preferredReciterId,
          orElse: () => null,
        );

    return recitationsAsync.maybeWhen(
      data: (recitations) {
        if (recitations.isEmpty) {
          return 'اختر القارئ';
        }

        QuranRecitation activeRecitation = recitations.first;
        if (audioState.recitationId != null) {
          for (final recitation in recitations) {
            if (recitation.id == audioState.recitationId) {
              activeRecitation = recitation;
              break;
            }
          }
        } else if (preferredReciterId != null) {
          for (final recitation in recitations) {
            if (recitation.id == preferredReciterId) {
              activeRecitation = recitation;
              break;
            }
          }
        }

        return _recitationLabel(activeRecitation);
      },
      orElse: () => 'جاري تحميل القراء...',
    );
  }

  Future<void> _showListeningOptionsSheet(
    BuildContext context,
    WidgetRef ref,
    QuranAudioState audioState,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ListeningOptionsSheet(audioState: audioState),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isLoading,
    required this.isPlaying,
    required this.primaryColor,
    required this.onTap,
  });

  final bool isLoading;
  final bool isPlaying;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10),
        child: CircularProgressIndicator(strokeWidth: 2.4, color: primaryColor),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: primaryColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _ListeningOptionsSheet extends ConsumerWidget {
  const _ListeningOptionsSheet({required this.audioState});

  final QuranAudioState audioState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'اختر القارئ وفعّل وضع الاستماع السهل.',
                              style: Theme.of(context).textTheme.bodySmall
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: mutedColor),
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
                  ref
                      .watch(quranRecitationsProvider)
                      .when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stackTrace) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'تعذر تحميل قائمة القراء.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: mutedColor),
                          ),
                        ),
                        data: (recitations) {
                          if (recitations.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'لا توجد قراءات متاحة الآن.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: mutedColor),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              for (final recitation in recitations) ...[
                                _ListeningRecitationTile(
                                  recitation: recitation,
                                  isSelected:
                                      audioState.recitationId ==
                                          recitation.id ||
                                      (audioState.recitationId == null &&
                                          preferredReciterId == recitation.id),
                                  onTap: () async {
                                    ref
                                            .read(
                                              selectedQuranRecitationProvider
                                                  .notifier,
                                            )
                                            .state =
                                        recitation;
                                    await ref
                                        .read(
                                          appUserPreferencesProvider.notifier,
                                        )
                                        .setPreferredReciter(recitation);

                                    if (audioState.currentAyah != null) {
                                      await ref
                                          .read(
                                            quranAudioControllerProvider
                                                .notifier,
                                          )
                                          .playOrToggleAyah(
                                            ayahRef: audioState.currentAyah!,
                                            recitationId: recitation.id,
                                          );
                                    }

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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: mutedColor),
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
