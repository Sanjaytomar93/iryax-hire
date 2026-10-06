import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(title: 'Forgot Password'),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 45, 28, 30),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Text(
                      'Enter your registered email address.\nWe will send OTP to reset your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 34),
                    AppTextField(
                      label: 'Email Address',
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      controller: controller.forgotEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.email,
                    ),
                    const SizedBox(height: 36),
                    PrimaryButton(
                      title: 'Send OTP',
                      isLoading: controller.isLoading,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          controller.forgotPassword();
                        }
                      },
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