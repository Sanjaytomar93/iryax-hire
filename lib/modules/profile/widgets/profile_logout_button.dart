import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const ProfileLogoutButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 242,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.logout,
          color: AppColors.white,
          size: 20,
        ),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}