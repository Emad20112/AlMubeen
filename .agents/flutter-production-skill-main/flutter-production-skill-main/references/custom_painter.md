# Custom Painter & Canvas

## CustomPainter Basics

```dart
class ArcProgressPainter extends CustomPainter {
  final double progress;   // 0.0 to 1.0
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  const ArcProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    this.strokeWidth = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track (background arc)
    paint.color = trackColor;
    canvas.drawArc(rect, math.pi * 0.75, math.pi * 1.5, false, paint);

    // Progress arc
    paint.color = progressColor;
    canvas.drawArc(
        rect, math.pi * 0.75, math.pi * 1.5 * progress, false, paint);

    // Draw text in center
    _drawCenterText(canvas, size, '${(progress * 100).toInt()}%');
  }

  void _drawCenterText(Canvas canvas, Size size, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: progressColor,
          fontSize: size.shortestSide * 0.18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(ArcProgressPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor;
}

// Usage
CustomPaint(
  size: const Size(200, 200),
  painter: ArcProgressPainter(
    progress: downloadProgress,
    progressColor: Theme.of(context).colorScheme.primary,
    trackColor: Theme.of(context).colorScheme.surfaceVariant,
  ),
)
```

---

## Animated Speed Dial Gauge

```dart
class SpeedGaugePainter extends CustomPainter {
  final double speedMbps;
  final double maxSpeed;
  final Animation<double> animation;

  SpeedGaugePainter({
    required this.speedMbps,
    required this.maxSpeed,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.6);
    final radius = size.width * 0.45;
    final sweepAngle = math.pi * 1.5; // 270 degrees
    final startAngle = math.pi * 0.75;

    // Draw gradient track
    _drawGradientArc(canvas, center, radius, startAngle, sweepAngle, size);

    // Draw needle
    final needleAngle = startAngle +
        sweepAngle * (speedMbps / maxSpeed).clamp(0, 1) * animation.value;
    _drawNeedle(canvas, center, radius * 0.75, needleAngle);

    // Draw speed text
    _drawText(canvas, center, '${speedMbps.toStringAsFixed(1)}', 'Mbps',
        size.width * 0.09);
  }

  void _drawGradientArc(Canvas canvas, Offset center, double radius,
      double startAngle, double sweepAngle, Size size) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(
      rect, startAngle, sweepAngle, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = Colors.grey.shade200,
    );

    // Gradient progress
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [Colors.green, Colors.yellow, Colors.red],
    );
    canvas.drawArc(
      rect, startAngle, sweepAngle, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(rect),
    );
  }

  void _drawNeedle(Canvas canvas, Offset center, double length, double angle) {
    final end = Offset(
      center.dx + length * math.cos(angle),
      center.dy + length * math.sin(angle),
    );
    canvas.drawLine(center, end,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 8,
        Paint()..color = Colors.white);
  }

  void _drawText(Canvas canvas, Offset center, String value,
      String unit, double fontSize) {
    final valuePainter = TextPainter(
      text: TextSpan(text: value,
          style: TextStyle(color: Colors.white,
              fontSize: fontSize, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    valuePainter.paint(canvas,
        Offset(center.dx - valuePainter.width / 2,
               center.dy + 12));
  }

  @override
  bool shouldRepaint(SpeedGaugePainter old) =>
      old.speedMbps != speedMbps || old.animation != animation;
}
```

---

## Line Chart Painter

```dart
class LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  const LineChartPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxVal = values.reduce(math.max);
    final minVal = values.reduce(math.min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minVal) / range) * size.height * 0.85
                - size.height * 0.05;
      points.add(Offset(x, y));
    }

    // Smooth path using cubic bezier
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i + 1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy,
          points[i + 1].dx, points[i + 1].dy);
    }

    // Fill gradient under the line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillColor.withOpacity(0.4), fillColor.withOpacity(0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw the line
    canvas.drawPath(path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Draw data points
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = lineColor);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(LineChartPainter old) => old.values != values;
}
```

---

## Dashed Border Painter

```dart
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  const DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, Radius.circular(borderRadius)));

    final dashPath = Path();
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) => old.color != color;
}

// Usage
CustomPaint(
  painter: const DashedBorderPainter(color: Colors.blue),
  child: YourWidget(),
)
```

---

## Performance Tips for CustomPainter

```dart
// 1. Use repaint: listenable to only repaint when needed
class MyPainter extends CustomPainter {
  MyPainter(Animation<double> animation) : super(repaint: animation);
}

// 2. Cache Paint objects — don't create in paint()
class EfficientPainter extends CustomPainter {
  final _trackPaint = Paint()   // created once
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12;

  @override
  void paint(Canvas canvas, Size size) {
    _trackPaint.color = Colors.grey; // just update color
    canvas.drawArc(..., _trackPaint);
  }
}

// 3. Wrap in RepaintBoundary
RepaintBoundary(
  child: CustomPaint(painter: ComplexPainter()),
)

// 4. Use shouldRepaint correctly — return false when nothing changed
@override
bool shouldRepaint(MyPainter old) =>
    old.progress != progress || old.color != color;
```
