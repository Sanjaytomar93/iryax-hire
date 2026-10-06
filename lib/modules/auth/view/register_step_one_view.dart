import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/controller/auth_controller.dart';

class RegisterStepOneView extends StatefulWidget {
  const RegisterStepOneView({super.key});

  @override
  State<RegisterStepOneView> createState() => _RegisterStepOneViewState();
}

class _RegisterStepOneViewState extends State<RegisterStepOneView> {
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const AuthHeader(
                title: 'Create Account',
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  30,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Name',
                        icon: Icons.person_outline,
                        controller: controller.fullNameController,
                        validator: (value) => AppValidators.required(
                          value,
                          'Full name is required',
                        ),
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Mobile Number',
                        hint: 'Mobile Number',
                        icon: Icons.phone_outlined,
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        validator: AppValidators.phone,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Location',
                        hint: 'Location',
                        icon: Icons.location_on_outlined,
                        controller: controller.locationController,
                        validator: (value) => AppValidators.required(
                          value,
                          'Location is required',
                        ),
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Highest Qualification',
                        hint: 'B.Tech / Degree / MBA',
                        icon: Icons.school_outlined,
                        controller: controller.qualificationController,
                        validator: (value) => AppValidators.required(
                          value,
                          'Qualification is required',
                        ),
                      ),

                      const SizedBox(height: 16),

                      Obx(
                            () => AppTextField(
                          label: 'Password',
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          controller: controller.passwordController,
                          obscureText:
                          !controller.isRegisterPasswordVisible.value,
                          validator: AppValidators.password,
                          suffixIcon: IconButton(
                            onPressed:
                            controller.toggleRegisterPassword,
                            icon: Icon(
                              controller.isRegisterPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.greyText,
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      PrimaryButton(
                        title: 'Next',
                        onTap: () {
                          FocusScope.of(context).unfocus();

                          if (formKey.currentState?.validate() ?? false) {
                            Get.toNamed(
                              AppRoutes.registerStepTwo,
                            );
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
      ),
    );
  }
}