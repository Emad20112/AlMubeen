import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
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
  String? _selectedStyle;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final selectedRecitation = ref.watch(selectedQuranRecitationProvider);
    final downloadState = ref.watch(quranAudioDownloadProvider);
    final normalizedQuery = _query.trim().toLowerCase();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('استماع القرآن الكريم')),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = math.min(constraints.maxWidth, 760.0);

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: maxWidth,
                  child: recitationsAsync.when(
                    loading: () => const _AudioScreenLoading(),
                    error: (error, stackTrace) => _AudioScreenMessage(
                      icon: Icons.wifi_off_rounded,
                      title: 'لم تصل قائمة القراء',
                      message:
                          'تأكد من الاتصال ثم جرّب مرة أخرى. سنعيد المحاولة بهدوء.',
                      actionLabel: 'إعادة المحاولة',
                      onAction: () => ref.invalidate(quranRecitationsProvider),
                    ),
                    data: (recitations) {
                      if (recitations.isEmpty) {
                        return _AudioScreenMessage(
                          icon: Icons.record_voice_over_outlined,
                          title: 'لا توجد تلاوات الآن',
                          message: 'جرّب تحديث القائمة بعد قليل.',
                          actionLabel: 'تحديث',
                          onAction: () =>
                              ref.invalidate(quranRecitationsProvider),
                        );
                      }

                      final filteredRecitations = _filterRecitations(
                        recitations,
                        normalizedQuery,
                        _selectedStyle,
                      );
                      final visibleRecitations = filteredRecitations.isEmpty
                          ? recitations
                          : filteredRecitations;
                      final activeRecitation = _activeRecitation(
                        visibleRecitations,
                        selectedRecitation,
                      );

                      if (selectedRecitation == null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) {
                            return;
                          }
                          ref
                                  .read(
                                    selectedQuranRecitationProvider.notifier,
                                  )
                                  .state =
                              activeRecitation;
                        });
                      }

                      return CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            sliver: SliverList.list(
                              children: [
                                const _ListeningHero(),
                                const SizedBox(height: 14),
                                _RecitationSearchFilterBar(
                                  controller: _searchController,
                                  query: _query,
                                  availableStyles: _recitationStyles(
                                    recitations,
                                  ),
                                  selectedStyle: _selectedStyle,
                                  resultCount: filteredRecitations.length,
                                  totalCount: recitations.length,
                                  onQueryChanged: (value) {
                                    setState(() {
                                      _query = value;
                                    });
                                  },
                                  onClearQuery: () {
                                    setState(() {
                                      _query = '';
                                      _searchController.clear();
                                    });
                                  },
                                  onStyleChanged: (style) {
                                    setState(() {
                                      _selectedStyle = style;
                                    });
                                  },
                                ),
                                const SizedBox(height: 14),
                                _RecitationPickerCard(
                                  recitations: filteredRecitations,
                                  activeRecitation: activeRecitation,
                                  onClearFilters: _resetRecitationFilters,
                                  onChanged: (recitation) {
                                    ref
                                            .read(
                                              selectedQuranRecitationProvider
                                                  .notifier,
                                            )
                                            .state =
                                        recitation;
                                  },
                                ),
                                const SizedBox(height: 14),
                                _HowToListenCard(
                                  onOpenReader: () =>
                                      openSurahPickerAndReader(context),
                                ),
                                const SizedBox(height: 14),
                                _OfflineDownloadCard(
                                  recitation: activeRecitation,
                                  downloadState: downloadState,
                                  onDownload: downloadState.isDownloading
                                      ? null
                                      : () {
                                          ref
                                              .read(
                                                quranAudioDownloadProvider
                                                    .notifier,
                                              )
                                              .downloadFullQuran(
                                                recitation: activeRecitation,
                                              );
                                        },
                                ),
                                if (downloadState.status !=
                                    QuranAudioDownloadStatus.idle) ...[
                                  const SizedBox(height: 14),
                                  _DownloadStatusCard(state: downloadState),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
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

  void _resetRecitationFilters() {
    setState(() {
      _query = '';
      _selectedStyle = null;
      _searchController.clear();
    });
  }

  List<QuranRecitation> _filterRecitations(
    List<QuranRecitation> recitations,
    String normalizedQuery,
    String? selectedStyle,
  ) {
    return recitations.where((recitation) {
      if (selectedStyle != null && recitation.style != selectedStyle) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      return _containsQuery(normalizedQuery, [
        recitation.reciterName,
        recitation.translatedName,
        recitation.style,
        recitation.languageName,
        _recitationLabel(recitation),
      ]);
    }).toList();
  }

  bool _containsQuery(String query, Iterable<String?> values) {
    return values.any((value) {
      final normalized = value?.toLowerCase();
      return normalized != null && normalized.contains(query);
    });
  }

  List<String> _recitationStyles(List<QuranRecitation> recitations) {
    final styles = recitations
        .map((recitation) => recitation.style?.trim())
        .where((style) => style != null && style.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    styles.sort(
      (left, right) =>
          _recitationStyleLabel(left).compareTo(_recitationStyleLabel(right)),
    );
    return styles;
  }
}

class _ListeningHero extends StatelessWidget {
  const _ListeningHero();

  @override
  Widget build(BuildContext context) {
    return _AudioSurface(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const _LargeIconBadge(icon: Icons.headphones_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استمع للآية من المصحف',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر القارئ، افتح السورة، ثم اضغط مطولًا على أي آية لتشغيلها.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _mutedColor(context),
                    height: 1.35,
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

class _RecitationPickerCard extends StatelessWidget {
  const _RecitationPickerCard({
    required this.recitations,
    required this.activeRecitation,
    required this.onClearFilters,
    required this.onChanged,
  });

  final List<QuranRecitation> recitations;
  final QuranRecitation activeRecitation;
  final VoidCallback onClearFilters;
  final ValueChanged<QuranRecitation> onChanged;

  @override
  Widget build(BuildContext context) {
    if (recitations.isEmpty) {
      return _AudioSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionHeader(
              icon: Icons.search_off_rounded,
              title: 'لا توجد نتائج مطابقة',
              subtitle: 'جرّب تعديل البحث أو أزل فلتر النمط لعرض جميع القراء.',
            ),
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('مسح البحث والفلترة'),
            ),
          ],
        ),
      );
    }

    return _AudioSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.record_voice_over_outlined,
            title: 'القارئ المختار',
            subtitle: 'يمكن تغييره قبل تشغيل الآية أو من النافذة المنبثقة.',
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: activeRecitation.id,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.mic_external_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: _fieldColor(context),
              labelText: 'اختر صوت القارئ',
            ),
            items: [
              for (final recitation in recitations)
                DropdownMenuItem<int>(
                  value: recitation.id,
                  child: Text(
                    _recitationLabel(recitation),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (recitationId) {
              if (recitationId == null) return;
              onChanged(
                recitations.firstWhere(
                  (recitation) => recitation.id == recitationId,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _InlineHint(
            icon: Icons.touch_app_outlined,
            text:
                'لمن لا يعرف القراءة: اتبع الأيقونات — مصحف ثم ضغط مطوّل ثم تشغيل.',
          ),
        ],
      ),
    );
  }
}

class _HowToListenCard extends StatelessWidget {
  const _HowToListenCard({required this.onOpenReader});

  final VoidCallback onOpenReader;

  @override
  Widget build(BuildContext context) {
    return _AudioSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.route_outlined,
            title: 'طريقة الاستماع',
            subtitle: 'ثلاث خطوات بسيطة داخل صفحة المصحف.',
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _GuidanceStep(
                  icon: Icons.menu_book_rounded,
                  title: 'افتح المصحف',
                  subtitle: 'اختر السورة',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _GuidanceStep(
                  icon: Icons.touch_app_rounded,
                  title: 'اضغط مطولًا',
                  subtitle: 'على الآية',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _GuidanceStep(
                  icon: Icons.play_circle_fill_rounded,
                  title: 'استمع',
                  subtitle: 'زر التشغيل',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onOpenReader,
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('فتح المصحف للاستماع'),
          ),
        ],
      ),
    );
  }
}

class _OfflineDownloadCard extends StatelessWidget {
  const _OfflineDownloadCard({
    required this.recitation,
    required this.downloadState,
    required this.onDownload,
  });

  final QuranRecitation recitation;
  final QuranAudioDownloadState downloadState;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final isDownloading = downloadState.isDownloading;

    return _AudioSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.offline_bolt_outlined,
            title: 'الاستماع دون إنترنت',
            subtitle: 'خيار إضافي لحفظ صوت المصحف كاملًا على الجهاز.',
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onDownload,
            icon: Icon(
              isDownloading
                  ? Icons.downloading_rounded
                  : downloadState.isPaused
                      ? Icons.pause_circle_filled_rounded
                      : Icons.cloud_download_outlined,
            ),
            label: Text(
              isDownloading
                  ? 'يتم الحفظ الآن...'
                  : downloadState.isPaused
                      ? 'تنزيل معلّق'
                      : 'حفظ المصحف بصوت ${_shortRecitationName(recitation)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadStatusCard extends ConsumerWidget {
  const _DownloadStatusCard({required this.state});

  final QuranAudioDownloadState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusIcon = switch (state.status) {
      QuranAudioDownloadStatus.completed => Icons.check_circle_rounded,
      QuranAudioDownloadStatus.failed => Icons.info_outline_rounded,
      QuranAudioDownloadStatus.downloading => Icons.downloading_rounded,
      QuranAudioDownloadStatus.paused => Icons.pause_circle_outline_rounded,
      QuranAudioDownloadStatus.cancelled => Icons.cancel_rounded,
      QuranAudioDownloadStatus.idle => Icons.cloud_download_outlined,
    };
    final statusColor = state.status == QuranAudioDownloadStatus.failed
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    final progress = state.totalCount == 0
        ? null
        : state.progress.clamp(0.0, 1.0).toDouble();

    return _AudioSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.message ?? 'متابعة حالة الحفظ',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                icon: Icons.done_all_rounded,
                text: '${state.completedCount} / ${state.totalCount}',
              ),
              if (state.currentVerse.isNotEmpty)
                _StatusChip(icon: Icons.graphic_eq, text: state.currentVerse),
            ],
          ),
          if (state.isDownloading || state.isPaused) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (state.isDownloading && !state.isPaused)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(quranAudioDownloadProvider.notifier).pauseDownload();
                    },
                    icon: const Icon(Icons.pause_rounded, size: 18),
                    label: const Text('إيقاف مؤقت'),
                  ),
                if (state.isPaused)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(quranAudioDownloadProvider.notifier).resumeDownload();
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('استئناف'),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    ref.read(quranAudioDownloadProvider.notifier).cancelDownload();
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
          if (state.errorMessage != null) ...[
            const SizedBox(height: 10),
            _InlineHint(
              icon: Icons.info_outline_rounded,
              text: 'تعذر حفظ بعض الملفات. يمكنك المحاولة مرة أخرى لاحقًا.',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }
}

class _AudioScreenLoading extends StatelessWidget {
  const _AudioScreenLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _AudioSurface(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _LargeIconBadge(icon: Icons.record_voice_over_outlined),
              const SizedBox(height: 16),
              Text(
                'جاري تجهيز أصوات القراء',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
              const SizedBox(height: 10),
              Text(
                'ثوانٍ قليلة ونفتح لك باب الاستماع.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _mutedColor(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioScreenMessage extends StatelessWidget {
  const _AudioScreenMessage({
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
        child: _AudioSurface(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LargeIconBadge(icon: icon),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor(context)),
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
    );
  }
}

class _AudioSurface extends StatelessWidget {
  const _AudioSurface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.parchmentLight;
    final borderColor = isDark
        ? AppColors.parchmentMuted.withValues(alpha: 0.16)
        : AppColors.maroon700.withValues(alpha: 0.18);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon900.withValues(alpha: isDark ? 0.22 : 0.09),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _LargeIconBadge extends StatelessWidget {
  const _LargeIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final foreground = isDark ? AppColors.maroon800 : AppColors.parchmentLight;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: foreground, size: 30),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _mutedColor(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecitationSearchFilterBar extends StatelessWidget {
  const _RecitationSearchFilterBar({
    required this.controller,
    required this.query,
    required this.availableStyles,
    required this.selectedStyle,
    required this.resultCount,
    required this.totalCount,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onStyleChanged,
  });

  final TextEditingController controller;
  final String query;
  final List<String> availableStyles;
  final String? selectedStyle;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String?> onStyleChanged;

  @override
  Widget build(BuildContext context) {
    return _AudioSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.manage_search_rounded,
            title: 'البحث والفلترة',
            subtitle: 'ابحث عن قارئ أو قيّد النتائج بالنمط.',
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
              labelText: 'ابحث عن قارئ',
              hintText: 'مثال: السديس، الحصري، عبد الباسط...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: _fieldColor(context),
            ),
          ),
          if (availableStyles.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'فلترة حسب النمط',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('الكل'),
                  selected: selectedStyle == null,
                  onSelected: (_) => onStyleChanged(null),
                ),
                for (final style in availableStyles)
                  ChoiceChip(
                    label: Text(_recitationStyleLabel(style)),
                    selected: selectedStyle == style,
                    onSelected: (_) => onStyleChanged(style),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'عرض $resultCount من $totalCount قارئ',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _mutedColor(context)),
          ),
        ],
      ),
    );
  }
}

class _GuidanceStep extends StatelessWidget {
  const _GuidanceStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _fieldColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: _mutedColor(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineHint extends StatelessWidget {
  const _InlineHint({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _mutedColor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: effectiveColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: effectiveColor),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _fieldColor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
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
  if (style != null) {
    return '${recitation.reciterName} - $style';
  }
  return recitation.reciterName;
}

String _shortRecitationName(QuranRecitation recitation) {
  return recitation.translatedName ?? recitation.reciterName;
}

String _recitationStyleLabel(String style) {
  final normalized = style.toLowerCase().trim();
  return switch (normalized) {
    'murattal' => 'مرتل',
    'mujawwad' => 'مجود',
    'warsh' => 'ورش',
    'hafs' => 'حفص',
    'mushaf' => 'مصحف',
    _ => style,
  };
}

Color _fieldColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? AppColors.darkSurface
      : AppColors.parchment;
}

Color _mutedColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68);
}
