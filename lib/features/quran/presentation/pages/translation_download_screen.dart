import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/translation_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationDownloadScreen extends ConsumerStatefulWidget {
  const TranslationDownloadScreen({super.key});

  static const String routeName = '/translation-download';

  @override
  ConsumerState<TranslationDownloadScreen> createState() =>
      _TranslationDownloadScreenState();
}

class _TranslationDownloadScreenState
    extends ConsumerState<TranslationDownloadScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _TranslationLibraryFilter _filter = _TranslationLibraryFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final translationsAsync = ref.watch(translationsProvider);
    final downloadedTranslationsAsync = ref.watch(
      downloadedTranslationsProvider,
    );
    final downloadState = ref.watch(translationDownloadControllerProvider);
    final selectedTranslationId = ref.watch(selectedTranslationProvider);
    final downloadedTranslations = downloadedTranslationsAsync.maybeWhen(
      data: (translations) => translations,
      orElse: () => <Translation>[],
    );
    final downloadedTranslationIds = downloadedTranslations
        .map((translation) => translation.id)
        .toSet();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      appBar: AppBar(
        title: const Text('تحميل الترجمات'),
        backgroundColor: isDark ? const Color(0xFF1A1210) : AppColors.maroon800,
        foregroundColor: isDark
            ? const Color(0xFFD8B457)
            : AppColors.parchmentLight,
        elevation: 0,
      ),
      body: translationsAsync.when(
        loading: () {
          if (downloadedTranslations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (selectedTranslationId == null && !downloadState.isDownloading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              ref.read(selectedTranslationProvider.notifier).state =
                  downloadedTranslations.first.id;
            });
          }

          return _buildTranslationLibraryBody(
            context: context,
            isDark: isDark,
            translations: downloadedTranslations,
            downloadedTranslationIds: downloadedTranslationIds,
            selectedTranslationId: selectedTranslationId,
            downloadState: downloadState,
            showFallbackNotice: true,
            onRetry: () => ref.invalidate(translationsProvider),
          );
        },
        error: (error, stack) {
          if (downloadedTranslations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ أثناء تحميل الترجمات',
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
                    onPressed: () => ref.invalidate(translationsProvider),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (selectedTranslationId == null && !downloadState.isDownloading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              ref.read(selectedTranslationProvider.notifier).state =
                  downloadedTranslations.first.id;
            });
          }

          return _buildTranslationLibraryBody(
            context: context,
            isDark: isDark,
            translations: downloadedTranslations,
            downloadedTranslationIds: downloadedTranslationIds,
            selectedTranslationId: selectedTranslationId,
            downloadState: downloadState,
            showFallbackNotice: true,
            onRetry: () => ref.invalidate(translationsProvider),
          );
        },
        data: (translations) {
          if (translations.isEmpty) {
            if (downloadedTranslations.isNotEmpty) {
              if (selectedTranslationId == null &&
                  !downloadState.isDownloading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) {
                    return;
                  }
                  ref.read(selectedTranslationProvider.notifier).state =
                      downloadedTranslations.first.id;
                });
              }

              return _buildTranslationLibraryBody(
                context: context,
                isDark: isDark,
                translations: downloadedTranslations,
                downloadedTranslationIds: downloadedTranslationIds,
                selectedTranslationId: selectedTranslationId,
                downloadState: downloadState,
                showFallbackNotice: true,
                onRetry: () => ref.invalidate(translationsProvider),
              );
            }

            return _TranslationEmptyMessage(
              isDark: isDark,
              icon: Icons.translate_rounded,
              title: 'لا توجد ترجمات متاحة',
              message: 'جرّب تحديث القائمة بعد قليل.',
              actionLabel: 'إعادة المحاولة',
              onAction: () => ref.invalidate(translationsProvider),
            );
          }

          if (selectedTranslationId == null && !downloadState.isDownloading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              ref.read(selectedTranslationProvider.notifier).state =
                  translations.first.id;
            });
          }

          return _buildTranslationLibraryBody(
            context: context,
            isDark: isDark,
            translations: translations,
            downloadedTranslationIds: downloadedTranslationIds,
            selectedTranslationId: selectedTranslationId,
            downloadState: downloadState,
            showFallbackNotice: false,
            onRetry: () => ref.invalidate(translationsProvider),
          );
        },
      ),
    );
  }

  Widget _buildTranslationLibraryBody({
    required BuildContext context,
    required bool isDark,
    required List<Translation> translations,
    required Set<int> downloadedTranslationIds,
    required int? selectedTranslationId,
    required TranslationDownloadState downloadState,
    required bool showFallbackNotice,
    required VoidCallback onRetry,
  }) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredTranslations = _filterTranslations(
      translations,
      downloadedTranslationIds,
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
                      'تعذر تحميل القائمة الكاملة. تم عرض الترجمات المحفوظة محليًا فقط.',
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
        if (downloadState.isDownloading)
          _TranslationDownloadProgressBanner(state: downloadState),
        _TranslationSearchFilterBar(
          isDark: isDark,
          controller: _searchController,
          query: _searchQuery,
          filter: _filter,
          resultCount: filteredTranslations.length,
          totalCount: translations.length,
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
          child: filteredTranslations.isEmpty
              ? _TranslationEmptyResults(
                  isDark: isDark,
                  onClearFilters: _resetTranslationFilters,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTranslations.length,
                  itemBuilder: (context, index) {
                    final translation = filteredTranslations[index];
                    final isSelected = translation.id == selectedTranslationId;
                    final isDownloaded = downloadedTranslationIds.contains(
                      translation.id,
                    );
                    final isDownloadingCurrent =
                        downloadState.isDownloading &&
                        downloadState.resourceId == translation.id;

                    return _TranslationTile(
                      translation: translation,
                      isSelected: isSelected,
                      isDownloaded: isDownloaded,
                      isDownloading: isDownloadingCurrent,
                      downloadProgress: isDownloadingCurrent
                          ? downloadState.progress
                          : null,
                      onTap: () async {
                        if (isDownloaded) {
                          ref.read(selectedTranslationProvider.notifier).state =
                              translation.id;
                          Navigator.pop(context);
                          return;
                        }

                        if (downloadState.isDownloading || downloadState.isPaused) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يوجد تنزيل لترجمة جارٍ بالفعل.'),
                            ),
                          );
                          return;
                        }

                        final success = await ref
                            .read(
                              translationDownloadControllerProvider.notifier,
                            )
                            .downloadTranslationBook(
                              translation: translation,
                              selectOnComplete: true,
                            );

                        if (!context.mounted) {
                          return;
                        }

                        if (success) {
                          ref.read(selectedTranslationProvider.notifier).state =
                              translation.id;
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

  List<Translation> _filterTranslations(
    List<Translation> translations,
    Set<int> downloadedTranslationIds,
    String normalizedQuery,
  ) {
    return translations.where((translation) {
      final isDownloaded = downloadedTranslationIds.contains(translation.id);
      final matchesFilter = switch (_filter) {
        _TranslationLibraryFilter.all => true,
        _TranslationLibraryFilter.downloaded => isDownloaded,
        _TranslationLibraryFilter.notDownloaded => !isDownloaded,
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

  void _resetTranslationFilters() {
    setState(() {
      _searchQuery = '';
      _filter = _TranslationLibraryFilter.all;
      _searchController.clear();
    });
  }
}

enum _TranslationLibraryFilter { all, downloaded, notDownloaded }

class _TranslationSearchFilterBar extends StatelessWidget {
  const _TranslationSearchFilterBar({
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
  final _TranslationLibraryFilter filter;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<_TranslationLibraryFilter> onFilterChanged;

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
                        'ابحث عن ترجمة أو مترجم ثم اختر حالة العرض.',
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
                hintText: 'ابحث عن ترجمة أو مترجم',
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
                  selected: filter == _TranslationLibraryFilter.all,
                  onSelected: (_) =>
                      onFilterChanged(_TranslationLibraryFilter.all),
                ),
                ChoiceChip(
                  label: const Text('المحمّل'),
                  selected: filter == _TranslationLibraryFilter.downloaded,
                  onSelected: (_) =>
                      onFilterChanged(_TranslationLibraryFilter.downloaded),
                ),
                ChoiceChip(
                  label: const Text('غير المحمّل'),
                  selected: filter == _TranslationLibraryFilter.notDownloaded,
                  onSelected: (_) =>
                      onFilterChanged(_TranslationLibraryFilter.notDownloaded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'عرض $resultCount من $totalCount ترجمة',
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

class _TranslationEmptyResults extends StatelessWidget {
  const _TranslationEmptyResults({
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
                'جرّب تعديل البحث أو مسح الفلترة لإظهار جميع الترجمات.',
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

class _TranslationEmptyMessage extends StatelessWidget {
  const _TranslationEmptyMessage({
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

class _TranslationFallbackSection extends ConsumerWidget {
  const _TranslationFallbackSection({
    required this.isDark,
    required this.selectedTranslationId,
    required this.downloadState,
    required this.downloadedTranslations,
    required this.onRetry,
  });

  final bool isDark;
  final int? selectedTranslationId;
  final TranslationDownloadState downloadState;
  final List<Translation> downloadedTranslations;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final downloadedTranslationIds = downloadedTranslations
        .map((translation) => translation.id)
        .toSet();

    if (selectedTranslationId == null &&
        downloadedTranslations.isNotEmpty &&
        !downloadState.isDownloading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        ref.read(selectedTranslationProvider.notifier).state =
            downloadedTranslations.first.id;
      });
    }

    if (downloadedTranslations.isEmpty) {
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
                Icon(Icons.translate_rounded, size: 52, color: accentColor),
                const SizedBox(height: 16),
                Text(
                  'تعذر تحميل قائمة الترجمات',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تأكد من تشغيل الخادم المحلي ثم أعد المحاولة. إذا كانت لديك ترجمات محفوظة مسبقًا فستظهر هنا تلقائيًا.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: accentColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'تعذر تحميل القائمة الكاملة. تم عرض الترجمات المحفوظة محليًا فقط.',
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
        if (downloadState.isDownloading)
          _TranslationDownloadProgressBanner(state: downloadState),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: downloadedTranslations.length,
            itemBuilder: (context, index) {
              final translation = downloadedTranslations[index];
              final isSelected = translation.id == selectedTranslationId;
              return _TranslationTile(
                translation: translation,
                isSelected: isSelected,
                isDownloaded: downloadedTranslationIds.contains(translation.id),
                isDownloading: false,
                downloadProgress: null,
                onTap: () {
                  ref.read(selectedTranslationProvider.notifier).state =
                      translation.id;
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TranslationDownloadProgressBanner extends ConsumerWidget {
  const _TranslationDownloadProgressBanner({required this.state});

  final TranslationDownloadState state;

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
                  state.message ?? 'جاري تنزيل الترجمة...',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (state.isPaused)
                Icon(Icons.pause_circle_outline, color: Theme.of(context).colorScheme.error, size: 20)
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
                    ref.read(translationDownloadControllerProvider.notifier).pauseDownload();
                  },
                  icon: const Icon(Icons.pause_rounded, size: 18),
                  label: const Text('إيقاف مؤقت'),
                ),
              if (state.isPaused)
                TextButton.icon(
                  onPressed: () {
                    ref.read(translationDownloadControllerProvider.notifier).resumeDownload();
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('استئناف'),
                ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  ref.read(translationDownloadControllerProvider.notifier).cancelDownload();
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

class _TranslationTile extends StatelessWidget {
  const _TranslationTile({
    required this.translation,
    required this.isSelected,
    required this.isDownloaded,
    required this.isDownloading,
    required this.downloadProgress,
    required this.onTap,
  });

  final Translation translation;
  final bool isSelected;
  final bool isDownloaded;
  final bool isDownloading;
  final double? downloadProgress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final statusWidgets = <Widget>[];
    Widget? trailingWidget;

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
    } else if (isDownloaded) {
      statusWidgets.addAll([
        const SizedBox(height: 4),
        Text(
          'محمّلة محليًا',
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
        tooltip: 'تنزيل الترجمة',
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
                child: Icon(
                  Icons.translate_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translation.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (translation.resourceName != null &&
                        translation.resourceName != translation.name) ...[
                      const SizedBox(height: 4),
                      Text(
                        translation.resourceName!,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (translation.authorName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'المترجم: ${translation.authorName!}',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (translation.translatedAuthorName != null &&
                        translation.translatedAuthorName !=
                            translation.authorName) ...[
                      const SizedBox(height: 2),
                      Text(
                        translation.translatedAuthorName!,
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
              if (trailingWidget != null) trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}
