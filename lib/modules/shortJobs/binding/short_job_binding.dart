import 'package:get/get.dart';

import '../../home/services/job_service.dart';
import '../controller/short_jobs_controller.dart';
import '../view/short_jobs_view.dart';

class ShortJobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShortJobsController>(
          () => ShortJobsController(
        Get.find<JobService>(),
      ),
    );
  }
}