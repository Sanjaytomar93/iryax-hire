import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/storage_service.dart';
import '../model/medical_certificate_model.dart';
import '../services/profile_service.dart';
import 'profile_controller.dart';

class MedicalCertificateController extends GetxController {
  final ProfileService profileService;

  MedicalCertificateController(this.profileService);

  final isLoading = false.obs;
  final isSaving = false.obs;

  final certificates = <MedicalCertificateModel>[].obs;

  final employeeIdController = TextEditingController();
  final employeeNameController = TextEditingController();
  final registrationDateController = TextEditingController();
  final expiryDateController = TextEditingController();

  final selectedCertificate = Rxn<File>();

  String get candidateId {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>()
          .candidateId
          .value;
    }

    return '';
  }

  String get candidateName {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>()
          .profile
          .value
          ?.name ??
          '';
    }

    return '';
  }

  String get selectedFileName {
    final file = selectedCertificate.value;

    if (file == null) {
      return '';
    }

    return file.path
        .split('/')
        .last
        .split('\\')
        .last;
  }

  @override
  void onInit() {
    super.onInit();
    getMedicalCertificates();
  }

  Future<void> getMedicalCertificates() async {
    try {
      isLoading.value = true;

      final id = candidateId;

      debugPrint(
        '🟡 MEDICAL candidateId: $id',
      );

      if (id.isEmpty) {
        debugPrint(
          '🔴 MEDICAL candidateId EMPTY',
        );
        return;
      }

      final response =
      await profileService
          .getMedicalCertificates(
        token: StorageService.getToken(),
        candidateId: id,
      );

      final data = response.data;

      debugPrint(
        '🟢 MEDICAL RAW DATA: $data',
      );

      if (data is List) {
        certificates.assignAll(
          data
              .map(
                (item) =>
                MedicalCertificateModel
                    .fromJson(item),
          )
              .toList(),
        );
      } else if (data is Map &&
          data['data'] is List) {
        certificates.assignAll(
          (data['data'] as List)
              .map(
                (item) =>
                MedicalCertificateModel
                    .fromJson(item),
          )
              .toList(),
        );
      } else {
        debugPrint(
          '🔴 MEDICAL UNKNOWN RESPONSE FORMAT',
        );

        certificates.clear();
      }

      debugPrint(
        '🟢 MEDICAL CERTIFICATES COUNT: '
            '${certificates.length}',
      );
    } catch (e) {
      debugPrint(
        '🔴 MEDICAL FETCH ERROR: $e',
      );

      Get.snackbar(
        'Error',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDocument() async {
    try {
      final result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
        ],
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final path =
          result.files.single.path;

      if (path == null ||
          path.isEmpty) {
        Get.snackbar(
          'Error',
          'Unable to select document',
        );
        return;
      }

      selectedCertificate.value =
          File(path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to select document',
      );

      debugPrint(
        '🔴 MEDICAL FILE PICK ERROR: $e',
      );
    }
  }

  Future<void> uploadMedicalCertificate() async {
    if (isSaving.value) {
      return;
    }

    final id = candidateId;

    if (id.isEmpty) {
      Get.snackbar(
        'Error',
        'Candidate ID missing',
      );
      return;
    }

    if (registrationDateController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please select registration date',
      );
      return;
    }

    if (expiryDateController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please select expiry date',
      );
      return;
    }

    if (selectedCertificate.value == null) {
      Get.snackbar(
        'Error',
        'Please select certificate file',
      );
      return;
    }

    try {
      isSaving.value = true;

      final file = selectedCertificate.value!;

      final registrationDate = _toApiDate(
        registrationDateController.text.trim(),
      );

      final expiryDate = _toApiDate(
        expiryDateController.text.trim(),
      );

      final formData = dio.FormData.fromMap({
        'candidateId': id,
        'candidateName': candidateName,
        'registrationDate': registrationDate,
        'expiryDate': expiryDate,
        'document': await dio.MultipartFile.fromFile(
          file.path,
          filename: selectedFileName,
        ),
      });

      debugPrint(
        '🟡 MEDICAL UPLOAD candidateId: $id',
      );

      debugPrint(
        '🟡 MEDICAL UPLOAD candidateName: $candidateName',
      );

      debugPrint(
        '🟡 MEDICAL UPLOAD registrationDate: $registrationDate',
      );

      debugPrint(
        '🟡 MEDICAL UPLOAD expiryDate: $expiryDate',
      );

      debugPrint(
        '🟡 MEDICAL UPLOAD document: $selectedFileName',
      );

      await profileService.uploadMedicalCertificate(
        token: StorageService.getToken(),
        formData: formData,
      );

      clearForm();

      Get.snackbar(
        'Success',
        'Medical certificate uploaded',
      );

      await getMedicalCertificates();
    } on dio.DioException catch (e) {
      debugPrint(
        '🔴 MEDICAL UPLOAD STATUS: ${e.response?.statusCode}',
      );

      debugPrint(
        '🔴 MEDICAL UPLOAD RESPONSE: ${e.response?.data}',
      );

      Get.snackbar(
        'Error',
        e.response?.data is Map
            ? e.response?.data['message']?.toString() ??
            'Unable to upload medical certificate'
            : 'Unable to upload medical certificate',
      );
    } catch (e) {
      debugPrint(
        '🔴 MEDICAL UPLOAD ERROR: $e',
      );

      Get.snackbar(
        'Error',
        e.toString(),
      );
    } finally {
      isSaving.value = false;
    }
  }

  void clearForm() {
    registrationDateController.clear();
    expiryDateController.clear();
    selectedCertificate.value = null;
  }

  Future<void> viewCertificate(
      String documentUrl,
      ) async {
    if (documentUrl.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Certificate file not available',
      );
      return;
    }

    final fullUrl =
    documentUrl.startsWith('http')
        ? documentUrl
        : 'https://ingrainhirebackend.ingrainsystems.com'
        '$documentUrl';

    final uri = Uri.parse(fullUrl);

    final opened = await launchUrl(
      uri,
      mode:
      LaunchMode.externalApplication,
    );

    if (!opened) {
      Get.snackbar(
        'Error',
        'Unable to open certificate',
      );
    }
  }

  @override
  void onClose() {
    employeeIdController.dispose();
    employeeNameController.dispose();
    registrationDateController.dispose();
    expiryDateController.dispose();

    super.onClose();
  }


  String _toApiDate(String value) {
    try {
      final parts = value.split('-');

      if (parts.length != 3) {
        return value;
      }

      return '${parts[2]}-${parts[1]}-${parts[0]}';
    } catch (_) {
      return value;
    }
  }
}