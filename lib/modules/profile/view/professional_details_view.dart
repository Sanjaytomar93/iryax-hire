import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/experience_controller.dart';
import '../widgets/experience_card_widget.dart';
import '../widgets/profile_stepper_widget.dart';

class ProfessionalDetailsView extends GetView<ExperienceController> {
  const ProfessionalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: Container(
            color: AppColors.black,
            padding: const EdgeInsets.fromLTRB(
              22,
              10,
              22,
              8,
            ),
            child: _topBar(),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          22,
          16,
          22,
          24,
        ),
        child: Column(
          children: [
            const ProfileStepperWidget(
              currentStep: 3,
              progress: 0.80,
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  controller.clearForm();
                  Get.toNamed(
                    AppRoutes.addProfessional,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child: const Text(
                  '+ Add Professional details',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Obx(
                    () {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                      ),
                    );
                  }

                  if (controller.experiences.isEmpty) {
                    return const Center(
                      child: Text(
                        'No professional details added',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics:
                    const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount:
                    controller.experiences.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      return ExperienceCardWidget(
                        experience:
                        controller.experiences[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF211F20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ),

        const Spacer(),

        SizedBox(
          width: 84,
          height: 38,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(
                AppRoutes.profile,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}