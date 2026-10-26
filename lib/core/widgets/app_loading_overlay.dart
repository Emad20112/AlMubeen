import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppLoadingOverlay extends StatefulWidget {
  const AppLoadingOverlay({
    required this.icon,
    this.message,
    this.size = 72,
    super.key,
  });

  final IconData icon;
  final String? message;
  final double size;

  @override
  State<AppLoadingOverlay> createState() => _AppLoadingOverlayState();
}

class _AppLoadingOverlayState extends State<AppLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final iconSize = widget.size * 0.47;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: child,
            );
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryStrong,
              boxShadow: context.tokens.shadows.medium,
            ),
            child: Icon(widget.icon, size: iconSize, color: colors.onPrimaryStrong),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
