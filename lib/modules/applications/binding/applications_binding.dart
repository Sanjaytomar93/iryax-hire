import 'package:get/get.dart';

import '../../home/services/job_service.dart';
import '../controller/applications_controller.dart';

class ApplicationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationsController>(
          () => ApplicationsController(Get.find<JobService>()),
      fenix: true,
    );
  }
}