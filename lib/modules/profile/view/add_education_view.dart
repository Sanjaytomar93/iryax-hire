import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../controller/education_controller.dart';
import '../widgets/profile_form_field.dart';

class AddEducationView extends GetView<EducationController> {
  const AddEducationView({super.key});

  Future<void> _pickDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      controller.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit =
        controller.editingEducation != null;

    return Scaffold(
      backgroundColor: AppColors.black,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: Container(
            color: AppColors.black,
            padding: const EdgeInsets.fromLTRB(
                22, 10, 22, 8),
            child: _topBar(isEdit),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.fromLTRB(22, 18, 22, 30),
        child: Column(
          children: [
            ProfileFormField(
              label: "Qualification",
              hint: "B.Tech",
              controller:
              controller.qualificationController,
            ),

            const SizedBox(height: 16),

            ProfileFormField(
              label: "Institution",
              hint: "Institution name",
              controller:
              controller.institutionController,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ProfileFormField(
                    label: "Start Date",
                    hint: "DD-MM-YYYY",
                    controller:
                    controller.startDateController,
                    readOnly: true,
                    onTap: () => _pickDate(
                        context,
                        controller
                            .startDateController),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.greyText,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ProfileFormField(
                    label: "End Date",
                    hint: "DD-MM-YYYY",
                    controller:
                    controller.endDateController,
                    readOnly: true,
                    onTap: () => _pickDate(
                        context,
                        controller.endDateController),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.greyText,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ProfileFormField(
                    label: "Passing Year",
                    hint: "2024",
                    controller:
                    controller.passingYearController,
                    keyboardType:
                    TextInputType.number,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ProfileFormField(
                    label: "Location",
                    hint: "Hyderabad",
                    controller:
                    controller.locationController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ProfileFormField(
              label: "Score (%)",
              hint: "85",
              controller:
              controller.percentageController,
              keyboardType:
              TextInputType.number,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: 180,
              child: PrimaryButton(
                title:
                isEdit ? "Update" : "Save",
                isLoading: controller.isSaving,
                onTap: controller.saveEducation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(bool isEdit) {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            width: 44,
            height: 44,
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

        Expanded(
          child: Text(
            isEdit
                ? "Edit Education"
                : "Education Details",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}