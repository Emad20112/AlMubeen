import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/tafsir_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TafsirDownloadScreen extends ConsumerStatefulWidget {
  const TafsirDownloadScreen({super.key});

  static const String routeName = '/tafsir-download';

  @override
  ConsumerState<TafsirDownloadScreen> createState() =>
      _TafsirDownloadScreenState();
}

class _TafsirDownloadScreenState extends ConsumerState<TafsirDownloadScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _TafsirLibraryFilter _filter = _TafsirLibraryFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tafsirsAsync = ref.watch(tafsirsProvider);
    final downloadedTafsirsAsync = ref.watch(downloadedTafsirsProvider);
    final downloadState = ref.watch(tafsirDownloadControllerProvider);
    final selectedTafsirId = ref.watch(selectedTafsirProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      appBar: AppBar(
        title: const Text('تحميل التفاسير'),
        backgroundColor: isDark ? const Color(0xFF1A1210) : AppColors.maroon800,
        foregroundColor: isDark
            ? const Color(0xFFD8B457)
            : AppColors.parchmentLight,
        elevation: 0,
      ),
      body: tafsirsAsync.when(
        loading: () {
          final downloadedTafsirs = downloadedTafsirsAsync.maybeWhen(
            data: (tafsirs) => tafsirs,
            orElse: () => <Tafsir>[],
          );

          if (downloadedTafsirs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!downloadedTafsirs.any(
                (tafsir) => tafsir.id == selectedTafsirId,
              ) &&
              !downloadState.isActiveDownload) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              ref.read(selectedTafsirProvider.notifier).state =
                  downloadedTafsirs.first.id;
            });
          }

          return _buildTafsirLibraryBody(
            context: context,
            isDark: isDark,
            tafsirs: downloadedTafsirs,
            downloadedTafsirIds: downloadedTafsirs
                .map((tafsir) => tafsir.id)
                .toSet(),
            selectedTafsirId: selectedTafsirId,
            downloadState: downloadState,
            showFallbackNotice: true,
            onRetry: () => ref.invalidate(tafsirsProvider),
          );
        },
        error: (error, stack) {
          final downloadedTafsirs = downloadedTafsirsAsync.maybeWhen(
            data: (tafsirs) => tafsirs,
            orElse: () => <Tafsir>[],
          );

          if (downloadedTafsirs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ أثناء تحميل التفاسير',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(tafsirsProvider),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (!downloadedTafsirs.any(
                (tafsir) => tafsir.id == selectedTafsirId,
              ) &&
              !downloadState.isActiveDownload) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              ref.read(selectedTafsirProvider.notifier).state =
                  downloadedTafsirs.first.id;
            });
          }

          return _buildTafsirLibraryBody(
            context: context,
            isDark: isDark,
            tafsirs: downloadedTafsirs,
            downloadedTafsirIds: downloadedTafsirs
                .map((tafsir) => tafsir.id)
                .toSet(),
            selectedTafsirId: selectedTafsirId,
            downloadState: downloadState,
            showFallbackNotice: true,
            onRetry: () => ref.invalidate(tafsirsProvider),
          );
        },
        data: (tafsirs) {
          if (tafsirs.isEmpty) {
            final downloadedTafsirs = downloadedTafsirsAsync.maybeWhen(
              data: (tafsirs) => tafsirs,
              orElse: () => <Tafsir>[],
            );

            if (downloadedTafsirs.isNotEmpty) {
              if (!downloadedTafsirs.any(
                    (tafsir) => tafsir.id == selectedTafsirId,
                  ) &&
                  !downloadState.isActiveDownload) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) {
                    return;
                  }
                  ref.read(selectedTafsirProvider.notifier).state =
                      downloadedTafsirs.first.id;
                });
              }

              return _buildTafsirLibraryBody(
                context: context,
                isDark: isDark,
                tafsirs: downloadedTafsirs,
                downloadedTafsirIds: downloadedTafsirs
                    .map((tafsir) => tafsir.id)
                    .toSet(),
                selectedTafsirId: selectedTafsirId,
                downloadState: downloadState,
                showFallbackNotice: true,
                onRetry: () => ref.invalidate(tafsirsProvider),
              );
            }

            return _TafsirEmptyMessage(
              isDark: isDark,
              icon: Icons.menu_book_outlined,
              title: 'لا توجد تفاسير متاحة',
              message: 'جرّب تحديث القائمة بعد قليل.',
              actionLabel: 'إعادة المحاولة',
              onAction: () => ref.invalidate(tafsirsProvider),
            );
          }

          if (!tafsirs.any((tafsir) => tafsir.id == selectedTafsirId) &&
              !downloadState.isActiveDownload) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              ref.read(selectedTafsirProvider.notifier).state =
                  tafsirs.first.id;
            });
          }

          return _buildTafsirLibraryBody(
            context: context,
            isDark: isDark,
            tafsirs: tafsirs,
            downloadedTafsirIds: downloadedTafsirsAsync.maybeWhen(
              data: (tafsirs) => tafsirs.map((tafsir) => tafsir.id).toSet(),
              orElse: () => <int>{},
            ),
            selectedTafsirId: selectedTafsirId,
            downloadState: downloadState,
            showFallbackNotice: false,
            onRetry: () => ref.invalidate(tafsirsProvider),
          );
        },
      ),
    );
  }

  Widget _buildTafsirLibraryBody({
    required BuildContext context,
    required bool isDark,
    required List<Tafsir> tafsirs,
    required Set<int> downloadedTafsirIds,
    required int? selectedTafsirId,
    required TafsirDownloadState downloadState,
    required bool showFallbackNotice,
    required VoidCallback onRetry,
  }) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredTafsirs = _filterTafsirs(
      tafsirs,
      downloadedTafsirIds,
      normalizedQuery,
    );

    return Column(
      children: [
        if (showFallbackNotice) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF2B201C) : AppColors.maroon800)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      (isDark ? const Color(0xFFD8B457) : AppColors.maroon800)
                          .withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    color: isDark
                        ? const Color(0xFFD8B457)
                        : AppColors.maroon800,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تعذر تحميل القائمة الكاملة. تم عرض التفاسير المحفوظة محليًا فقط.',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(onPressed: onRetry, child: const Text('إعادة')),
                ],
              ),
            ),
          ),
        ],
        if (downloadState.isActiveDownload)
          _TafsirDownloadProgressBanner(state: downloadState),
        _TafsirSearchFilterBar(
          isDark: isDark,
          controller: _searchController,
          query: _searchQuery,
          filter: _filter,
          resultCount: filteredTafsirs.length,
          totalCount: tafsirs.length,
          onQueryChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onClearQuery: () {
            setState(() {
              _searchQuery = '';
              _searchController.clear();
            });
          },
          onFilterChanged: (value) {
            setState(() {
              _filter = value;
            });
          },
        ),
        Expanded(
          child: filteredTafsirs.isEmpty
              ? _TafsirEmptyResults(
                  isDark: isDark,
                  onClearFilters: _resetTafsirFilters,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTafsirs.length,
                  itemBuilder: (context, index) {
                    final tafsir = filteredTafsirs[index];
                    final isSelected = tafsir.id == selectedTafsirId;
                    final isDownloaded = downloadedTafsirIds.contains(
                      tafsir.id,
                    );
                    final isDownloadingCurrent =
                        downloadState.isDownloading &&
                        downloadState.resourceId == tafsir.id;
                    final isPausedCurrent =
                        downloadState.isPaused &&
                        downloadState.resourceId == tafsir.id;

                    return _TafsirTile(
                      tafsir: tafsir,
                      isSelected: isSelected,
                      isDownloaded: isDownloaded,
                      isDownloading: isDownloadingCurrent,
                      isPaused: isPausedCurrent,
                      downloadProgress:
                          (isDownloadingCurrent || isPausedCurrent)
                          ? downloadState.progress
                          : null,
                      onTap: () async {
                        if (isDownloaded) {
                          ref.read(selectedTafsirProvider.notifier).state =
                              tafsir.id;
                          Navigator.pop(context);
                          return;
                        }

                        if (downloadState.isActiveDownload) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يوجد تنزيل للتفسير جارٍ بالفعل.'),
                            ),
                          );
                          return;
                        }

                        final success = await ref
                            .read(tafsirDownloadControllerProvider.notifier)
                            .downloadTafsirBook(
                              tafsir: tafsir,
                              selectOnComplete: true,
                            );

                        if (!context.mounted) {
                          return;
                        }

                        if (success) {
                          ref.read(selectedTafsirProvider.notifier).state =
                              tafsir.id;
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Tafsir> _filterTafsirs(
    List<Tafsir> tafsirs,
    Set<int> downloadedTafsirIds,
    String normalizedQuery,
  ) {
    return tafsirs.where((tafsir) {
      final isDownloaded = downloadedTafsirIds.contains(tafsir.id);
      final matchesFilter = switch (_filter) {
        _TafsirLibraryFilter.all => true,
        _TafsirLibraryFilter.downloaded => isDownloaded,
        _TafsirLibraryFilter.notDownloaded => !isDownloaded,
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

  void _resetTafsirFilters() {
    setState(() {
      _searchQuery = '';
      _filter = _TafsirLibraryFilter.all;
      _searchController.clear();
    });
  }
}

enum _TafsirLibraryFilter { all, downloaded, notDownloaded }

class _TafsirSearchFilterBar extends StatelessWidget {
  const _TafsirSearchFilterBar({
    required this.isDark,
    required this.controller,
    required this.query,
    required this.filter,
    required this.resultCount,
    required this.totalCount,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onFilterChanged,
  });

  final bool isDark;
  final TextEditingController controller;
  final String query;
  final _TafsirLibraryFilter filter;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<_TafsirLibraryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF231A17) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.manage_search_rounded, color: accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'البحث والفلترة',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ابحث عن تفسير أو مفسر ثم اختر حالة العرض.',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                hintText: 'ابحث عن تفسير أو مفسر',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2B201C)
                    : AppColors.parchment,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('الكل'),
                  selected: filter == _TafsirLibraryFilter.all,
                  onSelected: (_) => onFilterChanged(_TafsirLibraryFilter.all),
                ),
                ChoiceChip(
                  label: const Text('المحمّل'),
                  selected: filter == _TafsirLibraryFilter.downloaded,
                  onSelected: (_) =>
                      onFilterChanged(_TafsirLibraryFilter.downloaded),
                ),
                ChoiceChip(
                  label: const Text('غير المحمّل'),
                  selected: filter == _TafsirLibraryFilter.notDownloaded,
                  onSelected: (_) =>
                      onFilterChanged(_TafsirLibraryFilter.notDownloaded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'عرض $resultCount من $totalCount كتاب',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TafsirEmptyResults extends StatelessWidget {
  const _TafsirEmptyResults({
    required this.isDark,
    required this.onClearFilters,
  });

  final bool isDark;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF231A17) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 52, color: accentColor),
              const SizedBox(height: 16),
              Text(
                'لا توجد نتائج مطابقة',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'جرّب تعديل البحث أو مسح الفلترة لإظهار جميع التفاسير.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('إظهار الكل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TafsirEmptyMessage extends StatelessWidget {
  const _TafsirEmptyMessage({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF231A17) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: accentColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
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

class _TafsirDownloadProgressBanner extends ConsumerWidget {
  const _TafsirDownloadProgressBanner({required this.state});

  final TafsirDownloadState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2B201C)
            : AppColors.maroon800.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD8B457).withValues(alpha: 0.25)
              : AppColors.maroon800.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.message ?? 'جاري تنزيل التفسير...',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (state.isPaused)
                Icon(
                  Icons.pause_circle_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: state.progress),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السورة ${state.currentChapter ?? 0} من ${state.totalChapters}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              Text(
                '${(state.progress * 100).toInt()}%',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (state.isDownloading && !state.isPaused)
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(tafsirDownloadControllerProvider.notifier)
                        .pauseDownload();
                  },
                  icon: const Icon(Icons.pause_rounded, size: 18),
                  label: const Text('إيقاف مؤقت'),
                ),
              if (state.isPaused)
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(tafsirDownloadControllerProvider.notifier)
                        .resumeDownload();
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('استئناف'),
                ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(tafsirDownloadControllerProvider.notifier)
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
      ),
    );
  }
}

class _TafsirTile extends StatelessWidget {
  const _TafsirTile({
    required this.tafsir,
    required this.isSelected,
    required this.isDownloaded,
    required this.isDownloading,
    required this.isPaused,
    required this.downloadProgress,
    required this.onTap,
  });

  final Tafsir tafsir;
  final bool isSelected;
  final bool isDownloaded;
  final bool isDownloading;
  final bool isPaused;
  final double? downloadProgress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final statusWidgets = <Widget>[];
    Widget trailingWidget = const SizedBox.shrink();

    if (isDownloading) {
      statusWidgets.addAll([
        const SizedBox(height: 8),
        LinearProgressIndicator(value: downloadProgress),
        const SizedBox(height: 4),
        Text(
          'جاري التنزيل...',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 12,
          ),
        ),
      ]);
      trailingWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
        ),
      );
    } else if (isPaused) {
      statusWidgets.addAll([
        const SizedBox(height: 8),
        LinearProgressIndicator(value: downloadProgress),
        const SizedBox(height: 4),
        Text(
          'متوقف مؤقتًا',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 12,
          ),
        ),
      ]);
      trailingWidget = Icon(
        Icons.pause_circle_outline_rounded,
        color: primaryColor,
        size: 24,
      );
    } else if (isDownloaded) {
      statusWidgets.addAll([
        const SizedBox(height: 4),
        Text(
          'محمّل محليًا',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 12,
          ),
        ),
      ]);
      trailingWidget = Icon(
        Icons.download_done_rounded,
        color: primaryColor,
        size: 24,
      );
    } else {
      trailingWidget = IconButton(
        icon: const Icon(Icons.download_rounded),
        color: primaryColor,
        tooltip: 'تنزيل التفسير',
        onPressed: onTap,
      );
    }

    if (isSelected && isDownloaded) {
      trailingWidget = Icon(Icons.check_circle, color: primaryColor, size: 24);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.menu_book, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tafsir.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tafsir.resourceName != null &&
                        tafsir.resourceName != tafsir.name) ...[
                      const SizedBox(height: 4),
                      Text(
                        tafsir.resourceName!,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (tafsir.authorName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'المفسر: ${tafsir.authorName!}',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (tafsir.translatedAuthorName != null &&
                        tafsir.translatedAuthorName != tafsir.authorName) ...[
                      const SizedBox(height: 2),
                      Text(
                        tafsir.translatedAuthorName!,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    ...statusWidgets,
                  ],
                ),
              ),
              trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}
