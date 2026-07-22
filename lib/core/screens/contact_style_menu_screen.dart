import 'package:al_mubeen/app/theme/app_colors.dart';
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
    final backgroundColor = isDark ? AppColors.darkScaffold : AppColors.parchment;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final accentColor = isDark ? AppColors.goldenAccentDark : AppColors.maroon800;
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
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.maroon800,
          foregroundColor: isDark ? AppColors.goldenAccentDark : AppColors.parchmentLight,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MenuHeader(
                        icon: icon,
                        title: title,
                        subtitle: subtitle,
                        accentColor: accentColor,
                        surfaceColor: surfaceColor,
                        titleColor: titleColor,
                        mutedColor: mutedColor,
                      ),
                      const SizedBox(height: 18),
                      for (final section in sections) ...[
                        if (section.title != null) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
                            child: Text(
                              section.title!,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: mutedColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              for (var index = 0; index < section.items.length; index++) ...[
                                ContactStyleMenuTile(item: section.items[index]),
                                if (index != section.items.length - 1)
                                  Divider(
                                    height: 1,
                                    indent: 72,
                                    endIndent: 16,
                                    color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
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

class ContactStyleMenuTile extends StatelessWidget {
  const ContactStyleMenuTile({required this.item, super.key});

  final ContactStyleMenuItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final subtitleColor = isDark ? AppColors.parchmentMuted : Colors.black54;
    final disabledOpacity = item.enabled ? 1.0 : 0.56;

    return Opacity(
      opacity: disabledOpacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.enabled ? item.onTap : null,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: item.accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.accentColor, size: 23),
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
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (item.badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.accentColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: item.accentColor.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Text(
                                item.badge!,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_left_rounded,
                  color: item.enabled
                      ? item.accentColor.withValues(alpha: 0.86)
                      : subtitleColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.surfaceColor,
    required this.titleColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color surfaceColor;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
