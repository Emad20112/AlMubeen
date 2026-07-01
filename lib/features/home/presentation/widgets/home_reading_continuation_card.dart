import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_page_reader.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class HomeReadingContinuationCard extends StatelessWidget {
  const HomeReadingContinuationCard({required this.progressEntry, super.key});

  final QuranReadingProgressEntry? progressEntry;

  bool get hasProgress => progressEntry != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final accentColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final borderColor = AppColors.maroon800.withValues(
      alpha: isDark ? 0.24 : 0.12,
    );
    final progressFraction = _progressFraction;

    return Transform.translate(
      offset: const Offset(0, -8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openPrimaryAction(context),
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.maroon900.withValues(
                      alpha: isDark ? 0.16 : 0.08,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 460;

                    final content = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ContinuationTextBlock(
                                hasProgress: hasProgress,
                                titleColor: titleColor,
                                mutedColor: mutedColor,
                                progressEntry: progressEntry,
                              ),
                            ),
                            const SizedBox(width: 14),
                            _ProgressBadge(
                              fraction: progressFraction,
                              accentColor: accentColor,
                              titleColor: titleColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton(
                              onPressed: () => _openPrimaryAction(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.maroon800,
                                foregroundColor: AppColors.parchmentLight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 13,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(
                                hasProgress ? 'متابعة القراءة' : 'ابدأ التلاوة',
                              ),
                            ),
                            if (!hasProgress)
                              FilledButton.tonal(
                                onPressed: () =>
                                    openSurahPickerAndReader(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.maroon800
                                      .withValues(alpha: 0.08),
                                  foregroundColor: AppColors.maroon800,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 13,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('اختر سورة'),
                              ),
                          ],
                        ),
                      ],
                    );

                    if (!isWide) {
                      return content;
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _ContinuationTextBlock(
                            hasProgress: hasProgress,
                            titleColor: titleColor,
                            mutedColor: mutedColor,
                            progressEntry: progressEntry,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _ProgressBadge(
                          fraction: progressFraction,
                          accentColor: accentColor,
                          titleColor: titleColor,
                          size: 76,
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.end,
                              children: [
                                FilledButton(
                                  onPressed: () => _openPrimaryAction(context),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.maroon800,
                                    foregroundColor: AppColors.parchmentLight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 13,
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: Text(
                                    hasProgress
                                        ? 'متابعة القراءة'
                                        : 'ابدأ التلاوة',
                                  ),
                                ),
                                if (!hasProgress)
                                  FilledButton.tonal(
                                    onPressed: () =>
                                        openSurahPickerAndReader(context),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.maroon800
                                          .withValues(alpha: 0.08),
                                      foregroundColor: AppColors.maroon800,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 13,
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    child: const Text('اختر سورة'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double get _progressFraction {
    if (progressEntry == null) {
      return 0;
    }

    return (progressEntry!.lastPage / totalPagesCount)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  void _openPrimaryAction(BuildContext context) {
    if (hasProgress) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              QuranPageReader(initialPage: progressEntry!.lastPage),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const QuranPageReader(initialPage: 1),
      ),
    );
  }
}

class _ContinuationTextBlock extends StatelessWidget {
  const _ContinuationTextBlock({
    required this.hasProgress,
    required this.titleColor,
    required this.mutedColor,
    required this.progressEntry,
  });

  final bool hasProgress;
  final Color titleColor;
  final Color mutedColor;
  final QuranReadingProgressEntry? progressEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final surahNumber = progressEntry?.lastSurahNumber ?? 1;
    final surahName = hasProgress
        ? getSurahNameArabic(surahNumber)
        : 'لا توجد متابعة محفوظة';
    final pageText = hasProgress
        ? 'صفحة ${progressEntry!.lastPage}'
        : 'اختر سورة أو ابدأ من الصفحة الأولى';
    final hintText = hasProgress
        ? 'تابع من حيث توقفت بهدوء وبنفس ترتيب القراءة.'
        : 'يمكنك البدء مباشرة أو اختيار سورة مناسبة لك.';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'متابعة القراءة',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.titleLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          surahName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.titleMedium?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          pageText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyMedium?.copyWith(
            color: mutedColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hintText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.bodySmall?.copyWith(
            color: mutedColor.withValues(alpha: 0.9),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({
    required this.fraction,
    required this.accentColor,
    required this.titleColor,
    this.size = 66,
  });

  final double fraction;
  final Color accentColor;
  final Color titleColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final percent = (fraction * 100).round().clamp(0, 100);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: fraction <= 0 ? 0.02 : fraction,
              strokeWidth: 5,
              backgroundColor: accentColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تقدم',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: titleColor.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
