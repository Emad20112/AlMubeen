import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/application/translation_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/translation_download_progress_banner.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/translation_empty_views.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/translation_fallback_notice.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/translation_filter_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/translation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// جسم مكتبة الترجمات: تنبيه الاحتياط ← شريط التقدم ← البحث/الفلترة ← القائمة.
///
/// يحتفظ بحالة البحث والفلترة محليًا (نطاق ضيّق) فلا يُعاد بناء الشاشة
/// بأكملها عند كل حرف، ويحصر مسؤولية الشاشة في جلب الحالة فقط.
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

    return Column(
      children: [
        if (widget.showFallbackNotice)
          TranslationFallbackNotice(onRetry: widget.onRetry),
        if (widget.downloadState.isActiveDownload)
          TranslationDownloadProgressBanner(state: widget.downloadState),
        TranslationFilterBar(
          controller: _searchController,
          filter: _filter,
          resultCount: filtered.length,
          totalCount: widget.translations.length,
          onQueryChanged: (value) => setState(() => _searchQuery = value),
          onFilterChanged: (value) => setState(() => _filter = value),
        ),
        Expanded(
          child: filtered.isEmpty
              ? TranslationEmptyResults(onClearFilters: _resetFilters)
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

                    return TranslationTile(
                      key: ValueKey(translation.id),
                      translation: translation,
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
