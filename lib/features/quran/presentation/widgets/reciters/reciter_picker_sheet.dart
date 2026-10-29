import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/core/widgets/app_search_bar.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/reciters/reciter_picker_tile.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/reciters/reciter_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// يعرض نافذة اختيار القارئ التكيفية للآيات أو لمشغل السور.
Future<void> showAdaptiveReciterPicker({
  required BuildContext context,
  AyahRef? currentAyah,
  int? currentRecitationId,
  QuranRecitation? activeRecitation,
  bool playOnSelect = false,
  bool forSurahPlayer = false,
  ValueChanged<QuranRecitation>? onSurahPlayerChanged,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final windowClass = AdaptiveBreakpoints.fromWidth(width);

  if (windowClass == AdaptiveWindowClass.compact) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReciterPickerBottomSheet(
        currentAyah: currentAyah,
        currentRecitationId: currentRecitationId,
        activeRecitation: activeRecitation,
        playOnSelect: playOnSelect,
        forSurahPlayer: forSurahPlayer,
        onSurahPlayerChanged: onSurahPlayerChanged,
      ),
    );
  }

  return showDialog<void>(
    context: context,
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      final colors = context.semanticColors;

      return Dialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(size.width, 640.0),
            maxHeight: size.height * 0.85,
          ),
          child: ReciterPickerContent(
            currentAyah: currentAyah,
            currentRecitationId: currentRecitationId,
            activeRecitation: activeRecitation,
            playOnSelect: playOnSelect,
            forSurahPlayer: forSurahPlayer,
            onSurahPlayerChanged: onSurahPlayerChanged,
            showDragHandle: false,
          ),
        ),
      );
    },
  );
}

class _ReciterPickerBottomSheet extends StatelessWidget {
  const _ReciterPickerBottomSheet({
    this.currentAyah,
    this.currentRecitationId,
    this.activeRecitation,
    this.playOnSelect = false,
    this.forSurahPlayer = false,
    this.onSurahPlayerChanged,
  });

  final AyahRef? currentAyah;
  final int? currentRecitationId;
  final QuranRecitation? activeRecitation;
  final bool playOnSelect;
  final bool forSurahPlayer;
  final ValueChanged<QuranRecitation>? onSurahPlayerChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
      ),
      child: ReciterPickerContent(
        currentAyah: currentAyah,
        currentRecitationId: currentRecitationId,
        activeRecitation: activeRecitation,
        playOnSelect: playOnSelect,
        forSurahPlayer: forSurahPlayer,
        onSurahPlayerChanged: onSurahPlayerChanged,
        showDragHandle: true,
      ),
    );
  }
}

/// المحتوى الرئيسي لقائمة اختيار القراء مع البحث والتقسيم وتفويض التبديل السلس.
class ReciterPickerContent extends ConsumerStatefulWidget {
  const ReciterPickerContent({
    super.key,
    this.currentAyah,
    this.currentRecitationId,
    this.activeRecitation,
    this.playOnSelect = false,
    this.forSurahPlayer = false,
    this.onSurahPlayerChanged,
    this.showDragHandle = true,
  });

  final AyahRef? currentAyah;
  final int? currentRecitationId;
  final QuranRecitation? activeRecitation;
  final bool playOnSelect;
  final bool forSurahPlayer;
  final ValueChanged<QuranRecitation>? onSurahPlayerChanged;
  final bool showDragHandle;

  @override
  ConsumerState<ReciterPickerContent> createState() =>
      _ReciterPickerContentState();
}

class _ReciterPickerContentState extends ConsumerState<ReciterPickerContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onReciterSelected(QuranRecitation recitation) {
    if (widget.forSurahPlayer) {
      if (widget.onSurahPlayerChanged != null) {
        widget.onSurahPlayerChanged!(recitation);
      }
      Navigator.of(context).pop();
      return;
    }

    ref.read(selectedQuranRecitationProvider.notifier).state = recitation;
    Navigator.of(context).pop();

    unawaited(() async {
      await ref
          .read(appUserPreferencesProvider.notifier)
          .setPreferredReciter(recitation);

      final audioController = ref.read(quranAudioControllerProvider.notifier);
      final audioState = ref.read(quranAudioControllerProvider);
      final wasActive = audioState.isPlaying || audioState.isLoading;

      // ⚡ تبديل فوري وسلس للقارئ الجديد مع مسح كاش الآيات القديمة
      await audioController.switchReciter(
        newRecitationId: recitation.id,
        fallbackAyah: widget.currentAyah,
        autoPlay: widget.playOnSelect || wasActive,
      );
    }());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showDragHandle) ...[
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختيار القارئ',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.forSurahPlayer
                              ? 'اختر قارئ الاستماع لسور القرآن الكريم'
                              : 'اختر القارئ لتلاوة الآيات الكريمة',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.textSecondary,
                    ),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: AppSearchBar(
                controller: _searchController,
                hintText: 'ابحث عن قارئ...',
                height: 44,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Divider(height: 1, color: colors.border.withValues(alpha: 0.15)),
            Flexible(
              child: _RecitersListBody(
                query: _searchQuery,
                forSurahPlayer: widget.forSurahPlayer,
                activeRecitationId: widget.forSurahPlayer
                    ? widget.activeRecitation?.id
                    : widget.currentRecitationId,
                onSelect: _onReciterSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecitersListBody extends ConsumerWidget {
  const _RecitersListBody({
    required this.query,
    required this.forSurahPlayer,
    required this.activeRecitationId,
    required this.onSelect,
  });

  final String query;
  final bool forSurahPlayer;
  final int? activeRecitationId;
  final ValueChanged<QuranRecitation> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.semanticColors;
    final preferencesAsync = ref.watch(appUserPreferencesProvider);
    final selectedRecitation = ref.watch(selectedQuranRecitationProvider);

    final preferredReciterId = preferencesAsync.maybeWhen(
      data: (p) => p.preferredReciterId,
      orElse: () => null,
    );

    final effectiveActiveId =
        activeRecitationId ?? selectedRecitation?.id ?? preferredReciterId;

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
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          ),
          data: (recitations) {
            final capable = recitations.where((r) {
              return forSurahPlayer ? r.hasSurahAudio : r.hasAyahAudio;
            }).toList();

            final filtered = _filterRecitations(capable, query);

            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    query.isEmpty
                        ? 'لا توجد قراءات متاحة.'
                        : 'لا توجد نتائج مطابقة للبحث.',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              );
            }

            final items = groupAndBuildReciterItems(filtered);

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is ReciterSectionItem) {
                  return ReciterSectionHeader(header: item);
                }

                final recitation = item as QuranRecitation;
                final isSelected = recitation.id == effectiveActiveId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ReciterPickerTile(
                    key: ValueKey(recitation.id),
                    recitation: recitation,
                    isSelected: isSelected,
                    onTap: () => onSelect(recitation),
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
