import 'package:get/get.dart';

import '../../home/services/job_service.dart';
import '../controller/applications_controller.dart';

class OfferLettersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApplicationsController>()) {
      Get.lazyPut<ApplicationsController>(
            () => ApplicationsController(
          Get.find<JobService>(),
        ),
      );
    }
  }
}