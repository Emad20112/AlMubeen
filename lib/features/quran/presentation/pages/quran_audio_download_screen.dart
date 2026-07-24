import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranAudioDownloadScreen extends ConsumerStatefulWidget {
  const QuranAudioDownloadScreen({super.key});

  static const String routePath = '/quran/audio-download';

  @override
  ConsumerState<QuranAudioDownloadScreen> createState() =>
      _QuranAudioDownloadScreenState();
}

class _QuranAudioDownloadScreenState
    extends ConsumerState<QuranAudioDownloadScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final preferencesAsync = ref.watch(appUserPreferencesProvider);
    final selectedRecitation = ref.watch(selectedQuranRecitationProvider);
    final downloadState = ref.watch(quranAudioDownloadProvider);
    final preferredReciterId = preferencesAsync.maybeWhen(
      data: (preferences) => preferences.preferredReciterId,
      orElse: () => null,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
        body: SafeArea(
          child: Column(
            children: [
              IslamicHeader(
                title: 'المكتبة الصوتية',
                subtitle: 'اختر قارئًا واجعله الافتراضي أو نزّل التلاوة كاملة.',
                leading: IconButton(
                  tooltip: 'رجوع',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark
                        ? AppColors.parchmentLight
                        : AppColors.maroon800,
                  ),
                ),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        (isDark
                                ? AppColors.goldenAccentDark
                                : AppColors.maroon800)
                            .withValues(alpha: isDark ? 0.16 : 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.headphones_rounded,
                    color: isDark
                        ? AppColors.goldenAccentDark
                        : AppColors.maroon800,
                    size: 21,
                  ),
                ),
              ),
              Expanded(
                child: recitationsAsync.when(
                  loading: () => const _AudioLibraryLoadingView(),
                  error: (error, stackTrace) => _AudioLibraryMessageView(
                    icon: Icons.wifi_off_rounded,
                    title: 'تعذر تحميل قائمة القراء',
                    message:
                        'تحقق من الاتصال بالإنترنت ثم أعد المحاولة لعرض مكتبة الاستماع.',
                    actionLabel: 'إعادة المحاولة',
                    onAction: () => ref.invalidate(quranRecitationsProvider),
                  ),
                  data: (recitations) {
                    if (recitations.isEmpty) {
                      return _AudioLibraryMessageView(
                        icon: Icons.record_voice_over_outlined,
                        title: 'لا توجد تلاوات متاحة الآن',
                        message: 'جرّب تحديث القائمة بعد قليل.',
                        actionLabel: 'تحديث',
                        onAction: () =>
                            ref.invalidate(quranRecitationsProvider),
                      );
                    }

                    final effectiveSelected = _resolveSelectedRecitation(
                      recitations: recitations,
                      selectedRecitation: selectedRecitation,
                      preferredReciterId: preferredReciterId,
                    );

                    if (selectedRecitation == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        ref
                                .read(selectedQuranRecitationProvider.notifier)
                                .state =
                            effectiveSelected;
                      });
                    }

                    final filteredRecitations = _filterRecitations(
                      recitations,
                      _query,
                    );

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(quranRecitationsProvider);
                        await ref.read(quranRecitationsProvider.future);
                      },
                      child: ListView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 680),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _RecitersToolbarCard(
                                    controller: _searchController,
                                    query: _query,
                                    resultCount: filteredRecitations.length,
                                    totalCount: recitations.length,
                                    onQueryChanged: (value) {
                                      setState(() => _query = value);
                                    },
                                    onClearQuery: () {
                                      setState(() {
                                        _query = '';
                                        _searchController.clear();
                                      });
                                    },
                                    onOpenReader: () =>
                                        openSurahPickerAndReader(context),
                                  ),
                                  if (downloadState.status !=
                                      QuranAudioDownloadStatus.idle) ...[
                                    const SizedBox(height: 14),
                                    _ActiveDownloadBanner(state: downloadState),
                                  ],
                                  const SizedBox(height: 14),
                                  if (filteredRecitations.isEmpty)
                                    _EmptyRecitersView(
                                      onReset: () {
                                        setState(() {
                                          _query = '';
                                          _searchController.clear();
                                        });
                                      },
                                    )
                                  else ...[
                                    for (
                                      var i = 0;
                                      i < filteredRecitations.length;
                                      i++
                                    ) ...[
                                      _ReciterCard(
                                        recitation: filteredRecitations[i],
                                        isSelected:
                                            filteredRecitations[i].id ==
                                            effectiveSelected.id,
                                        isDownloadTarget:
                                            downloadState.recitationId ==
                                            filteredRecitations[i].id,
                                        hasAnotherActiveDownload:
                                            downloadState.isActiveDownload &&
                                            downloadState.recitationId !=
                                                null &&
                                            downloadState.recitationId !=
                                                filteredRecitations[i].id,
                                        isDownloading:
                                            downloadState.isDownloading &&
                                            downloadState.recitationId ==
                                                filteredRecitations[i].id,
                                        isPaused:
                                            downloadState.isPaused &&
                                            downloadState.recitationId ==
                                                filteredRecitations[i].id,
                                        onTap: () => _selectRecitation(
                                          filteredRecitations[i],
                                        ),
                                        onDownload: () => _downloadForReciter(
                                          filteredRecitations[i],
                                        ),
                                      ),
                                      if (i != filteredRecitations.length - 1)
                                        const SizedBox(height: 10),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  QuranRecitation _resolveSelectedRecitation({
    required List<QuranRecitation> recitations,
    required QuranRecitation? selectedRecitation,
    required int? preferredReciterId,
  }) {
    if (selectedRecitation != null) {
      for (final recitation in recitations) {
        if (recitation.id == selectedRecitation.id) {
          return recitation;
        }
      }
    }

    if (preferredReciterId != null) {
      for (final recitation in recitations) {
        if (recitation.id == preferredReciterId) {
          return recitation;
        }
      }
    }

    return recitations.first;
  }

  List<QuranRecitation> _filterRecitations(
    List<QuranRecitation> recitations,
    String rawQuery,
  ) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return recitations;

    return recitations.where((recitation) {
      return [
        recitation.reciterName,
        recitation.translatedName,
        recitation.style,
        recitation.languageName,
      ].any((value) {
        final normalized = value?.toLowerCase();
        return normalized != null && normalized.contains(query);
      });
    }).toList();
  }

  void _selectRecitation(QuranRecitation recitation) {
    ref.read(selectedQuranRecitationProvider.notifier).state = recitation;
    ref
        .read(appUserPreferencesProvider.notifier)
        .setPreferredReciter(recitation);
  }

  void _downloadForReciter(QuranRecitation recitation) {
    _selectRecitation(recitation);
    final controller = ref.read(quranAudioDownloadProvider.notifier);
    final state = ref.read(quranAudioDownloadProvider);

    if (state.isPaused && state.recitationId == recitation.id) {
      controller.resumeDownload();
      return;
    }

    if (state.isActiveDownload) {
      return;
    }

    controller.downloadFullQuran(recitation: recitation);
  }
}

class _RecitersToolbarCard extends StatelessWidget {
  const _RecitersToolbarCard({
    required this.controller,
    required this.query,
    required this.resultCount,
    required this.totalCount,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onOpenReader,
  });

  final TextEditingController controller;
  final String query;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final VoidCallback onOpenReader;

  @override
  Widget build(BuildContext context) {
    return _SoftSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'المكتبة الصوتية',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'اختر قارئك المفضل أو نزّل التلاوة كاملة للاستماع دون اتصال.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _mutedColor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClearQuery,
                      icon: const Icon(Icons.clear_rounded),
                      tooltip: 'مسح البحث',
                    ),
              hintText: 'ابحث عن قارئ...',
              filled: true,
              fillColor: _fieldColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'عرض $resultCount من $totalCount قارئ',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _mutedColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenReader,
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text('فتح المصحف'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveDownloadBanner extends ConsumerWidget {
  const _ActiveDownloadBanner({required this.state});

  final QuranAudioDownloadState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = state.status == QuranAudioDownloadStatus.failed
        ? Theme.of(context).colorScheme.error
        : (isDark ? AppColors.goldenAccentDark : AppColors.maroon800);

    return _SoftSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  state.isPaused
                      ? Icons.pause_rounded
                      : state.status == QuranAudioDownloadStatus.completed
                      ? Icons.check_rounded
                      : state.status == QuranAudioDownloadStatus.failed
                      ? Icons.info_outline_rounded
                      : Icons.downloading_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.reciterName == null || state.reciterName!.isEmpty
                          ? 'حالة التنزيل'
                          : 'تنزيل: ${state.reciterName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.message ?? 'متابعة حالة التنزيل الحالية.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _mutedColor(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: state.totalCount == 0
                ? null
                : state.progress.clamp(0.0, 1.0).toDouble(),
            minHeight: 7,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(
                icon: Icons.done_all_rounded,
                text: '${state.completedCount} / ${state.totalCount}',
              ),
              if (state.currentVerse.isNotEmpty)
                _MiniChip(
                  icon: Icons.graphic_eq_rounded,
                  text: state.currentVerse,
                ),
            ],
          ),
          if (state.isDownloading || state.isPaused) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (state.isDownloading)
                  TextButton.icon(
                    onPressed: () {
                      ref
                          .read(quranAudioDownloadProvider.notifier)
                          .pauseDownload();
                    },
                    icon: const Icon(Icons.pause_rounded, size: 18),
                    label: const Text('إيقاف مؤقت'),
                  ),
                if (state.isPaused)
                  TextButton.icon(
                    onPressed: () {
                      ref
                          .read(quranAudioDownloadProvider.notifier)
                          .resumeDownload();
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('استئناف'),
                  ),
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(quranAudioDownloadProvider.notifier)
                        .cancelDownload();
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('إلغاء'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReciterCard extends StatelessWidget {
  const _ReciterCard({
    required this.recitation,
    required this.isSelected,
    required this.isDownloadTarget,
    required this.hasAnotherActiveDownload,
    required this.isDownloading,
    required this.isPaused,
    required this.onTap,
    required this.onDownload,
  });

  final QuranRecitation recitation;
  final bool isSelected;
  final bool isDownloadTarget;
  final bool hasAnotherActiveDownload;
  final bool isDownloading;
  final bool isPaused;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isSelected
        ? (isDark ? AppColors.goldenAccentDark : AppColors.maroon800)
        : (isDark ? AppColors.parchmentMuted : AppColors.maroon700);
    final buttonLabel = isPaused
        ? 'استئناف'
        : isDownloading
        ? 'قيد التنزيل'
        : 'تنزيل كامل';
    final buttonIcon = isPaused
        ? Icons.play_arrow_rounded
        : isDownloading
        ? Icons.downloading_rounded
        : Icons.download_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: isSelected ? 0.26 : 0.10),
          width: isSelected ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent.withValues(alpha: isDark ? 0.24 : 0.16),
                              accent.withValues(alpha: isDark ? 0.12 : 0.08),
                            ],
                          ),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Icon(
                          Icons.mic_none_rounded,
                          color: accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    recitation.reciterName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'الافتراضي',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: accent,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _reciterSubtitle(recitation),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _mutedColor(context),
                                    height: 1.35,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.touch_app_rounded,
                                  size: 15,
                                  color: accent.withValues(alpha: 0.84),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isSelected
                                        ? 'محدد حاليًا للاستماع داخل التطبيق'
                                        : 'اضغط لاختيار هذا القارئ للاستماع',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: accent.withValues(alpha: 0.84),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: FilledButton.tonalIcon(
                    onPressed: (hasAnotherActiveDownload || isDownloading)
                        ? null
                        : onDownload,
                    icon: Icon(buttonIcon, size: 18),
                    label: Text(buttonLabel, textAlign: TextAlign.center),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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

class _EmptyRecitersView extends StatelessWidget {
  const _EmptyRecitersView({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return _SoftSurface(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا توجد نتائج مطابقة',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'جرّب تعديل اسم القارئ أو امسح البحث لعرض جميع القراء.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: _mutedColor(context)),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onReset,
            icon: const Icon(Icons.clear_all_rounded),
            label: const Text('مسح البحث'),
          ),
        ],
      ),
    );
  }
}

class _AudioLibraryLoadingView extends StatelessWidget {
  const _AudioLibraryLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _SoftSurface(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'جاري تجهيز مكتبة القراء',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
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

class _AudioLibraryMessageView extends StatelessWidget {
  const _AudioLibraryMessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: _SoftSurface(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 38,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _mutedColor(context),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(actionLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftSurface extends StatelessWidget {
  const _SoftSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppColors.parchmentMuted.withValues(alpha: 0.14)
              : AppColors.maroon700.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _fieldColor(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _mutedColor(context)),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

String _reciterSubtitle(QuranRecitation recitation) {
  final parts = <String>[];
  if (recitation.translatedName != null &&
      recitation.translatedName!.trim().isNotEmpty &&
      recitation.translatedName!.trim() != recitation.reciterName.trim()) {
    parts.add(recitation.translatedName!.trim());
  }
  if (recitation.style != null && recitation.style!.trim().isNotEmpty) {
    parts.add(recitation.style!.trim());
  }
  if (recitation.languageName != null &&
      recitation.languageName!.trim().isNotEmpty) {
    parts.add(recitation.languageName!.trim());
  }
  return parts.isEmpty
      ? 'تلاوة كاملة متاحة للاستماع والتنزيل.'
      : parts.join(' • ');
}

Color _mutedColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.parchmentMuted : AppColors.maroon700;
}

Color _fieldColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? AppColors.darkSurfaceHigh.withValues(alpha: 0.72)
      : AppColors.parchment.withValues(alpha: 0.84);
}
