import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranRecitersListView extends ConsumerWidget {
  const QuranRecitersListView({
    super.key,
    required this.currentAyah,
    required this.recitationId,
  });

  final AyahRef currentAyah;
  final int? recitationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    final preferencesAsync = ref.watch(appUserPreferencesProvider);

    final preferredReciterId = preferencesAsync.maybeWhen(
      data: (preferences) => preferences.preferredReciterId,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'القراء المتاحون',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),

        ref.watch(quranRecitationsProvider).when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'تعذر تحميل قائمة القراء.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: mutedColor),
                  ),
                ),
              ),
              data: (recitations) {
                if (recitations.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'لا توجد قراءات متاحة الآن.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: mutedColor),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final recitation in recitations) ...[
                      _ListeningRecitationTile(
                        key: ValueKey(recitation.id),
                        recitation: recitation,
                        isSelected: recitationId == recitation.id ||
                            (recitationId == null &&
                                preferredReciterId == recitation.id),
                        onTap: () async {
                          ref
                              .read(selectedQuranRecitationProvider.notifier)
                              .state = recitation;

                          await ref
                              .read(appUserPreferencesProvider.notifier)
                              .setPreferredReciter(recitation);

                          await ref
                              .read(quranAudioControllerProvider.notifier)
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
    );
  }
}

class _ListeningRecitationTile extends StatelessWidget {
  const _ListeningRecitationTile({
    super.key,
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
    final titleColor =
        isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor =
        isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: isDark ? 0.16 : 0.08)
                : accentColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.35)
                  : accentColor.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: accentColor,
                  size: 22,
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
                    const SizedBox(height: 2),
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
                color: isSelected
                    ? accentColor
                    : mutedColor.withValues(alpha: 0.5),
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
