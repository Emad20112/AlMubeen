import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

Future<void> showAyahActionSheet({
  required BuildContext context,
  required AyahRef ayahRef,
  required bool isHighlighted,
  required VoidCallback onToggleHighlight,
  required VoidCallback onClearHighlight,
}) {
  final width = MediaQuery.sizeOf(context).width;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(maxWidth: math.min(width, 560.0)),
    builder: (context) {
      return _AyahActionSheet(
        ayahRef: ayahRef,
        isHighlighted: isHighlighted,
        onToggleHighlight: onToggleHighlight,
        onClearHighlight: onClearHighlight,
      );
    },
  );
}

class _AyahActionSheet extends ConsumerWidget {
  const _AyahActionSheet({
    required this.ayahRef,
    required this.isHighlighted,
    required this.onToggleHighlight,
    required this.onClearHighlight,
  });

  final AyahRef ayahRef;
  final bool isHighlighted;
  final VoidCallback onToggleHighlight;
  final VoidCallback onClearHighlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final surahName = getSurahNameArabic(ayahRef.surah);
    final verseText = getVerse(ayahRef.surah, ayahRef.ayah);
    final revelation = getPlaceOfRevelation(ayahRef.surah) == 'Makkah'
        ? 'مكية'
        : 'مدنية';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: size.height * 0.85),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 0.12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const SizedBox(height: 5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'سورة $surahName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                SelectableText(
                  verseText,
                  maxLines: 8,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _AyahMetaPill(
                      icon: Icons.format_list_numbered_rtl,
                      label: 'الآية',
                      value: ayahRef.ayah.toString(),
                    ),
                    _AyahMetaPill(
                      icon: Icons.auto_stories_outlined,
                      label: 'الصفحة',
                      value: ayahRef.page.toString(),
                    ),
                    _AyahMetaPill(
                      icon: Icons.pie_chart_outline,
                      label: 'الجزء',
                      value: getJuzNumber(
                        ayahRef.surah,
                        ayahRef.ayah,
                      ).toString(),
                    ),
                    _AyahMetaPill(
                      icon: Icons.data_usage_outlined,
                      label: 'الربع',
                      value: getQuarterNumber(
                        ayahRef.surah,
                        ayahRef.ayah,
                      ).toString(),
                    ),
                    _AyahMetaPill(
                      icon: Icons.place_outlined,
                      label: 'النزول',
                      value: revelation,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildAudioControls(context, ref),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        onToggleHighlight();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        isHighlighted
                            ? Icons.bookmark_remove_outlined
                            : Icons.bookmark_add_outlined,
                      ),
                      label: Text(
                        isHighlighted ? 'إزالة التظليل' : 'تظليل الآية',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        onClearHighlight();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.layers_clear_outlined),
                      label: const Text(
                        'مسح التظليل',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioControls(BuildContext context, WidgetRef ref) {
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final selectedRecitation = ref.watch(selectedQuranRecitationProvider);
    final audioState = ref.watch(quranAudioControllerProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurfaceHigh
            : AppColors.parchmentLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: recitationsAsync.when(
          loading: () => const _AudioLoadingState(),
          error: (error, stackTrace) => _AudioErrorState(
            message: 'تعذر تحميل قائمة القراء.',
            onRetry: () => ref.invalidate(quranRecitationsProvider),
          ),
          data: (recitations) {
            if (recitations.isEmpty) {
              return _AudioErrorState(
                message: 'لا توجد قراءات متاحة الآن.',
                onRetry: () => ref.invalidate(quranRecitationsProvider),
              );
            }

            final activeRecitation = _activeRecitation(
              recitations,
              selectedRecitation,
            );
            // Prefetch audio for the active recitation for this ayah so playback
            // starts faster if the user taps play. Failures are ignored.
            unawaited(ref.read(quranAudioControllerProvider.notifier).prefetchAyah(
              ayahRef: ayahRef,
              recitationId: activeRecitation.id,
            ));
            final isCurrent = audioState.isCurrent(
              ayahRef: ayahRef,
              recitationId: activeRecitation.id,
            );
            final isLoading = isCurrent && audioState.isLoading;
            final isPlaying = isCurrent && audioState.isPlaying;
            final canShowProgress = isCurrent &&
                audioState.duration > Duration.zero &&
                !isLoading;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.graphic_eq_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تلاوة الآية',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: activeRecitation.id,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'القارئ',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (final recitation in recitations)
                      DropdownMenuItem<int>(
                        value: recitation.id,
                        child: Text(
                          _recitationLabel(recitation),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                  ],
                  onChanged: (recitationId) {
                    if (recitationId == null) {
                      return;
                    }

                    ref.read(selectedQuranRecitationProvider.notifier).state =
                        recitations.firstWhere(
                          (recitation) => recitation.id == recitationId,
                        );
                  },
                ),
                const SizedBox(height: 12),
                if (canShowProgress) ...[
                  _AudioProgressBar(state: audioState),
                  const SizedBox(height: 12),
                ],
                FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          final controller = ref.read(
                            quranAudioControllerProvider.notifier,
                          );
                          if (isPlaying) {
                            controller.stop();
                            return;
                          }

                          controller.playOrToggleAyah(
                            ayahRef: ayahRef,
                            recitationId: activeRecitation.id,
                          );
                        },
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline,
                        ),
                  label: Text(
                    isLoading
                        ? 'جاري تجهيز التلاوة...'
                        : isPlaying
                        ? 'إيقاف التلاوة'
                        : isCurrent
                        ? 'متابعة التلاوة'
                        : 'تشغيل الآية',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                if (isCurrent && audioState.errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    audioState.errorMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  QuranRecitation _activeRecitation(
    List<QuranRecitation> recitations,
    QuranRecitation? selectedRecitation,
  ) {
    if (selectedRecitation != null) {
      for (final recitation in recitations) {
        if (recitation.id == selectedRecitation.id) {
          return recitation;
        }
      }
    }

    return recitations.first;
  }

  String _recitationLabel(QuranRecitation recitation) {
    final translatedName = recitation.translatedName;
    final style = recitation.style;
    if (translatedName != null && translatedName != recitation.reciterName) {
      return '$translatedName - ${recitation.reciterName}';
    }
    if (style != null) {
      return '${recitation.reciterName} - $style';
    }
    return recitation.reciterName;
  }
}

class _AudioLoadingState extends StatelessWidget {
  const _AudioLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
        SizedBox(width: 10),
        Flexible(
          child: Text(
            'جاري تحميل القراء...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _AudioErrorState extends StatelessWidget {
  const _AudioErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}

class _AudioProgressBar extends StatelessWidget {
  const _AudioProgressBar({required this.state});

  final QuranAudioState state;

  @override
  Widget build(BuildContext context) {
    final durationMs = state.duration.inMilliseconds;
    final positionMs = state.position.inMilliseconds.clamp(0, durationMs);
    final value = durationMs <= 0 ? 0.0 : positionMs / durationMs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(value: value.clamp(0.0, 1.0).toDouble()),
        const SizedBox(height: 6),
        Text(
          '${_formatDuration(state.position)} / ${_formatDuration(state.duration)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _AyahMetaPill extends StatelessWidget {
  const _AyahMetaPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurfaceHigh
            : AppColors.parchmentLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
