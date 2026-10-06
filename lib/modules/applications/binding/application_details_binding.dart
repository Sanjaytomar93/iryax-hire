import 'package:get/get.dart';

import '../../home/services/job_service.dart';
import '../controller/application_details_controller.dart';

class ApplicationDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationDetailsController>(
          () => ApplicationDetailsController(
        Get.find<JobService>(),
      ),
    );
  }
}