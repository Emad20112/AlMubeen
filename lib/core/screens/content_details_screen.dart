import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/models/unified_content_item.dart';
import 'package:al_mubeen/core/widgets/app_error_view.dart';
import 'package:al_mubeen/core/widgets/app_loading_view.dart';
import 'package:al_mubeen/core/widgets/share_button.dart';
import 'package:al_mubeen/features/adhkar/data/adhkar_providers.dart';
import 'package:al_mubeen/features/adhkar/presentation/widgets/adhkar_text_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentDetailsScreen extends ConsumerStatefulWidget {
  const ContentDetailsScreen({
    required this.categoryId,
    required this.categoryAsync,
    required this.itemsAsync,
    this.enableProgress = false,
    this.onRetry,
    super.key,
  });

  final String categoryId;
  final AsyncValue<dynamic> categoryAsync;
  final AsyncValue<List<dynamic>> itemsAsync;
  final bool enableProgress;
  final VoidCallback? onRetry;

  @override
  ConsumerState<ContentDetailsScreen> createState() =>
      _ContentDetailsScreenState();
}

class _ContentDetailsScreenState extends ConsumerState<ContentDetailsScreen> {
  double _fontSize = 26.0;
  int _currentIndex = 0;

  final PageController _pageController = PageController();

  bool get _isProgressMode => widget.enableProgress;

  @override
  void initState() {
    super.initState();
    if (_isProgressMode) {
      Future.microtask(() {
        if (mounted) {
          ref
              .read(adhkarProgressProvider.notifier)
              .loadProgress(widget.categoryId);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectItem(int index, List<UnifiedContentItem> items) {
    if (index < 0 || index >= items.length) return;
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showFontSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AdhkarTextSettings(
              fontSize: _fontSize,
              onFontSizeChanged: (value) {
                setModalState(() => _fontSize = value);
                setState(() => _fontSize = value);
              },
            );
          },
        );
      },
    );
  }

  void _handleScreenTap(
    TapUpDetails details,
    BuildContext context,
    List<UnifiedContentItem> items,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final dx = details.localPosition.dx;

    if (dx < width * 0.3) {
      if (_currentIndex < items.length - 1) {
        _selectItem(_currentIndex + 1, items);
      }
    } else if (dx > width * 0.7) {
      if (_currentIndex > 0) {
        _selectItem(_currentIndex - 1, items);
      }
    } else if (_isProgressMode) {
      _incrementProgress(items[_currentIndex], items);
    }
  }

  void _incrementProgress(
    UnifiedContentItem item,
    List<UnifiedContentItem> items,
  ) {
    ref
        .read(adhkarProgressProvider.notifier)
        .incrementProgress(item.id, widget.categoryId, item.repeatCount);

    final newProgress = ref.read(adhkarProgressProvider)[item.id];
    final newCount = newProgress?.completedCount ?? 0;

    if (newCount == item.repeatCount && _currentIndex < items.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _selectItem(_currentIndex + 1, items);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = widget.categoryAsync;
    final itemsAsync = widget.itemsAsync;
    final progressMap = _isProgressMode
        ? ref.watch(adhkarProgressProvider)
        : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return categoryAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
        body: const AppLoadingView(
          title: 'جاري تحميل القسم',
          message: 'يتم جلب تفاصيل القسم.',
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
        body: AppErrorView(
          title: 'تعذر تحميل القسم',
          message: 'حدث خطأ غير متوقع.',
          actionLabel: 'العودة',
          onActionPressed: () => Navigator.of(context).pop(),
        ),
      ),
      data: (category) {
        if (category == null) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColors.darkScaffold
                : AppColors.parchment,
            body: AppErrorView(
              title: 'لم يتم العثور على القسم',
              message: 'تعذر تحميل هذا القسم.',
              actionLabel: 'العودة',
              onActionPressed: () => Navigator.of(context).pop(),
            ),
          );
        }

        final categoryTitle = category.title as String;

        return itemsAsync.when(
          loading: () => Scaffold(
            backgroundColor: isDark
                ? AppColors.darkScaffold
                : AppColors.parchment,
            body: const AppLoadingView(
              title: 'جاري تحميل المحتوى',
              message: 'يتم جلب النصوص.',
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            backgroundColor: isDark
                ? AppColors.darkScaffold
                : AppColors.parchment,
            body: AppErrorView(
              title: 'تعذر تحميل البيانات',
              message: 'حدث خطأ غير متوقع أثناء تحميل المحتوى.',
              actionLabel: 'إعادة المحاولة',
              onActionPressed:
                  widget.onRetry ?? () => Navigator.of(context).pop(),
            ),
          ),
          data: (rawItems) {
            if (rawItems.isEmpty) {
              return Scaffold(
                backgroundColor: isDark
                    ? AppColors.darkScaffold
                    : AppColors.parchment,
                body: AppErrorView(
                  title: 'لا يوجد محتوى',
                  message: 'لم يتم العثور على عناصر في هذا القسم.',
                  actionLabel: 'العودة',
                  onActionPressed: () => Navigator.of(context).pop(),
                ),
              );
            }

            final items = rawItems
                .map((e) => UnifiedContentItem.fromDynamic(e))
                .toList();

            return Scaffold(
              backgroundColor: isDark
                  ? AppColors.darkScaffold
                  : AppColors.parchment,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final maxWidth = switch (AdaptiveBreakpoints.fromWidth(
                      width,
                    )) {
                      AdaptiveWindowClass.compact => width,
                      AdaptiveWindowClass.medium => 720.0,
                      AdaptiveWindowClass.expanded => 820.0,
                    };
                    final side = math.max((width - maxWidth) / 2, 0.0);

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: side + 16,
                            vertical: 8,
                          ),
                          child: _buildStoryProgressBar(items.length, isDark),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: side + 8),
                          child: _buildHeader(context, categoryTitle, isDark),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTapUp: (details) =>
                                _handleScreenTap(details, context, items),
                            child: PageView.builder(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final itemProgress =
                                    _isProgressMode && progressMap != null
                                    ? progressMap[item.id]
                                    : null;
                                final completedCount =
                                    itemProgress?.completedCount ?? 0;
                                final isCompleted =
                                    itemProgress?.isCompleted ?? false;

                                return Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    side + 16,
                                    16,
                                    side + 16,
                                    16,
                                  ),
                                  child: _buildCardItem(
                                    item: item,
                                    completedCount: completedCount,
                                    isCompleted: isCompleted,
                                    isDark: isDark,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            side + 24,
                            8,
                            side + 24,
                            24,
                          ),
                          child: _buildSmallBottomNav(items),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String categoryTitle, bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            categoryTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.text_fields, size: 22),
          tooltip: 'حجم الخط',
          onPressed: () => _showFontSettings(context),
        ),
      ],
    );
  }

  Widget _buildStoryProgressBar(int totalCount, bool isDark) {
    return Row(
      children: List.generate(totalCount, (index) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 3,
            decoration: BoxDecoration(
              color: index <= _currentIndex
                  ? (isDark ? Colors.white : AppColors.maroon800)
                  : (isDark
                        ? Colors.white30
                        : AppColors.maroon800.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSmallBottomNav(List<UnifiedContentItem> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg = isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.parchmentLight;
    final fgColor = isDark ? Colors.white : AppColors.maroon800;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(
          opacity: _currentIndex > 0 ? 1.0 : 0.0,
          child: Material(
            color: buttonBg,
            borderRadius: BorderRadius.circular(30),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _currentIndex > 0
                  ? () => _selectItem(_currentIndex - 1, items)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 14, color: fgColor),
                    const SizedBox(width: 4),
                    Text(
                      'السابق',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: fgColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: buttonBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentIndex + 1} / ${items.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: fgColor,
            ),
            textDirection: TextDirection.ltr,
          ),
        ),
        Opacity(
          opacity: _currentIndex < items.length - 1 ? 1.0 : 0.0,
          child: Material(
            color: buttonBg,
            borderRadius: BorderRadius.circular(30),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _currentIndex < items.length - 1
                  ? () => _selectItem(_currentIndex + 1, items)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: fgColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 14, color: fgColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem({
    required UnifiedContentItem item,
    required int completedCount,
    required bool isCompleted,
    required bool isDark,
  }) {
    final fgColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: _isProgressMode
              ? _buildProgressStatus(item, completedCount, isCompleted, fgColor)
              : _buildShareStatus(item, context),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.8,
                  color: fgColor,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (item.fadl != null && item.fadl!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fgColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.fadl!,
              style: TextStyle(
                fontSize: 14,
                color: fgColor.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.source,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: fgColor.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
              textDirection: TextDirection.rtl,
            ),
            if (item.reference != null && item.reference!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: fgColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.reference!,
                  style: TextStyle(
                    fontSize: 11,
                    color: fgColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProgressStatus(
    UnifiedContentItem item,
    int completedCount,
    bool isCompleted,
    Color fgColor,
  ) {
    return isCompleted
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                SizedBox(width: 6),
                Text(
                  'مكتمل',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: fgColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              completedCount > 0
                  ? '$completedCount / ${item.repeatCount}'
                  : 'التكرار: ${item.repeatCount}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: fgColor.withValues(alpha: 0.8),
              ),
            ),
          );
  }

  Widget _buildShareStatus(UnifiedContentItem item, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ShareButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: item.text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 1),
                content: Text('تم نسخ النص', textAlign: TextAlign.right),
              ),
            );
          },
        ),
      ],
    );
  }
}
