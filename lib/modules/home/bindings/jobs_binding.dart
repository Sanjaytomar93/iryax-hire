import 'package:get/get.dart';

import '../../jobs/controller/apply_job_controller.dart';
import '../../jobs/controller/job_details_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/services/profile_service.dart';
import '../controller/explore_controller.dart';
import '../controller/home_controller.dart';
import '../services/job_service.dart';

class JobsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<JobService>()) {
      Get.lazyPut<JobService>(
            () => JobService(
          Get.find(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(
            () => ProfileController(
          Get.find<ProfileService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
            () => HomeController(
          Get.find<JobService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ExploreController>()) {
      Get.lazyPut<ExploreController>(
            () => ExploreController(
          Get.find<JobService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<JobDetailsController>()) {
      Get.lazyPut<JobDetailsController>(
            () => JobDetailsController(
          Get.find<JobService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ApplyJobController>()) {
      Get.lazyPut<ApplyJobController>(
            () => ApplyJobController(
          Get.find<JobService>(),
        ),
        fenix: true,
      );
    }
  }
}