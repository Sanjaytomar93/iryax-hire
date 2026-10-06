import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileStepperWidget extends StatelessWidget {
  final int currentStep;
  final double progress;

  const ProfileStepperWidget({
    super.key,
    required this.currentStep,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _step(1, 'Personal\ndetails'),
              _line(currentStep >= 2),
              _step(2, 'Education\ndetails'),
              _line(currentStep >= 3),
              _step(3, 'Professional\ndetails'),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Your Profile ${(progress * 100).toInt()}% Completed',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(int step, String title) {
    final active = currentStep >= step;

    return Column(
      children: [
        Container(
          height: 32,
          width: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: TextStyle(
              color: active ? AppColors.white : AppColors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 11,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  Widget _line(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 35),
        color: active ? AppColors.primary : AppColors.white,
      ),
    );
  }
}