import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/controller/home_controller.dart';

class AssessmentSuccessView extends StatelessWidget {
  const AssessmentSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final message = Get.arguments?['message']?.toString() ??
        'Assessment submitted successfully';

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 40, 26, 40),
          child: Column(
            children: [
              const Spacer(),

              Container(
                height: 96,
                width: 96,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 58,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Assessment Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    await Get.offAllNamed(AppRoutes.home);

                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>().silentRefresh();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back To Home',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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