import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_form_field.dart';
import '../widgets/profile_stepper_widget.dart';

class PersonalDetailsView extends GetView<ProfileController> {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,

      // Fixed header
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

      body: Obx(
            () {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            );
          }

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              22,
              16,
              22,
              36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileStepperWidget(
                  currentStep: 1,
                  progress: 0.30,
                ),

                const SizedBox(height: 24),

                ProfileFormField(
                  label: 'Full Name',
                  hint: 'Enter full name',
                  controller: controller.nameController,
                ),

                const SizedBox(height: 14),

                ProfileFormField(
                  label: 'Email',
                  hint: 'Enter email',
                  controller: controller.emailController,
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                ProfileFormField(
                  label: 'Phone Number',
                  hint: 'Enter phone number',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                ProfileFormField(
                  label: 'Gender',
                  hint: 'Male / Female / Other',
                  controller: controller.genderController,
                ),

                const SizedBox(height: 14),

                ProfileFormField(
                  label: 'Date Of Birth',
                  hint: 'YYYY-MM-DD',
                  controller: controller.dobController,
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    final currentDate =
                    DateTime.tryParse(controller.dobController.text);

                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1970),
                      lastDate: DateTime.now(),
                      initialDate: currentDate ?? DateTime(2000),
                    );

                    if (picked != null) {
                      controller.dobController.text =
                      '${picked.year}-'
                          '${picked.month.toString().padLeft(2, '0')}-'
                          '${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.greyText,
                    size: 20,
                  ),
                ),

                const SizedBox(height: 14),

                ProfileFormField(
                  label: 'Current Address',
                  hint: 'Enter current address',
                  controller: controller.addressController,
                ),

                const SizedBox(height: 14),

                ProfileFormField(
                  label: 'City',
                  hint: 'Enter city',
                  controller: controller.cityController,
                ),

                const SizedBox(height: 14),

                ProfileFormField(
                  label: 'State',
                  hint: 'Enter state',
                  controller: controller.stateController,
                ),

                const SizedBox(height: 14),

                ProfileFormField(
                  label: 'Pincode',
                  hint: 'Enter pincode',
                  controller: controller.pincodeController,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),

                Center(
                  child: SizedBox(
                    width: 180,
                    child: PrimaryButton(
                      title: 'Save',
                      isLoading: controller.isSaving,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        controller.updateBasicDetails();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
                AppRoutes.educationDetails,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Next',
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