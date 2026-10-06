import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  void goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }
}