import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdhkarCounter extends StatelessWidget {
  const AdhkarCounter({
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'عدد التكرار',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CounterButton(
              icon: Icons.remove,
              onPressed: onDecrement,
              color: foregroundColor,
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 140,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      AppAssets.counterFrame,
                      fit: BoxFit.fill,
                      colorFilter: ColorFilter.mode(
                        foregroundColor.withValues(alpha: 0.36),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      count.toString(),
                      key: ValueKey(count),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _CounterButton(
              icon: Icons.add,
              onPressed: onIncrement,
              color: foregroundColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'اضغط + لزيادة العدد',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foregroundColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      color: color,
      icon: Icon(icon),
    );
  }
}
