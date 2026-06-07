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
    return IconButton(
      tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
      onPressed: onPressed,
      color: AppColors.maroon800,
      icon: Icon(isFavorite ? Icons.star : Icons.star_outline),
    );
  }
}
