import 'package:get/get.dart';

import '../controller/personal_documents_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/education_controller.dart';
import '../controller/experience_controller.dart';
import '../controller/medical_certificate_controller.dart';
import '../controller/wallet_controller.dart';
import '../services/profile_service.dart';

class ProfileBinding
    extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
          () => ProfileController(
        Get.find<ProfileService>(),
      ),
    );

    Get.lazyPut(
          () => EducationController(
        Get.find<ProfileService>(),
      ),
    );

    Get.lazyPut(
          () => ExperienceController(
        Get.find<ProfileService>(),
      ),
    );

    Get.lazyPut(
          () =>
          MedicalCertificateController(
            Get.find<ProfileService>(),
          ),
    );
    Get.lazyPut<WalletController>(
          () => WalletController(Get.find<ProfileService>()),
    );


    Get.lazyPut<PersonalDocumentsController>(
          () => PersonalDocumentsController(
        Get.find<ProfileService>(),
      ),
    );

  }
}