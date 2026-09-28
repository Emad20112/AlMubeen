import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// ترويسة صفحة موحّدة، تحلّ محل 4 أنماط ترويسة متكرّرة.
///
/// ## المشكلة التي يحلّها
///
/// التدقيق وجد **12 شاشة موجّهة**، لكل منها نمط ترويسة مختلف: 4 منها
/// `AppBar` مادي، والباقي `Container` + `Row` + نصّين بتباعدين مختلفين
/// (`12`، `14`، `16`)، وواحدة تستخدم `AppBar` بأزرار مخصّصة لا ترث
/// `IconButtonTheme`.
///
/// ## البديل
///
/// ```dart
/// AppPageHeader(
///   title: 'أذكار الصباح',
///   subtitle: '12 ذكرًا',
///   actions: [IconButton(icon: const Icon(AppIcon.favorite), onPressed: …)],
/// )
/// ```
///
/// كل الأنماط في الثيم، والتباعد والطباعة من التوكنز.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showDivider = true,
    this.centerTitle = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showDivider;

  /// التوسيط متوافق مع `SectionTitle` القائم على فاصل زخرفي؛ الإبقاء على
  /// الخيار هنا يجعل الانتقال من الترويسة القديمة ممكنًا بلا كسر بصري.
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final theme = Theme.of(context);

    final titleColumn = Column(
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          style: AppTypography.headline(
            theme.textTheme,
          )?.copyWith(color: colors.textPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: centerTitle ? TextAlign.center : TextAlign.start,
            style: AppTypography.bodySmall(
              theme.textTheme,
            )?.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (actions.isEmpty || centerTitle)
          titleColumn
        else
          Row(
            children: [
              Expanded(child: titleColumn),
              const SizedBox(width: AppSpacing.md),
              Row(mainAxisSize: MainAxisSize.min, children: actions),
            ],
          ),
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: colors.divider),
        ],
      ],
    );
  }
}
