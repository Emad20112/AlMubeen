import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum AdhkarDisplayMode {
  readOnly,
  listenOnly,
  readAndListen,
}

class AdhkarModeSelector extends StatelessWidget {
  const AdhkarModeSelector({
    required this.currentMode,
    required this.onModeChanged,
    super.key,
  });

  final AdhkarDisplayMode currentMode;
  final ValueChanged<AdhkarDisplayMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkSurfaceHigh : AppColors.parchmentMuted;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(
            context: context,
            mode: AdhkarDisplayMode.readOnly,
            label: 'قراءة',
            icon: Icons.menu_book_outlined,
          ),
          _buildTab(
            context: context,
            mode: AdhkarDisplayMode.readAndListen,
            label: 'قراءة واستماع',
            icon: Icons.headset_mic_outlined,
          ),
          _buildTab(
            context: context,
            mode: AdhkarDisplayMode.listenOnly,
            label: 'استماع',
            icon: Icons.volume_up_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required AdhkarDisplayMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBgColor = isDark ? AppColors.maroon700 : AppColors.maroon800;
    final selectedFgColor = AppColors.parchmentLight;
    final unselectedFgColor = isDark ? AppColors.darkInk.withValues(alpha: 0.6) : AppColors.ink.withValues(alpha: 0.6);

    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? selectedFgColor : unselectedFgColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? selectedFgColor : unselectedFgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
