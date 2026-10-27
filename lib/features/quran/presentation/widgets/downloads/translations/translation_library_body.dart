import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/application/translation_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_download_progress_banner.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_empty_views.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_fallback_notice.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_filter_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// خيارات فلترة مكتبة الترجمات.
enum TranslationLibraryFilter { all, downloaded, notDownloaded }

/// جسم مكتبة الترجمات المعتمد على المكونات المشتركة الموحدة.
class TranslationLibraryBody extends ConsumerStatefulWidget {
  const TranslationLibraryBody({
    super.key,
    required this.translations,
    required this.downloadedTranslationIds,
    required this.selectedTranslationId,
    required this.downloadState,
    required this.showFallbackNotice,
    required this.onRetry,
  });

  final List<Translation> translations;
  final Set<int> downloadedTranslationIds;
  final int? selectedTranslationId;
  final TranslationDownloadState downloadState;
  final bool showFallbackNotice;
  final VoidCallback onRetry;

  @override
  ConsumerState<TranslationLibraryBody> createState() =>
      _TranslationLibraryBodyState();
}

class _TranslationLibraryBodyState
    extends ConsumerState<TranslationLibraryBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TranslationLibraryFilter _filter = TranslationLibraryFilter.all;

  static const _filterOptions = [
    FilterOption(value: TranslationLibraryFilter.all, label: 'الكل'),
    FilterOption(value: TranslationLibraryFilter.downloaded, label: 'المحمّل'),
    FilterOption(
      value: TranslationLibraryFilter.notDownloaded,
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
      _filter = TranslationLibraryFilter.all;
      _searchController.clear();
    });
  }

  Future<void> _handleTranslationTap(Translation translation) async {
    final isDownloaded = widget.downloadedTranslationIds.contains(
      translation.id,
    );
    if (isDownloaded) {
      ref.read(selectedTranslationProvider.notifier).state = translation.id;
      Navigator.pop(context);
      return;
    }

    if (widget.downloadState.isActiveDownload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يوجد تنزيل لترجمة جارٍ بالفعل.')),
      );
      return;
    }

    final success = await ref
        .read(translationDownloadControllerProvider.notifier)
        .downloadTranslationBook(
          translation: translation,
          selectOnComplete: true,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      ref.read(selectedTranslationProvider.notifier).state = translation.id;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterTranslations();
    final downloadController = ref.read(
      translationDownloadControllerProvider.notifier,
    );

    return Column(
      children: [
        if (widget.showFallbackNotice)
          ResourceFallbackNotice(
            message:
                'تعذر تحميل القائمة الكاملة. تم عرض الترجمات المحفوظة محليًا فقط.',
            onRetry: widget.onRetry,
          ),
        if (widget.downloadState.isActiveDownload)
          ResourceDownloadProgressBanner(
            title: widget.downloadState.message ?? 'جاري تنزيل الترجمة...',
            progress: widget.downloadState.progress,
            progressDetail:
                'السورة ${widget.downloadState.currentChapter ?? 0} من ${widget.downloadState.totalChapters}',
            isDownloading: widget.downloadState.isDownloading,
            isPaused: widget.downloadState.isPaused,
            onPause: downloadController.pauseDownload,
            onResume: downloadController.resumeDownload,
            onCancel: downloadController.cancelDownload,
          ),
        ResourceFilterBar<TranslationLibraryFilter>(
          controller: _searchController,
          hintText: 'ابحث عن ترجمة أو مترجم...',
          resultCount: filtered.length,
          totalCount: widget.translations.length,
          countUnit: 'ترجمة',
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
                    final translation = filtered[index];
                    final isDownloadingCurrent =
                        widget.downloadState.isDownloading &&
                        widget.downloadState.resourceId == translation.id;
                    final isPausedCurrent =
                        widget.downloadState.isPaused &&
                        widget.downloadState.resourceId == translation.id;

                    return ResourceTile(
                      key: ValueKey(translation.id),
                      title: translation.name,
                      subtitle: translation.resourceName,
                      author: translation.authorName != null
                          ? 'المترجم: ${translation.authorName!}'
                          : null,
                      additionalInfo:
                          translation.translatedAuthorName != null &&
                              translation.translatedAuthorName !=
                                  translation.authorName
                          ? translation.translatedAuthorName
                          : null,
                      leadingIcon: Icons.translate_rounded,
                      downloadTooltip: 'تنزيل الترجمة',
                      isSelected:
                          translation.id == widget.selectedTranslationId,
                      isDownloaded: widget.downloadedTranslationIds.contains(
                        translation.id,
                      ),
                      isDownloading: isDownloadingCurrent,
                      isPaused: isPausedCurrent,
                      downloadProgress:
                          (isDownloadingCurrent || isPausedCurrent)
                          ? widget.downloadState.progress
                          : null,
                      onTap: () => _handleTranslationTap(translation),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Translation> _filterTranslations() {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    return widget.translations.where((translation) {
      final isDownloaded = widget.downloadedTranslationIds.contains(
        translation.id,
      );
      final matchesFilter = switch (_filter) {
        TranslationLibraryFilter.all => true,
        TranslationLibraryFilter.downloaded => isDownloaded,
        TranslationLibraryFilter.notDownloaded => !isDownloaded,
      };

      if (!matchesFilter) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      return _containsQuery(normalizedQuery, [
        translation.name,
        translation.authorName,
        translation.translatedAuthorName,
        translation.resourceName,
        translation.slug,
        translation.languageName,
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
