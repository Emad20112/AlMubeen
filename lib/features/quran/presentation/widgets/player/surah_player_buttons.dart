import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_state_models.dart';
import 'package:flutter/material.dart';

class ControlIconButton extends StatelessWidget {
  const ControlIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 22, color: iconColor),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: iconColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class SeekButton extends StatelessWidget {
  const SeekButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 28, color: iconColor.withValues(alpha: 0.3)),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingPlayPauseButton extends StatelessWidget {
  const FloatingPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final bool isPlaying;
  final bool isLoading;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isDark
                ? ListeningPalette.goldGradient
                : [AppColors.maroon700, AppColors.maroon900],
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 24,
                color: Colors.white,
              ),
      ),
    );
  }
}

class MiniDownloadIconButton extends StatelessWidget {
  const MiniDownloadIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: accentColor),
        ),
      ),
    );
  }
}

class SurahPlayButton extends StatelessWidget {
  const SurahPlayButton({
    super.key,
    required this.isPlaying,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  final bool isPlaying;
  final Color accentColor;
  final bool isDark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isDark
                ? ListeningPalette.goldGradient
                : [AppColors.maroon700, AppColors.maroon900],
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class SurahDownloadButton extends StatelessWidget {
  const SurahDownloadButton({
    super.key,
    required this.isDownloading,
    required this.isPaused,
    required this.isFullyDownloaded,
    required this.hasOtherActiveDownload,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  final bool isDownloading;
  final bool isPaused;
  final bool isFullyDownloaded;
  final bool hasOtherActiveDownload;
  final Color accentColor;
  final bool isDark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = isFullyDownloaded
        ? Icons.download_done_rounded
        : isPaused
        ? Icons.play_arrow_rounded
        : isDownloading
        ? Icons.downloading_rounded
        : Icons.cloud_download_outlined;
    final iconColor = isFullyDownloaded
        ? accentColor.withValues(alpha: 0.5)
        : hasOtherActiveDownload
        ? accentColor.withValues(alpha: 0.35)
        : accentColor;

    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: hasOtherActiveDownload ? null : onPressed,
          customBorder: const CircleBorder(),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}
