import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PlayAudioButton extends StatelessWidget {
  const PlayAudioButton({
    required this.onPressed,
    this.isPlaying = false,
    super.key,
  });

  final VoidCallback onPressed;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;
    final foregroundColor = isDark
        ? AppColors.maroon800
        : AppColors.parchmentLight;

    return IconButton.filled(
      tooltip: isPlaying ? 'إيقاف' : 'تشغيل',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size.square(56),
      ),
      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
    );
  }
}
