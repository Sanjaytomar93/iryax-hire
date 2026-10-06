import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../home/controller/explore_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/job_model.dart';
import '../../home/services/job_service.dart';

class JobDetailsController extends GetxController {
  final JobService jobService;

  JobDetailsController(this.jobService);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final job = Rxn<JobModel>();

  String jobId = '';

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is JobModel) {
      job.value = args;
      jobId = args.id;
    } else if (args is Map) {
      final argumentJob = args['job'];

      if (argumentJob is JobModel) {
        job.value = argumentJob;
        jobId = argumentJob.id;
      } else {
        jobId =
            args['jobId']?.toString() ?? '';
      }
    } else {
      jobId = args?.toString() ?? '';
    }

    if (jobId.isNotEmpty) {
      getJobDetails();
    } else {
      debugPrint(
        '🔴 JOB DETAILS ERROR: Job ID is empty',
      );
    }
  }

  Future<void> getJobDetails() async {
    try {
      isLoading.value = true;

      final previousJob = job.value;

      final response =
      await jobService.getJobDetails(
        jobId: jobId,
        token: StorageService.getToken(),
      );

      debugPrint(
        '🟢 JOB DETAILS RESPONSE: ${response.data}',
      );

      final responseData = response.data;

      dynamic data;

      if (responseData is Map) {
        data = responseData['jobPost'] ??
            responseData['data'];
      }

      if (data is! Map) {
        debugPrint(
          '🔴 JOB DETAILS: Job object missing',
        );
        return;
      }

      final rawJob =
      Map<String, dynamic>.from(data);

      final apiJob = JobModel.fromJson(rawJob);

      final hasIsSaved =
      rawJob.containsKey('isSaved');

      final hasIsApplied =
      rawJob.containsKey('isApplied');

      job.value = apiJob.copyWith(
        isSaved: hasIsSaved
            ? apiJob.isSaved
            : previousJob?.isSaved ?? false,
        isApplied: hasIsApplied
            ? apiJob.isApplied
            : previousJob?.isApplied ?? false,
      );

      job.refresh();

      debugPrint(
        '🟢 JOB DETAILS isSaved: '
            '${job.value?.isSaved}',
      );

      debugPrint(
        '🟢 JOB DETAILS isApplied: '
            '${job.value?.isApplied}',
      );
    } on DioException catch (e, stackTrace) {
      debugPrint(
        '🔴 JOB DETAILS ERROR: ${e.message}',
      );
      debugPrint(
        '🔴 JOB DETAILS STATUS: '
            '${e.response?.statusCode}',
      );
      debugPrint(
        '🔴 JOB DETAILS DATA: '
            '${e.response?.data}',
      );
      debugPrint(
        '🔴 JOB DETAILS URL: '
            '${e.requestOptions.uri}',
      );
      debugPrint(
        '🔴 JOB DETAILS METHOD: '
            '${e.requestOptions.method}',
      );
      debugPrint(
        '🔴 JOB DETAILS STACK: $stackTrace',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 JOB DETAILS ERROR: $e',
      );
      debugPrint(
        '🔴 JOB DETAILS STACK: $stackTrace',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSave() async {
    final currentJob = job.value;

    if (currentJob == null ||
        currentJob.id.isEmpty ||
        isSaving.value) {
      return;
    }

    final token = StorageService.getToken();

    if (token.isEmpty) {
      debugPrint(
        '🔴 JOB SAVE ERROR: Token missing',
      );
      return;
    }

    final oldValue = currentJob.isSaved;
    final optimisticValue = !oldValue;

    job.value = currentJob.copyWith(
      isSaved: optimisticValue,
    );
    job.refresh();

    try {
      isSaving.value = true;

      final response =
      await jobService.toggleSavedJob(
        token: token,
        jobId: currentJob.id,
      );

      debugPrint(
        '🟢 JOB DETAILS SAVE RESPONSE: '
            '${response.data}',
      );

      final responseData = response.data;

      bool finalSavedValue = optimisticValue;

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

      final latestJob = job.value;

      if (latestJob != null) {
        job.value = latestJob.copyWith(
          isSaved: finalSavedValue,
        );
        job.refresh();
      }

      _syncSavedStateEverywhere(
        jobId: currentJob.id,
        isSaved: finalSavedValue,
      );
    } catch (e, stackTrace) {
      final latestJob = job.value;

      if (latestJob != null) {
        job.value = latestJob.copyWith(
          isSaved: oldValue,
        );
        job.refresh();
      }

      debugPrint(
        '🔴 JOB DETAILS TOGGLE SAVE ERROR: $e',
      );
      debugPrint('$stackTrace');
    } finally {
      isSaving.value = false;
    }
  }

  void markAsApplied() {
    final currentJob = job.value;

    if (currentJob == null) {
      return;
    }

    job.value = currentJob.copyWith(
      isApplied: true,
    );

    job.refresh();

    _syncAppliedStateEverywhere(
      jobId: currentJob.id,
    );
  }

  void _syncSavedStateEverywhere({
    required String jobId,
    required bool isSaved,
  }) {
    if (Get.isRegistered<HomeController>()) {
      final homeController =
      Get.find<HomeController>();

      final index =
      homeController.jobs.indexWhere(
            (item) => item.id == jobId,
      );

      if (index != -1) {
        homeController.jobs[index] =
            homeController.jobs[index].copyWith(
              isSaved: isSaved,
            );

        homeController.jobs.refresh();
      }

      if (Get.isRegistered<ExploreController>()) {
        Get.find<ExploreController>()
            .markJobAsApplied(jobId);
      }
    }

    if (Get.isRegistered<ExploreController>()) {
      final exploreController =
      Get.find<ExploreController>();

      final index =
      exploreController.allJobs.indexWhere(
            (item) => item.id == jobId,
      );

      if (index != -1) {
        exploreController.allJobs[index] =
            exploreController
                .allJobs[index]
                .copyWith(
              isSaved: isSaved,
            );

        exploreController.allJobs.refresh();
      }
    }
  }

  void _syncAppliedStateEverywhere({
    required String jobId,
  }) {
    if (Get.isRegistered<HomeController>()) {
      final homeController =
      Get.find<HomeController>();

      final index =
      homeController.jobs.indexWhere(
            (item) => item.id == jobId,
      );

      if (index != -1) {
        homeController.jobs[index] =
            homeController.jobs[index].copyWith(
              isApplied: true,
            );

        homeController.jobs.refresh();
      }
    }

    if (Get.isRegistered<ExploreController>()) {
      final exploreController =
      Get.find<ExploreController>();

      final index =
      exploreController.allJobs.indexWhere(
            (item) => item.id == jobId,
      );

      if (index != -1) {
        exploreController.allJobs[index] =
            exploreController
                .allJobs[index]
                .copyWith(
              isApplied: true,
            );

        exploreController.allJobs.refresh();
      }
    }
  }
}