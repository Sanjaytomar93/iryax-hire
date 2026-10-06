import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/services/profile_service.dart';
import '../model/candidate_documents_model.dart';

class PersonalDocumentsController extends GetxController {
  final ProfileService service;

  PersonalDocumentsController(this.service);

  final isLoading = false.obs;
  final isSaving = false.obs;

  final uploadingType = ''.obs;

  final documents = Rxn<CandidateDocumentsModel>();

  final selectedFiles = <String, File>{}.obs;

  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();

  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final relationController = TextEditingController();

  ProfileController get profileController =>
      Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();

    getCandidateDocuments();
  }

  Future<void> getCandidateDocuments() async {
    try {
      isLoading.value = true;

      final token = StorageService.getToken();

      if (token.isEmpty) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
        );

        return;
      }

      final response = await service.getCandidateDocuments(
        token: token,
      );

      debugPrint(
        '🟢 PERSONAL DOCUMENTS RESPONSE: ${response.data}',
      );

      final model = CandidateDocumentsModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      documents.value = model;

      _populateForm(model);
    } on dio.DioException catch (e) {
      debugPrint(
        '🔴 DOCUMENTS STATUS: ${e.response?.statusCode}',
      );

      debugPrint(
        '🔴 DOCUMENTS RESPONSE: ${e.response?.data}',
      );

      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;

      Get.snackbar(
        'Error',
        message ?? 'Unable to load personal documents',
      );
    } catch (e) {
      debugPrint(
        '🔴 DOCUMENTS ERROR: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to load personal documents',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _populateForm(
      CandidateDocumentsModel model,
      ) {
    final bank = model.documents.bankDetails;

    bankNameController.text = bank.bankName;
    accountNumberController.text = bank.accountNumber;
    ifscController.text = bank.ifscCode;

    final contact = model.documents.emergencyContact1;

    contactNameController.text = contact.name;
    contactPhoneController.text = contact.phone;
    relationController.text = contact.relationship;
  }

  Future<void> pickAndUploadDocument({
    required String type,
    required bool imageOnly,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: imageOnly
            ? [
          'jpg',
          'jpeg',
          'png',
        ]
            : [
          'pdf',
          'jpg',
          'jpeg',
          'png',
        ],
      );

      if (result == null ||
          result.files.single.path == null) {
        return;
      }

      final file = File(
        result.files.single.path!,
      );

      selectedFiles[type] = file;

      debugPrint(
        '🟡 SELECTED DOCUMENT TYPE: $type',
      );

      debugPrint(
        '🟡 SELECTED DOCUMENT FILE: ${file.path}',
      );

      await uploadDocument(
        type: type,
        file: file,
      );
    } catch (e) {
      debugPrint(
        '🔴 PICK DOCUMENT ERROR: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to select document',
      );
    }
  }

  Future<void> uploadDocument({
    required String type,
    required File file,
  }) async {
    try {
      uploadingType.value = type;

      final token = StorageService.getToken();

      if (token.isEmpty) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
        );

        return;
      }

      if (profileController.profile.value == null) {
        await profileController.getProfile();
      }

      final profile = profileController.profile.value;

      if (profile == null || profile.id.isEmpty) {
        Get.snackbar(
          'Error',
          'Candidate ID missing',
        );

        return;
      }

      final fileName = file.path
          .split('/')
          .last
          .split('\\')
          .last;

      final formData = dio.FormData.fromMap({
        'document': await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'type': type,
        'candidateId': profile.id,
      });

      debugPrint(
        '🟡 UPLOAD TYPE: $type',
      );

      debugPrint(
        '🟡 UPLOAD CANDIDATE ID: ${profile.id}',
      );

      debugPrint(
        '🟡 UPLOAD FILE: $fileName',
      );

      final response = await service.uploadCandidateDocument(
        token: token,
        formData: formData,
      );

      debugPrint(
        '🟢 DOCUMENT UPLOAD RESPONSE: ${response.data}',
      );

      Get.snackbar(
        'Success',
        response.data['message']?.toString() ??
            'Document uploaded successfully',
      );

      selectedFiles.remove(type);

      await getCandidateDocuments();
    } on dio.DioException catch (e) {
      debugPrint(
        '🔴 UPLOAD STATUS: ${e.response?.statusCode}',
      );

      debugPrint(
        '🔴 UPLOAD RESPONSE: ${e.response?.data}',
      );

      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;

      Get.snackbar(
        'Upload Failed',
        message ?? 'Unable to upload document',
      );
    } catch (e) {
      debugPrint(
        '🔴 UPLOAD DOCUMENT ERROR: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to upload document',
      );
    } finally {
      uploadingType.value = '';
    }
  }

  CandidateDocument? getDocument(
      String type,
      ) {
    final data = documents.value?.documents;

    if (data == null) {
      return null;
    }

    switch (type) {
      case 'aadharCard':
        return data.aadharCard;

      case 'panCard':
        return data.panCard;

      case 'tenthCertificate':
        return data.tenthCertificate;

      case 'twelfthCertificate':
        return data.twelfthCertificate;

      case 'graduationCertificate':
        return data.graduationCertificate;

      case 'experienceLetters':
        return data.experienceLetters;

      case 'passportPhoto':
        return data.passportPhoto;

      default:
        return null;
    }
  }

  String documentTitle({
    required String type,
    required String defaultTitle,
  }) {
    final selected = selectedFiles[type];

    if (selected != null) {
      return selected.path
          .split('/')
          .last
          .split('\\')
          .last;
    }

    final document = getDocument(type);

    if (document?.isUploaded == true) {
      return 'Uploaded';
    }

    return defaultTitle;
  }

  String documentStatus(String type) {
    final document = getDocument(type);

    if (document == null || !document.isUploaded) {
      return '';
    }

    if (document.verified) {
      return 'Verified';
    }

    return 'Uploaded';
  }


  Future<void> saveDocuments() async {
    if (isSaving.value) return;

    try {
      // ---------------------------------------------------------
      // VALIDATE BANK DETAILS
      // ---------------------------------------------------------

      final bankName = bankNameController.text.trim();
      final accountNumber = accountNumberController.text
          .replaceAll(' ', '')
          .trim();
      final ifscCode = ifscController.text.trim().toUpperCase();

      // ---------------------------------------------------------
      // VALIDATE EMERGENCY CONTACT
      // ---------------------------------------------------------

      final contactName = contactNameController.text.trim();
      final contactPhone = contactPhoneController.text
          .replaceAll(' ', '')
          .trim();
      final relationship = relationController.text.trim();

      if (bankName.isEmpty) {
        Get.snackbar(
          'Required',
          'Please enter bank name',
        );
        return;
      }

      if (accountNumber.isEmpty) {
        Get.snackbar(
          'Required',
          'Please enter account number',
        );
        return;
      }

      if (ifscCode.isEmpty) {
        Get.snackbar(
          'Required',
          'Please enter IFSC code',
        );
        return;
      }

      if (contactName.isEmpty) {
        Get.snackbar(
          'Required',
          'Please enter emergency contact name',
        );
        return;
      }

      if (contactPhone.isEmpty) {
        Get.snackbar(
          'Required',
          'Please enter emergency contact phone number',
        );
        return;
      }

      if (relationship.isEmpty) {
        Get.snackbar(
          'Required',
          'Please enter relationship',
        );
        return;
      }

      // ---------------------------------------------------------
      // START SAVING
      // ---------------------------------------------------------

      isSaving.value = true;

      final token = StorageService.getToken();

      if (token.isEmpty) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
        );
        return;
      }

      // Always make sure latest profile is available.
      if (profileController.profile.value == null) {
        await profileController.getProfile();
      }

      final profile = profileController.profile.value;

      if (profile == null || profile.id.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Candidate ID missing',
        );
        return;
      }

      final candidateId = profile.id.trim();

      // ---------------------------------------------------------
      // BANK BODY
      // ---------------------------------------------------------

      final Map<String, dynamic> bankBody = {
        'candidateId': candidateId,
        'bankDetails': {
          'bankName': bankName,
          'accountNumber': accountNumber,
          'ifscCode': ifscCode,
        },
      };

      debugPrint(
        '🟡 SAVE BANK REQUEST: $bankBody',
      );

      // ---------------------------------------------------------
      // EMERGENCY CONTACT BODY
      // ---------------------------------------------------------

      final Map<String, dynamic> contactBody = {
        'candidateId': candidateId,
        'contactNumber': 1,
        'contact': {
          'name': contactName,
          'phone': contactPhone,
          'relationship': relationship,
        },
      };

      debugPrint(
        '🟡 SAVE CONTACT REQUEST: $contactBody',
      );

      // ---------------------------------------------------------
      // SAVE BANK DETAILS
      // ---------------------------------------------------------

      try {
        final bankResponse = await service.updateBankDetails(
          token: token,
          body: bankBody,
        );

        debugPrint(
          '🟢 BANK STATUS: ${bankResponse.statusCode}',
        );

        debugPrint(
          '🟢 BANK RESPONSE: ${bankResponse.data}',
        );
      } on dio.DioException catch (e) {
        debugPrint(
          '🔴 BANK SAVE STATUS: ${e.response?.statusCode}',
        );

        debugPrint(
          '🔴 BANK SAVE RESPONSE: ${e.response?.data}',
        );

        final message = _getApiErrorMessage(
          e,
          fallback: 'Unable to save bank details',
        );

        Get.snackbar(
          'Bank Details Failed',
          message,
        );

        return;
      }

      // ---------------------------------------------------------
      // SAVE EMERGENCY CONTACT
      // ---------------------------------------------------------

      try {
        final contactResponse =
        await service.saveEmergencyContact(
          token: token,
          body: contactBody,
        );

        debugPrint(
          '🟢 CONTACT STATUS: ${contactResponse.statusCode}',
        );

        debugPrint(
          '🟢 CONTACT RESPONSE: ${contactResponse.data}',
        );
      } on dio.DioException catch (e) {
        debugPrint(
          '🔴 CONTACT SAVE STATUS: ${e.response?.statusCode}',
        );

        debugPrint(
          '🔴 CONTACT SAVE RESPONSE: ${e.response?.data}',
        );

        final message = _getApiErrorMessage(
          e,
          fallback: 'Unable to save emergency contact',
        );

        Get.snackbar(
          'Emergency Contact Failed',
          message,
        );

        return;
      }

      // ---------------------------------------------------------
      // EVERYTHING SAVED
      // ---------------------------------------------------------

      await getCandidateDocuments();
      await profileController.getProfile();


      Get.snackbar(
        'Success',
        'Personal documents saved successfully',
      );
      Get.offNamed(AppRoutes.profile);
      // Get.back();
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 SAVE DOCUMENTS ERROR: $e',
      );

      debugPrint(
        '🔴 SAVE DOCUMENTS STACKTRACE: $stackTrace',
      );

      Get.snackbar(
        'Error',
        'Unable to save personal documents',
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();

    contactNameController.dispose();
    contactPhoneController.dispose();
    relationController.dispose();

    super.onClose();
  }


  String _getApiErrorMessage(
      dio.DioException e, {
        required String fallback,
      }) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final error = data['error'];

      if (error != null &&
          error.toString().trim().isNotEmpty) {
        return error.toString();
      }
    }

    return fallback;
  }


  Future<void> previewDocument(String type) async {
    final document = getDocument(type);

    if (document == null ||
        !document.isUploaded ||
        document.url.trim().isEmpty) {
      Get.snackbar(
        'Preview',
        'Document is not available',
      );
      return;
    }

    var documentUrl = document.url.trim();

    // Change this to your actual API base URL constant if available.
    if (!documentUrl.startsWith('http')) {
      documentUrl =
      'https://ingrainhirebackend.ingrainsystems.com$documentUrl';
    }

    debugPrint(
      '🟡 PREVIEW DOCUMENT URL: $documentUrl',
    );

    final uri = Uri.tryParse(documentUrl);

    if (uri == null) {
      Get.snackbar(
        'Preview Failed',
        'Invalid document URL',
      );
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      Get.snackbar(
        'Preview Failed',
        'Unable to open document',
      );
    }
  }
}