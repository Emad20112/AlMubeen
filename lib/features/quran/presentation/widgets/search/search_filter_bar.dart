import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/compact_filter_chip.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/search/search_models.dart';
import 'package:flutter/material.dart';

/// شريط رقائق تصفية نتائج البحث القرآني.
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final SearchFilter activeFilter;
  final ValueChanged<SearchFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.15)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (final filter in SearchFilter.values) ...[
              CompactFilterChip(
                label: filter.label,
                isSelected: activeFilter == filter,
                onTap: () => onFilterChanged(filter),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}
