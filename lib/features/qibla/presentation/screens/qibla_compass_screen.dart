import 'dart:async';
import 'dart:math' as math;

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/qibla/application/qibla_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  static const String routePath = '/qibla';

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with WidgetsBindingObserver {
  final QiblaService _qiblaService = QiblaService();
  StreamSubscription<QiblaDirection>? _qiblaSubscription;
  QiblaDirection? _currentDirection;
  QiblaLocationException? _locationError;
  bool _isLoading = true;
  bool _waitingForSettings = false;
  Timer? _hapticTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeQibla();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForSettings) {
      _waitingForSettings = false;
      _retry();
    }
  }

  void _cancelSubscription() {
    _qiblaSubscription?.cancel();
    _qiblaSubscription = null;
  }

  Future<void> _initializeQibla() async {
    _cancelSubscription();

    try {
      final position = await _qiblaService.getCurrentLocation();
      _qiblaService.calculateQiblaAngle(
        position.latitude,
        position.longitude,
      );

      _qiblaSubscription = _qiblaService.getQiblaDirectionStream().listen(
        (direction) {
          if (!mounted) return;
          setState(() {
            _currentDirection = direction;
            _isLoading = false;
          });

          if (_qiblaService.isFacingQibla(direction.qiblaDirection)) {
            _triggerContinuousHaptic();
          } else {
            _stopContinuousHaptic();
          }
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _locationError = error is QiblaLocationException
                ? error
                : const QiblaCompassUnsupportedException();
            _isLoading = false;
          });
        },
      );

      await Future<void>.delayed(const Duration(seconds: 5));

      if (!mounted) return;
      if (_currentDirection == null && _locationError == null) {
        _cancelSubscription();
        setState(() {
          _locationError = const QiblaCompassUnsupportedException();
          _isLoading = false;
        });
      }
    } on QiblaLocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = const QiblaServiceDisabledException();
        _isLoading = false;
      });
    }
  }

  void _triggerContinuousHaptic() {
    if (_hapticTimer == null || !_hapticTimer!.isActive) {
      _hapticTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        HapticFeedback.lightImpact();
      });
    }
  }

  void _stopContinuousHaptic() {
    _hapticTimer?.cancel();
    _hapticTimer = null;
  }

  Future<void> _openLocationSettings() async {
    _waitingForSettings = true;
    await Geolocator.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    _waitingForSettings = true;
    await Geolocator.openAppSettings();
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _locationError = null;
      _currentDirection = null;
    });
    _initializeQibla();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelSubscription();
    _stopContinuousHaptic();
    _qiblaService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      body: SafeArea(
        child: Column(
          children: [
            IslamicHeader(
              title: 'اتجاه القبلة',
              subtitle: 'وجه نفسك نحو الكعبة المشرفة',
              leading: IconButton(
                tooltip: 'رجوع',
                onPressed: () => context.go('/'),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: isDark
                      ? AppColors.parchmentLight
                      : AppColors.maroon800,
                ),
              ),
              trailing: Icon(
                FlutterIslamicIcons.qibla,
                color: isDark
                    ? AppColors.goldenAccentDark
                    : AppColors.maroon800,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.goldenAccentDark
                            : AppColors.maroon800,
                      ),
                    )
                  : _locationError != null
                      ? _buildErrorView(isDark)
                      : _buildCompass(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Error view ────────────────────────────────────────────

  Widget _buildErrorView(bool isDark) {
    final error = _locationError!;
    final isDisabled = error is QiblaServiceDisabledException;
    final isPermanentlyDenied =
        error is QiblaPermissionPermanentlyDeniedException;

    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.parchmentLight;
    final titleColor =
        isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor =
        isDark ? AppColors.parchmentMuted : AppColors.maroon700;
    final accentColor =
        isDark ? AppColors.goldenAccentDark : AppColors.maroon800;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  AppColors.maroon700.withValues(alpha: isDark ? 0.2 : 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon900
                    .withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDisabled
                      ? AppColors.goldenAccent.withValues(alpha: 0.12)
                      : AppColors.maroon700.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isDisabled
                      ? Icons.location_off_rounded
                      : Icons.location_disabled_rounded,
                  size: 36,
                  color: isDisabled
                      ? (isDark
                          ? AppColors.goldenAccentDark
                          : AppColors.goldenAccent)
                      : AppColors.maroon700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isDisabled
                    ? 'خدمات الموقع مطفئة'
                    : isPermanentlyDenied
                        ? 'إذن الموقع محظور'
                        : 'إذن الموقع مطلوب',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                error.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: isPermanentlyDenied
                    ? _openAppSettings
                    : _openLocationSettings,
                icon: Icon(
                  isPermanentlyDenied
                      ? Icons.settings_rounded
                      : Icons.location_on_rounded,
                  size: 20,
                ),
                label: Text(
                  isPermanentlyDenied
                      ? 'فتح إعدادات التطبيق'
                      : 'تفعيل خدمات الموقع',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor:
                      isDark ? AppColors.darkScaffold : AppColors.parchmentLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _retry,
                child: Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    color: mutedColor,
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

  // ─── Compass ───────────────────────────────────────────────

  Widget _buildCompass(bool isDark) {
    if (_currentDirection == null) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? AppColors.goldenAccentDark : AppColors.maroon800,
        ),
      );
    }

    final isFacingQibla =
        _qiblaService.isFacingQibla(_currentDirection!.qiblaDirection);
    final qiblaAngle = _currentDirection!.qiblaAngle;
    final deviceHeading = _currentDirection!.deviceHeading;
    final qiblaDirection = _currentDirection!.qiblaDirection;

    final accentColor =
        isDark ? AppColors.goldenAccentDark : AppColors.maroon800;
    final surfaceColor =
        isDark ? AppColors.darkSurfaceHigh : AppColors.parchmentLight;
    final borderColor = isDark
        ? AppColors.goldenAccent.withValues(alpha: 0.2)
        : AppColors.maroon700.withValues(alpha: 0.15);
    final textColor =
        isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Column(
      children: [
        const SizedBox(height: 32),

        // Qibla angle pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_rounded, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'زاوية القبلة: ${qiblaAngle.toStringAsFixed(1)}°',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Compass
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compassSize =
                  constraints.maxWidth < 360 ? 240.0 : 300.0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Top indicator
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isFacingQibla
                            ? const Color(0xFF10B981)
                            : accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Compass ring (rotates to True North)
                  Transform.rotate(
                    angle: (-deviceHeading * math.pi) / 180,
                    child: Container(
                      width: compassSize,
                      height: compassSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: surfaceColor,
                        border: Border.all(
                          color: isFacingQibla
                              ? const Color(0xFF10B981)
                                  .withValues(alpha: 0.35)
                              : borderColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isFacingQibla
                                ? const Color(0xFF10B981)
                                    .withValues(alpha: 0.12)
                                : AppColors.maroon900.withValues(
                                    alpha: isDark ? 0.25 : 0.08,
                                  ),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _CompassRosePainter(isDark: isDark),
                      ),
                    ),
                  ),

                  // Qibla arrow (rotates to Qibla direction)
                  Transform.rotate(
                    angle: (qiblaDirection * math.pi) / 180,
                    child: SizedBox(
                      width: compassSize,
                      height: compassSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(compassSize, compassSize),
                            painter: _QiblaArrowPainter(
                              isFacingQibla: isFacingQibla,
                            ),
                          ),
                          Positioned(
                            top: 15,
                            child: Icon(
                              FlutterIslamicIcons.kaaba,
                              size: 42,
                              color: isFacingQibla
                                  ? const Color(0xFF10B981)
                                  : accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center checkmark (facing Qibla)
                  AnimatedScale(
                    scale: isFacingQibla ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),

                  // Center dot (not facing Qibla)
                  AnimatedScale(
                    scale: isFacingQibla ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: surfaceColor, width: 4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 32),

        // Status pill
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: isFacingQibla
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : surfaceColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isFacingQibla
                  ? const Color(0xFF10B981).withValues(alpha: 0.45)
                  : borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFacingQibla
                    ? Icons.verified_rounded
                    : Icons.screen_rotation,
                color: isFacingQibla
                    ? const Color(0xFF10B981)
                    : accentColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  isFacingQibla
                      ? 'أنت تتجه نحو القبلة'
                      : 'دوّر الهاتف للوصول إلى القبلة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isFacingQibla
                        ? const Color(0xFF10B981)
                        : textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

// ─── Compass rose painter ────────────────────────────────────

class _CompassRosePainter extends CustomPainter {
  final bool isDark;

  _CompassRosePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickColor = (isDark ? AppColors.parchmentLight : AppColors.maroon800)
        .withValues(alpha: 0.3);
    final majorColor =
        isDark ? AppColors.parchmentLight : AppColors.maroon800;

    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final majorTickPaint = Paint()
      ..color = majorColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 15) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;
      final innerRadius = radius - (isMajor ? 20 : 12);
      final outerRadius = radius - 4;

      canvas.drawLine(
        Offset(
          center.dx + innerRadius * math.sin(angle),
          center.dy - innerRadius * math.cos(angle),
        ),
        Offset(
          center.dx + outerRadius * math.sin(angle),
          center.dy - outerRadius * math.cos(angle),
        ),
        isMajor ? majorTickPaint : tickPaint,
      );
    }

    final directions = [
      {'label': 'ش', 'angle': 0.0},
      {'label': 'ق', 'angle': 90.0},
      {'label': 'ج', 'angle': 180.0},
      {'label': 'غ', 'angle': 270.0},
    ];

    for (final dir in directions) {
      final angle = (dir['angle'] as double) * math.pi / 180;
      final textRadius = radius - 40;
      final x = center.dx + textRadius * math.sin(angle);
      final y = center.dy - textRadius * math.cos(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: dir['label'] as String,
          style: TextStyle(
            color: majorColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(-angle);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CompassRosePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

// ─── Qibla arrow painter ─────────────────────────────────────

class _QiblaArrowPainter extends CustomPainter {
  final bool isFacingQibla;

  _QiblaArrowPainter({required this.isFacingQibla});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color =
          isFacingQibla ? const Color(0xFF10B981) : AppColors.maroon700;

    final path = Path();
    final yOffset = 25.0;

    path.moveTo(center.dx, center.dy - size.height / 2 + 30 + yOffset);
    path.lineTo(
        center.dx + 20, center.dy - size.height / 2 + 60 + yOffset);
    path.lineTo(
        center.dx + 8, center.dy - size.height / 2 + 55 + yOffset);
    path.lineTo(center.dx + 4, center.dy - 30 + yOffset);
    path.lineTo(center.dx - 4, center.dy - 30 + yOffset);
    path.lineTo(
        center.dx - 8, center.dy - size.height / 2 + 55 + yOffset);
    path.lineTo(
        center.dx - 20, center.dy - size.height / 2 + 60 + yOffset);
    path.close();

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.3),
      8.0,
      false,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_QiblaArrowPainter oldDelegate) {
    return oldDelegate.isFacingQibla != isFacingQibla;
  }
}
