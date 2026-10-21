import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return IconButton(
      tooltip: 'مشاركة',
      onPressed: onPressed,
      color: colors.primaryStrong,
      icon: const Icon(Icons.share_outlined),
    );
  }
}
