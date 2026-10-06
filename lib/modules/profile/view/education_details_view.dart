import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/education_controller.dart';
import '../widgets/education_card_widget.dart';
import '../widgets/profile_stepper_widget.dart';

class EducationDetailsView extends GetView<EducationController> {
  const EducationDetailsView({super.key});

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
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
            child: _topBar(),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          children: [
            const ProfileStepperWidget(
              currentStep: 2,
              progress: .60,
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  controller.clearForm();
                  Get.toNamed(AppRoutes.addEducation);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '+ Add Education',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  );
                }

                if (controller.educations.isEmpty) {
                  return const Center(
                    child: Text(
                      'No education added yet',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.educations.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    return EducationCardWidget(
                      education: controller.educations[index],
                    );
                  },
                );
              }),
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
              color: Color(0xff211F20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Text(
            "Education Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Obx(() {
          return SizedBox(
            width: 84,
            height: 38,
            child: ElevatedButton(
              onPressed: controller.educations.isEmpty
                  ? null
                  : () => Get.toNamed(
                AppRoutes.professionalDetails,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                AppColors.field,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 14),
              ),
            ),
          );
        }),
      ],
    );
  }
}