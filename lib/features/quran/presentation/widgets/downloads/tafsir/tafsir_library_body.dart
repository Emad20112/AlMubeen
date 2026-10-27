import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/application/tafsir_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_download_progress_banner.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_empty_views.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_fallback_notice.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_filter_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// خيارات فلترة مكتبة التفاسير.
enum TafsirLibraryFilter { all, downloaded, notDownloaded }

/// جسم مكتبة التفاسير المعتمد على المكونات المشتركة الموحدة.
class TafsirLibraryBody extends ConsumerStatefulWidget {
  const TafsirLibraryBody({
    super.key,
    required this.tafsirs,
    required this.downloadedTafsirIds,
    required this.selectedTafsirId,
    required this.downloadState,
    required this.showFallbackNotice,
    required this.onRetry,
  });

  final List<Tafsir> tafsirs;
  final Set<int> downloadedTafsirIds;
  final int? selectedTafsirId;
  final TafsirDownloadState downloadState;
  final bool showFallbackNotice;
  final VoidCallback onRetry;

  @override
  ConsumerState<TafsirLibraryBody> createState() => _TafsirLibraryBodyState();
}

class _TafsirLibraryBodyState extends ConsumerState<TafsirLibraryBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TafsirLibraryFilter _filter = TafsirLibraryFilter.all;

  static const _filterOptions = [
    FilterOption(value: TafsirLibraryFilter.all, label: 'الكل'),
    FilterOption(value: TafsirLibraryFilter.downloaded, label: 'المحمّل'),
    FilterOption(
      value: TafsirLibraryFilter.notDownloaded,
      label: 'غير المحمّل',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _filter = TafsirLibraryFilter.all;
      _searchController.clear();
    });
  }

  Future<void> _handleTafsirTap(Tafsir tafsir) async {
    final isDownloaded = widget.downloadedTafsirIds.contains(tafsir.id);
    if (isDownloaded) {
      ref.read(selectedTafsirProvider.notifier).state = tafsir.id;
      Navigator.pop(context);
      return;
    }

    if (widget.downloadState.isActiveDownload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يوجد تنزيل للتفسير جارٍ بالفعل.')),
      );
      return;
    }

    final success = await ref
        .read(tafsirDownloadControllerProvider.notifier)
        .downloadTafsirBook(tafsir: tafsir, selectOnComplete: true);

    if (!mounted) {
      return;
    }

    if (success) {
      ref.read(selectedTafsirProvider.notifier).state = tafsir.id;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterTafsirs();
    final downloadController = ref.read(
      tafsirDownloadControllerProvider.notifier,
    );

    return Column(
      children: [
        if (widget.showFallbackNotice)
          ResourceFallbackNotice(
            message:
                'تعذر تحميل القائمة الكاملة. تم عرض التفاسير المحفوظة محليًا فقط.',
            onRetry: widget.onRetry,
          ),
        if (widget.downloadState.isActiveDownload)
          ResourceDownloadProgressBanner(
            title: widget.downloadState.message ?? 'جاري تنزيل التفسير...',
            progress: widget.downloadState.progress,
            progressDetail:
                'السورة ${widget.downloadState.currentChapter ?? 0} من ${widget.downloadState.totalChapters}',
            isDownloading: widget.downloadState.isDownloading,
            isPaused: widget.downloadState.isPaused,
            onPause: downloadController.pauseDownload,
            onResume: downloadController.resumeDownload,
            onCancel: downloadController.cancelDownload,
          ),
        ResourceFilterBar<TafsirLibraryFilter>(
          controller: _searchController,
          hintText: 'ابحث عن تفسير أو مفسر...',
          resultCount: filtered.length,
          totalCount: widget.tafsirs.length,
          countUnit: 'تفسير',
          selectedFilter: _filter,
          filterOptions: _filterOptions,
          onQueryChanged: (value) => setState(() => _searchQuery = value),
          onFilterChanged: (value) => setState(() => _filter = value),
        ),
        Expanded(
          child: filtered.isEmpty
              ? ResourceEmptyResults(onClearFilters: _resetFilters)
              : ListView.builder(
                  padding: AppSpacing.all(AppSpacing.screenPadding),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final tafsir = filtered[index];
                    final isDownloadingCurrent =
                        widget.downloadState.isDownloading &&
                        widget.downloadState.resourceId == tafsir.id;
                    final isPausedCurrent =
                        widget.downloadState.isPaused &&
                        widget.downloadState.resourceId == tafsir.id;

                    return ResourceTile(
                      key: ValueKey(tafsir.id),
                      title: tafsir.name,
                      subtitle: tafsir.resourceName,
                      author: tafsir.authorName != null
                          ? 'المفسر: ${tafsir.authorName!}'
                          : null,
                      additionalInfo:
                          tafsir.translatedAuthorName != null &&
                              tafsir.translatedAuthorName != tafsir.authorName
                          ? tafsir.translatedAuthorName
                          : null,
                      leadingIcon: Icons.menu_book_rounded,
                      downloadTooltip: 'تنزيل التفسير',
                      isSelected: tafsir.id == widget.selectedTafsirId,
                      isDownloaded: widget.downloadedTafsirIds.contains(
                        tafsir.id,
                      ),
                      isDownloading: isDownloadingCurrent,
                      isPaused: isPausedCurrent,
                      downloadProgress:
                          (isDownloadingCurrent || isPausedCurrent)
                          ? widget.downloadState.progress
                          : null,
                      onTap: () => _handleTafsirTap(tafsir),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Tafsir> _filterTafsirs() {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    return widget.tafsirs.where((tafsir) {
      final isDownloaded = widget.downloadedTafsirIds.contains(tafsir.id);
      final matchesFilter = switch (_filter) {
        TafsirLibraryFilter.all => true,
        TafsirLibraryFilter.downloaded => isDownloaded,
        TafsirLibraryFilter.notDownloaded => !isDownloaded,
      };

      if (!matchesFilter) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      return _containsQuery(normalizedQuery, [
        tafsir.name,
        tafsir.authorName,
        tafsir.translatedAuthorName,
        tafsir.resourceName,
        tafsir.slug,
        tafsir.languageName,
      ]);
    }).toList();
  }

  bool _containsQuery(String query, Iterable<String?> values) {
    return values.any((value) {
      final normalized = value?.toLowerCase();
      return normalized != null && normalized.contains(query);
    });
  }
}
