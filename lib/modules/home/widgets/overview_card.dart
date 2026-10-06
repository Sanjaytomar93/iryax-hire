import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class OverviewCard extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onTap;

  const OverviewCard({
    super.key,
    required this.title,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(
            14,
            13,
            12,
            12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1D33),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Padding(
                padding:
                const EdgeInsets.only(right: 24),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const Positioned(
                right: -3,
                top: -6,
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.white,
                  size: 25,
                ),
              ),

              Positioned(
                left: 0,
                bottom: 0,
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
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