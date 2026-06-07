import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<CustomBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final foregroundColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;
    final selectedColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;

    return SafeArea(
      top: false,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          height: 100, // Taller to accommodate protruding button
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background SVG
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                height: 76,
                child: SvgPicture.asset(
                  AppAssets.bottomNavFrame,
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                    backgroundColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              // Background SVG Border overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                height: 76,
                child: SvgPicture.asset(
                  AppAssets.bottomNavFrame,
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                    foregroundColor.withValues(alpha: 0.62),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              // Icons row
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                height: 76,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (items.isNotEmpty)
                        Expanded(
                          child: _BottomNavButton(
                            item: items[0],
                            isSelected: 0 == selectedIndex,
                            onTap: () => onSelected(0),
                            foregroundColor: foregroundColor,
                            selectedColor: selectedColor,
                          ),
                        ),
                      if (items.length > 1)
                        Expanded(
                          child: _BottomNavButton(
                            item: items[1],
                            isSelected: 1 == selectedIndex,
                            onTap: () => onSelected(1),
                            foregroundColor: foregroundColor,
                            selectedColor: selectedColor,
                          ),
                        ),
                      // Empty space for the protruding center button
                      const Expanded(child: SizedBox()),
                      if (items.length > 3)
                        Expanded(
                          child: _BottomNavButton(
                            item: items[3],
                            isSelected: 3 == selectedIndex,
                            onTap: () => onSelected(3),
                            foregroundColor: foregroundColor,
                            selectedColor: selectedColor,
                          ),
                        ),
                      if (items.length > 4)
                        Expanded(
                          child: _BottomNavButton(
                            item: items[4],
                            isSelected: 4 == selectedIndex,
                            onTap: () => onSelected(4),
                            foregroundColor: foregroundColor,
                            selectedColor: selectedColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Center protruding button
              if (items.length > 2)
                Positioned(
                  bottom: 30, // Protrudes upwards
                  child: GestureDetector(
                    onTap: () => onSelected(2),
                    child: Container(
                      width: 72,
                      height: 84,
                      decoration: BoxDecoration(
                        color: selectedIndex == 2 ? selectedColor : backgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(36),
                          bottom: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.maroon900.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: selectedIndex == 2
                              ? backgroundColor
                              : foregroundColor.withValues(alpha: 0.62),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[2].icon,
                            size: 32,
                            color: selectedIndex == 2
                                ? backgroundColor
                                : foregroundColor,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            items[2].label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: selectedIndex == 2
                                  ? backgroundColor
                                  : foregroundColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavItem {
  const CustomBottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.foregroundColor,
    required this.selectedColor,
  });

  final CustomBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color foregroundColor;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 26,
              color: isSelected ? selectedColor : foregroundColor,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? selectedColor : foregroundColor,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
