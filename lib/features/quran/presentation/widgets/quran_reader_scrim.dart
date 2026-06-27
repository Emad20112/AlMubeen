import 'package:flutter/material.dart';

class QuranReaderScrim extends StatelessWidget {
  const QuranReaderScrim({
    required this.animation,
    required this.onTap,
    super.key,
  });

  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        if (animation.isDismissed) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black.withValues(alpha: 0.35 * animation.value),
          ),
        );
      },
    );
  }
}
