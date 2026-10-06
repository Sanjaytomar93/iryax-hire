import 'package:get/get.dart';

import '../../core/services/api_service.dart';
import '../../modules/auth/controller/auth_controller.dart';
import '../../modules/auth/services/auth_service.dart';
import '../../modules/home/controller/home_controller.dart';
import '../../modules/home/services/job_service.dart';
import '../../modules/onboarding/controller/onboarding_controller.dart';
import '../../modules/profile/services/profile_service.dart';
import '../../modules/splash/controller/splash_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(
      ApiService(),
      permanent: true,
    );

    Get.put<AuthService>(
      AuthService(Get.find<ApiService>()),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(Get.find<AuthService>()),
      permanent: true,
    );

    Get.put<ProfileService>(
      ProfileService(Get.find<ApiService>().dio),
      permanent: true,
    );

    Get.put<JobService>(
      JobService(Get.find<ApiService>().dio),
      permanent: true,
    );

    Get.put<HomeController>(
      HomeController(Get.find<JobService>()),
      permanent: true,
    );


  }
}