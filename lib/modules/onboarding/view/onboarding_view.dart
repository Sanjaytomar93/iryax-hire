import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/logo_widget.dart';
import '../controller/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: AppColors.black.withOpacity(0.72),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 36),

                  const Center(
                    child: LogoWidget(
                      vertical: true,
                      size: 74,
                      textSize: 27,
                    ),
                  ),

                  const Spacer(flex: 5),

                  const Text(
                    'Step into your future career.',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Access your personalized dashboard to track '
                        'applications and complete assessments.',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: 168,
                    height: 46,
                    child: Stack(
                      children: [
                        _avatar('assets/images/avatar1.png', 0),
                        _avatar('assets/images/avatar2.png', 28),
                        _avatar('assets/images/avatar3.png', 56),
                        _avatar('assets/images/avatar4.png', 84),

                        Positioned(
                          left: 112,
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '+2K',
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'JOINED BY 2000+ TOP CANDIDATES',
                    style: TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Spacer(flex: 7),

                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: controller.goToLogin,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 70,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 34),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _avatar(String path, double left) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: AppColors.white,
        backgroundImage: AssetImage(path),
      ),
    );
  }
}