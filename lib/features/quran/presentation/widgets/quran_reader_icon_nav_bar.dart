import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

const double kQuranReaderIconNavBarHeight = 64;

class QuranReaderIconNavBar extends StatelessWidget {
  const QuranReaderIconNavBar({
    this.selectedIndex = 0,
    this.onQuranTapped,
    this.onAdhkarTapped,
    this.onLibrariesTapped,
    this.onMoreTapped,
    super.key,
  });

  final int selectedIndex;
  final VoidCallback? onQuranTapped;
  final VoidCallback? onAdhkarTapped;
  final VoidCallback? onLibrariesTapped;
  final VoidCallback? onMoreTapped;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.goldenAccentDark : AppColors.maroon800;
    final unselectedColor = isDark ? Colors.white60 : Colors.black54;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          height: kQuranReaderIconNavBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: 'القرآن',
                isSelected: selectedIndex == 0,
                activeColor: primaryColor,
                inactiveColor: unselectedColor,
                onTap: onQuranTapped,
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'الأذكار',
                isSelected: selectedIndex == 1,
                activeColor: primaryColor,
                inactiveColor: unselectedColor,
                onTap: onAdhkarTapped,
              ),
              _NavItem(
                icon: Icons.local_library_rounded,
                label: 'المكتبات',
                isSelected: selectedIndex == 2,
                activeColor: primaryColor,
                inactiveColor: unselectedColor,
                onTap: onLibrariesTapped,
              ),
              _NavItem(
                icon: Icons.more_horiz_rounded,
                label: 'المزيد',
                isSelected: selectedIndex == 3,
                activeColor: primaryColor,
                inactiveColor: unselectedColor,
                onTap: onMoreTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 23,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
