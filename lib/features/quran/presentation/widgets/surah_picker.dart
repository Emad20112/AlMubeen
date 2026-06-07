import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_page_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

Future<void> openSurahPickerAndReader(BuildContext context) async {
  final surahNumber = await showSurahPicker(context);

  if (!context.mounted || surahNumber == null) {
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) =>
          QuranPageReader(initialPage: getPageNumber(surahNumber, 1)),
    ),
  );
}

Future<int?> showSurahPicker(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final windowClass = AdaptiveBreakpoints.fromWidth(width);

  if (windowClass == AdaptiveWindowClass.compact) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _SurahPickerSheet();
      },
    );
  }

  return showDialog<int>(
    context: context,
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final backgroundColor = isDark
          ? AppColors.darkSurface
          : AppColors.parchmentLight;

      return Dialog(
        backgroundColor: backgroundColor,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(size.width - 48, 760.0),
            maxHeight: size.height * 0.82,
          ),
          child: const _SurahPickerContent(),
        ),
      );
    },
  );
}

class _SurahPickerSheet extends StatelessWidget {
  const _SurahPickerSheet();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * 0.86),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const _SurahPickerContent(showDragHandle: true),
        ),
      ),
    );
  }
}

class _SurahPickerContent extends StatelessWidget {
  const _SurahPickerContent({this.showDragHandle = false});

  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle) ...[
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.maroon700.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const SizedBox(height: 5),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Icon(
                    FlutterIslamicIcons.quran2,
                    color: foregroundColor,
                    size: textScaler.scale(26).clamp(24, 34).toDouble(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'اختر السورة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: foregroundColor.withValues(alpha: 0.18)),
            const Expanded(child: _SurahPickerBody()),
          ],
        ),
      ),
    );
  }
}

class _SurahPickerBody extends StatelessWidget {
  const _SurahPickerBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final windowClass = AdaptiveBreakpoints.fromWidth(width);
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final isGrid = windowClass != AdaptiveWindowClass.compact;

        if (!isGrid) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
            itemBuilder: (context, index) {
              return _SurahTile(surahNumber: index + 1);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: totalSurahCount,
          );
        }

        final crossAxisCount = windowClass == AdaptiveWindowClass.medium
            ? 2
            : 3;
        final spacing = width >= AdaptiveBreakpoints.expandedMinWidth
            ? 14.0
            : 12.0;
        final itemExtent = 78.0 + (math.max(textScale, 1.0) - 1) * 36;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: itemExtent,
          ),
          itemBuilder: (context, index) {
            return _SurahTile(surahNumber: index + 1);
          },
          itemCount: totalSurahCount,
        );
      },
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surahNumber});

  final int surahNumber;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? AppColors.darkSurfaceHigh : AppColors.parchment;
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final metaColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final surahName = getSurahNameArabic(surahNumber);
    final ayahCount = getVerseCount(surahNumber);
    final pageNumber = getPageNumber(surahNumber, 1);
    final revelation = getPlaceOfRevelation(surahNumber) == 'Makkah'
        ? 'مكية'
        : 'مدنية';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => Navigator.of(context).pop(surahNumber),
        child: Ink(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: metaColor.withValues(alpha: 0.24)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _SurahNumberBadge(number: surahNumber),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surahName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$revelation • $ayahCount آية • صفحة $pageNumber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: metaColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahNumberBadge extends StatelessWidget {
  const _SurahNumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBackground = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;
    final badgeForeground = isDark
        ? AppColors.maroon800
        : AppColors.parchmentLight;

    return SizedBox.square(
      dimension: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: badgeBackground,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                number.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: badgeForeground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
