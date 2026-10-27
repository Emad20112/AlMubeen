import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/widgets/app_search_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/compact_filter_chip.dart';
import 'package:flutter/material.dart';

/// عنصر خيار الفلترة الموحد.
class FilterOption<T> {
  const FilterOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// شريط بحث وفلترة عام عالي الأداء للمكتبات والتنزيلات (Generic Resource Filter Bar).
///
/// يدعم:
/// - حقل البحث الموحد [AppSearchBar].
/// - خيارات فلترة ديناميكية ومدمجة عبر [CompactFilterChip].
/// - عداد النتائج بصيغة مخصصة (مثل: "X من Y ترجمة/تفسير/قارئ").
/// - ودجت إجراء إضافي اختياري في نهاية الصف (مثل زر "فتح المصحف").
class ResourceFilterBar<T> extends StatelessWidget {
  const ResourceFilterBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.resultCount,
    required this.totalCount,
    required this.countUnit,
    required this.onQueryChanged,
    this.selectedFilter,
    this.filterOptions = const [],
    this.onFilterChanged,
    this.trailingAction,
  });

  final TextEditingController controller;
  final String hintText;
  final int resultCount;
  final int totalCount;
  final String countUnit;
  final ValueChanged<String> onQueryChanged;
  final T? selectedFilter;
  final List<FilterOption<T>> filterOptions;
  final ValueChanged<T>? onFilterChanged;
  final Widget? trailingAction;

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
            hintText: hintText,
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$resultCount من $totalCount $countUnit',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (filterOptions.isNotEmpty && onFilterChanged != null) ...[
                for (var i = 0; i < filterOptions.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  CompactFilterChip(
                    label: filterOptions[i].label,
                    isSelected: filterOptions[i].value == selectedFilter,
                    onTap: () => onFilterChanged!(filterOptions[i].value),
                  ),
                ],
              ],
              if (trailingAction != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailingAction!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
