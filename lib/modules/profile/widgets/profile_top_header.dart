import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileTopHeader extends StatelessWidget {
  const ProfileTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.header,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -90,
            top: -190,
            child: Container(
              height: 360,
              width: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.headerCircle.withOpacity(0.55),
              ),
            ),
          ),
          Positioned(
            left: -70,
            top: -115,
            child: Container(
              height: 190,
              width: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}