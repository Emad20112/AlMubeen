import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/audio/reciter_card.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_download_progress_banner.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_empty_views.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_filter_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// جسم مكتبة التلاوات الصوتية والتنزيلات.
///
/// يدير حالة البحث محلياً ويستفيد من المكونات الموحدة:
/// [ResourceFilterBar] و [ResourceDownloadProgressBanner] و [ResourceEmptyResults].
class AudioDownloadLibraryBody extends ConsumerStatefulWidget {
  const AudioDownloadLibraryBody({
    super.key,
    required this.recitations,
    required this.selectedRecitation,
    required this.downloadState,
  });

  final List<QuranRecitation> recitations;
  final QuranRecitation selectedRecitation;
  final QuranAudioDownloadState downloadState;

  @override
  ConsumerState<AudioDownloadLibraryBody> createState() =>
      _AudioDownloadLibraryBodyState();
}

class _AudioDownloadLibraryBodyState
    extends ConsumerState<AudioDownloadLibraryBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearQuery() {
    setState(() {
      _query = '';
      _searchController.clear();
    });
  }

  void _selectRecitation(QuranRecitation recitation) {
    ref.read(selectedQuranRecitationProvider.notifier).state = recitation;
    ref
        .read(appUserPreferencesProvider.notifier)
        .setPreferredReciter(recitation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار القارئ: ${recitation.reciterName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _downloadForReciter(QuranRecitation recitation) {
    final controller = ref.read(quranAudioDownloadProvider.notifier);
    if (widget.downloadState.isActiveDownload &&
        widget.downloadState.recitationId == recitation.id) {
      if (widget.downloadState.isPaused) {
        controller.resumeDownload();
      } else {
        controller.pauseDownload();
      }
      return;
    }
    controller.downloadFullQuran(recitation: recitation);
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecitations = _filterRecitations(widget.recitations, _query);
    final downloadState = widget.downloadState;
    final downloadController = ref.read(quranAudioDownloadProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(quranRecitationsProvider);
        await ref.read(quranRecitationsProvider.future);
      },
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResourceFilterBar<void>(
                    controller: _searchController,
                    hintText: 'ابحث عن قارئ...',
                    resultCount: filteredRecitations.length,
                    totalCount: widget.recitations.length,
                    countUnit: 'قارئ',
                    onQueryChanged: (value) => setState(() => _query = value),
                    trailingAction: FilledButton.tonalIcon(
                      onPressed: () => openSurahPickerAndReader(context),
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: const Text('المصحف'),
                    ),
                  ),
                  if (downloadState.status !=
                      QuranAudioDownloadStatus.idle) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ResourceDownloadProgressBanner(
                      title:
                          downloadState.reciterName == null ||
                              downloadState.reciterName!.isEmpty
                          ? 'حالة التنزيل'
                          : 'تنزيل: ${downloadState.reciterName}',
                      subtitle: downloadState.message,
                      progress: downloadState.totalCount == 0
                          ? 0.0
                          : (downloadState.completedCount /
                                downloadState.totalCount),
                      progressDetail:
                          '${downloadState.completedCount} من ${downloadState.totalCount} ملف',
                      isDownloading: downloadState.isDownloading,
                      isPaused: downloadState.isPaused,
                      isFailed:
                          downloadState.status ==
                          QuranAudioDownloadStatus.failed,
                      onPause: downloadController.pauseDownload,
                      onResume: downloadController.resumeDownload,
                      onCancel: downloadController.cancelDownload,
                      onRetry: downloadController.resumeDownload,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (filteredRecitations.isEmpty)
                    ResourceEmptyResults(
                      title: 'لا يوجد قارئ بهذا الاسم',
                      message: 'جرّب كتابة جزء من اسم القارئ أو مسح البحث.',
                      onClearFilters: _clearQuery,
                    )
                  else ...[
                    for (final recitation in filteredRecitations) ...[
                      ReciterCard(
                        key: ValueKey(recitation.id),
                        recitation: recitation,
                        isSelected:
                            recitation.id == widget.selectedRecitation.id,
                        isDownloadTarget:
                            downloadState.recitationId == recitation.id,
                        hasAnotherActiveDownload:
                            downloadState.isActiveDownload &&
                            downloadState.recitationId != null &&
                            downloadState.recitationId != recitation.id,
                        isDownloading:
                            downloadState.isDownloading &&
                            downloadState.recitationId == recitation.id,
                        isPaused:
                            downloadState.isPaused &&
                            downloadState.recitationId == recitation.id,
                        onTap: () => _selectRecitation(recitation),
                        onDownload: () => _downloadForReciter(recitation),
                      ),
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
  }

  List<QuranRecitation> _filterRecitations(
    List<QuranRecitation> source,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return source;
    return source.where((r) {
      final name = r.reciterName.toLowerCase();
      final style = (r.style ?? '').toLowerCase();
      final translated = (r.translatedName ?? '').toLowerCase();
      return name.contains(trimmed) ||
          style.contains(trimmed) ||
          translated.contains(trimmed);
    }).toList();
  }
}
