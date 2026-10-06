import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _moveNext();
  }

  Future<void> _moveNext() async {
    await Future.delayed(const Duration(seconds: 2));

    debugPrint('SplashController: isLoggedIn = ${StorageService.isLoggedIn}');

    if (StorageService.isLoggedIn) {
      debugPrint('SplashController: navigating to Home');
      Get.offAllNamed(AppRoutes.home);
    } else {
      debugPrint('SplashController: navigating to Onboarding');
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}