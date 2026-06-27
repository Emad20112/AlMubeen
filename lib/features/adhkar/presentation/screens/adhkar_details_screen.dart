import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/widgets/app_error_view.dart';
import 'package:al_mubeen/core/widgets/app_loading_view.dart';
import 'package:al_mubeen/core/widgets/custom_bottom_nav.dart';
import 'package:al_mubeen/core/widgets/decorative_badge.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/adhkar/data/adhkar_providers.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_user_progress.dart';
import 'package:al_mubeen/features/adhkar/presentation/widgets/adhkar_navigation_bar.dart';
import 'package:al_mubeen/features/adhkar/presentation/widgets/adhkar_text_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdhkarDetailsScreen extends ConsumerStatefulWidget {
  const AdhkarDetailsScreen({required this.categoryId, super.key});

  static const String routePath = '/adhkar/:categoryId';

  final String categoryId;

  @override
  ConsumerState<AdhkarDetailsScreen> createState() =>
      _AdhkarDetailsScreenState();
}

class _AdhkarDetailsScreenState extends ConsumerState<AdhkarDetailsScreen> {
  double _fontSize = 26.0;
  int _currentIndex = 0;

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();

    // تحميل التقدم المخزن عند تهيئة الشاشة
    Future.microtask(() {
      if (mounted) {
        ref
            .read(adhkarProgressProvider.notifier)
            .loadProgress(widget.categoryId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncItemKeys(int length) {
    if (_itemKeys.length == length) return;
    _itemKeys
      ..clear()
      ..addAll(List<GlobalKey>.generate(length, (index) => GlobalKey()));
  }

  void _scrollToItem(int index) {
    if (index < 0 || index >= _itemKeys.length) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _itemKeys[index].currentContext;
      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: 0.3,
      );
    });
  }

  void _selectItem(int index, List<AdhkarItem> items) {
    if (index < 0 || index >= items.length) return;

    setState(() {
      _currentIndex = index;
    });

    _scrollToItem(index);
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

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(adhkarCategoryProvider(widget.categoryId));
    final itemsAsync = ref.watch(adhkarItemsProvider(widget.categoryId));
    final progressMap = ref.watch(adhkarProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (category == null) {
      return Scaffold(
        body: AppErrorView(
          title: 'لم يتم العثور على القسم',
          message: 'تعذر تحميل هذا القسم من الأذكار.',
          actionLabel: 'العودة',
          onActionPressed: () => context.go('/adhkar'),
        ),
      );
    }

    return itemsAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
        body: const AppLoadingView(
          title: 'جاري تحميل الأذكار',
          message: 'يتم جلب نصوص الأذكار والعدادات.',
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
        body: AppErrorView(
          title: 'تعذر تحميل البيانات',
          message: 'حدث خطأ غير متوقع أثناء تحميل الأذكار.',
          actionLabel: 'إعادة المحاولة',
          onActionPressed: () {
            ref.invalidate(adhkarItemsProvider(widget.categoryId));
          },
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColors.darkScaffold
                : AppColors.parchment,
            body: AppErrorView(
              title: 'لا توجد أذكار',
              message: 'لم يتم العثور على أذكار في هذا القسم.',
              actionLabel: 'العودة',
              onActionPressed: () => context.go('/adhkar'),
            ),
          );
        }

        _syncItemKeys(items.length);

        final currentItem = items[_currentIndex.clamp(0, items.length - 1)];

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkScaffold
              : AppColors.parchment,
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: 2,
            onSelected: (index) {
              if (index == 4) {
                context.go('/');
              } else if (index == 3) {
                // go to quran
              } else if (index == 2) {
                context.go('/adhkar');
              }
            },
            items: const [
              CustomBottomNavItem(
                icon: Icons.more_horiz_outlined,
                label: 'المزيد',
              ),
              CustomBottomNavItem(
                icon: Icons.bookmark_border,
                label: 'المفضلة',
              ),
              CustomBottomNavItem(
                icon: FlutterIslamicIcons.tasbih,
                label: 'الأذكار',
              ),
              CustomBottomNavItem(
                icon: FlutterIslamicIcons.quran2,
                label: 'القرآن',
              ),
              CustomBottomNavItem(icon: Icons.home_outlined, label: 'الرئيسية'),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final maxWidth = switch (AdaptiveBreakpoints.fromWidth(width)) {
                  AdaptiveWindowClass.compact => width,
                  AdaptiveWindowClass.medium => 720.0,
                  AdaptiveWindowClass.expanded => 820.0,
                };
                final side = math.max((width - maxWidth) / 2, 14.0);

                return Column(
                  children: [
                    IslamicHeader(
                      title: category.title,
                      subtitle: category.subtitle,
                      leading: IconButton(
                        tooltip: 'رجوع',
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 22),
                            tooltip: 'تصفير التقدم',
                            onPressed: () {
                              ref
                                  .read(adhkarProgressProvider.notifier)
                                  .resetCategory(widget.categoryId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text(
                                    'تم إعادة ضبط تقدم هذا القسم',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.text_fields),
                            tooltip: 'حجم الخط',
                            onPressed: () => _showFontSettings(context),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          _buildModeContent(
                            side: side,
                            items: items,
                            currentItem: currentItem,
                            progressMap: progressMap,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildNavigationBar(
                            items: items,
                            progressMap: progressMap,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeContent({
    required double side,
    required List<AdhkarItem> items,
    required AdhkarItem currentItem,
    required Map<String, AdhkarUserProgress> progressMap,
    required bool isDark,
  }) {
    return Expanded(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(side, 10, side, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int index = 0; index < items.length; index++) ...[
              if (index > 0) const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final item = items[index];
                  final isSelected = index == _currentIndex;
                  final itemProgress = progressMap[item.id];
                  final completedCount = itemProgress?.completedCount ?? 0;
                  final isCompleted = itemProgress?.isCompleted ?? false;

                  return _buildListItem(
                    key: _itemKeys[index],
                    item: item,
                    index: index,
                    isSelected: isSelected,
                    completedCount: completedCount,
                    isCompleted: isCompleted,
                    isDark: isDark,
                    onTap: () => _selectItem(index, items),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar({
    required List<AdhkarItem> items,
    required Map<String, AdhkarUserProgress> progressMap,
    required bool isDark,
  }) {
    final currentItem = items[_currentIndex.clamp(0, items.length - 1)];
    final currentProgress = progressMap[currentItem.id];
    final completedCount = currentProgress?.completedCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AdhkarNavigationBar(
        currentIndex: _currentIndex,
        totalCount: items.length,
        completedCount: completedCount,
        repeatCount: currentItem.repeatCount,
        onPrevious: () => _selectItem(_currentIndex - 1, items),
        onNext: () => _selectItem(_currentIndex + 1, items),
        onSkip: () {
          if (_currentIndex < items.length - 1) {
            _selectItem(_currentIndex + 1, items);
          }
        },
        onIncrement: () {
          ref
              .read(adhkarProgressProvider.notifier)
              .incrementProgress(
                currentItem.id,
                widget.categoryId,
                currentItem.repeatCount,
              );

          final newProgress = ref.read(adhkarProgressProvider)[currentItem.id];
          final newCount = newProgress?.completedCount ?? 0;

          if (newCount == currentItem.repeatCount &&
              _currentIndex < items.length - 1) {
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) {
                _selectItem(_currentIndex + 1, items);
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildListItem({
    required Key key,
    required AdhkarItem item,
    required int index,
    required bool isSelected,
    required int completedCount,
    required bool isCompleted,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final cardColor = isSelected
        ? (isDark ? AppColors.darkSurfaceHigh : AppColors.parchmentLight)
        : (isDark ? AppColors.darkSurface : AppColors.parchmentLight);

    final borderColor = isSelected
        ? AppColors.maroon700.withValues(alpha: 0.6)
        : (isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.transparent);

    final fgColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.maroon900.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 36,
                      child: DecorativeBadge(
                        label: '${index + 1}',
                        backgroundColor: isSelected
                            ? AppColors.maroon800
                            : fgColor.withValues(alpha: 0.08),
                        foregroundColor: isSelected
                            ? AppColors.parchmentLight
                            : fgColor,
                      ),
                    ),
                    const Spacer(),
                    if (isCompleted)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'مكتمل',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else if (completedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.maroon600.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$completedCount / ${item.repeatCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.maroon600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.text,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.75,
                    color: fgColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: fgColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: fgColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'التكرار: ${item.repeatCount}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: fgColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
