import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class QuranReaderBackButton extends StatelessWidget {
  const QuranReaderBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2320).withOpacity(.82)
                    : const Color(0xFFFDF8F0).withOpacity(.88),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.maroon700.withOpacity(.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? AppColors.parchmentLight : AppColors.maroon900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
