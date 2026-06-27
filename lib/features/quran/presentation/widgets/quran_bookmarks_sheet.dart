import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

Future<void> showQuranBookmarksSheet({
  required BuildContext context,
  required int currentPage,
  required ValueChanged<int> onPageSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _QuranBookmarksSheet(
        currentPage: currentPage,
        onPageSelected: onPageSelected,
      );
    },
  );
}

class _QuranBookmarksSheet extends ConsumerWidget {
  const _QuranBookmarksSheet({
    required this.currentPage,
    required this.onPageSelected,
  });

  final int currentPage;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final bookmarksAsync = ref.watch(quranBookmarksProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.maroon800.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'المحفوظات',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await ref
                            .read(quranBookmarkServiceProvider)
                            .togglePageBookmark(page: currentPage);
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('إضافة الصفحة الحالية'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bookmarksAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                  error: (error, stackTrace) => Center(
                    child: Text('تعذر تحميل المحفوظات'),
                  ),
                  data: (bookmarks) {
                    if (bookmarks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'لا توجد محفوظات بعد.\nيمكنك إضافة الصفحة الحالية أو حفظ آية من الضغط المطول.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: bookmarks.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];
                        return _BookmarkTile(
                          bookmark: bookmark,
                          onOpen: () {
                            Navigator.of(context).pop();
                            onPageSelected(bookmark.page);
                          },
                          onDelete: () async {
                            await ref
                                .read(quranBookmarkServiceProvider)
                                .removeBookmark(bookmark.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.bookmark,
    required this.onOpen,
    required this.onDelete,
  });

  final QuranBookmarkEntry bookmark;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final label = bookmark.label ??
        '${getSurahNameArabic(bookmark.surahNumber)} • صفحة ${bookmark.page}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.maroon800.withValues(alpha: 0.1),
        child: Icon(
          bookmark.ayahNumber != null
              ? Icons.bookmark_rounded
              : Icons.bookmark_outline_rounded,
          color: AppColors.maroon800,
        ),
      ),
      title: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('صفحة ${bookmark.page}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: onDelete,
      ),
      onTap: onOpen,
    );
  }
}
