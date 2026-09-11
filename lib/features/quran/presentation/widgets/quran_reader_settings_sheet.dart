import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/translation_download_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showQuranReaderSettingsSheet({
  required BuildContext context,
  required int currentPage,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.36),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final drawerWidth = screenWidth < 430 ? screenWidth * 0.88 : 380.0;

      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: drawerWidth,
            height: double.infinity,
            child: _QuranReaderSettingsSheet(
              parentContext: context,
              currentPage: currentPage,
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class _QuranReaderSettingsSheet extends ConsumerStatefulWidget {
  const _QuranReaderSettingsSheet({
    required this.parentContext,
    required this.currentPage,
  });

  final BuildContext parentContext;
  final int currentPage;

  @override
  ConsumerState<_QuranReaderSettingsSheet> createState() =>
      _QuranReaderSettingsSheetState();
}

class _QuranReaderSettingsSheetState
    extends ConsumerState<_QuranReaderSettingsSheet> {
  bool? _isPageBookmarked;
  double? _draftFontScale;

  @override
  void initState() {
    super.initState();
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    final isBookmarked = await ref
        .read(quranBookmarkServiceProvider)
        .isBookmarked(page: widget.currentPage);
    if (mounted) {
      setState(() => _isPageBookmarked = isBookmarked);
    }
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(
      widget.parentContext,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preferences = ref
        .watch(appUserPreferencesProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const AppUserPreferences.initial(),
        );
    final preferencesNotifier = ref.read(appUserPreferencesProvider.notifier);
    final backgroundColor = isDark
        ? AppColors.darkScaffold
        : AppColors.parchment;
    final surfaceColor = isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.parchmentLight;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final borderColor = AppColors.goldenAccent.withValues(
      alpha: isDark ? 0.24 : 0.14,
    );
    final buttonIcon = isDark
        ? Icons.light_mode_rounded
        : Icons.dark_mode_rounded;
    final buttonLabel = isDark ? 'فاتح' : 'داكن';
    final fontScale = (_draftFontScale ?? preferences.fontScale)
        .clamp(0.55, 1.25)
        .toDouble();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon900.withValues(alpha: isDark ? 0.28 : 0.10),
            blurRadius: 24,
            offset: const Offset(-8, 0),
          ),
        ],
      ),
      child: SafeArea(
        left: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.goldenAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: AppColors.goldenAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإعدادات',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'الوضع، الخط، والمكتبات من مكان واحد.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: mutedColor, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      color: titleColor.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 10.0;
                  final isTwoColumn = constraints.maxWidth >= 390;
                  final cardWidth = isTwoColumn
                      ? (constraints.maxWidth - spacing) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _SettingsSectionCard(
                          title: 'المظهر',
                          subtitle: 'الوضع العام وحجم الخط.',
                          backgroundColor: surfaceColor,
                          borderColor: borderColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.goldenAccent.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      buttonIcon,
                                      color: AppColors.goldenAccent,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'الوضع العام',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                color: titleColor,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isDark
                                              ? 'الوضع الحالي: داكن'
                                              : 'الوضع الحالي: فاتح',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: mutedColor,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: () {
                                      preferencesNotifier.setThemePreference(
                                        isDark
                                            ? AppThemePreference.light
                                            : AppThemePreference.dark,
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      minimumSize: const Size(0, 36),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: Icon(buttonIcon, size: 18),
                                    label: Text(
                                      buttonLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(
                                    Icons.text_fields_rounded,
                                    color: mutedColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'حجم الخط',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: titleColor,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '${(fontScale * 100).round()}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: mutedColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: fontScale,
                                min: 0.55,
                                max: 1.25,
                                divisions: 14,
                                label: '${(fontScale * 100).round()}%',
                                activeColor: AppColors.goldenAccent,
                                inactiveColor: AppColors.goldenAccent
                                    .withValues(alpha: 0.18),
                                onChanged: (value) {
                                  setState(() => _draftFontScale = value);
                                },
                                onChangeEnd: (value) {
                                  setState(() => _draftFontScale = null);
                                  preferencesNotifier.setFontScale(
                                    value.clamp(0.55, 1.25).toDouble(),
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'أصغر',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: mutedColor.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                  ),
                                  Text(
                                    'أكبر',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: mutedColor.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _SettingsSectionCard(
                          title: 'المكتبة',
                          subtitle: 'التفاسير والترجمات والقراء.',
                          backgroundColor: surfaceColor,
                          borderColor: borderColor,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final tileSpacing = 8.0;
                              final useTwoColumns = constraints.maxWidth >= 330;
                              final tileWidth = useTwoColumns
                                  ? (constraints.maxWidth - tileSpacing) / 2
                                  : constraints.maxWidth;

                              return Wrap(
                                spacing: tileSpacing,
                                runSpacing: tileSpacing,
                                children: [
                                  SizedBox(
                                    width: tileWidth,
                                    child: _LibraryActionTile(
                                      icon: Icons.menu_book_rounded,
                                      title: 'مكتبة التفاسير',
                                      subtitle: 'حمّل أو افتح التفاسير.',
                                      accentColor: AppColors.goldenAccent,
                                      onTap: () => _openScreen(
                                        const TafsirDownloadScreen(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: _LibraryActionTile(
                                      icon: Icons.translate_rounded,
                                      title: 'مكتبة الترجمات',
                                      subtitle: 'اختر الترجمات المناسبة.',
                                      accentColor: const Color(0xFF2E6E6A),
                                      onTap: () => _openScreen(
                                        const TranslationDownloadScreen(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: _LibraryActionTile(
                                      icon: Icons.headphones_rounded,
                                      title: 'مكتبة القراء',
                                      subtitle: 'استعرض القراء وحمّل التلاوات.',
                                      accentColor: const Color(0xFF8A6B3B),
                                      onTap: () => _openScreen(
                                        const QuranAudioDownloadScreen(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _SettingsSectionCard(
                          title: 'خيارات القراءة',
                          subtitle: 'الحفظ السريع وخيارات القراءة.',
                          backgroundColor: surfaceColor,
                          borderColor: borderColor,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final tileSpacing = 8.0;
                              final useTwoColumns = constraints.maxWidth >= 330;
                              final tileWidth = useTwoColumns
                                  ? (constraints.maxWidth - tileSpacing) / 2
                                  : constraints.maxWidth;

                              return Wrap(
                                spacing: tileSpacing,
                                runSpacing: tileSpacing,
                                children: [
                                  if (_isPageBookmarked != null)
                                    SizedBox(
                                      width: tileWidth,
                                      child: _ToggleActionCard(
                                        icon: Icons.bookmark_add_rounded,
                                        title: 'حفظ الصفحة الحالية',
                                        subtitle: 'صفحة ${widget.currentPage}',
                                        accentColor: AppColors.goldenAccent,
                                        value: _isPageBookmarked!,
                                        onChanged: (value) async {
                                          await ref
                                              .read(
                                                quranBookmarkServiceProvider,
                                              )
                                              .togglePageBookmark(
                                                page: widget.currentPage,
                                              );
                                          await _loadBookmarkState();
                                        },
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon900.withValues(alpha: isDark ? 0.10 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: mutedColor, height: 1.25),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _LibraryActionTile extends StatelessWidget {
  const _LibraryActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.10 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 19),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                        fontSize: 11.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: mutedColor.withValues(alpha: 0.72),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleActionCard extends StatelessWidget {
  const _ToggleActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.10 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: isDark ? 0.16 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 19),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                    value: value,
                    onChanged: onChanged,
                    activeThumbColor: accentColor,
                    activeTrackColor: accentColor.withValues(alpha: 0.28),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedColor,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
