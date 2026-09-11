import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a reciter picker from the Surah Player screen.
/// Unlike [showReciterPickerSheet], it does NOT auto-play an ayah;
/// instead it calls [onChanged] so the caller can react.
Future<void> showReciterPickerForSurahPlayer({
  required BuildContext context,
  required QuranRecitation? activeRecitation,
  required ValueChanged<QuranRecitation> onChanged,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final windowClass = AdaptiveBreakpoints.fromWidth(width);

  if (windowClass == AdaptiveWindowClass.compact) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SurahPlayerReciterSheet(
        activeRecitation: activeRecitation,
        onChanged: onChanged,
        showDragHandle: true,
      ),
    );
  }

  return showDialog<void>(
    context: context,
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final backgroundColor = isDark
          ? AppColors.darkSurface
          : AppColors.parchmentLight;

      return Dialog(
        backgroundColor: backgroundColor,
        insetPadding: EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(size.width, 680.0),
            maxHeight: size.height * 0.85,
          ),
          child: _SurahPlayerReciterContent(
            activeRecitation: activeRecitation,
            onChanged: onChanged,
          ),
        ),
      );
    },
  );
}

class _SurahPlayerReciterSheet extends StatelessWidget {
  const _SurahPlayerReciterSheet({
    required this.activeRecitation,
    required this.onChanged,
    this.showDragHandle = false,
  });

  final QuranRecitation? activeRecitation;
  final ValueChanged<QuranRecitation> onChanged;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _SurahPlayerReciterContent(
        activeRecitation: activeRecitation,
        onChanged: onChanged,
        showDragHandle: showDragHandle,
      ),
    );
  }
}

class _SurahPlayerReciterContent extends ConsumerStatefulWidget {
  const _SurahPlayerReciterContent({
    required this.activeRecitation,
    required this.onChanged,
    this.showDragHandle = false,
  });

  final QuranRecitation? activeRecitation;
  final ValueChanged<QuranRecitation> onChanged;
  final bool showDragHandle;

  @override
  ConsumerState<_SurahPlayerReciterContent> createState() =>
      _SurahPlayerReciterContentState();
}

class _SurahPlayerReciterContentState
    extends ConsumerState<_SurahPlayerReciterContent> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _query = ValueNotifier<String>('');

  @override
  void dispose() {
    _searchController.dispose();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            if (widget.showDragHandle) ...[
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: foregroundColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      color: foregroundColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'اختر القارئ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: foregroundColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, queryValue, _) {
                  return SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => _query.value = val,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(fontSize: 13, color: foregroundColor),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن قارئ...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: foregroundColor.withValues(alpha: 0.5),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 0,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: foregroundColor.withValues(alpha: 0.5),
                        ),
                        suffixIcon: queryValue.isNotEmpty
                            ? SizedBox(
                                width: 36,
                                child: IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _query.value = '';
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: 16,
                                    color: foregroundColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 0,
                                  ),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: foregroundColor.withValues(alpha: 0.06),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1, color: foregroundColor.withValues(alpha: 0.12)),
            Flexible(
              child: ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, queryValue, _) {
                  return _SurahPlayerReciterBody(
                    query: queryValue,
                    activeRecitation: widget.activeRecitation,
                    onChanged: (r) {
                      widget.onChanged(r);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahPlayerReciterBody extends ConsumerWidget {
  const _SurahPlayerReciterBody({
    required this.query,
    required this.activeRecitation,
    required this.onChanged,
  });

  final String query;
  final QuranRecitation? activeRecitation;
  final ValueChanged<QuranRecitation> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    return ref
        .watch(quranRecitationsProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'تعذر تحميل قائمة القراء.',
                style: TextStyle(color: mutedColor),
              ),
            ),
          ),
          data: (recitations) {
            // Only reciters that support full surah audio can play here.
            final capable = recitations.where((r) => r.hasSurahAudio).toList();
            final filtered = _filterRecitations(capable, query);
            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    query.isEmpty ? 'لا توجد قراءات.' : 'لا توجد نتائج.',
                    style: TextStyle(color: mutedColor),
                  ),
                ),
              );
            }
            // Build sectioned list items
            final items = _buildSectionedItems(filtered, isDark);
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                if (item is _SectionHeader) {
                  return _ReciterSectionHeader(header: item, isDark: isDark);
                }
                final r = (item as QuranRecitation);
                final isSelected = activeRecitation?.id == r.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ReciterPickerTile(
                    key: ValueKey(r.id),
                    recitation: r,
                    isSelected: isSelected,
                    onTap: () => onChanged(r),
                  ),
                );
              },
            );
          },
        );
  }

  List<Object> _buildSectionedItems(List<QuranRecitation> list, bool isDark) {
    return _groupAndBuildItems(list);
  }

  List<QuranRecitation> _filterRecitations(
    List<QuranRecitation> list,
    String raw,
  ) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((r) {
      return [
        r.reciterName,
        r.translatedName,
        r.style,
        r.languageName,
      ].any((v) => v != null && v.toLowerCase().contains(q));
    }).toList();
  }
}

/// Shows a bottom sheet / dialog for reciter selection, similar in style to the
/// surah picker, with search and bilingual names. Selecting a reciter
/// plays it on [currentAyah] via [QuranAudioController].
Future<void> showReciterPickerSheet({
  required BuildContext context,
  required AyahRef currentAyah,
  required int? currentRecitationId,
  bool playOnSelect = false,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final windowClass = AdaptiveBreakpoints.fromWidth(width);

  if (windowClass == AdaptiveWindowClass.compact) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReciterPickerSheet(
        currentAyah: currentAyah,
        currentRecitationId: currentRecitationId,
        playOnSelect: playOnSelect,
        showDragHandle: true,
      ),
    );
  }

  return showDialog<void>(
    context: context,
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final backgroundColor = isDark
          ? AppColors.darkSurface
          : AppColors.parchmentLight;

      return Dialog(
        backgroundColor: backgroundColor,
        insetPadding: EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(size.width, 680.0),
            maxHeight: size.height * 0.85,
          ),
          child: _ReciterPickerContent(
            currentAyah: currentAyah,
            currentRecitationId: currentRecitationId,
            playOnSelect: playOnSelect,
          ),
        ),
      );
    },
  );
}

class _ReciterPickerSheet extends StatelessWidget {
  const _ReciterPickerSheet({
    required this.currentAyah,
    required this.currentRecitationId,
    required this.playOnSelect,
    this.showDragHandle = false,
  });

  final AyahRef currentAyah;
  final int? currentRecitationId;
  final bool playOnSelect;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _ReciterPickerContent(
        currentAyah: currentAyah,
        currentRecitationId: currentRecitationId,
        playOnSelect: playOnSelect,
        showDragHandle: showDragHandle,
      ),
    );
  }
}

class _ReciterPickerContent extends ConsumerStatefulWidget {
  const _ReciterPickerContent({
    required this.currentAyah,
    required this.currentRecitationId,
    this.playOnSelect = false,
    this.showDragHandle = false,
  });

  final AyahRef currentAyah;
  final int? currentRecitationId;
  final bool playOnSelect;
  final bool showDragHandle;

  @override
  ConsumerState<_ReciterPickerContent> createState() =>
      _ReciterPickerContentState();
}

class _ReciterPickerContentState extends ConsumerState<_ReciterPickerContent> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _query = ValueNotifier<String>('');

  @override
  void dispose() {
    _searchController.dispose();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            if (widget.showDragHandle) ...[
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: foregroundColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      color: foregroundColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'اختر القارئ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: foregroundColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, queryValue, _) {
                  return SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => _query.value = val,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(fontSize: 13, color: foregroundColor),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن قارئ...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: foregroundColor.withValues(alpha: 0.5),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 0,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: foregroundColor.withValues(alpha: 0.5),
                        ),
                        suffixIcon: queryValue.isNotEmpty
                            ? SizedBox(
                                width: 36,
                                child: IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _query.value = '';
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: 16,
                                    color: foregroundColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 0,
                                  ),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: foregroundColor.withValues(alpha: 0.06),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1, color: foregroundColor.withValues(alpha: 0.12)),
            Flexible(
              child: ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, queryValue, _) {
                  return _ReciterPickerBody(
                    query: queryValue,
                    currentAyah: widget.currentAyah,
                    currentRecitationId: widget.currentRecitationId,
                    playOnSelect: widget.playOnSelect,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReciterPickerBody extends ConsumerWidget {
  const _ReciterPickerBody({
    required this.query,
    required this.currentAyah,
    required this.currentRecitationId,
    required this.playOnSelect,
  });

  final String query;
  final AyahRef currentAyah;
  final int? currentRecitationId;
  final bool playOnSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final preferencesAsync = ref.watch(appUserPreferencesProvider);
    final selectedRecitation = ref.watch(selectedQuranRecitationProvider);
    final preferredReciterId = preferencesAsync.maybeWhen(
      data: (p) => p.preferredReciterId,
      orElse: () => null,
    );
    final activeSelectionId = selectedRecitation?.hasAyahAudio == true
        ? selectedRecitation!.id
        : preferredReciterId ?? currentRecitationId;

    return ref
        .watch(quranRecitationsProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'تعذر تحميل قائمة القراء.',
                style: TextStyle(color: mutedColor),
              ),
            ),
          ),
          data: (recitations) {
            // Only reciters that support per-ayah playback are selectable here.
            final capable = recitations.where((r) => r.hasAyahAudio).toList();
            final filtered = _filterRecitations(capable, query);

            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    query.isEmpty ? 'لا توجد قراءات متاحة.' : 'لا توجد نتائج.',
                    style: TextStyle(color: mutedColor),
                  ),
                ),
              );
            }

            final items = _groupAndBuildItems(filtered);
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is _SectionHeader) {
                  return _ReciterSectionHeader(header: item, isDark: isDark);
                }
                final recitation = item as QuranRecitation;
                final isSelected = recitation.id == activeSelectionId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ReciterPickerTile(
                    key: ValueKey(recitation.id),
                    recitation: recitation,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedQuranRecitationProvider.notifier).state =
                          recitation;
                      // Close the picker immediately so the selection feels
                      // instant; preference saving continues async.
                      Navigator.of(context).pop();
                      unawaited(() async {
                        await ref
                            .read(appUserPreferencesProvider.notifier)
                            .setPreferredReciter(recitation);

                        if (playOnSelect) {
                          await ref
                              .read(quranAudioControllerProvider.notifier)
                              .playOrToggleAyah(
                                ayahRef: currentAyah,
                                recitationId: recitation.id,
                              );
                        }
                      }());
                    },
                  ),
                );
              },
            );
          },
        );
  }

  List<QuranRecitation> _filterRecitations(
    List<QuranRecitation> recitations,
    String rawQuery,
  ) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return recitations;
    return recitations.where((r) {
      return [
        r.reciterName,
        r.translatedName,
        r.style,
        r.languageName,
        r.category,
      ].any((v) => v != null && v.toLowerCase().contains(q));
    }).toList();
  }
}
// ---------------------------------------------------------------------------
// Section grouping helpers
// ---------------------------------------------------------------------------

/// Ordered section definitions with Arabic title and subtitle.
const List<(String key, String title, String subtitle)> _kSectionDefs = [
  (
    'قراء الحرمين الشريفين',
    'قراء الحرمين الشريفين',
    'أئمة وقراء المسجد الحرام والمسجد النبوي الشريف',
  ),
  (
    'تلاوات التراويح والصلوات',
    'تلاوات التراويح والصلوات',
    'تسجيلات خاشعة ومميزة من صلوات التراويح والقيام',
  ),
  (
    'قراء للتعلم والتجويد',
    'قراء للتعلم والتجويد',
    'تلاوات ومصحف معلم للتعليم والترتيل والتجويد',
  ),
  (
    'قراء خدمة Quran.com',
    'قراء خدمة Quran.com',
    'المكتبة الصوتية الشاملة من شبكة Quran.com',
  ),
  (
    'قراء خدمة Islamic.app',
    'قراء خدمة Islamic.app',
    'مكتبة صوتية عالية الجودة من منصة Islamic.app',
  ),
];

@immutable
final class _SectionHeader {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

/// Groups [reciters] by category and inserts [_SectionHeader] items between
/// sections. Categories without any reciters are silently skipped.
List<Object> _groupAndBuildItems(List<QuranRecitation> reciters) {
  final Map<String, List<QuranRecitation>> grouped = {};
  for (final r in reciters) {
    final cat = r.category ?? 'قراء خدمة Quran.com';
    grouped.putIfAbsent(cat, () => []).add(r);
  }

  final List<Object> result = [];
  for (final (key, title, subtitle) in _kSectionDefs) {
    final list = grouped[key];
    if (list == null || list.isEmpty) continue;
    result.add(_SectionHeader(title: title, subtitle: subtitle));
    result.addAll(list);
  }

  // Any category not matching predefined sections goes at the end.
  final knownKeys = _kSectionDefs.map((d) => d.$1).toSet();
  for (final entry in grouped.entries) {
    if (!knownKeys.contains(entry.key)) {
      result.add(_SectionHeader(title: entry.key, subtitle: ''));
      result.addAll(entry.value);
    }
  }

  return result;
}

/// Section header widget showing the category name + descriptive subtitle.
class _ReciterSectionHeader extends StatelessWidget {
  const _ReciterSectionHeader({required this.header, required this.isDark});

  final _SectionHeader header;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? const Color(0xFFE8C860) : AppColors.maroon800;
    final subtitleColor = isDark
        ? AppColors.parchmentMuted.withValues(alpha: 0.75)
        : AppColors.maroon700.withValues(alpha: 0.65);
    final dividerColor = isDark
        ? const Color(0xFFE8C860).withValues(alpha: 0.18)
        : AppColors.maroon700.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10, left: 6, right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFE8C860) : AppColors.maroon700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  header.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          if (header.subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(right: 11),
              child: Text(
                header.subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                  height: 1.3,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ),
    );
  }
}

class _ReciterPickerTile extends StatelessWidget {
  const _ReciterPickerTile({
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
    final titleColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    // Determine source badge label
    final isIslamicApp = recitation.id < 0;
    final sourceBadge = isIslamicApp ? 'Islamic.app' : 'Quran.com';
    final sourceBadgeColor = isIslamicApp
        ? const Color(0xFF2E7D55)
        : AppColors.maroon700;

    // Arabic name = reciterName, English name = translatedName
    final arabicName = recitation.reciterName;
    final englishName =
        (recitation.translatedName?.trim().isNotEmpty == true &&
            recitation.translatedName != recitation.reciterName)
        ? recitation.translatedName!
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08)
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
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
                      accentColor.withValues(alpha: isDark ? 0.10 : 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(
                  Icons.record_voice_over_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Names + source badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arabic name (primary)
                    Text(
                      arabicName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: accentColor,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'القارئ المستخدم حالياً',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),
                    // English name (secondary, small)
                    if (englishName != null) ...[
                      Text(
                        englishName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: mutedColor.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ] else
                      const SizedBox(height: 4),
                    // Source badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: sourceBadgeColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sourceBadge,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: sourceBadgeColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  size: isSelected ? 22 : 16,
                  color: isSelected
                      ? accentColor
                      : mutedColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legacy widget kept for backward-compatibility (used in ayah_interaction_overlay, etc.)
// ---------------------------------------------------------------------------

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
    // Delegate to the new full-featured picker sheet.
    // This widget is still exposed but just shows the picker content inline.
    return _ReciterPickerContent(
      currentAyah: currentAyah,
      currentRecitationId: recitationId,
    );
  }
}
