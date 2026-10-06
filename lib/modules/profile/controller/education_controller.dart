import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../model/education_model.dart';
import '../services/profile_service.dart';

class EducationController extends GetxController {
  final ProfileService profileService;

  EducationController(this.profileService);

  final isLoading = false.obs;
  final isSaving = false.obs;

  final educations = <EducationModel>[].obs;
  EducationModel? editingEducation;

  final qualificationController = TextEditingController();
  final institutionController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final passingYearController = TextEditingController();
  final locationController = TextEditingController();
  final percentageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getEducations();
  }

  Future<void> getEducations() async {
    try {
      isLoading.value = true;

      final response = await profileService.getEducationDetails(
        StorageService.getToken(),
      );

      final data = response.data;

      if (data is List) {
        educations.assignAll(
          data.map((e) => EducationModel.fromJson(e)).toList(),
        );
      } else if (data is Map && data['data'] is List) {
        educations.assignAll(
          (data['data'] as List)
              .map((e) => EducationModel.fromJson(e))
              .toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    editingEducation = null;
    qualificationController.clear();
    institutionController.clear();
    startDateController.clear();
    endDateController.clear();
    passingYearController.clear();
    locationController.clear();
    percentageController.clear();
  }

  void fillEducation(EducationModel education) {
    editingEducation = education;

    qualificationController.text = education.qualification;
    institutionController.text = education.institution;
    startDateController.text = education.startDate;
    endDateController.text = education.endDate;
    passingYearController.text = education.passingYear;
    locationController.text = education.location;
    percentageController.text = education.percentage;
  }

  Map<String, dynamic> _body() {
    return {
      'qualification': qualificationController.text.trim(),
      'institution': institutionController.text.trim(),
      'startDate': startDateController.text.trim(),
      'endDate': endDateController.text.trim(),
      'passingYear': passingYearController.text.trim(),
      'location': locationController.text.trim(),
      'percentage': percentageController.text.trim(),
    };
  }

  Future<void> saveEducation() async {
    try {
      isSaving.value = true;

      final token = StorageService.getToken();

      if (editingEducation == null) {
        await profileService.addEducation(
          token: token,
          body: _body(),
        );

        Get.snackbar('Success', 'Education added successfully');
      } else {
        await profileService.updateEducation(
          token: token,
          educationId: editingEducation!.id,
          body: _body(),
        );

        Get.snackbar('Success', 'Education updated successfully');
      }

      clearForm();
      await getEducations();
      Get.offNamed(AppRoutes.educationDetails);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteEducation(String id) async {
    try {
      isLoading.value = true;

      await profileService.deleteEducation(
        token: StorageService.getToken(),
        educationId: id,
      );

      await getEducations();
      Get.snackbar('Success', 'Education deleted successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    qualificationController.dispose();
    institutionController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    passingYearController.dispose();
    locationController.dispose();
    percentageController.dispose();
    super.onClose();
  }
}