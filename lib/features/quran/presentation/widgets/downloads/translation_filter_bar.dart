import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/widgets/app_search_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/compact_filter_chip.dart';
import 'package:flutter/material.dart';

/// فلتر مكتبة الترجمات: الكل / المحمّل / غير المحمّل.
enum TranslationLibraryFilter { all, downloaded, notDownloaded }

/// شريط البحث والفلترة لشاشة تحميل الترجمات.
///
/// يعتمد على [AppSearchBar] الموحّد (بحوافه الكبسولية والألوان الدلالية)
/// بدل حقل `TextField` المخصص القديم، وعلى [CompactFilterChip] المشتركة.
class TranslationFilterBar extends StatelessWidget {
  const TranslationFilterBar({
    super.key,
    required this.controller,
    required this.filter,
    required this.resultCount,
    required this.totalCount,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final TranslationLibraryFilter filter;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<TranslationLibraryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return Padding(
      padding: AppSpacing.directional(
        start: AppSpacing.screenPadding,
        top: AppSpacing.md,
        end: AppSpacing.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchBar(
            controller: controller,
            hintText: 'ابحث عن ترجمة أو مترجم',
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$resultCount من $totalCount ترجمة',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CompactFilterChip(
                label: 'الكل',
                isSelected: filter == TranslationLibraryFilter.all,
                onTap: () => onFilterChanged(TranslationLibraryFilter.all),
              ),
              const SizedBox(width: AppSpacing.sm),
              CompactFilterChip(
                label: 'المحمّل',
                isSelected: filter == TranslationLibraryFilter.downloaded,
                onTap: () =>
                    onFilterChanged(TranslationLibraryFilter.downloaded),
              ),
              const SizedBox(width: AppSpacing.sm),
              CompactFilterChip(
                label: 'غير المحمّل',
                isSelected: filter == TranslationLibraryFilter.notDownloaded,
                onTap: () =>
                    onFilterChanged(TranslationLibraryFilter.notDownloaded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
