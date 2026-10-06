import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/auth_header.dart';
import '../../auth/controller/auth_controller.dart';

class RegisterStepTwoView extends GetView<AuthController> {
  const RegisterStepTwoView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareRoleSelection();
    });

    final keyboardOpen =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AuthHeader(
              title: 'Create Account',
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  controller.showRoleSuggestions.value = false;
                },
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    keyboardOpen ? 26 : 54,
                    24,
                    30,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                      MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.vertical -
                          (keyboardOpen ? 420 : 455),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _buildSteps(),

                          const SizedBox(height: 30),

                          const Text(
                            'Job Preferences',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _buildSearchField(),

                          Obx(
                                () {
                              if (!controller
                                  .showRoleSuggestions.value) {
                                return const SizedBox.shrink();
                              }

                              return _buildRoleSuggestions();
                            },
                          ),

                          const SizedBox(height: 16),

                          Obx(
                                () => _buildSelectedRoles(),
                          ),

                          if (!keyboardOpen) ...[
                            const Spacer(),

                            const SizedBox(height: 40),

                            _buildNextButton(),

                            const SizedBox(height: 36),

                            _buildSignUpText(),

                            const SizedBox(height: 36),

                            _buildDivider(),

                            const SizedBox(height: 38),

                            _buildGoogleLogin(),

                            const SizedBox(height: 40),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepCircle(
            number: '1',
            active: false,
          ),
          SizedBox(
            width: 116,
            child: Row(
              children: List.generate(
                8,
                    (index) => Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _stepCircle(
            number: '2',
            active: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.roleSearchController,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      cursorColor: AppColors.white,
      textInputAction: TextInputAction.search,
      onTap: () {
        if (controller.roleSearchController.text
            .trim()
            .isNotEmpty) {
          controller.showRoleSuggestions.value = true;
        }
      },
      onChanged: controller.searchRoles,
      decoration: InputDecoration(
        hintText: 'Search with title',
        hintStyle: const TextStyle(
          color: AppColors.greyText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.greyText,
          size: 26,
        ),
        suffixIcon: Obx(
              () {
            final showClear =
                controller.roleSearchController.text.isNotEmpty;

            if (!showClear) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: () {
                controller.roleSearchController.clear();
                controller.searchRoles('');
                FocusManager.instance.primaryFocus?.unfocus();
              },
              icon: const Icon(
                Icons.close,
                color: AppColors.greyText,
                size: 20,
              ),
            );
          },
        ),
        filled: true,
        fillColor: AppColors.field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF294D78),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSuggestions() {
    return Obx(
          () {
        if (controller.isRolesLoading.value) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF171C2C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              ),
            ),
          );
        }

        if (controller.rolesError.value.isNotEmpty) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF171C2C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.rolesError.value,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: controller.getRoles,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.filteredRoles.isEmpty) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF171C2C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No matching roles found',
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
            ),
          );
        }

        final visibleRoles =
        controller.filteredRoles.take(6).toList();

        return Container(
          constraints: const BoxConstraints(
            maxHeight: 245,
          ),
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF171C2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF282E40),
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
            ),
            shrinkWrap: true,
            itemCount: visibleRoles.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Color(0xFF282E40),
            ),
            itemBuilder: (context, index) {
              final role = visibleRoles[index];

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    controller.selectRole(role.name);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            role.name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedRoles() {
    if (controller.selectedRoles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: controller.selectedRoles.map(
            (role) {
          return Container(
            padding: const EdgeInsets.fromLTRB(
              14,
              9,
              10,
              9,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF555555),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 145,
                  ),
                  child: Text(
                    role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    controller.removeRole(role);
                  },
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildNextButton() {
    return Obx(
          () => SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
            FocusManager.instance.primaryFocus?.unfocus();

            if (controller.selectedRoles.isEmpty) {
              Get.snackbar(
                'Required',
                'Please select at least one job preference',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            controller.register();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF174A80),
            disabledBackgroundColor:
            const Color(0xFF174A80).withOpacity(.6),
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
            height: 23,
            width: 23,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.white,
            ),
          )
              : const Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Text(
                'Next',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.arrow_forward,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpText() {
    return Center(
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "DON'T HAVE AN ACCOUNT? ",
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'SignUP',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: Color(0xFF686868),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Text(
            'or',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 17,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Color(0xFF686868),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLogin() {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.white,
            child: Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 18),
          Text(
            'Login with Google',
            style: TextStyle(
              color: Color(0xFF555555),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _stepCircle({
    required String number,
    required bool active,
  }) {
    return Container(
      height: 60,
      width: 60,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: Text(
        number,
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}