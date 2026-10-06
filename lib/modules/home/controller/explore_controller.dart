import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../jobs/controller/job_details_controller.dart';
import '../../shortJobs/controller/short_jobs_controller.dart';
import '../model/job_model.dart';
import '../services/job_service.dart';

class ExploreController extends GetxController {
  final JobService service;

  ExploreController(this.service);

  final allJobs = <JobModel>[].obs;

  final isLoading = false.obs;
  final error = ''.obs;

  final searchController = TextEditingController();

  final searchQuery = ''.obs;
  final selectedJobType = ''.obs;

  List<JobModel> get filteredJobs {
    final query =
    searchQuery.value.trim().toLowerCase();

    final type =
    selectedJobType.value.trim().toLowerCase();

    return allJobs.where((job) {
      final matchesSearch = query.isEmpty ||
          job.role.toLowerCase().contains(query) ||
          job.companyName
              .toLowerCase()
              .contains(query) ||
          job.location.toLowerCase().contains(query) ||
          job.skills.toLowerCase().contains(query) ||
          job.department
              .toLowerCase()
              .contains(query);

      final matchesJobType = type.isEmpty ||
          job.jobType.toLowerCase() == type;

      return matchesSearch && matchesJobType;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();

    Future.microtask(getAllJobs);
  }

  Future<void> getAllJobs() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      debugPrint(
        '🟡 EXPLORE FETCHING ALL JOBS',
      );

      final response = await service.getJobs();

      debugPrint(
        '🟢 EXPLORE ALL JOBS RESPONSE: '
            '${response.data}',
      );

      final responseData = response.data;

      List<dynamic> list = [];

      if (responseData is List) {
        list = responseData;
      } else if (responseData is Map &&
          responseData['jobs'] is List) {
        list = List<dynamic>.from(
          responseData['jobs'],
        );
      } else if (responseData is Map &&
          responseData['jobPosts'] is List) {
        list = List<dynamic>.from(
          responseData['jobPosts'],
        );
      } else if (responseData is Map &&
          responseData['data'] is List) {
        list = List<dynamic>.from(
          responseData['data'],
        );
      } else if (responseData is Map &&
          responseData['data'] is Map &&
          responseData['data']['jobs'] is List) {
        list = List<dynamic>.from(
          responseData['data']['jobs'],
        );
      } else if (responseData is Map &&
          responseData['data'] is Map &&
          responseData['data']['jobPosts']
          is List) {
        list = List<dynamic>.from(
          responseData['data']['jobPosts'],
        );
      }

      allJobs.assignAll(
        list
            .whereType<Map>()
            .map(
              (item) => JobModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .where(
              (job) => job.id.isNotEmpty,
        )
            .toList(),
      );

      await Future.wait([
        syncSavedJobs(),
        syncAppliedJobs(),
      ]);

      debugPrint(
        '🟢 EXPLORE ALL JOBS COUNT: '
            '${allJobs.length}',
      );
    } on DioException catch (e, stackTrace) {
      error.value = _extractErrorMessage(e);

      debugPrint(
        '🔴 EXPLORE JOBS DIO ERROR: ${e.message}',
      );
      debugPrint(
        '🔴 EXPLORE JOBS STATUS: '
            '${e.response?.statusCode}',
      );
      debugPrint(
        '🔴 EXPLORE JOBS RESPONSE: '
            '${e.response?.data}',
      );
      debugPrint(
        '🔴 EXPLORE JOBS URL: '
            '${e.requestOptions.uri}',
      );
      debugPrint(
        '🔴 EXPLORE JOBS STACK: $stackTrace',
      );
    } catch (e, stackTrace) {
      error.value = 'Unable to load jobs';

      debugPrint(
        '🔴 EXPLORE JOBS ERROR: $e',
      );
      debugPrint(
        '🔴 EXPLORE JOBS STACK: $stackTrace',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void markJobAsApplied(String jobId) {
    if (jobId.trim().isEmpty) {
      return;
    }

    final index = allJobs.indexWhere(
          (job) => job.id == jobId,
    );

    if (index == -1) {
      return;
    }

    allJobs[index] = allJobs[index].copyWith(
      isApplied: true,
    );

    allJobs.refresh();

    debugPrint(
      '🟢 EXPLORE JOB MARKED AS APPLIED: $jobId',
    );
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void onFilterSelected(String value) {
    selectedJobType.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void clearFilters() {
    selectedJobType.value = '';
  }

  Future<void> syncSavedJobs() async {
    try {
      final token = StorageService.getToken();

      if (token.isEmpty) {
        return;
      }

      final response = await service.getSavedJobs(
        token: token,
      );

      final responseData = response.data;

      List<dynamic> savedJobs = [];

      if (responseData is Map &&
          responseData['savedJobs'] is List) {
        savedJobs = List<dynamic>.from(
          responseData['savedJobs'],
        );
      } else if (responseData is Map &&
          responseData['data'] is Map &&
          responseData['data']['savedJobs'] is List) {
        savedJobs = List<dynamic>.from(
          responseData['data']['savedJobs'],
        );
      } else if (responseData is Map &&
          responseData['data'] is List) {
        savedJobs = List<dynamic>.from(
          responseData['data'],
        );
      }

      final savedIds = savedJobs
          .map((item) {
        if (item is Map) {
          return item['_id']?.toString() ??
              item['id']?.toString() ??
              item['jobId']?.toString() ??
              '';
        }

        return item.toString();
      })
          .where((id) => id.isNotEmpty)
          .toSet();

      allJobs.assignAll(
        allJobs
            .map(
              (job) => job.copyWith(
            isSaved:
            savedIds.contains(job.id),
          ),
        )
            .toList(),
      );
    } catch (e) {
      debugPrint(
        '🔴 EXPLORE SAVED JOBS SYNC ERROR: $e',
      );
    }
  }


  Future<void> syncAppliedJobs() async {
    try {
      final token = StorageService.getToken();

      if (token.isEmpty) {
        debugPrint(
          '🔴 EXPLORE APPLIED JOBS SYNC: Token missing',
        );
        return;
      }

      final response =
      await service.getCandidateApplications(
        token: token,
      );

      debugPrint(
        '🟢 EXPLORE APPLICATIONS RESPONSE: '
            '${response.data}',
      );

      final responseData = response.data;

      List<dynamic> applications = [];

      if (responseData is List) {
        applications = responseData;
      } else if (responseData is Map &&
          responseData['applications'] is List) {
        applications = List<dynamic>.from(
          responseData['applications'],
        );
      } else if (responseData is Map &&
          responseData['data'] is List) {
        applications = List<dynamic>.from(
          responseData['data'],
        );
      } else if (responseData is Map &&
          responseData['data'] is Map &&
          responseData['data']['applications']
          is List) {
        applications = List<dynamic>.from(
          responseData['data']['applications'],
        );
      }

      final appliedJobIds = applications
          .map(_extractAppliedJobId)
          .where((id) => id.isNotEmpty)
          .toSet();

      allJobs.assignAll(
        allJobs.map((job) {
          return job.copyWith(
            isApplied:
            job.isApplied ||
                appliedJobIds.contains(job.id),
          );
        }).toList(),
      );

      allJobs.refresh();

      debugPrint(
        '🟢 EXPLORE APPLIED JOB IDS: '
            '$appliedJobIds',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 EXPLORE APPLIED JOBS SYNC ERROR: $e',
      );
      debugPrint(
        '🔴 EXPLORE APPLIED JOBS SYNC STACK: '
            '$stackTrace',
      );
    }
  }

  String _extractAppliedJobId(dynamic item) {
    if (item is! Map) {
      return '';
    }

    final jobData =
        item['jobId'] ??
            item['job'] ??
            item['jobPost'];

    // jobId contains the complete job object.
    if (jobData is Map) {
      return jobData['_id']?.toString() ??
          jobData['id']?.toString() ??
          '';
    }

    // jobId contains only the ID string.
    if (jobData != null) {
      return jobData.toString();
    }

    // Fallback response structures.
    return item['jobPostId']?.toString() ??
        item['job_id']?.toString() ??
        '';
  }

  Future<void> toggleSave(JobModel job) async {
    if (job.id.isEmpty) {
      debugPrint(
        '🔴 EXPLORE SAVE ERROR: Job ID missing',
      );
      return;
    }

    final token = StorageService.getToken();

    if (token.isEmpty) {
      debugPrint(
        '🔴 EXPLORE SAVE ERROR: Token missing',
      );
      return;
    }

    final index = allJobs.indexWhere(
          (item) => item.id == job.id,
    );

    if (index == -1) {
      return;
    }

    final oldValue = allJobs[index].isSaved;
    final newValue = !oldValue;

    _updateSavedState(
      jobId: job.id,
      isSaved: newValue,
    );

    try {
      final response =
      await service.toggleSavedJob(
        token: token,
        jobId: job.id,
      );

      debugPrint(
        '🟢 EXPLORE SAVE RESPONSE: '
            '${response.data}',
      );

      final responseData = response.data;

      bool finalSavedValue = newValue;

      if (responseData is Map &&
          responseData['isSaved'] is bool) {
        finalSavedValue =
            responseData['isSaved'] == true;
      } else if (responseData is Map &&
          responseData['data'] is Map &&
          responseData['data']['isSaved']
          is bool) {
        finalSavedValue =
            responseData['data']['isSaved'] ==
                true;
      }

      _updateSavedState(
        jobId: job.id,
        isSaved: finalSavedValue,
      );
    } catch (e, stackTrace) {
      _updateSavedState(
        jobId: job.id,
        isSaved: oldValue,
      );

      debugPrint(
        '🔴 EXPLORE SAVE ERROR: $e',
      );
      debugPrint(
        '🔴 EXPLORE SAVE STACK: $stackTrace',
      );
    }
  }

  void _updateSavedState({
    required String jobId,
    required bool isSaved,
  }) {
    final index = allJobs.indexWhere(
          (item) => item.id == jobId,
    );

    if (index != -1) {
      allJobs[index] = allJobs[index].copyWith(
        isSaved: isSaved,
      );

      allJobs.refresh();
    }

    if (Get.isRegistered<JobDetailsController>()) {
      final detailsController =
      Get.find<JobDetailsController>();

      final detailsJob =
          detailsController.job.value;

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
      final shortController =
      Get.find<ShortJobsController>();

      final shortIndex =
      shortController.shortJobs.indexWhere(
            (item) => item.id == jobId,
      );

      if (shortIndex != -1) {
        shortController.shortJobs[shortIndex] =
            shortController
                .shortJobs[shortIndex]
                .copyWith(
              isSaved: isSaved,
            );

        shortController.shortJobs.refresh();
      }
    }
  }

  String _extractErrorMessage(
      DioException exception,
      ) {
    final data = exception.response?.data;

    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'Unable to load jobs';
    }

    return 'Unable to load jobs';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}