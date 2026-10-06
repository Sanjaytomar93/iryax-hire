import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onEdit;

  const ProfileAvatarWidget({
    super.key,
    this.imageUrl,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.75),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.white,
            backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
            child: hasImage
                ? null
                : const Icon(
              Icons.person,
              color: AppColors.black,
              size: 52,
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: -8,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                color: Color(0xFF4A4A4A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: AppColors.black,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}