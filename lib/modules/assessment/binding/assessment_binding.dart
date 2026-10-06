import 'package:get/get.dart';

import '../../home/services/job_service.dart';
import '../controller/assessment_controller.dart';

class AssessmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssessmentController>(
          () => AssessmentController(
        Get.find<JobService>(),
      ),
    );
  }
}