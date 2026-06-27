import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AdhkarNavigationBar extends StatelessWidget {
  const AdhkarNavigationBar({
    required this.currentIndex,
    required this.totalCount,
    required this.completedCount,
    required this.repeatCount,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
    required this.onIncrement,
    super.key,
  });

  final int currentIndex;
  final int totalCount;
  final int completedCount;
  final int repeatCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onIncrement;

  static const double _horizontalPadding = 12;
  static const double _verticalPadding = 12;
  static const double _space = 8;
  static const double _buttonSize = 40;
  static const double _counterSize = 48;
  static const double _radius = 18;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final mutedColor = isDark
        ? AppColors.parchmentLight.withValues(alpha: 0.55)
        : AppColors.maroon800.withValues(alpha: 0.52);
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;

    final safeRepeatCount = repeatCount <= 0 ? 1 : repeatCount;
    final progress = (completedCount / safeRepeatCount).clamp(0.0, 1.0);
    final canGoPrevious = currentIndex > 0;
    final canGoNext = currentIndex < totalCount - 1;
    final canSkip = canGoNext;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon900.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: isCompact
                ? Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.center,
                    spacing: _space,
                    runSpacing: _space,
                    children: [
                      _NavButton(
                        icon: Icons.chevron_right,
                        enabled: canGoPrevious,
                        onTap: onPrevious,
                        primaryColor: primaryColor,
                      ),
                      _CounterIndicator(
                        completedCount: completedCount,
                        repeatCount: safeRepeatCount,
                        progress: progress,
                        primaryColor: primaryColor,
                        onIncrement: onIncrement,
                      ),
                      _IndexChip(
                        currentIndex: currentIndex,
                        totalCount: totalCount,
                        mutedColor: mutedColor,
                        primaryColor: primaryColor,
                      ),
                      _SkipButton(
                        onTap: onSkip,
                        primaryColor: primaryColor,
                        enabled: canSkip,
                      ),
                      _NavButton(
                        icon: Icons.chevron_left,
                        enabled: canGoNext,
                        onTap: onNext,
                        primaryColor: primaryColor,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      _NavButton(
                        icon: Icons.chevron_right,
                        enabled: canGoPrevious,
                        onTap: onPrevious,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(width: _space),
                      Expanded(
                        child: Row(
                          children: [
                            _CounterIndicator(
                              completedCount: completedCount,
                              repeatCount: safeRepeatCount,
                              progress: progress,
                              primaryColor: primaryColor,
                              onIncrement: onIncrement,
                            ),
                            const SizedBox(width: _space),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _IndexChip(
                                  currentIndex: currentIndex,
                                  totalCount: totalCount,
                                  mutedColor: mutedColor,
                                  primaryColor: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: _space),
                      _SkipButton(
                        onTap: onSkip,
                        primaryColor: primaryColor,
                        enabled: canSkip,
                      ),
                      const SizedBox(width: _space),
                      _NavButton(
                        icon: Icons.chevron_left,
                        enabled: canGoNext,
                        onTap: onNext,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.primaryColor,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: AdhkarNavigationBar._buttonSize,
            height: AdhkarNavigationBar._buttonSize,
            decoration: BoxDecoration(
              color: AppColors.parchmentLight,
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon900.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: primaryColor.withValues(alpha: enabled ? 1 : 0.28),
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterIndicator extends StatelessWidget {
  const _CounterIndicator({
    required this.completedCount,
    required this.repeatCount,
    required this.progress,
    required this.primaryColor,
    required this.onIncrement,
  });

  final int completedCount;
  final int repeatCount;
  final double progress;
  final Color primaryColor;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'عداد التكرار',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onIncrement,
          customBorder: const CircleBorder(),
          child: Container(
            width: AdhkarNavigationBar._counterSize,
            height: AdhkarNavigationBar._counterSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.05),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.15),
                width: 1.4,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: AdhkarNavigationBar._counterSize - 6,
                  height: AdhkarNavigationBar._counterSize - 6,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$completedCount',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'من $repeatCount',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: primaryColor.withValues(alpha: 0.68),
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.onTap,
    required this.primaryColor,
    required this.enabled,
  });

  final VoidCallback onTap;
  final Color primaryColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: enabled
                  ? primaryColor.withValues(alpha: 0.08)
                  : AppColors.maroon800.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: enabled ? 0.15 : 0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.skip_next,
                  size: 16,
                  color: primaryColor.withValues(alpha: enabled ? 1 : 0.3),
                ),
                const SizedBox(width: 5),
                Text(
                  'تخطي',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryColor.withValues(alpha: enabled ? 1 : 0.3),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexChip extends StatelessWidget {
  const _IndexChip({
    required this.currentIndex,
    required this.totalCount,
    required this.mutedColor,
    required this.primaryColor,
  });

  final int currentIndex;
  final int totalCount;
  final Color mutedColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
      ),
      child: Text(
        'الذكر ${currentIndex + 1} / $totalCount',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: mutedColor,
          height: 1.0,
        ),
      ),
    );
  }
}
