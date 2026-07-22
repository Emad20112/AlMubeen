import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A compact, visually polished banner that slides into view when
/// the device loses connectivity. Supports an optional retry button.
///
/// Usage:
/// ```dart
/// if (!isConnected)
///   NetworkErrorBanner(onRetry: () => controller.retry())
/// ```
class NetworkErrorBanner extends StatelessWidget {
  const NetworkErrorBanner({
    this.onRetry,
    this.message,
    this.compact = false,
    super.key,
  });

  /// Called when the user taps the retry button. If `null`, the retry
  /// button is hidden and the banner becomes informational only.
  final VoidCallback? onRetry;

  /// Override the default Arabic message.
  final String? message;

  /// When `true`, renders a slimmer pill-shaped bar suitable for
  /// floating inside a player UI. When `false` (default), renders
  /// a full-width card with more breathing room.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScaler = MediaQuery.textScalerOf(context);

    if (compact) {
      return _CompactBanner(
        isDark: isDark,
        textScaler: textScaler,
        message: message ?? 'انقطع الاتصال بالإنترنت.',
        onRetry: onRetry,
      );
    }

    return _FullBanner(
      isDark: isDark,
      textScaler: textScaler,
      message: message ?? 'انقطع الاتصال بالإنترنت.',
      onRetry: onRetry,
    );
  }
}

// ─── Full banner ──────────────────────────────────────────────

class _FullBanner extends StatelessWidget {
  const _FullBanner({
    required this.isDark,
    required this.textScaler,
    required this.message,
    required this.onRetry,
  });

  final bool isDark;
  final TextScaler textScaler;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF3A1A1C), const Color(0xFF2E1215)]
              : [const Color(0xFFFFF0F0), const Color(0xFFFFE6E6)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF8B3A3A).withValues(alpha: 0.4)
              : const Color(0xFF8B0000).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFFD4A0A0).withValues(alpha: 0.12)
                  : const Color(0xFF8B0000).withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: isDark
                  ? const Color(0xFFD4A0A0)
                  : const Color(0xFF8B0000),
              size: textScaler.scale(20).clamp(18, 24).toDouble(),
            ),
          ),
          const SizedBox(width: 14),
          // Message
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.parchmentLight : const Color(0xFF5A1A1A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Retry button
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            _RetryPill(onTap: onRetry!, isDark: isDark),
          ],
        ],
      ),
    );
  }
}

// ─── Compact banner (for player bars) ────────────────────────

class _CompactBanner extends StatelessWidget {
  const _CompactBanner({
    required this.isDark,
    required this.textScaler,
    required this.message,
    required this.onRetry,
  });

  final bool isDark;
  final TextScaler textScaler;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF3A1A1C).withValues(alpha: 0.9)
                : const Color(0xFFFFE6E6).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF8B3A3A).withValues(alpha: 0.35)
                  : const Color(0xFF8B0000).withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: isDark
                    ? const Color(0xFFD4A0A0)
                    : const Color(0xFF8B0000),
                size: textScaler.scale(16).clamp(14, 20).toDouble(),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.parchmentLight
                        : const Color(0xFF5A1A1A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                _RetryPill(onTap: onRetry!, isDark: isDark, compact: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Retry pill button ───────────────────────────────────────

class _RetryPill extends StatelessWidget {
  const _RetryPill({
    required this.onTap,
    required this.isDark,
    this.compact = false,
  });

  final VoidCallback onTap;
  final bool isDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 5 : 7,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFFD8B457), const Color(0xFFB8943A)]
                  : [const Color(0xFF5A2A2E), const Color(0xFF3F1D20)],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: compact ? 13 : 15,
                color: Colors.white,
              ),
              SizedBox(width: compact ? 3 : 5),
              Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
