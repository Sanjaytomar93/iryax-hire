import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/job_model.dart';
import '../../home/services/job_service.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/services/profile_service.dart';

class ApplyJobController extends GetxController {
  final JobService jobService;

  ApplyJobController(this.jobService);

  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isProfileLoading = false.obs;
  final resume = Rxn<File>();

  late JobModel job;

  // Accordion states
  final personalExpanded = true.obs;
  final educationExpanded = false.obs;
  final professionalExpanded = false.obs;

  // Personal details
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  // Education details
  final institutionController = TextEditingController();
  final departmentController = TextEditingController();
  final percentageController = TextEditingController();

  final selectedQualification = ''.obs;
  final selectedPassingYear = ''.obs;

  // Professional details
  final currentCompanyController = TextEditingController();
  final currentRoleController = TextEditingController();
  final currentLocationController = TextEditingController();
  final skillsController = TextEditingController();
  final joiningDateController = TextEditingController();

  final selectedExperience = ''.obs;
  final selectedCurrentCTC = ''.obs;
  final selectedExpectedCTC = ''.obs;
  final selectedNoticePeriod = ''.obs;

  final qualificationOptions = <String>[
    '10th',
    'Intermediate',
    'ITI',
    'Diploma',
    'B.A',
    'B.Com',
    'B.Sc',
    'BCA',
    'B.Tech',
    'B.E',
    'M.A',
    'M.Com',
    'M.Sc',
    'MCA',
    'M.Tech',
    'MBA',
    'PhD',
    'Other',
  ];

  final experienceOptions = <String>[
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15+',
  ];

  final ctcOptions = <String>[
    'Fresher',
    '1 LPA',
    '2 LPA',
    '3 LPA',
    '4 LPA',
    '5 LPA',
    '6 LPA',
    '7 LPA',
    '8 LPA',
    '9 LPA',
    '10 LPA',
    '12 LPA',
    '15 LPA',
    '20 LPA',
    '25 LPA',
    '30+ LPA',
  ];

  final noticePeriodOptions = <String>[
    'Immediate',
    '7',
    '15',
    '30',
    '45',
    '60',
    '90',
  ];

  List<String> get passingYearOptions {
    final currentYear = DateTime.now().year;

    return List.generate(
      50,
          (index) => (currentYear - index).toString(),
    );
  }

  ProfileController get profileController {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>();
    }

    return Get.put<ProfileController>(
      ProfileController(Get.find<ProfileService>()),
      permanent: true,
    );
  }

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is! JobModel) {
      Get.snackbar(
        'Error',
        'Job data is missing',
        snackPosition: SnackPosition.BOTTOM,
      );

      Future.microtask(
            () => Get.offAllNamed(AppRoutes.home),
      );
      return;
    }

    job = arguments;
    currentRoleController.text = job.role;

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      isProfileLoading.value = true;

      final token = StorageService.getToken();

      debugPrint('🟡 APPLY TOKEN AVAILABLE: ${token.isNotEmpty}');

      if (token.isEmpty) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed(AppRoutes.login);
        return;
      }

      if (profileController.profile.value == null) {
        await profileController.getProfile();
      }

      final profile = profileController.profile.value;

      if (profile == null) {
        Get.snackbar(
          'Error',
          'Unable to load profile details',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      fullNameController.text = profile.name.trim();
      emailController.text = profile.email.trim();
      mobileController.text = profile.phone.trim();
      addressController.text = profile.address.trim();

      selectedQualification.value = profile.qualification.trim();
      institutionController.text = profile.institution.trim();

      departmentController.text = profile.department
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .join(', ');

      percentageController.text = profile.percentage.toString().trim();
      selectedPassingYear.value = profile.passingYear.toString().trim();

      currentCompanyController.text = profile.currentCompany.trim();
      currentRoleController.text =
      job.role.trim().isEmpty ? '' : job.role.trim();

      selectedExperience.value =
          _cleanExperience(profile.experience.toString());

      currentLocationController.text =
          profile.currentLocation.toString().trim();

      selectedCurrentCTC.value =
          _cleanText(profile.currentCTC.toString());

      selectedExpectedCTC.value =
          _cleanText(profile.expectedCTC.toString());

      selectedNoticePeriod.value =
          _cleanNoticePeriod(profile.noticePeriod.toString());

      skillsController.text = _skillsAsText(profile.skills);

      joiningDateController.text =
          _convertToApiDate(profile.dateOfJoining.toString());

      debugPrint('🟢 APPLY PROFILE PREFILLED');
    } catch (error) {
      debugPrint('🔴 APPLY PROFILE LOAD ERROR: $error');

      if (error.toString().contains('401')) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'Error',
          'Unable to load profile',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isProfileLoading.value = false;
    }
  }

  void togglePersonalSection() {
    final shouldOpen = !personalExpanded.value;

    personalExpanded.value = shouldOpen;

    if (shouldOpen) {
      educationExpanded.value = false;
      professionalExpanded.value = false;
    }
  }

  void toggleEducationSection() {
    final shouldOpen = !educationExpanded.value;

    educationExpanded.value = shouldOpen;

    if (shouldOpen) {
      personalExpanded.value = false;
      professionalExpanded.value = false;
    }
  }

  void toggleProfessionalSection() {
    final shouldOpen = !professionalExpanded.value;

    professionalExpanded.value = shouldOpen;

    if (shouldOpen) {
      personalExpanded.value = false;
      educationExpanded.value = false;
    }
  }

  Future<void> pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
        ],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final selectedPath = result.files.single.path;

      if (selectedPath == null || selectedPath.isEmpty) {
        Get.snackbar(
          'File Error',
          'Unable to read the selected file',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      resume.value = File(selectedPath);

      debugPrint(
        '🟢 RESUME SELECTED: ${resume.value?.path}',
      );
    } catch (error) {
      debugPrint('🔴 RESUME PICK ERROR: $error');

      Get.snackbar(
        'File Error',
        'Unable to select resume',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> selectJoiningDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    final currentValue = joiningDateController.text.trim();
    final parsedDate = DateTime.tryParse(currentValue);

    if (parsedDate != null) {
      initialDate = parsedDate;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF194F86),
              onPrimary: Colors.white,
              surface: Color(0xFF1A2133),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF111111),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) {
      return;
    }

    joiningDateController.text = _formatApiDate(selectedDate);
  }

  Future<void> submitApplication() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (isLoading.value) {
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      Get.snackbar(
        'Required Fields',
        'Please complete all mandatory fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedQualification.value.trim().isEmpty) {
      _openEducationSection();

      Get.snackbar(
        'Education Required',
        'Please select highest qualification',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedPassingYear.value.trim().isEmpty) {
      _openEducationSection();

      Get.snackbar(
        'Education Required',
        'Please select passing year',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedExperience.value.trim().isEmpty) {
      _openProfessionalSection();

      Get.snackbar(
        'Professional Details',
        'Please select total experience',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedCurrentCTC.value.trim().isEmpty) {
      _openProfessionalSection();

      Get.snackbar(
        'Professional Details',
        'Please select current CTC',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedExpectedCTC.value.trim().isEmpty) {
      _openProfessionalSection();

      Get.snackbar(
        'Professional Details',
        'Please select expected CTC',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedNoticePeriod.value.trim().isEmpty) {
      _openProfessionalSection();

      Get.snackbar(
        'Professional Details',
        'Please select notice period',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (joiningDateController.text.trim().isEmpty) {
      _openProfessionalSection();

      Get.snackbar(
        'Professional Details',
        'Please select preferred joining date',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (resume.value == null) {
      Get.snackbar(
        'Resume Required',
        'Please upload your resume',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final token = StorageService.getToken();

      if (token.isEmpty) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed(AppRoutes.login);
        return;
      }

      if (profileController.profile.value == null) {
        await profileController.getProfile();
      }

      final profile = profileController.profile.value;

      if (profile == null) {
        Get.snackbar(
          'Error',
          'Profile not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (profile.id.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Candidate ID is missing',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (job.id.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Job ID is missing',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final nameParts = fullNameController.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      final firstName =
      nameParts.isNotEmpty ? nameParts.first : '';

      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final selectedResume = resume.value!;
      final resumeFileName =
          selectedResume.path.split('/').last.split('\\').last;

      final formData = dio.FormData.fromMap({
        'jobId': job.id.trim(),
        'candidateId': profile.id.trim(),

        'firstName': firstName,
        'lastName': lastName,

        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'address': addressController.text.trim(),

        'highestQualification':
        selectedQualification.value.trim(),

        'institution': institutionController.text.trim(),
        'department': departmentController.text.trim(),
        'percentage': percentageController.text.trim(),
        'passingYear': selectedPassingYear.value.trim(),

        // Hiring company
        'companyName': job.companyName.trim(),

        // Selected job role
        'role': job.role.trim(),

        'totalExperience':
        selectedExperience.value.trim(),

        'currentCompany':
        currentCompanyController.text.trim(),

        'currentLocation':
        currentLocationController.text.trim(),

        'currentCTC':
        selectedCurrentCTC.value.trim(),

        'expectedCTC':
        selectedExpectedCTC.value.trim(),

        'noticePeriod':
        selectedNoticePeriod.value.trim(),

        'skills': skillsController.text.trim(),

        'dateOfJoining':
        joiningDateController.text.trim(),

        'resume': await dio.MultipartFile.fromFile(
          selectedResume.path,
          filename: resumeFileName,
        ),
      });

      debugPrint('🟡 APPLY JOB ID: ${job.id}');
      debugPrint('🟡 APPLY CANDIDATE ID: ${profile.id}');
      debugPrint('🟡 APPLY COMPANY: ${job.companyName}');
      debugPrint('🟡 APPLY ROLE: ${job.role}');
      debugPrint(
        '🟡 APPLY EXPERIENCE: ${selectedExperience.value}',
      );
      debugPrint(
        '🟡 APPLY JOIN DATE: ${joiningDateController.text}',
      );
      debugPrint('🟡 APPLY RESUME: $resumeFileName');

      for (final field in formData.fields) {
        debugPrint(
          '🟡 FORM FIELD: ${field.key} = ${field.value}',
        );
      }

      final response = await jobService.applyJob(
        token: token,
        formData: formData,
      );

      debugPrint('🟢 APPLY RESPONSE: ${response.data}');

      final responseData = response.data;

      final success = responseData is Map
          ? responseData['success'] == true
          : false;

      if (!success) {
        final message = responseData is Map
            ? responseData['message']?.toString()
            : null;

        throw Exception(
          message ?? 'Unable to submit application',
        );
      }

      Get.snackbar(
        'Success',
        responseData['message']?.toString() ??
            'Application submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      final applicationId =
          responseData['application']?['_id']?.toString() ??
              responseData['applicationId']?.toString() ??
              responseData['data']?['_id']?.toString() ??
              responseData['data']?['applicationId']
                  ?.toString() ??
              '';

      final quizId = _getQuizId();

      Map<String, dynamic>? selectedAssessment;

      for (final assessmentItem in job.assessmentIds) {
        Map<String, dynamic>? assessmentMap;

        if (assessmentItem is Map<String, dynamic>) {
          assessmentMap = assessmentItem;
        } else if (assessmentItem is Map) {
          assessmentMap =
          Map<String, dynamic>.from(assessmentItem);
        }

        if (assessmentMap == null) {
          continue;
        }

        final currentAssessmentId =
            assessmentMap['_id']?.toString() ??
                assessmentMap['id']?.toString() ??
                '';

        if (currentAssessmentId == quizId) {
          selectedAssessment = assessmentMap;
          break;
        }
      }

// Fallback to first assessment when quiz ID matching fails.
      if (selectedAssessment == null &&
          job.assessmentIds.isNotEmpty) {
        final firstAssessment = job.assessmentIds.first;

        if (firstAssessment is Map<String, dynamic>) {
          selectedAssessment = firstAssessment;
        } else if (firstAssessment is Map) {
          selectedAssessment =
          Map<String, dynamic>.from(firstAssessment);
        }
      }

      final rawQuestions =
      selectedAssessment?['questions'];

      final assessmentQuestions =
      rawQuestions is List
          ? rawQuestions
          .whereType<Map>()
          .map(
            (question) =>
        Map<String, dynamic>.from(question),
      )
          .toList()
          : <Map<String, dynamic>>[];

      debugPrint('══════════════════════════════════════');
      debugPrint('🟢 APPLICATION ID: $applicationId');
      debugPrint('🟢 QUIZ ID: $quizId');
      debugPrint(
        '🟢 ASSESSMENTS COUNT: '
            '${job.assessmentIds.length}',
      );
      debugPrint(
        '🟢 SELECTED ASSESSMENT: '
            '${selectedAssessment?['title']}',
      );
      debugPrint(
        '🟢 QUESTIONS WITH ANSWERS: '
            '${assessmentQuestions.length}',
      );

      for (int index = 0;
      index < assessmentQuestions.length;
      index++) {
        final question = assessmentQuestions[index];

        debugPrint('──────────────────────────────────────');
        debugPrint('🟢 QUESTION ${index + 1}');
        debugPrint(
          '🟢 ID: '
              '${question['_id'] ?? question['id']}',
        );
        debugPrint(
          '🟢 QUESTION: ${question['questionText']}',
        );
        debugPrint(
          '🟢 CORRECT ANSWER: '
              '${question['correctAnswer']}',
        );
        debugPrint(
          '🟢 MARKS: ${question['marks']}',
        );
      }

      debugPrint('══════════════════════════════════════');

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (applicationId.isNotEmpty &&
          quizId.isNotEmpty) {
        Get.offNamed(
          AppRoutes.assessment,
          arguments: {
            'jobId': job.id,
            'applicationId': applicationId,
            'quizId': quizId,
            'assessmentQuestions':
            assessmentQuestions,
            'assessmentTitle':
            selectedAssessment?['title']
                ?.toString() ??
                '',
          },
        );
      } else {
        await Get.offAllNamed(AppRoutes.home);

        Future.delayed(
          const Duration(milliseconds: 500),
              () {
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>()
                  .silentRefresh();
            }
          },
        );
      }
    } on dio.DioException catch (error) {
      debugPrint(
        '🔴 APPLY STATUS: ${error.response?.statusCode}',
      );
      debugPrint(
        '🔴 APPLY RESPONSE DATA: ${error.response?.data}',
      );
      debugPrint(
        '🔴 APPLY DIO MESSAGE: ${error.message}',
      );

      String message = 'Unable to apply for this job';

      final responseData = error.response?.data;

      if (responseData is Map) {
        message =
            responseData['message']?.toString() ?? message;
      } else if (error.message?.isNotEmpty == true) {
        message = error.message!;
      }

      Get.snackbar(
        'Apply Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('🔴 APPLY ERROR: $error');

      Get.snackbar(
        'Error',
        error
            .toString()
            .replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _getQuizId() {
    if (job.assessmentIds.isEmpty) {
      return '';
    }

    final firstAssessment = job.assessmentIds.first;

    if (firstAssessment is Map) {
      return firstAssessment['_id']?.toString() ??
          firstAssessment['id']?.toString() ??
          '';
    }

    return firstAssessment.toString();
  }

  void _openEducationSection() {
    personalExpanded.value = false;
    educationExpanded.value = true;
    professionalExpanded.value = false;
  }

  void _openProfessionalSection() {
    personalExpanded.value = false;
    educationExpanded.value = false;
    professionalExpanded.value = true;
  }

  String _cleanText(String value) {
    return value.trim();
  }

  String _cleanExperience(String value) {
    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      return '';
    }

    final numberMatch = RegExp(r'\d+').firstMatch(cleaned);

    if (numberMatch != null) {
      return numberMatch.group(0) ?? cleaned;
    }

    if (cleaned.toLowerCase().contains('fresher')) {
      return '0';
    }

    return cleaned;
  }

  String _cleanNoticePeriod(String value) {
    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      return '';
    }

    if (cleaned.toLowerCase().contains('immediate')) {
      return 'Immediate';
    }

    final numberMatch = RegExp(r'\d+').firstMatch(cleaned);

    return numberMatch?.group(0) ?? cleaned;
  }

  String _skillsAsText(dynamic skills) {
    if (skills == null) {
      return '';
    }

    if (skills is List) {
      return skills
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .join(', ');
    }

    return skills.toString().trim();
  }

  String _convertToApiDate(String value) {
    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      return '';
    }

    final directDate = DateTime.tryParse(cleaned);

    if (directDate != null) {
      return _formatApiDate(directDate);
    }

    final parts = cleaned.split(RegExp(r'[-/]'));

    if (parts.length == 3) {
      // Handles dd/MM/yyyy or dd-MM-yyyy.
      if (parts[0].length <= 2 &&
          parts[1].length <= 2 &&
          parts[2].length == 4) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);

        if (day != null && month != null && year != null) {
          return _formatApiDate(
            DateTime(year, month, day),
          );
        }
      }
    }

    return cleaned;
  }

  String _formatApiDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();

    institutionController.dispose();
    departmentController.dispose();
    percentageController.dispose();

    currentCompanyController.dispose();
    currentRoleController.dispose();
    currentLocationController.dispose();
    skillsController.dispose();
    joiningDateController.dispose();

    super.onClose();
  }
}