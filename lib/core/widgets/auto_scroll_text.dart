import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AutoScrollText extends StatelessWidget {
  const AutoScrollText({
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.maxLines = 1,
    this.softWrap = true,
    this.pauseDuration = const Duration(milliseconds: 900),
    this.velocity = 26,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int maxLines;
  final bool softWrap;
  final Duration pauseDuration;
  final double velocity;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final animationsDisabled =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return _StaticText(
            text: text,
            style: effectiveStyle,
            textAlign: textAlign,
            maxLines: maxLines,
            softWrap: softWrap,
          );
        }

        final painter = TextPainter(
          text: TextSpan(text: text, style: effectiveStyle),
          textAlign: textAlign,
          textDirection: textDirection,
          textScaler: textScaler,
          ellipsis: '...',
          maxLines: maxLines,
        )..layout(maxWidth: constraints.maxWidth);

        if (!painter.didExceedMaxLines || animationsDisabled) {
          return _StaticText(
            text: text,
            style: effectiveStyle,
            textAlign: textAlign,
            maxLines: maxLines,
            softWrap: softWrap,
          );
        }

        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : painter.preferredLineHeight * maxLines;
        final marqueeHeight = math.min(
          availableHeight,
          painter.preferredLineHeight * maxLines,
        );

        return Semantics(
          label: text,
          child: ExcludeSemantics(
            child: SizedBox(
              height: marqueeHeight,
              child: Center(
                child: SizedBox(
                  height: math.min(marqueeHeight, painter.preferredLineHeight),
                  child: Marquee(
                    text: text.replaceAll(RegExp(r'\s+'), ' ').trim(),
                    style: effectiveStyle,
                    textDirection: textDirection,
                    blankSpace: 34,
                    velocity: velocity,
                    startAfter: pauseDuration,
                    pauseAfterRound: pauseDuration,
                    showFadingOnlyWhenScrolling: false,
                    fadingEdgeStartFraction: 0.08,
                    fadingEdgeEndFraction: 0.08,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StaticText extends StatelessWidget {
  const _StaticText({
    required this.text,
    required this.style,
    required this.textAlign,
    required this.maxLines,
    required this.softWrap,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int maxLines;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: softWrap,
      textAlign: textAlign,
      style: style,
    );
  }
}
