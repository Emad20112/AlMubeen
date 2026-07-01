import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

Future<void> showQuranReaderSearchSheet({
  required BuildContext context,
  required int currentPage,
  required ValueChanged<int> onPageSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuranReaderSearchSheet(
      currentPage: currentPage,
      onPageSelected: onPageSelected,
    ),
  );
}

class _QuranReaderSearchSheet extends ConsumerStatefulWidget {
  const _QuranReaderSearchSheet({
    required this.currentPage,
    required this.onPageSelected,
  });

  final int currentPage;
  final ValueChanged<int> onPageSelected;

  @override
  ConsumerState<_QuranReaderSearchSheet> createState() =>
      _QuranReaderSearchSheetState();
}

class _QuranReaderSearchSheetState
    extends ConsumerState<_QuranReaderSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectPage(int page) async {
    Navigator.of(context).pop();
    widget.onPageSelected(page);
  }

  Future<void> _selectRecitation(QuranRecitation recitation) async {
    final preferencesNotifier = ref.read(appUserPreferencesProvider.notifier);
    ref.read(selectedQuranRecitationProvider.notifier).state = recitation;
    await preferencesNotifier.setPreferredReciter(recitation);

    final audioState = ref.read(quranAudioControllerProvider);
    if (audioState.currentAyah != null) {
      await ref
          .read(quranAudioControllerProvider.notifier)
          .playOrToggleAyah(
            ayahRef: audioState.currentAyah!,
            recitationId: recitation.id,
          );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final borderColor = AppColors.maroon800.withValues(
      alpha: isDark ? 0.18 : 0.12,
    );
    final normalizedQuery = _query.trim().toLowerCase();
    final currentSurah = getSurahNumberFromPage(widget.currentPage);
    final parsedPage = int.tryParse(normalizedQuery);

    final pageResults = <_SearchResult>[
      if (normalizedQuery.isEmpty)
        _SearchResult(
          title: 'الصفحة الحالية',
          subtitle: 'صفحة ${_toArabicDigits(widget.currentPage)}',
          page: widget.currentPage,
          icon: Icons.chrome_reader_mode_rounded,
        )
      else if (parsedPage != null &&
          parsedPage >= 1 &&
          parsedPage <= totalPagesCount)
        _SearchResult(
          title: 'صفحة ${_toArabicDigits(parsedPage)}',
          subtitle: 'الانتقال مباشرة إلى الصفحة',
          page: parsedPage,
          icon: Icons.chrome_reader_mode_rounded,
        ),
    ];

    final surahResults = <_SearchResult>[];
    if (normalizedQuery.isNotEmpty) {
      for (var surah = 1; surah <= totalSurahCount; surah++) {
        final name = getSurahNameArabic(surah);
        final page = getPageNumber(surah, 1);
        final ayahCount = getVerseCount(surah);
        final pageLabel = 'صفحة ${_toArabicDigits(page)}';
        final matches =
            name.contains(normalizedQuery) ||
            surah.toString() == normalizedQuery ||
            _toArabicDigits(surah).contains(normalizedQuery);
        if (!matches) {
          continue;
        }

        surahResults.add(
          _SearchResult(
            title: name,
            subtitle: '$pageLabel • $ayahCount آية',
            page: page,
            icon: Icons.auto_stories_rounded,
          ),
        );
      }
    } else {
      surahResults.add(
        _SearchResult(
          title: getSurahNameArabic(currentSurah),
          subtitle:
              'السورة الحالية • صفحة ${_toArabicDigits(widget.currentPage)}',
          page: getPageNumber(currentSurah, 1),
          icon: Icons.auto_stories_rounded,
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
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
            initialChildSize: 0.82,
            minChildSize: 0.48,
            maxChildSize: 0.96,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderColor,
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
                          child: Icon(
                            Icons.search_rounded,
                            color: AppColors.maroon800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'بحث سريع',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: titleColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ابحث عن الصفحة أو السورة أو القارئ.',
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
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  setState(() {
                                    _query = '';
                                    _searchController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear_rounded),
                              ),
                        hintText: 'ابحث عن الصفحة، السورة، القارئ...',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceHigh
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          if (_query.trim().isEmpty) ...[
                            Text(
                              'اختصارات',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _QuickActionChip(
                                  label: 'الصفحة الحالية',
                                  icon: Icons.chrome_reader_mode_rounded,
                                  onTap: () => _selectPage(widget.currentPage),
                                ),
                                _QuickActionChip(
                                  label: 'السورة الحالية',
                                  icon: Icons.auto_stories_rounded,
                                  onTap: () => _selectPage(
                                    getPageNumber(currentSurah, 1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (pageResults.isNotEmpty) ...[
                            _SectionTitle(title: 'الصفحات'),
                            const SizedBox(height: 8),
                            ...pageResults.map(
                              (result) => _SearchResultTile(
                                result: result,
                                titleColor: titleColor,
                                mutedColor: mutedColor,
                                onTap: () => _selectPage(result.page!),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (surahResults.isNotEmpty) ...[
                            _SectionTitle(title: 'السور'),
                            const SizedBox(height: 8),
                            ...surahResults.map(
                              (result) => _SearchResultTile(
                                result: result,
                                titleColor: titleColor,
                                mutedColor: mutedColor,
                                onTap: () => _selectPage(result.page!),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Consumer(
                            builder: (context, ref, child) {
                              final recitationsAsync = ref.watch(
                                quranRecitationsProvider,
                              );
                              return recitationsAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (error, stackTrace) =>
                                    const SizedBox.shrink(),
                                data: (recitations) {
                                  final filteredRecitations = _query.isEmpty
                                      ? recitations
                                            .take(6)
                                            .toList(growable: false)
                                      : recitations
                                            .where(
                                              (recitation) =>
                                                  _matchesRecitation(
                                                    recitation,
                                                    normalizedQuery,
                                                  ),
                                            )
                                            .toList(growable: false);

                                  if (filteredRecitations.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _SectionTitle(title: 'القراء'),
                                      const SizedBox(height: 8),
                                      for (final recitation
                                          in filteredRecitations) ...[
                                        _RecitationTile(
                                          recitation: recitation,
                                          titleColor: titleColor,
                                          mutedColor: mutedColor,
                                          onTap: () =>
                                              _selectRecitation(recitation),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          if (pageResults.isEmpty &&
                              surahResults.isEmpty &&
                              normalizedQuery.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 54,
                                    color: mutedColor,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'لا توجد نتائج مطابقة',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: titleColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'جرّب رقم صفحة آخر أو اسم سورة أو قارئ.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: mutedColor),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _matchesRecitation(QuranRecitation recitation, String query) {
    final reciter = recitation.reciterName.toLowerCase();
    final translated = recitation.translatedName?.toLowerCase() ?? '';
    final style = recitation.style?.toLowerCase() ?? '';
    return reciter.contains(query) ||
        translated.contains(query) ||
        style.contains(query);
  }
}

class _SearchResult {
  const _SearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int? page;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.titleColor,
    required this.mutedColor,
    required this.onTap,
  });

  final _SearchResult result;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.maroon800.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.maroon800.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.maroon800.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(result.icon, color: AppColors.maroon800),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.subtitle,
                        maxLines: 2,
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
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: mutedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecitationTile extends StatelessWidget {
  const _RecitationTile({
    required this.recitation,
    required this.titleColor,
    required this.mutedColor,
    required this.onTap,
  });

  final QuranRecitation recitation;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.maroon800.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.maroon800.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
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
                          : 'اختر القارئ للتشغيل السريع',
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
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: mutedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
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

String _toArabicDigits(int number) {
  const digits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return number.toString().split('').map((d) => digits[d] ?? d).join();
}
