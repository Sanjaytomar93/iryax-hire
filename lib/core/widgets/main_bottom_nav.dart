import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../constants/app_colors.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onTap(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Get.offAllNamed(AppRoutes.home);
        break;
      case 1:
        Get.offAllNamed(AppRoutes.explore);
        break;
      case 2:
        Get.offAllNamed(AppRoutes.shortJobs);
        break;
      case 3:
        Get.offAllNamed(AppRoutes.applications);
        break;
      case 4:
        Get.offAllNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width / 5;

    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0xFF242222),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            width: itemWidth,
            icon: Icons.home_outlined,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => _onTap(0),
          ),
          _NavItem(
            width: itemWidth,
            icon: Icons.search,
            label: 'Explore',
            selected: currentIndex == 1,
            onTap: () => _onTap(1),
          ),
          _NavItem(
            width: itemWidth,
            icon: Icons.work_outline,
            label: 'Short Jobs',
            selected: currentIndex == 2,
            onTap: () => _onTap(2),
          ),
          _NavItem(
            width: itemWidth,
            icon: Icons.grid_view_outlined,
            label: 'Applications',
            selected: currentIndex == 3,
            onTap: () => _onTap(3),
          ),
          _NavItem(
            width: itemWidth,
            icon: Icons.person_outline,
            label: 'Profile',
            selected: currentIndex == 4,
            onTap: () => _onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.width,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 82,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (selected)
              Positioned(
                top: -30,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      height: 54,
                      width: 54,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A2828),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),

            if (!selected)
              Positioned(
                top: 18,
                child: Icon(
                  icon,
                  color: AppColors.greyText,
                  size: 27,
                ),
              ),

            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.white : AppColors.greyText,
                  fontSize: label == 'Applications' ? 11 : 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}