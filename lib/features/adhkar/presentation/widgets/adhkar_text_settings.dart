import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AdhkarTextSettings extends StatelessWidget {
  const AdhkarTextSettings({
    required this.fontSize,
    required this.onFontSizeChanged,
    super.key,
  });

  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: fgColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'حجم الخط',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fgColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.format_size, size: 16, color: fgColor),
              Expanded(
                child: Slider(
                  value: fontSize,
                  min: 18.0,
                  max: 38.0,
                  divisions: 10,
                  activeColor: fgColor,
                  inactiveColor: fgColor.withValues(alpha: 0.2),
                  label: fontSize.round().toString(),
                  onChanged: onFontSizeChanged,
                ),
              ),
              Icon(Icons.format_size, size: 28, color: fgColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: fgColor,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
