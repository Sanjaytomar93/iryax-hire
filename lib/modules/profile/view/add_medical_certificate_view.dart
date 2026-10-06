import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../controller/medical_certificate_controller.dart';

class AddMedicalCertificateView extends GetView<MedicalCertificateController> {
  const AddMedicalCertificateView({super.key});

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
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      controller.selectedCertificate.value = File(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 42),

              const Text(
                'Health Profile Data',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.fromLTRB(12, 28, 12, 30),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DateBox(
                            label: 'Registration Date',
                            hint: 'DD-MM-YYYY',
                            controller: controller.registrationDateController,
                            onTap: () => _pickDate(
                              context,
                              controller.registrationDateController,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateBox(
                            label: 'Expire Date',
                            hint: 'YYYY-MM-DD',
                            controller: controller.expiryDateController,
                            onTap: () => _pickDate(
                              context,
                              controller.expiryDateController,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Obx(
                          () => GestureDetector(
                        onTap: _pickDocument,
                        child: Container(
                          height: 64,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF252323),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.upload,
                                color: AppColors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  controller.selectedCertificate.value == null
                                      ? 'Upload Document'
                                      : controller.selectedCertificate.value!.path
                                      .split('/')
                                      .last,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 58),

              Center(
                child: SizedBox(
                  width: 250,
                  height: 62,
                  child: PrimaryButton(
                    title: 'Submit',
                    isLoading: controller.isSaving,
                    onTap: controller.uploadMedicalCertificate,
                  ),
                ),
              ),
            ],
          ),
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
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF211F20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Medical Certificate',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _DateBox({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF302D2D),
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.greyText,
              fontSize: 12,
            ),
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.white,
              size: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 02,
              vertical: 17,
            ),
          ),
        ),
      ],
    );
  }
}