import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../model/candidate_profile_model.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService profileService;

  ProfileController(this.profileService);

  final isLoading = false.obs;
  final isSaving = false.obs;

  final profile = Rxn<CandidateProfileModel>();
  final walletCoins = 0.obs;
  final candidateId = ''.obs;

  double get profileCompletion {
    final data = profile.value;

    if (data == null) {
      return 0.0;
    }

    final fields = <bool>[
      // Personal details
      data.name.trim().isNotEmpty,
      data.email.trim().isNotEmpty,
      data.phone.trim().isNotEmpty,
      data.gender.trim().isNotEmpty,
      data.dob.trim().isNotEmpty,
      data.address.trim().isNotEmpty,
      data.city.trim().isNotEmpty,
      data.state.trim().isNotEmpty,
      data.pincode.trim().isNotEmpty,

      // Education details
      data.qualification.trim().isNotEmpty,
      data.institution.trim().isNotEmpty,
      data.department.isNotEmpty,
      data.percentage.trim().isNotEmpty,
      data.passingYear.trim().isNotEmpty,

      // Professional details
      data.skills.trim().isNotEmpty,
      data.experience.trim().isNotEmpty,
      data.role.isNotEmpty,
      data.currentLocation.trim().isNotEmpty,
      data.noticePeriod.trim().isNotEmpty,
      data.dateOfJoining.trim().isNotEmpty,
      data.currentCompany.trim().isNotEmpty,
      data.currentCTC.trim().isNotEmpty,
      data.expectedCTC.trim().isNotEmpty,
    ];

    final completedFields = fields.where((field) => field).length;

    return completedFields / fields.length;
  }

  int get profileCompletionPercentage {
    return (profileCompletion * 100).round();
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;

      final token = StorageService.getToken();
      final response = await profileService.getCandidateProfile(token);

      final data = CandidateProfileModel.fromJson(response.data);

      profile.value = data;
      candidateId.value = data.id;
      walletCoins.value = data.wallet.totalCoins;

      _fillPersonalDetails(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _fillPersonalDetails(CandidateProfileModel data) {
    nameController.text = data.name;
    emailController.text = data.email;
    phoneController.text = data.phone;
    genderController.text = data.gender;
    dobController.text = data.dob;
    addressController.text = data.address;
    cityController.text = data.city;
    stateController.text = data.state;
    pincodeController.text = data.pincode;
  }

  Future<void> updateBasicDetails() async {
    try {
      isSaving.value = true;

      final token = StorageService.getToken();
      final id = candidateId.value;

      if (id.isEmpty) {
        Get.snackbar('Error', 'Candidate ID missing');
        return;
      }

      await profileService.updateCandidateProfile(
        token: token,
        body: {
          'candidateId': id,
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'gender': genderController.text.trim(),
          'dob': dobController.text.trim(),
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
        },
      );

      await getProfile();

      Get.snackbar('Success', 'Profile updated successfully');

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.offNamed(AppRoutes.educationDetails);
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    genderController.dispose();
    dobController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.onClose();
  }
}