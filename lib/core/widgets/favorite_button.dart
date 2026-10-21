import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.onPressed,
    this.isFavorite = false,
    super.key,
  });

  final VoidCallback onPressed;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return IconButton(
      tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
      onPressed: onPressed,
      color: isFavorite ? colors.accent : colors.textSecondary,
      icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
    );
  }
}
