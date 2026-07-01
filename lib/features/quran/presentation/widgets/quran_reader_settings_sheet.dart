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
  required ValueNotifier<bool> isTajweedListenable,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuranReaderSettingsSheet(
      parentContext: context,
      currentPage: currentPage,
      isTajweedListenable: isTajweedListenable,
    ),
  );
}

class _QuranReaderSettingsSheet extends ConsumerStatefulWidget {
  const _QuranReaderSettingsSheet({
    required this.parentContext,
    required this.currentPage,
    required this.isTajweedListenable,
  });

  final BuildContext parentContext;
  final int currentPage;
  final ValueNotifier<bool> isTajweedListenable;

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
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final surfaceColor = isDark ? AppColors.darkSurfaceHigh : Colors.white;
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final borderColor = AppColors.maroon800.withValues(
      alpha: isDark ? 0.18 : 0.08,
    );
    final buttonIcon = isDark
        ? Icons.light_mode_rounded
        : Icons.dark_mode_rounded;
    final buttonLabel = isDark ? 'فاتح' : 'داكن';
    final fontScale = (_draftFontScale ?? preferences.fontScale)
        .clamp(0.9, 1.25)
        .toDouble();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.maroon800.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.maroon800.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: AppColors.maroon800,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإعدادات',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الوضع، الخط، والمكتبات من مكان واحد.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: mutedColor, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 12.0;
                  final isTwoColumn = constraints.maxWidth >= 400;
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
                          subtitle: 'بدّل بين الداكن والفاتح وعدّل حجم الخط.',
                          backgroundColor: surfaceColor,
                          borderColor: borderColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.maroon800.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      buttonIcon,
                                      color: AppColors.maroon800,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                        const SizedBox(height: 3),
                                        Text(
                                          isDark
                                              ? 'الوضع الحالي: داكن'
                                              : 'الوضع الحالي: فاتح',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: mutedColor),
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
                                    icon: Icon(buttonIcon),
                                    label: Text(buttonLabel),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Icon(
                                    Icons.text_fields_rounded,
                                    color: mutedColor,
                                  ),
                                  const SizedBox(width: 8),
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
                                        .labelLarge
                                        ?.copyWith(
                                          color: mutedColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: fontScale,
                                min: 0.9,
                                max: 1.25,
                                divisions: 7,
                                label: '${(fontScale * 100).round()}%',
                                activeColor: AppColors.maroon800,
                                inactiveColor: AppColors.maroon800.withValues(
                                  alpha: 0.18,
                                ),
                                onChanged: (value) {
                                  setState(() => _draftFontScale = value);
                                },
                                onChangeEnd: (value) {
                                  setState(() => _draftFontScale = null);
                                  preferencesNotifier.setFontScale(
                                    value.clamp(0.9, 1.25).toDouble(),
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
                          subtitle:
                              'افتح ما تحتاجه من القرّاء والتفاسير والترجمات.',
                          backgroundColor: surfaceColor,
                          borderColor: borderColor,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final tileSpacing = 10.0;
                              final useTwoColumns = constraints.maxWidth >= 320;
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
                                      subtitle:
                                          'حمّل التفاسير أو افتح ما لديك منها',
                                      accentColor: AppColors.maroon800,
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
                                      subtitle: 'اختر الترجمات المناسبة لك',
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
                                      subtitle: 'استعرض القراء وحمّل ما تفضله',
                                      accentColor: const Color(0xFF9B5E2E),
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
                          subtitle: 'أبقِ التجويد والحفظ السريع تحت يدك.',
                          backgroundColor: surfaceColor,
                          borderColor: borderColor,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final tileSpacing = 10.0;
                              final useTwoColumns = constraints.maxWidth >= 320;
                              final tileWidth = useTwoColumns
                                  ? (constraints.maxWidth - tileSpacing) / 2
                                  : constraints.maxWidth;

                              return Wrap(
                                spacing: tileSpacing,
                                runSpacing: tileSpacing,
                                children: [
                                  SizedBox(
                                    width: tileWidth,
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable:
                                          widget.isTajweedListenable,
                                      builder: (context, isTajweed, _) {
                                        return _ToggleActionCard(
                                          icon: Icons.auto_awesome_rounded,
                                          title: 'تفعيل التجويد',
                                          subtitle:
                                              'عرض ألوان التجويد على صفحات المصحف',
                                          accentColor: const Color(0xFF2F7A6B),
                                          value: isTajweed,
                                          onChanged: (value) {
                                            widget.isTajweedListenable.value =
                                                value;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  if (_isPageBookmarked != null)
                                    SizedBox(
                                      width: tileWidth,
                                      child: _ToggleActionCard(
                                        icon: Icons.bookmark_add_rounded,
                                        title: 'حفظ الصفحة الحالية',
                                        subtitle: 'صفحة ${widget.currentPage}',
                                        accentColor: AppColors.maroon800,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: mutedColor, height: 1.45),
          ),
          const SizedBox(height: 14),
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
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
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
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accentColor),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                    value: value,
                    onChanged: onChanged,
                    activeThumbColor: accentColor,
                    activeTrackColor: accentColor.withValues(alpha: 0.28),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedColor,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
