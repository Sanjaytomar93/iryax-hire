import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/otp_box_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../controller/auth_controller.dart';

class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(title: 'Reset Password'),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 30),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Text(
                      'Enter OTP sent to\n${controller.forgotEmailController.text.trim()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    OtpBoxField(
                      controller: controller.forgotOtpController,
                    ),
                    const SizedBox(height: 28),
                    Obx(
                          () => AppTextField(
                        label: 'New Password',
                        hint: 'New Password',
                        icon: Icons.lock_outline,
                        controller: controller.newPasswordController,
                        obscureText: !controller.isResetPasswordVisible.value,
                        validator: AppValidators.password,
                        suffixIcon: IconButton(
                          onPressed: controller.toggleResetPassword,
                          icon: Icon(
                            controller.isResetPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.greyText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    PrimaryButton(
                      title: 'Reset Password',
                      isLoading: controller.isLoading,
                      onTap: () {
                        if (controller.forgotOtpController.text.trim().length !=
                            4) {
                          Get.snackbar('Error', 'Please enter valid OTP');
                          return;
                        }

                        if (formKey.currentState!.validate()) {
                          controller.resetPassword();
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Get.offAllNamed(AppRoutes.login),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}