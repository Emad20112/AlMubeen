import 'package:flutter/material.dart';

const double kQuranReaderHeaderHeight = 74;

class QuranReaderHeader extends StatelessWidget {
  const QuranReaderHeader({
    required this.onSearchTapped,
    required this.onMenuTapped,
    required this.onSettingsTapped,
    super.key,
  });

  final VoidCallback onSearchTapped;
  final VoidCallback onMenuTapped;
  final VoidCallback onSettingsTapped;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = isDark
        ? const Color(0xFF161616)
        : const Color(0xFF202020);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.14);
    final iconColor = const Color(0xFFD8B457);
    final searchBorder = Colors.white.withValues(alpha: isDark ? 0.22 : 0.35);
    final searchFill = Colors.white.withValues(alpha: isDark ? 0.04 : 0.08);
    final searchHint = Colors.white.withValues(alpha: 0.72);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          decoration: BoxDecoration(
            color: scaffoldColor,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              _HeaderActionButton(
                icon: Icons.settings_rounded,
                tooltip: 'الإعدادات',
                iconColor: iconColor,
                onTap: onSettingsTapped,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SearchBarButton(
                  borderColor: searchBorder,
                  fillColor: searchFill,
                  hintColor: searchHint,
                  onTap: onSearchTapped,
                ),
              ),
              const SizedBox(width: 10),
              _HeaderActionButton(
                icon: Icons.menu_rounded,
                tooltip: 'السور',
                iconColor: iconColor,
                onTap: onMenuTapped,
              ),
            ],
          ),
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
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 22, color: hintColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'بحث: الصفحة، السورة، القارئ...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: hintColor,
                    fontWeight: FontWeight.w600,
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

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
      ),
    );
  }
}
