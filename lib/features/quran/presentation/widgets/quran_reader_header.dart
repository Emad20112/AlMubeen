import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
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
    // 🎨 Design tokens: بدل `isDark ? Color(0xFF161616) : Color(0xFFF7F4EB)`
    // اليدويين، نقرأ ورقة المصحف وحدوده من الأدوار الدلالية.
    final colors = AppColorScheme.of(context);

    // الشريط شبه شفاف فوق صفحة المصحف؛ تبقى الشفافية لأنه يُرسم فوق
    // `BackdropFilter` (زجاج). القيمة الدلالية هي اللون الأساس لا الشفافية.
    final scaffoldColor = colors.pageSurface.withValues(
      alpha: colors.isDark ? 0.75 : 0.85,
    );
    final borderColor = colors.isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
    final searchBorder = colors.isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    final searchFill = colors.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final searchHint = colors.isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.5);
    final iconColor = colors.isDark
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
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: scaffoldColor,
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                // الظل أضعف في الوضع الفاتح (0.03) لأنه يظهر كخط رمادي خفيف.
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: colors.isDark ? 0.3 : 0.03,
                    ),
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
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _SearchBarButton(
                      borderColor: searchBorder,
                      fillColor: searchFill,
                      hintColor: searchHint,
                      onTap: onSearchTapped,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (onWirdTapped != null)
                    _HeaderIconButton(
                      icon: Icons.auto_stories_rounded,
                      color: iconColor,
                      onTap: onWirdTapped,
                    ),
                  const SizedBox(width: AppSpacing.sm),
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
        borderRadius: BorderRadius.circular(AppRadii.md),
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
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          height: 36,
          padding: AppSpacing.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 17, color: hintColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'بحث: الصفحة، السورة، القارئ...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  // 📐 سلم الطباعة: `bodySmall` (12) بدل `fontSize: 12`
                  // اليدوي فوق `bodyMedium` (14) — نفس الحجم المعروض تماماً.
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
