import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

const double kQuranReaderHeaderHeight = 56;

class QuranReaderHeader extends StatelessWidget {
  const QuranReaderHeader({
    required this.onSearchTapped,
    this.onSurahListTapped,
    this.onSettingsTapped,
    this.onWirdTapped,
    super.key,
  });

  final VoidCallback onSearchTapped;
  final VoidCallback? onSurahListTapped;
  final VoidCallback? onSettingsTapped;
  final VoidCallback? onWirdTapped;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = isDark
        ? const Color(0xFF161616).withValues(alpha: 0.75)
        : const Color(0xFFF7F4EB).withValues(alpha: 0.85);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
    final searchBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    final searchFill = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final searchHint = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.5);
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.6);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        bottom: false,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scaffoldColor,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _HeaderIconButton(
                    icon: FlutterIslamicIcons.quran2,
                    color: iconColor,
                    onTap: onSurahListTapped,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SearchBarButton(
                      borderColor: searchBorder,
                      fillColor: searchFill,
                      hintColor: searchHint,
                      onTap: onSearchTapped,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (onWirdTapped != null)
                    _HeaderIconButton(
                      icon: Icons.auto_stories_rounded,
                      color: iconColor,
                      onTap: onWirdTapped,
                    ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.settings_rounded,
                    color: iconColor,
                    onTap: onSettingsTapped,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _SearchBarButton extends StatelessWidget {
  const _SearchBarButton({
    required this.borderColor,
    required this.fillColor,
    required this.hintColor,
    required this.onTap,
  });

  final Color borderColor;
  final Color fillColor;
  final Color hintColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 17, color: hintColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'بحث: الصفحة، السورة، القارئ...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: hintColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
