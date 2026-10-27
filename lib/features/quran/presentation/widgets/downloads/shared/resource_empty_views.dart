import 'package:al_mubeen/core/widgets/app_state_views.dart';
import 'package:flutter/material.dart';

/// حالة «لا توجد نتائج مطابقة» موحدة للبحث والفلترة.
class ResourceEmptyResults extends StatelessWidget {
  const ResourceEmptyResults({
    super.key,
    required this.onClearFilters,
    this.title = 'لا توجد نتائج مطابقة',
    this.message = 'جرّب تعديل البحث أو مسح الفلترة لإظهار جميع العناصر.',
    this.actionLabel = 'إظهار الكل',
  });

  final VoidCallback onClearFilters;
  final String title;
  final String message;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return AppEmptyStateView(
      icon: Icons.search_off_rounded,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onClearFilters,
    );
  }
}

/// حالة فارغة أو تعذر التحميل موحدة مع زر إجراء.
class ResourceEmptyMessage extends StatelessWidget {
  const ResourceEmptyMessage({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.inbox_rounded,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppEmptyStateView(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
