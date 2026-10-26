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
    final colors = AppColorScheme.of(context);

    return IconButton.filled(
      tooltip: isPlaying ? 'إيقاف' : 'تشغيل',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colors.primaryStrong,
        foregroundColor: colors.onPrimaryStrong,
        minimumSize: const Size.square(56),
      ),
      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
    );
  }
}
