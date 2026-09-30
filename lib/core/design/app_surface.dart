import 'dart:ui' show ImageFilter;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// دور السطح (Surface role) — بديل مسمّى لـ`BoxDecoration(color: …)`.
///
/// التطبيق كان فيه 181 لونًا مكتوبًا مباشرةً داخل `BoxDecoration`، ولا
/// يمكن تعديل خلفية أي بطاقة في المشروع دون مسح كل الملفات. هنا تكتب
/// **الدور** وتترك القيم للـ`Theme`:
///
/// ```dart
/// // قبل
/// BoxDecoration(color: Color(0xFFFFF8E8), borderRadius: …)
/// // بعد
/// AppSurface.solid(context, AppSurfaceRole.elevated)
/// ```
enum AppSurfaceRole {
  /// الخلفية الأساسية للشاشة.
  base,

  /// سطح فوق الخلفية: بطاقة، لوحة، قائمة منسدلة.
  elevated,

  /// سطح مكتوم: شريط بحث، خلفية ثانوية.
  muted,

  /// سطح غائر: حقل إدخال، حاوية مقعّرة.
  sunken,

  /// سطح زجاجي — يُستخدم مع `BackdropFilter`.
  glass,
}

/// واجهة موحّدة لأي سطح في التطبيق.
///
/// ## لماذا هذا المكوّن؟
///
/// `Container` بـ`BoxDecoration(color: Color(0xFF…))` تكرّر في كل مكان،
/// وهذه أكبر مصدر لتعدد الألوان في المشروع. [AppSurfaceRole] يجعل اللون
/// قرارًا دلاليًا، ويجعل الوضع الداكن مجانيًا تلقائيًا.
class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.role,
    required this.child,
    this.padding,
    this.borderRadius = _defaultRadius,
    this.border = true,
    this.blur = false,
    this.onTap,
    super.key,
  });

  /// سطح بلا حدّ وبالدور `base` — خلفية الشاشة نفسها.
  const AppSurface.base({required this.child, this.padding, super.key})
    : role = AppSurfaceRole.base,
      borderRadius = null,
      border = false,
      blur = false,
      onTap = null;

  static const double _defaultRadius = 20;

  final AppSurfaceRole role;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool border;
  final bool blur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final shape = BorderRadius.circular(borderRadius ?? _defaultRadius);

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: _colorOf(colors, role),
        borderRadius: shape,
        border: border && role != AppSurfaceRole.glass
            ? Border.all(color: colors.border)
            : null,
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    final clipped = borderRadius == null
        ? content
        : ClipRRect(borderRadius: shape, child: content);

    final withBlur = blur && role == AppSurfaceRole.glass
        ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: clipped,
          )
        : clipped;

    if (onTap == null) return withBlur;

    return Material(
      color: Colors.transparent,
      borderRadius: shape,
      child: InkWell(onTap: onTap, borderRadius: shape, child: withBlur),
    );
  }

  static Color _colorOf(AppColorScheme colors, AppSurfaceRole role) {
    return switch (role) {
      AppSurfaceRole.base => colors.surface,
      AppSurfaceRole.elevated => colors.surfaceElevated,
      AppSurfaceRole.muted => colors.surfaceMuted,
      AppSurfaceRole.sunken => colors.surfaceSunken,
      AppSurfaceRole.glass => colors.surfaceGlass,
    };
  }
}
