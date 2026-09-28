import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 🛡️ PERF: نبضة shimmer مشتركة (Shared Ticker) لمجموعة الـ skeletons.
///
/// **المشكلة قبل:** كان كل عنصر skeleton يملك `AnimationController` خاصاً به
/// (`SingleTickerProviderStateMixin`)، فشبكة من 8 عناصر = 8 tickers تعمل
/// بشكل متزامن ومستقل — هدر مباشر في ميزانية الرسم لكل إطار.
///
/// **الحل:** ticker واحد فقط في هذا الـ widget، وجميع العناصر تُبنى داخل
/// `builder` وتشترك في نفس قيمة التلاشي. النتيجة: `AnimationController`
/// واحد بدلاً من N.
class ShimmerGroup extends StatefulWidget {
  const ShimmerGroup({
    required this.itemCount,
    required this.builder,
    this.duration = const Duration(milliseconds: 1400),
    this.minOpacity = 0.3,
    this.maxOpacity = 0.8,
    super.key,
  });

  /// عدد العناصر المطلوب بناؤها بمشاركة نفس النبضة.
  final int itemCount;

  /// يُبنى لكل عنصر؛ يُمرَّر له العنصر (child) بمعامل ثابت لتفادي إعادة البناء.
  final Widget Function(BuildContext context, int index) builder;

  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  @override
  State<ShimmerGroup> createState() => _ShimmerGroupState();
}

class _ShimmerGroupState extends State<ShimmerGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: _ShimmerBatch(
            itemCount: widget.itemCount,
            builder: widget.builder,
          ),
        );
      },
    );
  }
}

/// حاوية بسيطة تُبنى مرة واحدة لكل تغيّر في الشفافية (بدون ticker خاص بها).
class _ShimmerBatch extends StatelessWidget {
  const _ShimmerBatch({required this.itemCount, required this.builder});

  final int itemCount;
  final Widget Function(BuildContext context, int index) builder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < itemCount; index++) builder(context, index),
      ],
    );
  }
}

/// لون قاعدة عناصر الـ skeleton حسب الثيم الحالي.
Color skeletonBaseColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white12
      : Colors.black12;
}

/// لون خلفية بطاقة الـ skeleton حسب الثيم الحالي.
Color skeletonCardColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? AppColors.darkSurfaceHigh
      : AppColors.parchmentLight;
}

/// مستطيل skeleton بسيط (عنصر نائب) بلون موحّد.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 4,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  const SkeletonBox.circle({required double size, super.key})
    : width = size,
      height = size,
      borderRadius = 0,
      shape = BoxShape.circle;

  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: skeletonBaseColor(context),
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
      ),
    );
  }
}
