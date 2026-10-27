import 'package:al_mubeen/core/widgets/app_state_views.dart';
import 'package:flutter/material.dart';

/// حالة «لا نتائج مطابقة» بعد تطبيق البحث أو الفلترة.
///
/// تعتمد [AppEmptyStateView] الموحّدة بدل الحاوية المخصّصة القديمة،
/// فيصبح الشكل متطابقًا مع بقية الشاشات.
class TranslationEmptyResults extends StatelessWidget {
  const TranslationEmptyResults({super.key, required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return AppEmptyStateView(
      icon: Icons.search_off_rounded,
      title: 'لا توجد نتائج مطابقة',
      message: 'جرّب تعديل البحث أو مسح الفلترة لإظهار جميع الترجمات.',
      actionLabel: 'إظهار الكل',
      onAction: onClearFilters,
    );
  }
}

/// حالة عدم توفّر أي ترجمة من المصدر (مع إمكانية إعادة المحاولة).
class TranslationEmptyMessage extends StatelessWidget {
  const TranslationEmptyMessage({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.translate_rounded,
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
