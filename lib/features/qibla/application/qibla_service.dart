import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

// ─── Typed location exceptions ────────────────────────────────

sealed class QiblaLocationException implements Exception {
  const QiblaLocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class QiblaServiceDisabledException extends QiblaLocationException {
  const QiblaServiceDisabledException()
      : super('خدمات الموقع مطفئة. يرجى تفعيلها من إعدادات الجهاز.');
}

class QiblaPermissionDeniedException extends QiblaLocationException {
  const QiblaPermissionDeniedException()
      : super('تم رفض إذن الموقع. يرجى منح الإذن للمتابعة.');
}

class QiblaPermissionPermanentlyDeniedException
    extends QiblaLocationException {
  const QiblaPermissionPermanentlyDeniedException()
      : super('تم حظر إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات الجهاز.');
}

class QiblaCompassUnsupportedException extends QiblaLocationException {
  const QiblaCompassUnsupportedException()
      : super('مستشعر البوصلة غير مدعوم في هذا الجهاز.');
}

// ─── Qibla service ───────────────────────────────────────────

class QiblaService {
  Stream<CompassEvent>? _compassStream;
  double? _cachedQiblaAngle;

  /// Requests location with typed error handling.
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const QiblaServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const QiblaPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const QiblaPermissionPermanentlyDeniedException();
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Calculate Qibla angle for given coordinates.
  double calculateQiblaAngle(double latitude, double longitude) {
    final coordinates = Coordinates(latitude, longitude);
    final qibla = Qibla(coordinates);
    _cachedQiblaAngle = qibla.direction;
    return qibla.direction;
  }

  double? getCachedQiblaAngle() => _cachedQiblaAngle;

  Stream<CompassEvent>? getCompassStream() {
    _compassStream ??= FlutterCompass.events;
    return _compassStream;
  }

  Stream<QiblaDirection> getQiblaDirectionStream() {
    final compassStream = getCompassStream();
    if (compassStream == null) {
      return Stream.error(const QiblaCompassUnsupportedException());
    }

    return compassStream.map((event) {
      final deviceHeading = event.heading ?? 0.0;
      final qiblaAngle = _cachedQiblaAngle ?? 0.0;
      final qiblaDirection = qiblaAngle - deviceHeading;

      var normalized = qiblaDirection % 360;
      if (normalized < 0) normalized += 360;

      return QiblaDirection(
        qiblaAngle: qiblaAngle,
        deviceHeading: deviceHeading,
        qiblaDirection: normalized,
        accuracy: event.accuracy ?? 0.0,
      );
    });
  }

  bool isFacingQibla(double qiblaDirection, {double tolerance = 2.0}) {
    final diff = (qiblaDirection - 0).abs();
    return diff <= tolerance || diff >= (360 - tolerance);
  }

  void dispose() {
    _compassStream = null;
  }
}

// ─── Data model ──────────────────────────────────────────────

class QiblaDirection {
  const QiblaDirection({
    required this.qiblaAngle,
    required this.deviceHeading,
    required this.qiblaDirection,
    required this.accuracy,
  });

  final double qiblaAngle;
  final double deviceHeading;
  final double qiblaDirection;
  final double accuracy;

  @override
  String toString() =>
      'QiblaDirection(qiblaAngle: $qiblaAngle, deviceHeading: $deviceHeading, '
      'qiblaDirection: $qiblaDirection, accuracy: $accuracy)';
}
