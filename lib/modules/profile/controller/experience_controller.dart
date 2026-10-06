import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../model/experience_model.dart';
import '../services/profile_service.dart';

class ExperienceController extends GetxController {
  final ProfileService profileService;

  ExperienceController(this.profileService);

  final isLoading = false.obs;
  final isSaving = false.obs;

  final isCurrentlyWorking = false.obs;

  final experiences = <ExperienceModel>[].obs;
  ExperienceModel? editingExperience;

  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final locationController = TextEditingController();
  final salaryController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  final offerLetter = Rxn<File>();
  final payslip = Rxn<File>();
  final relievingLetter = Rxn<File>();
  final otherDocument = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    getExperiences();
  }

  Future<void> getExperiences() async {
    try {
      isLoading.value = true;

      final response = await profileService.getExperienceDetails(
        StorageService.getToken(),
      );

      final data = response.data;

      if (data is List) {
        experiences.assignAll(
          data.map((e) => ExperienceModel.fromJson(e)).toList(),
        );
      } else if (data is Map && data['data'] is List) {
        experiences.assignAll(
          (data['data'] as List)
              .map((e) => ExperienceModel.fromJson(e))
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
    editingExperience = null;

    companyController.clear();
    roleController.clear();
    locationController.clear();
    salaryController.clear();
    startDateController.clear();
    endDateController.clear();

    offerLetter.value = null;
    payslip.value = null;
    relievingLetter.value = null;
    otherDocument.value = null;
    isCurrentlyWorking.value = false;
  }

  void fillExperience(ExperienceModel experience) {
    editingExperience = experience;

    companyController.text = experience.companyName;
    roleController.text = experience.role;
    locationController.text = experience.location;
    salaryController.text = experience.salary;
    startDateController.text = experience.startDate;
    endDateController.text = experience.endDate;

    offerLetter.value = null;
    payslip.value = null;
    relievingLetter.value = null;
    otherDocument.value = null;
  }

  Future<dio.FormData> _formData() async {
    return dio.FormData.fromMap({
      'companyName': companyController.text.trim(),
      'role': roleController.text.trim(),
      'location': locationController.text.trim(),
      'salary': salaryController.text.trim(),
      'startDate': startDateController.text.trim(),
      'endDate': isCurrentlyWorking.value
          ? ''
          : endDateController.text.trim(),


      if (offerLetter.value != null)
        'offerLetter': await dio.MultipartFile.fromFile(
          offerLetter.value!.path,
        ),

      if (payslip.value != null)
        'payslip': await dio.MultipartFile.fromFile(
          payslip.value!.path,
        ),

      if (relievingLetter.value != null)
        'relievingLetter': await dio.MultipartFile.fromFile(
          relievingLetter.value!.path,
        ),

      if (otherDocument.value != null)
        'otherDocument': await dio.MultipartFile.fromFile(
          otherDocument.value!.path,
        ),
    });
  }

  Future<void> saveExperience() async {
    try {
      isSaving.value = true;

      final token = StorageService.getToken();
      final formData = await _formData();

      if (editingExperience == null) {
        await profileService.addExperience(
          token: token,
          formData: formData,
        );

        Get.snackbar('Success', 'Experience added successfully');
      } else {
        await profileService.updateExperience(
          token: token,
          experienceId: editingExperience!.id,
          formData: formData,
        );

        Get.snackbar('Success', 'Experience updated successfully');
      }

      clearForm();
      await getExperiences();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      isLoading.value = true;

      await profileService.deleteExperience(
        token: StorageService.getToken(),
        experienceId: id,
      );

      await getExperiences();
      Get.snackbar('Success', 'Experience deleted successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    companyController.dispose();
    roleController.dispose();
    locationController.dispose();
    salaryController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
}