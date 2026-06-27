import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class TafsirHtmlContent extends StatelessWidget {
  const TafsirHtmlContent({
    required this.text,
    required this.textStyle,
    required this.accentColor,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final String text;
  final TextStyle textStyle;
  final Color accentColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final normalizedHtml = _normalizeTafsirHtml(text);

    return RepaintBoundary(
      child: HtmlWidget(
        normalizedHtml,
        enableCaching: true,
        buildAsync: normalizedHtml.length > 10000,
        renderMode: ListViewMode(padding: padding, primary: false),
        textStyle: textStyle,
        customStylesBuilder: (element) {
          switch (element.localName) {
            case 'body':
            case 'div':
              return const {
                'direction': 'rtl',
                'text-align': 'justify',
                'line-height': '1.95',
              };
            case 'p':
              return const {'margin': '0 0 12px 0', 'line-height': '1.95'};
            case 'ul':
            case 'ol':
              return const {
                'margin': '0 0 12px 0',
                'padding-inline-start': '22px',
              };
            case 'li':
              return const {'margin': '0 0 8px 0'};
            case 'blockquote':
              return {
                'margin': '12px 0',
                'padding': '12px 14px',
                'border-right': '3px solid ${_cssHexColor(accentColor)}',
                'background-color': _cssRgbaColor(
                  accentColor.withValues(alpha: 0.08),
                ),
                'border-radius': '12px',
              };
            case 'h1':
            case 'h2':
            case 'h3':
            case 'h4':
            case 'h5':
            case 'h6':
              return const {
                'margin': '16px 0 12px 0',
                'font-weight': '700',
                'line-height': '1.5',
              };
            case 'table':
              return const {'width': '100%', 'margin': '12px 0'};
            case 'td':
            case 'th':
              return const {'padding': '6px 8px', 'vertical-align': 'top'};
          }

          return null;
        },
        onLoadingBuilder: (context, element, progress) {
          return const _TafsirHtmlLoading();
        },
        onErrorBuilder: (context, element, error) {
          return Padding(
            padding: padding,
            child: Text(
              _plainTextFallback(text),
              style: textStyle,
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          );
        },
      ),
    );
  }
}

String _normalizeTafsirHtml(String source) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) {
    return '<div dir="rtl"></div>';
  }

  if (_looksLikeHtml(trimmed)) {
    return '<div dir="rtl">$trimmed</div>';
  }

  final paragraphs = trimmed
      .split(RegExp(r'\n\s*\n'))
      .map((paragraph) {
        final cleanParagraph = paragraph.trim();
        if (cleanParagraph.isEmpty) {
          return null;
        }

        final escaped = const HtmlEscape(
          HtmlEscapeMode.element,
        ).convert(cleanParagraph).replaceAll('\n', '<br/>');
        return '<p>$escaped</p>';
      })
      .whereType<String>()
      .join();

  return '<div dir="rtl">$paragraphs</div>';
}

bool _looksLikeHtml(String value) {
  return RegExp(r'<\s*\/?\s*[a-zA-Z][^>]*>').hasMatch(value);
}

String _plainTextFallback(String source) {
  return source
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .trim();
}

String _cssHexColor(Color color) {
  final red = _channelToHex(color.r);
  final green = _channelToHex(color.g);
  final blue = _channelToHex(color.b);

  return '#$red$green$blue';
}

String _cssRgbaColor(Color color) {
  final red = _channelToInt(color.r);
  final green = _channelToInt(color.g);
  final blue = _channelToInt(color.b);
  final alpha = color.a.toStringAsFixed(3);

  return 'rgba($red, $green, $blue, $alpha)';
}

String _channelToHex(double value) {
  return _channelToInt(value).toRadixString(16).padLeft(2, '0');
}

int _channelToInt(double value) {
  return (value * 255.0).round().clamp(0, 255);
}

class _TafsirHtmlLoading extends StatelessWidget {
  const _TafsirHtmlLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _line(lineColor, widthFactor: 1.0),
          _line(lineColor, widthFactor: 0.88),
          _line(lineColor, widthFactor: 0.74),
          _line(lineColor, widthFactor: 0.96),
          _line(lineColor, widthFactor: 0.68),
          _line(lineColor, widthFactor: 0.82),
        ],
      ),
    );
  }

  Widget _line(Color color, {required double widthFactor}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
