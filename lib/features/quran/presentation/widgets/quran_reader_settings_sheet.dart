import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_library_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showQuranReaderSettingsSheet({
  required BuildContext context,
  required int currentPage,
  required ValueNotifier<bool> isTajweedListenable,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _QuranReaderSettingsSheet(
        parentContext: context,
        currentPage: currentPage,
        isTajweedListenable: isTajweedListenable,
      );
    },
  );
}

class _QuranReaderSettingsSheet extends ConsumerStatefulWidget {
  const _QuranReaderSettingsSheet({
    required this.parentContext,
    required this.currentPage,
    required this.isTajweedListenable,
  });

  final BuildContext parentContext;
  final int currentPage;
  final ValueNotifier<bool> isTajweedListenable;

  @override
  ConsumerState<_QuranReaderSettingsSheet> createState() =>
      _QuranReaderSettingsSheetState();
}

class _QuranReaderSettingsSheetState
    extends ConsumerState<_QuranReaderSettingsSheet> {
  bool? _isPageBookmarked;

  @override
  void initState() {
    super.initState();
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    final isBookmarked = await ref
        .read(quranBookmarkServiceProvider)
        .isBookmarked(page: widget.currentPage);
    if (mounted) {
      setState(() => _isPageBookmarked = isBookmarked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.maroon800.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'خيارات القراءة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: widget.isTajweedListenable,
              builder: (context, isTajweed, child) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تفعيل التجويد'),
                  subtitle: const Text('عرض ألوان التجويد على صفحات المصحف'),
                  value: isTajweed,
                  onChanged: (value) {
                    widget.isTajweedListenable.value = value;
                  },
                );
              },
            ),
            if (_isPageBookmarked != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('حفظ الصفحة الحالية'),
                subtitle: Text('صفحة ${widget.currentPage}'),
                value: _isPageBookmarked!,
                onChanged: (value) async {
                  await ref
                      .read(quranBookmarkServiceProvider)
                      .togglePageBookmark(page: widget.currentPage);
                  await _loadBookmarkState();
                },
              ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('حجم خط المصحف'),
              subtitle: Text('قريباً — يعتمد على خط QCF'),
              trailing: Icon(Icons.tune_rounded),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('المكتبة'),
              subtitle: const Text('القرّاء، التفاسير، الترجمات، الأحاديث'),
              trailing: const Icon(Icons.local_library_rounded),
              onTap: () {
                Navigator.of(context).pop();
                showQuranLibrarySheet(context: widget.parentContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}
