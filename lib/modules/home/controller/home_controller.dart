import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../jobs/controller/job_details_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../shortJobs/controller/short_jobs_controller.dart';
import '../model/dashboard_count_model.dart';
import '../model/job_model.dart';
import '../services/job_service.dart';

class HomeController extends GetxController {
  final JobService service;

  HomeController(this.service);

  final jobs = <JobModel>[].obs;
  final candidateRoles = <String>[].obs;
  final totalMatchedJobs = 0.obs;
  final dashboard = Rxn<DashboardCountModel>();

  final isLoading = false.obs;

  ////////////////////////////////////////////////////////////
  /// Search & Filters
  ////////////////////////////////////////////////////////////

  final searchController = TextEditingController();

  final searchQuery = ''.obs;
  final selectedJobType = ''.obs;

  // @override
  // void onReady() {
  //   super.onReady();
  //   silentRefresh();
  // }

  Future<void> silentRefresh() async {
    try {
      await Future.wait([
        getDashboardCount(),
        getMatchedJobs(),
      ]);

      dashboard.refresh();
      jobs.refresh();
    } catch (e) {
      debugPrint(
        '🔴 SILENT REFRESH ERROR: $e',
      );
    }
  }
  ////////////////////////////////////////////////////////////
  /// Candidate ID
  ////////////////////////////////////////////////////////////

  String get candidateId {
    if (Get.isRegistered<ProfileController>()) {
      final profileId =
      Get.find<ProfileController>().candidateId.value.trim();

      if (profileId.isNotEmpty) {
        return profileId;
      }
    }

    final candidate = StorageService.getCandidate();

    return candidate?['_id']?.toString() ??
        candidate?['id']?.toString() ??
        '';
  }

  String get candidateName {
    if (Get.isRegistered<ProfileController>()) {
      final profileName =
          Get.find<ProfileController>().profile.value?.name.trim() ?? '';

      if (profileName.isNotEmpty) {
        return profileName;
      }
    }

    final candidate = StorageService.getCandidate();

    return candidate?['name']?.toString() ??
        candidate?['fullName']?.toString() ??
        '';
  }
  ////////////////////////////////////////////////////////////
  /// Filtered Jobs
  ////////////////////////////////////////////////////////////

  List<JobModel> get filteredJobs {
    final query = searchQuery.value.trim().toLowerCase();
    final type = selectedJobType.value.trim().toLowerCase();

    return jobs.where((job) {
      final matchesSearch = query.isEmpty ||
          job.role.toLowerCase().contains(query) ||
          job.companyName.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query) ||
          job.skills.toLowerCase().contains(query) ||
          job.department.toLowerCase().contains(query);

      final matchesJobType = type.isEmpty ||
          job.jobType.toLowerCase() == type;

      return matchesSearch && matchesJobType;
    }).toList();
  }

  ////////////////////////////////////////////////////////////
  /// Lifecycle
  ////////////////////////////////////////////////////////////

  @override
  void onInit() {
    super.onInit();

    Future.microtask(() async {
      await loadHome();
    });
  }

  @override
  void onClose() {
    searchController.dispose();

    super.onClose();
  }

  ////////////////////////////////////////////////////////////
  /// Load Home
  ////////////////////////////////////////////////////////////

  Future<void> loadHome() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;

      String id = candidateId;

      debugPrint(
        '🟡 HOME INITIAL candidateId: $id',
      );

      debugPrint(
        '🟡 HOME TOKEN EXISTS: '
            '${StorageService.getToken().isNotEmpty}',
      );

      debugPrint(
        '🟡 HOME STORED CANDIDATE: '
            '${StorageService.getCandidate()}',
      );

      if (id.isEmpty &&
          Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().getProfile();

        id = candidateId;
      }

      if (id.isEmpty) {
        await Future.delayed(
          const Duration(milliseconds: 300),
        );

        id = candidateId;
      }

      if (id.isEmpty) {
        debugPrint(
          '🔴 HOME candidateId STILL EMPTY',
        );

        jobs.clear();
        candidateRoles.clear();
        totalMatchedJobs.value = 0;

        return;
      }

      await Future.wait([
        getDashboardCount(),
        getMatchedJobs(),
      ]);
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 HOME LOAD ERROR: $e',
      );

      debugPrint(
        '🔴 HOME LOAD STACK: $stackTrace',
      );
    } finally {
      isLoading.value = false;
    }
  }
  ////////////////////////////////////////////////////////////
  /// Dashboard Count
  ////////////////////////////////////////////////////////////

  Future<void> getDashboardCount() async {
    try {
      final id = candidateId;

      debugPrint('🟡 DASHBOARD candidateId: $id');

      if (id.isEmpty) {
        debugPrint('🔴 DASHBOARD candidateId EMPTY');

        return;
      }

      final response = await service.getDashboardCount(
        token: StorageService.getToken(),
        candidateId: id,
      );

      debugPrint(
        '🟢 DASHBOARD RESPONSE: ${response.data}',
      );

      dashboard.value = DashboardCountModel.fromJson(
        response.data,
      );
    } catch (e) {
      debugPrint('🔴 DASHBOARD ERROR: $e');
    }
  }

  ////////////////////////////////////////////////////////////
  /// Jobs
  ////////////////////////////////////////////////////////////

  Future<void> getMatchedJobs() async {
    try {
      final id = candidateId.trim();
      final token = StorageService.getToken();

      debugPrint(
        '🟡 HOME MATCHED JOBS candidateId: $id',
      );

      if (id.isEmpty) {
        debugPrint(
          '🔴 HOME MATCHED JOBS: candidateId is empty',
        );

        jobs.clear();
        candidateRoles.clear();
        totalMatchedJobs.value = 0;
        return;
      }

      final response = await service.getMatchedJobs(
        token: token,
        candidateId: id,
      );

      debugPrint(
        '🟢 HOME MATCHED JOBS RESPONSE: ${response.data}',
      );

      final responseData = response.data;

      if (responseData is! Map) {
        debugPrint(
          '🔴 HOME MATCHED JOBS: Invalid response',
        );

        jobs.clear();
        candidateRoles.clear();
        totalMatchedJobs.value = 0;
        return;
      }

      final data = responseData['data'];

      if (data is! Map) {
        debugPrint(
          '🔴 HOME MATCHED JOBS: data object missing',
        );

        jobs.clear();
        candidateRoles.clear();
        totalMatchedJobs.value = 0;
        return;
      }

      final roles = data['candidateRoles'];

      if (roles is List) {
        candidateRoles.assignAll(
          roles
              .map((role) => role.toString())
              .where((role) => role.trim().isNotEmpty)
              .toList(),
        );
      } else {
        candidateRoles.clear();
      }

      totalMatchedJobs.value = int.tryParse(
        data['totalMatchedJobs']?.toString() ?? '0',
      ) ??
          0;

      final matchedJobs = data['matchedJobs'];

      final List<dynamic> list = matchedJobs is List
          ? matchedJobs
          : <dynamic>[];

      final parsedJobs = list
          .whereType<Map>()
          .map(
            (item) => JobModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .where((job) => job.id.isNotEmpty)
          .toList();

      parsedJobs.sort(
            (first, second) =>
            second.matchPercentage.compareTo(
              first.matchPercentage,
            ),
      );

      jobs.assignAll(parsedJobs);

      await syncSavedJobs();

      debugPrint(
        '🟢 HOME MATCHED JOBS COUNT: ${jobs.length}',
      );

      debugPrint(
        '🟢 HOME CANDIDATE ROLES: $candidateRoles',
      );
    } on DioException catch (e, stackTrace) {
      debugPrint(
        '🔴 HOME MATCHED JOBS ERROR: ${e.message}',
      );

      debugPrint(
        '🔴 HOME MATCHED JOBS STATUS: '
            '${e.response?.statusCode}',
      );

      debugPrint(
        '🔴 HOME MATCHED JOBS RESPONSE: '
            '${e.response?.data}',
      );

      debugPrint(
        '🔴 HOME MATCHED JOBS URL: '
            '${e.requestOptions.uri}',
      );

      debugPrint(
        '🔴 HOME MATCHED JOBS STACK: $stackTrace',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 HOME MATCHED JOBS ERROR: $e',
      );

      debugPrint(
        '🔴 HOME MATCHED JOBS STACK: $stackTrace',
      );
    }
  }

  // Future<void> getJobs() async {
  //   try {
  //     final response = await service.getJobs();
  //
  //     debugPrint(
  //       '🟢 JOBS RESPONSE: ${response.data}',
  //     );
  //
  //     final data = response.data;
  //
  //     List list = [];
  //
  //     if (data is List) {
  //       list = data;
  //     } else if (data is Map &&
  //         data['jobs'] is List) {
  //       list = data['jobs'];
  //     } else if (data is Map &&
  //         data['data'] is List) {
  //       list = data['data'];
  //     } else if (data is Map &&
  //         data['jobPosts'] is List) {
  //       list = data['jobPosts'];
  //     }
  //
  //     jobs.assignAll(
  //       list
  //           .map(
  //             (e) => JobModel.fromJson(
  //           Map<String, dynamic>.from(e),
  //         ),
  //       )
  //           .toList(),
  //     );
  //
  //     await syncSavedJobs();
  //
  //     debugPrint(
  //       '🟢 JOBS COUNT: ${jobs.length}',
  //     );
  //   } catch (e) {
  //     debugPrint('🔴 JOBS ERROR: $e');
  //   }
  // }

  ////////////////////////////////////////////////////////////
  /// Search
  ////////////////////////////////////////////////////////////

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();

    searchQuery.value = '';
  }

  ////////////////////////////////////////////////////////////
  /// Filters
  ////////////////////////////////////////////////////////////

  void onFilterSelected(String value) {
    selectedJobType.value = value;
  }

  void openFilters() {
    Get.bottomSheet(
      Obx(
            () => Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            30,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF171717),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Jobs',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 20),

                _filterTile(
                  title: 'All Jobs',
                  value: '',
                ),

                _filterTile(
                  title: 'Normal Jobs',
                  value: 'normal',
                ),

                _filterTile(
                  title: 'Short Jobs',
                  value: 'short',
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _filterTile({
    required String title,
    required String value,
  }) {
    final isSelected =
        selectedJobType.value == value;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        selectedJobType.value = value;

        Get.back();
      },
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? AppColors.white
              : AppColors.greyText,
          fontSize: 16,
          fontWeight: isSelected
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(
        Icons.check_circle,
        color: AppColors.primary,
      )
          : const Icon(
        Icons.circle_outlined,
        color: AppColors.greyText,
      ),
    );
  }

  void clearFilters() {
    selectedJobType.value = '';
  }

  ////////////////////////////////////////////////////////////
  /// Saved Jobs
  ////////////////////////////////////////////////////////////

  Future<void> syncSavedJobs() async {
    try {
      final token = StorageService.getToken();

      if (token.isEmpty) {
        return;
      }

      final response = await service.getSavedJobs(
        token: token,
      );

      final List saved =
          response.data['savedJobs'] ?? [];

      final ids = saved
          .map(
            (e) => e['_id']?.toString() ?? '',
      )
          .where(
            (id) => id.isNotEmpty,
      )
          .toSet();

      jobs.assignAll(
        jobs
            .map(
              (job) => job.copyWith(
            isSaved: ids.contains(job.id),
          ),
        )
            .toList(),
      );
    } catch (e) {
      debugPrint(
        '🔴 SAVED JOBS SYNC ERROR: $e',
      );
    }
  }

  ////////////////////////////////////////////////////////////
  /// Toggle Save Job
  ////////////////////////////////////////////////////////////

  Future<void> toggleSave(JobModel job) async {
    if (job.id.isEmpty) {
      debugPrint(
        '🔴 HOME TOGGLE SAVE ERROR: Job ID missing',
      );
      return;
    }

    final token = StorageService.getToken();

    if (token.isEmpty) {
      debugPrint(
        '🔴 HOME TOGGLE SAVE ERROR: Token missing',
      );
      return;
    }

    final homeIndex = jobs.indexWhere(
          (item) => item.id == job.id,
    );

    final oldValue = homeIndex != -1
        ? jobs[homeIndex].isSaved
        : job.isSaved;

    final optimisticValue = !oldValue;

    _updateSavedStateEverywhere(
      jobId: job.id,
      isSaved: optimisticValue,
    );

    try {
      final response = await service.toggleSavedJob(
        token: token,
        jobId: job.id,
      );

      debugPrint(
        '🟢 HOME TOGGLE SAVE RESPONSE: ${response.data}',
      );

      final responseData = response.data;

      bool saved = optimisticValue;

      if (responseData is Map &&
          responseData['isSaved'] is bool) {
        saved = responseData['isSaved'] == true;
      } else if (responseData is Map &&
          responseData['data'] is Map &&
          responseData['data']['isSaved'] is bool) {
        saved = responseData['data']['isSaved'] == true;
      }

      _updateSavedStateEverywhere(
        jobId: job.id,
        isSaved: saved,
      );

      debugPrint(
        saved
            ? '🟢 HOME JOB SAVED SUCCESSFULLY'
            : '🟢 HOME JOB REMOVED SUCCESSFULLY',
      );

      // No snackbar.
    } catch (e, stackTrace) {
      _updateSavedStateEverywhere(
        jobId: job.id,
        isSaved: oldValue,
      );

      debugPrint(
        '🔴 HOME TOGGLE SAVE ERROR: $e',
      );
      debugPrint(
        '🔴 HOME TOGGLE SAVE STACK: $stackTrace',
      );

      if (e is DioException) {
        debugPrint(
          '🔴 HOME TOGGLE SAVE STATUS: '
              '${e.response?.statusCode}',
        );
        debugPrint(
          '🔴 HOME TOGGLE SAVE RESPONSE: '
              '${e.response?.data}',
        );
        debugPrint(
          '🔴 HOME TOGGLE SAVE URL: '
              '${e.requestOptions.uri}',
        );
        debugPrint(
          '🔴 HOME TOGGLE SAVE METHOD: '
              '${e.requestOptions.method}',
        );
        debugPrint(
          '🔴 HOME TOGGLE SAVE REQUEST: '
              '${e.requestOptions.data}',
        );
        debugPrint(
          '🔴 HOME TOGGLE SAVE QUERY: '
              '${e.requestOptions.queryParameters}',
        );
      }

      // No snackbar.
    }
  }

  void _updateSavedStateEverywhere({
    required String jobId,
    required bool isSaved,
  }) {
    final homeIndex = jobs.indexWhere(
          (item) => item.id == jobId,
    );

    if (homeIndex != -1) {
      jobs[homeIndex] = jobs[homeIndex].copyWith(
        isSaved: isSaved,
      );
      jobs.refresh();
    }

    if (Get.isRegistered<JobDetailsController>()) {
      final detailsController =
      Get.find<JobDetailsController>();

      final detailsJob = detailsController.job.value;

      if (detailsJob != null &&
          detailsJob.id == jobId) {
        detailsController.job.value =
            detailsJob.copyWith(
              isSaved: isSaved,
            );
        detailsController.job.refresh();
      }
    }

    if (Get.isRegistered<ShortJobsController>()) {
      final shortJobsController =
      Get.find<ShortJobsController>();

      final shortIndex =
      shortJobsController.shortJobs.indexWhere(
            (item) => item.id == jobId,
      );

      if (shortIndex != -1) {
        shortJobsController.shortJobs[shortIndex] =
            shortJobsController.shortJobs[shortIndex]
                .copyWith(
              isSaved: isSaved,
            );

        shortJobsController.shortJobs.refresh();
      }
    }
  }
  }