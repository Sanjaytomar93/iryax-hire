import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_bottom_links.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/controller/auth_controller.dart';

class RegisterEmailView extends GetView<AuthController> {
  const RegisterEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                const AuthHeader(title: 'Register'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Email Address',
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          controller: controller.registerEmailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidators.email,
                        ),
                        const SizedBox(height: 30),
                        PrimaryButton(
                          title: 'Send OTP',
                          isLoading: controller.isLoading,
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();

                            if (formKey.currentState!.validate()) {
                              controller.sendRegisterOtp();
                            }
                          },
                        ),
                        const SizedBox(height: 34),
                        AuthBottomLinks(
                          showGoogle: false,
                          accountText: 'ALREADY HAVE AN ACCOUNT?',
                          actionText: 'Login',
                          onActionTap: () => Get.offAllNamed(AppRoutes.login),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}