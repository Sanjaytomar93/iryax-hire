import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../home/model/job_model.dart';
import '../../home/services/job_service.dart';

class ShortJobsController extends GetxController {
  final JobService service;

  ShortJobsController(this.service);

  final shortJobs = <JobModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getShortJobs();
  }

  Future<void> getShortJobs() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      error.value = '';

      debugPrint('🟡 FETCHING SHORT JOBS');

      final response = await service.getShortJobs();

      debugPrint(
        '🟢 SHORT JOBS RESPONSE: ${response.data}',
      );

      final data = response.data;

      List<dynamic> list = [];

      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data['jobPosts'] is List) {
          list = data['jobPosts'];
        } else if (data['jobs'] is List) {
          list = data['jobs'];
        } else if (data['data'] is List) {
          list = data['data'];
        } else if (data['data'] is Map &&
            data['data']['jobPosts'] is List) {
          list = data['data']['jobPosts'];
        } else if (data['data'] is Map &&
            data['data']['jobs'] is List) {
          list = data['data']['jobs'];
        }
      }

      shortJobs.assignAll(
        list
            .whereType<Map>()
            .map(
              (item) => JobModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList(),
      );

      await syncSavedJobs();

      debugPrint(
        '🟢 SHORT JOBS COUNT: ${shortJobs.length}',
      );
    } catch (e, stackTrace) {
      error.value = e.toString();

      _printDioError(
        title: 'SHORT JOBS',
        error: e,
        stackTrace: stackTrace,
      );

      // No snackbar.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshShortJobs() async {
    await getShortJobs();
  }

  Future<void> syncSavedJobs() async {
    try {
      final token = StorageService.getToken();

      if (token.isEmpty) {
        debugPrint(
          '🔴 SHORT JOB SAVED SYNC: Token missing',
        );
        return;
      }

      final response = await service.getSavedJobs(
        token: token,
      );

      debugPrint(
        '🟢 SHORT JOB SAVED RESPONSE: ${response.data}',
      );

      final data = response.data;

      List<dynamic> saved = [];

      if (data is List) {
        saved = data;
      } else if (data is Map) {
        if (data['savedJobs'] is List) {
          saved = data['savedJobs'];
        } else if (data['data'] is List) {
          saved = data['data'];
        } else if (data['data'] is Map &&
            data['data']['savedJobs'] is List) {
          saved = data['data']['savedJobs'];
        }
      }

      final ids = saved
          .whereType<Map>()
          .map((item) {
        final savedItem = Map<String, dynamic>.from(item);

        // Handles both direct job objects and wrapped job objects.
        final nestedJob = savedItem['job'];

        if (nestedJob is Map) {
          return nestedJob['_id']?.toString() ??
              nestedJob['id']?.toString() ??
              '';
        }

        final jobId = savedItem['jobId'];

        if (jobId is Map) {
          return jobId['_id']?.toString() ??
              jobId['id']?.toString() ??
              '';
        }

        return savedItem['_id']?.toString() ??
            savedItem['id']?.toString() ??
            jobId?.toString() ??
            '';
      })
          .where((id) => id.isNotEmpty)
          .toSet();

      shortJobs.assignAll(
        shortJobs
            .map(
              (job) => job.copyWith(
            isSaved: ids.contains(job.id),
          ),
        )
            .toList(),
      );

      debugPrint(
        '🟢 SHORT JOB SAVED IDS: $ids',
      );
    } catch (e, stackTrace) {
      _printDioError(
        title: 'SHORT JOB SAVED SYNC',
        error: e,
        stackTrace: stackTrace,
      );

      // No snackbar.
    }
  }

  Future<void> toggleSave(JobModel job) async {
    if (isSaving.value) {
      debugPrint(
        '🟡 SHORT JOB SAVE: Request already running',
      );
      return;
    }

    if (job.id.isEmpty) {
      debugPrint(
        '🔴 SHORT JOB SAVE ERROR: Job ID missing',
      );
      return;
    }

    final token = StorageService.getToken();

    if (token.isEmpty) {
      debugPrint(
        '🔴 SHORT JOB SAVE ERROR: Token missing',
      );
      return;
    }

    final index = shortJobs.indexWhere(
          (item) => item.id == job.id,
    );

    if (index == -1) {
      debugPrint(
        '🔴 SHORT JOB SAVE ERROR: Job not found in list',
      );
      return;
    }

    final oldValue = shortJobs[index].isSaved;
    final optimisticValue = !oldValue;

    shortJobs[index] = shortJobs[index].copyWith(
      isSaved: optimisticValue,
    );
    shortJobs.refresh();

    try {
      isSaving.value = true;

      final response = await service.toggleSavedJob(
        token: token,
        jobId: job.id,
      );

      debugPrint(
        '🟢 SHORT JOB SAVE RESPONSE: ${response.data}',
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

      final updatedIndex = shortJobs.indexWhere(
            (item) => item.id == job.id,
      );

      if (updatedIndex != -1) {
        shortJobs[updatedIndex] =
            shortJobs[updatedIndex].copyWith(
              isSaved: saved,
            );
        shortJobs.refresh();
      }

      debugPrint(
        saved
            ? '🟢 SHORT JOB SAVED SUCCESSFULLY'
            : '🟢 SHORT JOB REMOVED SUCCESSFULLY',
      );

      // No success snackbar.
    } catch (e, stackTrace) {
      final rollbackIndex = shortJobs.indexWhere(
            (item) => item.id == job.id,
      );

      if (rollbackIndex != -1) {
        shortJobs[rollbackIndex] =
            shortJobs[rollbackIndex].copyWith(
              isSaved: oldValue,
            );
        shortJobs.refresh();
      }

      _printDioError(
        title: 'SHORT JOB SAVE',
        error: e,
        stackTrace: stackTrace,
      );

      // No error snackbar.
    } finally {
      isSaving.value = false;
    }
  }

  void _printDioError({
    required String title,
    required Object error,
    required StackTrace stackTrace,
  }) {
    debugPrint('🔴 $title ERROR: $error');
    debugPrint('🔴 $title STACK TRACE: $stackTrace');

    if (error is DioException) {
      debugPrint(
        '🔴 $title TYPE: ${error.type}',
      );
      debugPrint(
        '🔴 $title MESSAGE: ${error.message}',
      );
      debugPrint(
        '🔴 $title STATUS: ${error.response?.statusCode}',
      );
      debugPrint(
        '🔴 $title RESPONSE: ${error.response?.data}',
      );
      debugPrint(
        '🔴 $title URL: ${error.requestOptions.uri}',
      );
      debugPrint(
        '🔴 $title METHOD: ${error.requestOptions.method}',
      );
      debugPrint(
        '🔴 $title REQUEST DATA: ${error.requestOptions.data}',
      );
      debugPrint(
        '🔴 $title QUERY: ${error.requestOptions.queryParameters}',
      );
      debugPrint(
        '🔴 $title HEADERS: ${error.requestOptions.headers}',
      );
    }
  }
}