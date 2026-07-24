import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/quran_reader_icon_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContactStyleMenuScreen extends StatelessWidget {
  const ContactStyleMenuScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
    this.selectedNavIndex,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<ContactStyleMenuSection> sections;
  final int? selectedNavIndex;

  int? get _effectiveNavIndex {
    if (selectedNavIndex != null) return selectedNavIndex;
    if (title == 'المكتبات') return 2;
    if (title == 'المزيد') return 3;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkScaffold
        : AppColors.parchment;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final accentColor = isDark
        ? AppColors.goldenAccentDark
        : AppColors.maroon800;
    final navIndex = _effectiveNavIndex;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        bottomNavigationBar: navIndex == null
            ? null
            : QuranReaderIconNavBar(
                selectedIndex: navIndex,
                onQuranTapped: () => context.go('/'),
                onAdhkarTapped: () => context.go('/adhkar'),
                onLibrariesTapped: () => context.go('/quran/libraries'),
                onMoreTapped: () => context.go('/quran/more'),
              ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: IslamicHeader(
                  title: title,
                  subtitle: subtitle,
                  trailing: _HeaderAccentIcon(
                    icon: icon,
                    isDark: isDark,
                    accentColor: accentColor,
                  ),
                ),
              ),

              // ── Sections ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final section in sections) ...[
                              if (section.title != null) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    6,
                                    18,
                                    6,
                                    10,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              accentColor,
                                              accentColor.withValues(
                                                alpha: 0.4,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        section.title!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: mutedColor,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.3,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: accentColor.withValues(
                                      alpha: isDark ? 0.14 : 0.08,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.22 : 0.06,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: accentColor.withValues(
                                        alpha: isDark ? 0.04 : 0.03,
                                      ),
                                      blurRadius: 40,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    children: [
                                      for (
                                        var index = 0;
                                        index < section.items.length;
                                        index++
                                      ) ...[
                                        ContactStyleMenuTile(
                                          item: section.items[index],
                                        ),
                                        if (index != section.items.length - 1)
                                          Divider(
                                            height: 1,
                                            indent: 72,
                                            endIndent: 16,
                                            color: accentColor.withValues(
                                              alpha: isDark ? 0.10 : 0.06,
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactStyleMenuSection {
  const ContactStyleMenuSection({this.title, required this.items});

  final String? title;
  final List<ContactStyleMenuItem> items;
}

class ContactStyleMenuItem {
  const ContactStyleMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.badge,
    this.enabled = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String? badge;
  final bool enabled;
  final VoidCallback? onTap;
}

class ContactStyleMenuTile extends StatefulWidget {
  const ContactStyleMenuTile({required this.item, super.key});

  final ContactStyleMenuItem item;

  @override
  State<ContactStyleMenuTile> createState() => _ContactStyleMenuTileState();
}

class _ContactStyleMenuTileState extends State<ContactStyleMenuTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final subtitleColor = isDark ? AppColors.parchmentMuted : Colors.black54;
    final disabledOpacity = item.enabled ? 1.0 : 0.56;

    return Opacity(
      opacity: disabledOpacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        color: _isPressed
            ? item.accentColor.withValues(alpha: isDark ? 0.08 : 0.04)
            : Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.enabled ? item.onTap : null,
            onTapDown: item.enabled
                ? (_) => setState(() => _isPressed = true)
                : null,
            onTapUp: item.enabled
                ? (_) => setState(() => _isPressed = false)
                : null,
            onTapCancel: item.enabled
                ? () => setState(() => _isPressed = false)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  // ── Modern icon with gradient background ──
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item.accentColor.withValues(
                            alpha: isDark ? 0.22 : 0.14,
                          ),
                          item.accentColor.withValues(
                            alpha: isDark ? 0.10 : 0.06,
                          ),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.accentColor.withValues(
                          alpha: isDark ? 0.18 : 0.12,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Icon(item.icon, color: item.accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: titleColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            if (item.badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      item.accentColor.withValues(alpha: 0.14),
                                      item.accentColor.withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: item.accentColor.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: item.accentColor,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: subtitleColor, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── Arrow icon reversed for RTL ──
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: item.enabled
                          ? item.accentColor.withValues(
                              alpha: isDark ? 0.10 : 0.06,
                            )
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: item.enabled
                          ? item.accentColor.withValues(alpha: 0.86)
                          : subtitleColor.withValues(alpha: 0.5),
                    ),
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

class _HeaderAccentIcon extends StatelessWidget {
  const _HeaderAccentIcon({
    required this.icon,
    required this.isDark,
    required this.accentColor,
  });

  final IconData icon;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
        ),
      ),
      child: Icon(
        icon,
        color: isDark ? AppColors.goldenAccentDark : AppColors.maroon800,
        size: 21,
      ),
    );
  }
}
