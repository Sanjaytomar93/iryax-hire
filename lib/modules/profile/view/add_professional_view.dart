import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../controller/experience_controller.dart';
import '../widgets/profile_form_field.dart';

class AddProfessionalView
    extends GetView<ExperienceController> {
  const AddProfessionalView({super.key});

  Future<void> _pickDate(
      BuildContext context,
      TextEditingController textController,
      ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      textController.text =
      '${picked.year}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit =
        controller.editingExperience != null;

    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,

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
            child: _topBar(isEdit),
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior:
        ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          22,
          18,
          22,
          36,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            ProfileFormField(
              label: 'Company Name',
              hint: 'Timely Health',
              controller:
              controller.companyController,
            ),

            const SizedBox(height: 16),

            ProfileFormField(
              label: 'Role',
              hint: 'UI/UX Designer',
              controller:
              controller.roleController,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ProfileFormField(
                    label: 'Location',
                    hint: 'Hyderabad',
                    controller:
                    controller.locationController,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ProfileFormField(
                    label: 'Salary',
                    hint: 'e.g. 50,000',
                    controller:
                    controller.salaryController,
                    keyboardType:
                    TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ProfileFormField(
                    label: 'Start Date',
                    hint: 'DD-MM-YYYY',
                    controller:
                    controller.startDateController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      context,
                      controller.startDateController,
                    ),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.greyText,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Obx(
                        () => ProfileFormField(
                      label: 'End Date',
                      hint: 'DD-MM-YYYY',
                      controller:
                      controller.endDateController,
                      readOnly: true,
                      onTap: controller
                          .isCurrentlyWorking.value
                          ? null
                          : () => _pickDate(
                        context,
                        controller
                            .endDateController,
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.greyText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Obx(
                  () => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller
                      .isCurrentlyWorking.value =
                  !controller
                      .isCurrentlyWorking.value;

                  if (controller
                      .isCurrentlyWorking.value) {
                    controller.endDateController
                        .clear();
                  }
                },
                child: Row(
                  children: [
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(7),
                        border: Border.all(
                          color: AppColors.white,
                          width: 1.5,
                        ),
                        color: controller
                            .isCurrentlyWorking
                            .value
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                      child: controller
                          .isCurrentlyWorking
                          .value
                          ? const Icon(
                        Icons.check,
                        color:
                        AppColors.white,
                        size: 18,
                      )
                          : null,
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'I am Currently Working Here',
                        style: TextStyle(
                          color:
                          AppColors.white,
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            const _UploadTile(
              title: 'Offer Letter',
            ),

            const SizedBox(height: 14),

            const _UploadTile(
              title: 'Pay Slip',
            ),

            const SizedBox(height: 14),

            const _UploadTile(
              title: 'Relieving Letter',
            ),

            const SizedBox(height: 14),

            const _UploadTile(
              title: 'Other Documents',
            ),

            const SizedBox(height: 40),

            Center(
              child: SizedBox(
                width: 180,
                child: PrimaryButton(
                  title:
                  isEdit ? 'Update' : 'Save',
                  isLoading:
                  controller.isSaving,
                  onTap:
                  controller.saveExperience,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(
      bool isEdit,
      ) {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            height: 44,
            width: 44,
            decoration:
            const BoxDecoration(
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

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            isEdit
                ? 'Edit Professional Details'
                : 'Professional Details',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String title;

  const _UploadTile({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.upload_outlined,
            color: AppColors.greyText,
            size: 21,
          ),

          const SizedBox(width: 12),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}