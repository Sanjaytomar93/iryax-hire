import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../home/controller/home_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../model/role_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService authService;

  AuthController(this.authService);

  final isLoading = false.obs;

  final isLoginPasswordVisible = false.obs;
  final isRegisterPasswordVisible = false.obs;
  final isResetPasswordVisible = false.obs;

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final registerEmailController = TextEditingController();
  final registerOtpController = TextEditingController();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final passwordController = TextEditingController();
  final qualificationController = TextEditingController();

  final forgotEmailController = TextEditingController();
  final forgotOtpController = TextEditingController();
  final newPasswordController = TextEditingController();

  final roleSearchController = TextEditingController();

  final allRoles = <RoleModel>[].obs;
  final filteredRoles = <RoleModel>[].obs;

  final isRolesLoading = false.obs;
  final rolesError = ''.obs;
  final showRoleSuggestions = false.obs;

  final selectedRoles = <String>[].obs;

  String registerEmail = '';

  void toggleLoginPassword() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void toggleRegisterPassword() {
    isRegisterPasswordVisible.value = !isRegisterPasswordVisible.value;
  }

  void toggleResetPassword() {
    isResetPasswordVisible.value = !isResetPasswordVisible.value;
  }

  Future<void> sendRegisterOtp() async {
    try {
      isLoading.value = true;

      final email = registerEmailController.text.trim();

      final response = await authService.sendRegisterOtp(email);

      if (response.data['success'] == true) {
        registerEmail = email;
        registerOtpController.clear();

        Get.toNamed(AppRoutes.registerOtp);

        Get.snackbar(
          'Success',
          response.data['message'] ?? 'OTP sent successfully',
        );
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      Get.snackbar('Error', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyRegisterOtp(String otp) async {
    try {
      isLoading.value = true;

      final response = await authService.verifyRegisterOtp(
        email: registerEmail,
        otp: otp,
      );

      if (response.data['success'] == true) {
        Get.offNamed(AppRoutes.registerStepOne);

        Get.snackbar(
          'Success',
          response.data['message'] ?? 'Email verified successfully',
        );
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Invalid OTP',
        );
      }
    } catch (e) {
      Get.snackbar('Error', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendRegisterOtp() async {
    try {
      isLoading.value = true;

      final email = registerEmail.isNotEmpty
          ? registerEmail
          : registerEmailController.text.trim();

      final response = await authService.resendOtp(email);

      Get.snackbar(
        response.data['success'] == true ? 'Success' : 'Error',
        response.data['message'] ?? 'OTP resent successfully',
      );
    } catch (e) {
      Get.snackbar('Error', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    try {
      isLoading.value = true;

      final fcmToken = await NotificationService.getFcmToken();


      final response = await authService.register(
        name: fullNameController.text.trim(),
        email: registerEmail,
        phone: phoneController.text.trim(),
        address: locationController.text.trim(),
        password: passwordController.text.trim(),
        qualification: qualificationController.text.trim(),
        roles: selectedRoles.toList(),
        fcmToken: fcmToken,

      );

      if (response.data['success'] == true) {
        final token = (response.data['token'] ?? '').toString();

        if (token.isEmpty) {
          Get.snackbar('Error', 'Token missing from registration response');
          return;
        }

        await StorageService.saveToken(token);

        if (response.data['candidate'] != null) {
          await StorageService.saveCandidate(response.data['candidate']);
        }

        _clearRegisterData();

        await _openHomeAfterAuthentication();

        // Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar(
          'Registration Failed',
          response.data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      Get.snackbar('Registration Failed', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> getRoles() async {
    try {
      isRolesLoading.value = true;
      rolesError.value = '';

      final response = await authService.getRoles();
      final responseData = response.data;

      if (responseData is Map &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        final list = responseData['data'] as List;

        final loadedRoles = list
            .whereType<Map>()
            .map(
              (item) => RoleModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .where((role) => role.name.isNotEmpty)
            .toList();

        // Remove duplicate names returned by API.
        final uniqueRoles = <String, RoleModel>{};

        for (final role in loadedRoles) {
          uniqueRoles[role.name.toLowerCase()] = role;
        }

        final sortedRoles = uniqueRoles.values.toList()
          ..sort(
                (a, b) => a.name
                .toLowerCase()
                .compareTo(b.name.toLowerCase()),
          );

        allRoles.assignAll(sortedRoles);
        filteredRoles.assignAll(sortedRoles);
      } else {
        rolesError.value =
        responseData is Map
            ? responseData['message']?.toString() ??
            'Unable to load roles'
            : 'Unable to load roles';
      }
    } catch (e) {
      rolesError.value = _getErrorMessage(e);
    } finally {
      isRolesLoading.value = false;
    }
  }

  void searchRoles(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredRoles.assignAll(allRoles);
      showRoleSuggestions.value = false;
      return;
    }

    filteredRoles.assignAll(
      allRoles.where(
            (role) =>
        role.name.toLowerCase().contains(query) &&
            !selectedRoles.contains(role.name),
      ),
    );

    showRoleSuggestions.value = true;
  }

  void selectRole(String role) {
    if (!selectedRoles.contains(role)) {
      selectedRoles.add(role);
    }

    roleSearchController.clear();
    filteredRoles.assignAll(allRoles);
    showRoleSuggestions.value = false;

    FocusManager.instance.primaryFocus?.unfocus();
  }

  void removeRole(String role) {
    selectedRoles.remove(role);

    if (roleSearchController.text.trim().isNotEmpty) {
      searchRoles(roleSearchController.text);
    }
  }

  bool isRoleSelected(String role) {
    return selectedRoles.contains(role);
  }

  Future<void> login() async {
    try {
      isLoading.value = true;

      final response = await authService.login(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      if (response.data['success'] == true) {
        final token =
        (response.data['token'] ?? '').toString();

        if (token.isEmpty) {
          Get.snackbar(
            'Error',
            'Token missing from login response',
          );
          return;
        }

        await StorageService.saveToken(token);

        final candidate = response.data['candidate'];

        if (candidate is Map) {
          await StorageService.saveCandidate(
            Map<String, dynamic>.from(candidate),
          );
        }

        debugPrint(
          '🟢 LOGIN TOKEN SAVED: ${StorageService.getToken().isNotEmpty}',
        );

        debugPrint(
          '🟢 LOGIN CANDIDATE SAVED: ${StorageService.getCandidate()}',
        );

        loginPasswordController.clear();

        await _openHomeAfterAuthentication();
      }else {
        Get.snackbar(
          'Login Failed',
          response.data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      Get.snackbar('Login Failed', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> _openHomeAfterAuthentication() async {
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }

    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }

    await Get.offAllNamed(AppRoutes.home);

    // Wait until Home route binding creates HomeController.
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().loadHome();
    } else {
      debugPrint(
        '🔴 HomeController was not created by Home route binding',
      );
    }
  }

  Future<void> forgotPassword() async {
    try {
      isLoading.value = true;

      final response = await authService.forgotPassword(
        forgotEmailController.text.trim(),
      );

      if (response.data['success'] == true) {
        forgotOtpController.clear();
        newPasswordController.clear();

        Get.toNamed(AppRoutes.resetPassword);

        Get.snackbar(
          'Success',
          response.data['message'] ?? 'OTP sent successfully',
        );
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      Get.snackbar('Error', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    try {
      isLoading.value = true;

      final response = await authService.resetPassword(
        email: forgotEmailController.text.trim(),
        otp: forgotOtpController.text.trim(),
        password: newPasswordController.text.trim(),
      );

      if (response.data['success'] == true) {
        forgotEmailController.clear();
        forgotOtpController.clear();
        newPasswordController.clear();

        FocusManager.instance.primaryFocus?.unfocus();


        Get.offAllNamed(AppRoutes.login);

        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            'Success',
            response.data['message'] ?? 'Password reset successfully',
          );
        });
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Password reset failed',
        );
      }
    } catch (e) {
      Get.snackbar('Error', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void addRole(String role) {
    selectRole(role);
  }
  //
  // void removeRole(String role) {
  //   selectedRoles.remove(role);
  // }

  void prepareRoleSelection() {
    roleSearchController.clear();
    showRoleSuggestions.value = false;

    if (allRoles.isEmpty && !isRolesLoading.value) {
      getRoles();
    }
  }

  void _clearRegisterData() {
    registerEmailController.clear();
    registerOtpController.clear();
    fullNameController.clear();
    phoneController.clear();
    locationController.clear();
    passwordController.clear();
    qualificationController.clear();
    roleSearchController.clear();

    selectedRoles.clear();
    filteredRoles.assignAll(allRoles);

    showRoleSuggestions.value = false;
    registerEmail = '';
  }


  String _getErrorMessage(dynamic error) {
    try {
      final response = error.response;
      if (response != null && response.data != null) {
        final data = response.data;

        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
      }
    } catch (_) {}

    return error.toString();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // @override
  // void onClose() {
  //   loginEmailController.dispose();
  //   loginPasswordController.dispose();
  //
  //   registerEmailController.dispose();
  //   registerOtpController.dispose();
  //
  //   fullNameController.dispose();
  //   phoneController.dispose();
  //   locationController.dispose();
  //   passwordController.dispose();
  //   qualificationController.dispose();
  //
  //   forgotEmailController.dispose();
  //   forgotOtpController.dispose();
  //   newPasswordController.dispose();
  //
  //   super.onClose();
  // }
}