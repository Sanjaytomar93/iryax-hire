import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/auth_bottom_links.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/otp_box_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/controller/auth_controller.dart';

class RegisterOtpView extends GetView<AuthController> {
  const RegisterOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              const AuthHeader(title: 'Let’s Get Started!'),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Verify Email',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter OTP',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OtpBoxField(
                      controller: controller.registerOtpController,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: controller.resendRegisterOtp,
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'We Sent A 4-Digit Code To ${controller.registerEmail}.',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      title: 'Verify',
                      isLoading: controller.isLoading,
                      onTap: () {
                        FocusScope.of(context).unfocus();

                        final otp = controller.registerOtpController.text.trim();

                        if (otp.length != 4) {
                          Get.snackbar('Error', 'Please enter valid OTP');
                          return;
                        }

                        controller.verifyRegisterOtp(otp);
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthBottomLinks(
                      accountText: "DON’T HAVE AN ACCOUNT?",
                      actionText: 'SignUP',
                      onActionTap: () => Get.offAllNamed(AppRoutes.registerEmail),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}