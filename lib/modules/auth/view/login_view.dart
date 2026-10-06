import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_bottom_links.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../controller/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
  }

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
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Candidate Login',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),

                      AppTextField(
                        label: 'EMAIL ADDRESS',
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        controller: controller.loginEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.email,
                      ),

                      const SizedBox(height: 28),

                      Obx(
                            () => AppTextField(
                          label: 'PASSWORD',
                          hint: '* * * * ',
                          icon: Icons.lock_outline,
                          controller: controller.loginPasswordController,
                          obscureText: !controller.isLoginPasswordVisible.value,
                          validator: AppValidators.password,
                          suffixIcon: IconButton(
                            onPressed: controller.toggleLoginPassword,
                            icon: Icon(
                              controller.isLoginPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.greyText,
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.forgotPassword),
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: AppColors.greyText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 38),

                      PrimaryButton(
                        title: 'LOGIN',
                        isLoading: controller.isLoading,
                        onTap: () {
                          FocusScope.of(context).unfocus();

                          if (formKey.currentState!.validate()) {
                            controller.login();
                          }
                        },
                      ),

                      const SizedBox(height: 42),

                      AuthBottomLinks(
                        showGoogle: false,
                        accountText: "DON’T HAVE AN ACCOUNT?",
                        actionText: 'SignUP',
                        onActionTap: () => Get.toNamed(AppRoutes.registerEmail),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}