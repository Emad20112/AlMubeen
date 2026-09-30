import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_motion.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// هيكل تحميل (Skeleton) بوميض متوقف تلقائيًا.
///
/// ## لماذا هذا المكوّن مختلف عن `ShimmerGroup` القائم؟
///
/// `ShimmerGroup` في `lib/core/widgets/` يعتمد على `AnimationController`
/// مع `repeat()` **لا يتوقف أبدًا**، ويستمر في إعادة بناء الأبناء حتى بعد
/// ظهور البيانات. و`AppLoadingOverlay` عنده نفس المشكلة صراحةً: `repeat()`
/// غير محدود + `mounted` غير محمي = تسريب ticker، مع خطر deadlock عند
/// `showLoading` فوق `Scaffold` مغلق.
///
/// هنا:
///
/// - الحركة **تتوقف تلقائيًا** عندما يصبح [progress] = 1 (لا نبض على بيانات
///   ظاهرة).
/// - `active: false` يوقفها فورًا — وهو ما نحتاجه عند تفعيل
///   `MediaQuery.disableAnimations` (إعداد "تقليل الحركة" في النظام) أو
///   في اختبارات الـwidget.
/// - المنحنى والمدة من [AppMotion] بدل `Curves.easeInOut` المكرر.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    required this.child,
    this.progress,
    this.active = true,
    super.key,
  });

  /// المحتوى النهائي — يظهر متوهجًا (بلا وميض) عند اكتمال التحميل.
  final Widget child;

  /// قيمة معروفة (0..1). عند `>= 1` تتوقف الحركة نهائيًا.
  final double? progress;

  /// تفعيل/إيقاف الحركة يدويًا.
  final bool active;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.skeletonCycle,
    );
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(AppSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _start();
      } else {
        _controller.stop();
      }
    }
  }

  void _start() {
    // `repeat(reverse: true)` يعطي موجة ناعمة ذهابًا وإيابًا، وهي نفس
    // حركة `ShimmerGroup` الحالية.
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // بيانات مكتملة → لا وميض إطلاقًا. هذا هو الفرق الجوهري عن
    // `ShimmerGroup`: هنا لا نبض فوق نص مقروء.
    final settled = widget.progress != null && widget.progress! >= 1;
    if (settled || !widget.active) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // جيبية بين الحدّين:الحدّ الأدنى 0.35، الأقصى 0.85.
        final wave = math.sin(_controller.value * 2 * math.pi);
        final opacity = 0.6 + (wave * 0.25);
        return Opacity(
          opacity: opacity.clamp(0.35, 0.85).toDouble(),
          child: widget.child,
        );
      },
    );
  }
}

/// هيكل تحميل على شكل عظام (bone) — بديل `SkeletonBox` القائم.
///
/// ```dart
/// AppSkeletonBone(width: double.infinity, height: 16)
/// ```
class AppSkeletonBone extends StatelessWidget {
  const AppSkeletonBone({
    required this.width,
    required this.height,
    this.radius = AppRadii.xs,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  final double width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    return AppSkeleton(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// بطاقة زجاجية (Glass card) — للاستخدام فوق الصور أو الخلفيات الداكنة.
///
/// تستخدم [AppColorScheme.surfaceGlass]، فتنقلب تلقائيًا بين الوضعين بلا
/// أي كود إضافي.
class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = AppRadii.lg,
    this.blurSigma = 12,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final shape = BorderRadius.circular(borderRadius);

    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceGlass,
            borderRadius: shape,
            border: Border.all(color: colors.glassBorder),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
