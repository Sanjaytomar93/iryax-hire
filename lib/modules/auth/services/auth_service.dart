import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';

class AuthService {
  final ApiService api;

  AuthService(this.api);

  Future<Response> getRoles() {
    return api.get(
      ApiConstants.allRoles,
    );
  }

  Future<Response> sendRegisterOtp(String email) {
    return api.post(
      ApiConstants.sendRegisterOtp,
      data: {
        'email': email,
      },
    );
  }

  Future<Response> verifyRegisterOtp({
    required String email,
    required String otp,
  }) {
    return api.post(
      ApiConstants.verifyRegisterOtp,
      data: {
        'email': email,
        'otp': otp,
      },
    );
  }

  Future<Response> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String qualification,
    required List<String> roles,
    String? fcmToken,
  }) {
    return api.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'password': password,
        'highestQualification': qualification,
        'role': roles.join(', '),
        'fcmToken': fcmToken ?? '',
      },
    );
  }

  Future<Response> login({
    required String email,
    required String password,
  }) {
    return api.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> resendOtp(String email) {
    return api.post(
      ApiConstants.resendOtp,
      data: {
        'email': email,
      },
    );
  }

  Future<Response> forgotPassword(String email) {
    return api.post(
      ApiConstants.forgotPassword,
      data: {
        'email': email,
      },
    );
  }

  Future<Response> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) {
    return api.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'newPassword': password,
      },
    );
  }
}