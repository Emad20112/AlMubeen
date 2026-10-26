import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_buttons.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reciters_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurahPlayerTopBar extends StatelessWidget {
  const SurahPlayerTopBar({
    super.key,
    required this.isDark,
    required this.accentColor,
  });

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

class SurahPlayerReciterRow extends StatelessWidget {
  const SurahPlayerReciterRow({
    super.key,
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
          Expanded(
            child: SurahPlayerReciterDropdown(
              recitationsAsync: recitationsAsync,
              activeRecitation: activeRecitation,
              isDark: isDark,
              accentColor: accentColor,
              onChanged: onReciterChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SurahDownloadAllButton(
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

class SurahPlayerReciterDropdown extends StatelessWidget {
  const SurahPlayerReciterDropdown({
    super.key,
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
    showReciterPickerForSurahPlayer(
      context: context,
      activeRecitation: activeRecitation,
      onChanged: onChanged,
    );
  }
}

class SurahDownloadAllButton extends StatelessWidget {
  const SurahDownloadAllButton({
    super.key,
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

class SurahDownloadActionBar extends StatelessWidget {
  const SurahDownloadActionBar({
    super.key,
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
              MiniDownloadIconButton(
                icon: Icons.pause_rounded,
                tooltip: 'إيقاف مؤقت',
                accentColor: accentColor,
                onTap: onPause!,
              ),
            if (onResume != null)
              MiniDownloadIconButton(
                icon: Icons.play_arrow_rounded,
                tooltip: 'استئناف',
                accentColor: accentColor,
                onTap: onResume!,
              ),
            if (onCancel != null)
              MiniDownloadIconButton(
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
