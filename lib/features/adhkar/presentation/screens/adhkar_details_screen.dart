import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/core/widgets/app_error_view.dart';
import 'package:al_mubeen/core/widgets/app_loading_view.dart';
import 'package:al_mubeen/core/widgets/custom_bottom_nav.dart';
import 'package:al_mubeen/core/widgets/decorative_badge.dart';
import 'package:al_mubeen/core/widgets/decorative_card.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/adhkar/data/adhkar_providers.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_user_progress.dart';
import 'package:al_mubeen/features/adhkar/presentation/controllers/adhkar_audio_controller.dart';
import 'package:al_mubeen/features/adhkar/presentation/widgets/adhkar_mode_selector.dart';
import 'package:al_mubeen/features/adhkar/presentation/widgets/adhkar_text_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AdhkarDetailsScreen extends ConsumerStatefulWidget {
  const AdhkarDetailsScreen({required this.categoryId, super.key});

  static const String routePath = '/adhkar/:categoryId';

  final String categoryId;

  @override
  ConsumerState<AdhkarDetailsScreen> createState() => _AdhkarDetailsScreenState();
}

class _AdhkarDetailsScreenState extends ConsumerState<AdhkarDetailsScreen> with SingleTickerProviderStateMixin {
  AdhkarDisplayMode _displayMode = AdhkarDisplayMode.readAndListen;
  double _fontSize = 26.0;
  int _currentIndex = 0;
  bool _isFavorite = false;
  
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // تحميل التقدم المخزن عند تهيئة الشاشة
    Future.microtask(() {
      if (mounted) {
        ref.read(adhkarProgressProvider.notifier).loadProgress(widget.categoryId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
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
    
    ref.read(adhkarAudioProvider.notifier).selectItem(index);
    
    if (_displayMode == AdhkarDisplayMode.readAndListen) {
      _scrollToItem(index);
    }
  }

  void _incrementCounter(AdhkarItem item, List<AdhkarItem> items, Map<String, AdhkarUserProgress> progressMap) {
    final currentProgress = progressMap[item.id];
    final currentCount = currentProgress?.completedCount ?? 0;

    if (currentCount < item.repeatCount) {
      HapticFeedback.lightImpact();
      
      ref.read(adhkarProgressProvider.notifier)
          .incrementProgress(item.id, widget.categoryId, item.repeatCount);

      if (currentCount + 1 == item.repeatCount) {
        HapticFeedback.vibrate();
        
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && _currentIndex < items.length - 1) {
            _selectItem(_currentIndex + 1, items);
          }
        });
      }
    }
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
    final audioState = ref.watch(adhkarAudioProvider);
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
            backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
            body: AppErrorView(
              title: 'لا توجد أذكار',
              message: 'لم يتم العثور على أذكار في هذا القسم.',
              actionLabel: 'العودة',
              onActionPressed: () => context.go('/adhkar'),
            ),
          );
        }

        _syncItemKeys(items.length);
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(adhkarAudioProvider.notifier).setPlaylist(items, initialIndex: _currentIndex);
        });

        if (audioState.currentItemId != null) {
          final index = items.indexWhere((item) => item.id == audioState.currentItemId);
          if (index != -1 && index != _currentIndex) {
            _currentIndex = index;
            if (_displayMode == AdhkarDisplayMode.readAndListen) {
              _scrollToItem(index);
            }
          }
        }

        final currentItem = items[_currentIndex.clamp(0, items.length - 1)];
        final hasAudio = currentItem.audioUrl?.isNotEmpty ?? false;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: 2,
            onSelected: (index) {
              ref.read(adhkarAudioProvider.notifier).stop();
              if (index == 4) {
                context.go('/');
              } else if (index == 3) {
                // go to quran
              } else if (index == 2) {
                context.go('/adhkar');
              }
            },
            items: const [
              CustomBottomNavItem(icon: Icons.more_horiz_outlined, label: 'المزيد'),
              CustomBottomNavItem(icon: Icons.bookmark_border, label: 'المفضلة'),
              CustomBottomNavItem(icon: FlutterIslamicIcons.tasbih, label: 'الأذكار'),
              CustomBottomNavItem(icon: FlutterIslamicIcons.quran2, label: 'القرآن'),
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
                          ref.read(adhkarAudioProvider.notifier).stop();
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
                              ref.read(adhkarProgressProvider.notifier).resetCategory(widget.categoryId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('تم إعادة ضبط تقدم هذا القسم', textAlign: TextAlign.right),
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

                    Padding(
                      padding: EdgeInsets.fromLTRB(side, 8, side, 8),
                      child: AdhkarModeSelector(
                        currentMode: _displayMode,
                        onModeChanged: (mode) {
                          setState(() {
                            _displayMode = mode;
                          });
                          if (mode == AdhkarDisplayMode.readAndListen) {
                            _scrollToItem(_currentIndex);
                          }
                        },
                      ),
                    ),

                    Expanded(
                      child: _buildModeContent(
                        side: side,
                        items: items,
                        currentItem: currentItem,
                        audioState: audioState,
                        progressMap: progressMap,
                        isDark: isDark,
                      ),
                    ),

                    _buildBottomControlPanel(
                      side: side,
                      currentItem: currentItem,
                      hasAudio: hasAudio,
                      audioState: audioState,
                      items: items,
                      isDark: isDark,
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
    required AdhkarAudioState audioState,
    required Map<String, AdhkarUserProgress> progressMap,
    required bool isDark,
  }) {
    switch (_displayMode) {
      case AdhkarDisplayMode.readOnly:
        return Padding(
          padding: EdgeInsets.fromLTRB(side, 12, side, 12),
          child: Column(
            children: [
              Expanded(
                child: _buildSingleCardView(
                  currentItem: currentItem,
                  isDark: isDark,
                  items: items,
                  progressMap: progressMap,
                ),
              ),
            ],
          ),
        );

      case AdhkarDisplayMode.listenOnly:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: side),
          child: _buildAudioOnlyView(currentItem, isDark),
        );

      case AdhkarDisplayMode.readAndListen:
        return ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(side, 10, side, 30),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
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
        );
    }
  }

  Widget _buildSingleCardView({
    required AdhkarItem currentItem,
    required bool isDark,
    required List<AdhkarItem> items,
    required Map<String, AdhkarUserProgress> progressMap,
  }) {
    final fgColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final currentProgress = progressMap[currentItem.id];
    final currentCount = currentProgress?.completedCount ?? 0;
    
    return DecorativeCard(
      isImportant: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              '${_currentIndex + 1} / ${items.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: fgColor.withValues(alpha: 0.6),
              ),
            ),
          ),
          
          InkWell(
            onTap: () => _incrementCounter(currentItem, items, progressMap),
            splashColor: fgColor.withValues(alpha: 0.05),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.decorativeDivider,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                          fgColor.withValues(alpha: 0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentItem.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _fontSize + 4,
                          fontWeight: FontWeight.w800,
                          height: 1.8,
                          color: fgColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentItem.source,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: fgColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildCounterIndicator(currentItem, currentCount, fgColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterIndicator(AdhkarItem item, int currentCount, Color color) {
    final percent = item.repeatCount > 0 ? currentCount / item.repeatCount : 0.0;
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: Colors.transparent,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currentCount',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                'من ${item.repeatCount}',
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioOnlyView(AdhkarItem currentItem, bool isDark) {
    final color = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final isPlaying = ref.watch(adhkarAudioProvider).isPlaying;
                final scale = isPlaying ? 1.0 + (_pulseController.value * 0.1) : 1.0;
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.04),
                      border: Border.all(
                        color: color.withValues(alpha: 0.12),
                        width: 4,
                      ),
                      boxShadow: isPlaying ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.08),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ] : null,
                    ),
                    child: Center(
                      child: Icon(
                        FlutterIslamicIcons.quran,
                        size: 90,
                        color: color.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              'الذكر الحالي',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                currentItem.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentItem.source,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
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
        : (isCompleted ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.transparent);

    final fgColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.maroon900.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : null,
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
                    DecorativeBadge(
                      label: '${index + 1}',
                      backgroundColor: isSelected ? AppColors.maroon800 : fgColor.withValues(alpha: 0.08),
                      foregroundColor: isSelected ? AppColors.parchmentLight : fgColor,
                    ),
                    const Spacer(),
                    if (isCompleted)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildBottomControlPanel({
    required double side,
    required AdhkarItem currentItem,
    required bool hasAudio,
    required AdhkarAudioState audioState,
    required List<AdhkarItem> items,
    required bool isDark,
  }) {
    final color = isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final isPlaying = audioState.isPlaying;
    final isLoading = audioState.isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(side, 12, side, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon900.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_displayMode != AdhkarDisplayMode.readOnly && hasAudio) ...[
            _buildAudioSlider(audioState, color),
            const SizedBox(height: 8),
          ],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 28),
                color: color,
                onPressed: _currentIndex > 0 ? () => _selectItem(_currentIndex - 1, items) : null,
              ),

              IconButton(
                icon: Icon(
                  Icons.sync,
                  size: 26,
                  color: audioState.isAutoRepeat ? AppColors.maroon600 : color.withValues(alpha: 0.5),
                ),
                tooltip: 'تكرار تلقائي للذكر',
                onPressed: () => ref.read(adhkarAudioProvider.notifier).toggleAutoRepeat(),
              ),

              GestureDetector(
                onTap: hasAudio && !isLoading
                    ? () => ref.read(adhkarAudioProvider.notifier).togglePlay(currentItem)
                    : null,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasAudio ? AppColors.maroon800 : Colors.grey.withValues(alpha: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.maroon900.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 32,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),

              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  size: 28,
                  color: _isFavorite ? Colors.amber : color,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(
                        _isFavorite ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.skip_next, size: 28),
                color: color,
                onPressed: _currentIndex < items.length - 1 ? () => _selectItem(_currentIndex + 1, items) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSlider(AdhkarAudioState state, Color color) {
    final pos = state.position;
    final dur = state.duration;
    final value = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(dur),
                style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.5)),
              ),
              Text(
                _formatDuration(pos),
                style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
