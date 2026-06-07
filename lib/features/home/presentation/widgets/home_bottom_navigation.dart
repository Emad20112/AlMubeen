import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/layout/adaptive_breakpoints.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final foregroundColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;
    final centerBackgroundColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;
    final centerForegroundColor = isDark
        ? AppColors.maroon800
        : AppColors.parchmentLight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final windowClass = AdaptiveBreakpoints.fromWidth(width);
            final maxWidth = switch (windowClass) {
              AdaptiveWindowClass.compact => math.min(width, 360.0),
              AdaptiveWindowClass.medium => 420.0,
              AdaptiveWindowClass.expanded => 460.0,
            };

            return Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: foregroundColor.withValues(alpha: 0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.maroon900.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: windowClass == AdaptiveWindowClass.compact
                          ? 16
                          : 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _NavIconButton(
                              tooltip: 'البحث',
                              icon: FlutterIslamicIcons.quran,
                              color: foregroundColor,
                              onPressed: () => _showSearchPlaceholder(context),
                            ),
                          ),
                        ),
                        _CenterQuranButton(
                          backgroundColor: centerBackgroundColor,
                          foregroundColor: centerForegroundColor,
                          onPressed: () => openSurahPickerAndReader(context),
                        ),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static void _showSearchPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'سيتم تفعيل البحث في مرحلة لاحقة.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}

class _CenterQuranButton extends StatelessWidget {
  const _CenterQuranButton({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final iconSize = textScaler.scale(28).clamp(26, 38).toDouble();
    final buttonSide = math.max(iconSize + 24, 56.0);

    return Tooltip(
      message: 'اختيار سورة',
      child: Semantics(
        button: true,
        label: 'اختيار سورة',
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: buttonSide,
              child: Icon(
                FlutterIslamicIcons.quran2,
                color: foregroundColor,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: IconButton(
          onPressed: onPressed,
          iconSize: textScaler.scale(25).clamp(24, 34).toDouble(),
          color: color,
          icon: Icon(icon),
        ),
      ),
    );
  }
}
