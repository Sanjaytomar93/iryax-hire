import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../home/services/job_service.dart';
import '../model/application_details_model.dart';
import '../model/application_model.dart';
import '../model/application_timeline_item.dart';

class ApplicationDetailsController extends GetxController {
  final JobService service;

  ApplicationDetailsController(this.service);

  final isLoading = false.obs;
  final isRespondingToInterview = false.obs;
  final error = ''.obs;

  final application =
  Rxn<ApplicationDetailsModel>();

  final interviewNoteController =
  TextEditingController();

  String applicationId = '';

  ApplicationModel? sourceApplication;

  final localInterviewResponseStatus = ''.obs;

  static const List<String> _progressStages = [
    'Application Submitted',
    'Application Reviewed',
    'Application Shortlisted',
    'Initial Screening Interview',
    'Technical Interview',
    'HR Round Interview',
    'Selected',
    'Offer Letter',
  ];

  @override
  void onInit() {
    super.onInit();

    _readArguments();

    if (applicationId.trim().isEmpty) {
      error.value = 'Application ID is missing';

      debugPrint(
        '🔴 APPLICATION DETAILS: '
            'Application ID missing',
      );

      return;
    }

    getApplicationDetails();
  }

  @override
  void onClose() {
    interviewNoteController.dispose();
    super.onClose();
  }

  void _readArguments() {
    final dynamic arguments = Get.arguments;

    debugPrint('');
    debugPrint(
      '════════════════════════════════════════',
    );
    debugPrint('🟡 APPLICATION DETAILS ARGUMENTS');
    debugPrint(
      '🟡 TYPE: ${arguments.runtimeType}',
    );
    debugPrint('🟡 VALUE: $arguments');
    debugPrint(
      '════════════════════════════════════════',
    );

    if (arguments is String) {
      applicationId = arguments.trim();
      return;
    }

    if (arguments is Map) {
      applicationId =
          arguments['applicationId']
              ?.toString()
              .trim() ??
              '';

      final dynamic source =
      arguments['application'];

      if (source is ApplicationModel) {
        sourceApplication = source;
      }
    }
  }

  ApplicationInterviewModel? get effectiveInterview {
    final ApplicationInterviewModel? detailsInterview =
        application.value?.interview;

    /*
     * A valid interview must contain interviewTime.
     */
    if (detailsInterview?.scheduledAt != null) {
      return detailsInterview;
    }

    final ApplicationInterviewModel? sourceInterview =
        sourceApplication?.interview;

    if (sourceInterview?.scheduledAt != null) {
      return sourceInterview;
    }

    return null;
  }

  String get effectiveStatus {
    final String detailsStatus =
        application.value?.status.trim() ?? '';

    final String sourceStatus =
        sourceApplication?.status.trim() ?? '';

    final ApplicationInterviewModel? interview =
        effectiveInterview;

    if (interview?.isConfirmed == true) {
      return 'Confirmed';
    }

    if (interview?.isDeclined == true) {
      return 'Declined';
    }

    if (interview?.hasSchedule == true) {
      return 'Interview';
    }

    if (detailsStatus.isNotEmpty) {
      return detailsStatus;
    }

    if (sourceStatus.isNotEmpty) {
      return sourceStatus;
    }

    return 'Application Submitted';
  }

  String get displayStatus {
    final ApplicationDetailsModel? details =
        application.value;

    final bool hasOfferLetter =
        sourceApplication?.hasOfferLetter == true;

    if (hasOfferLetter) {
      return 'Offer Letter';
    }

    final ApplicationInterviewModel? interview =
        effectiveInterview;

    if (isInterviewConfirmed) {
      return 'Interview Confirmed';
    }

    if (isInterviewDeclined) {
      return 'Interview Reschedule Requested';
    }

    if (interview?.hasSchedule == true) {
      return 'Selected for Interview';
    }

    if (details != null) {
      return _statusDisplayName(
        details.status,
      );
    }

    return _statusDisplayName(
      effectiveStatus,
    );
  }

  bool get canRespondToInterview {
    final ApplicationInterviewModel? interview =
        effectiveInterview;

    if (interview == null ||
        !interview.hasSchedule) {
      return false;
    }

    if (isInterviewConfirmed ||
        isInterviewDeclined) {
      return false;
    }

    return true;
  }


  bool get isInterviewConfirmed {
    final String localStatus =
    localInterviewResponseStatus.value
        .trim()
        .toLowerCase();

    if (localStatus == 'confirmed') {
      return true;
    }

    return effectiveInterview?.isConfirmed == true;
  }

  bool get isInterviewDeclined {
    final String localStatus =
    localInterviewResponseStatus.value
        .trim()
        .toLowerCase();

    if (localStatus == 'declined') {
      return true;
    }

    return effectiveInterview?.isDeclined == true;
  }

  int get scheduledInterviewStageIndex {
    final ApplicationInterviewModel? interview =
        effectiveInterview;

    if (interview == null) {
      return 4;
    }

    switch (interview.timelineTitle) {
      case 'HR Round Interview':
        return 5;

      case 'Initial Screening Interview':
        return 3;

      case 'Technical Interview':
      default:
        return 4;
    }
  }

  Future<void> getApplicationDetails() async {
    if (isLoading.value) {
      return;
    }

    if (applicationId.trim().isEmpty) {
      error.value = 'Application ID is missing';
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final String token =
      StorageService.getToken();

      if (token.isEmpty) {
        error.value =
        'Authentication token is missing';

        debugPrint(
          '🔴 SINGLE APPLICATION: Token missing',
        );

        return;
      }

      debugPrint('');
      debugPrint(
        '════════════════════════════════════════',
      );
      debugPrint(
        '🟡 GET SINGLE APPLICATION REQUEST',
      );
      debugPrint(
        '🟡 APPLICATION ID: $applicationId',
      );
      debugPrint(
        '🟡 SOURCE AVAILABLE: '
            '${sourceApplication != null}',
      );
      debugPrint(
        '════════════════════════════════════════',
      );

      _debugSourceApplication();

      final dio.Response<dynamic> response =
      await service.getSingleApplication(
        token: token,
        applicationId: applicationId,
      );

      debugPrint(
        '🟢 SINGLE APPLICATION STATUS: '
            '${response.statusCode}',
      );
      debugPrint(
        '🟢 SINGLE APPLICATION URL: '
            '${response.requestOptions.uri}',
      );

      final Map<String, dynamic>?
      applicationJson =
      _extractApplicationJson(
        response.data,
      );

      if (applicationJson == null) {
        error.value =
        'Application details were not found';

        _printCompleteJson(
          title:
          '🔴 UNRECOGNIZED SINGLE APPLICATION RESPONSE',
          data: response.data,
        );

        return;
      }

      _printCompleteJson(
        title:
        '🟢 COMPLETE SINGLE APPLICATION RESPONSE',
        data: applicationJson,
      );

      final ApplicationDetailsModel parsed =
      ApplicationDetailsModel.fromJson(
        applicationJson,
      );

      application.value = parsed;

      _debugParsedApplication(parsed);
      _debugTimeline();
    } on dio.DioException catch (
    exception,
    stackTrace
    ) {
    error.value = _getDioMessage(
    exception,
    );

    debugPrint(
    '🔴 SINGLE APPLICATION DIO ERROR',
    );
    debugPrint(
    '🔴 STATUS: '
    '${exception.response?.statusCode}',
    );
    debugPrint(
    '🔴 MESSAGE: ${exception.message}',
    );
    debugPrint(
    '🔴 URL: '
    '${exception.requestOptions.uri}',
    );

    _printCompleteJson(
    title:
    '🔴 COMPLETE SINGLE APPLICATION ERROR',
    data: exception.response?.data,
    );

    debugPrint('$stackTrace');
    } catch (exception, stackTrace) {
    error.value =
    'Unable to load application details';

    debugPrint(
    '🔴 APPLICATION DETAILS ERROR: '
    '$exception',
    );
    debugPrint('$stackTrace');
    } finally {
    isLoading.value = false;
    }
  }

  Map<String, dynamic>? _extractApplicationJson(
      dynamic data,
      ) {
    if (data is! Map) {
      return null;
    }

    final Map<String, dynamic> root =
    Map<String, dynamic>.from(data);

    if (root['application'] is Map) {
      return Map<String, dynamic>.from(
        root['application'] as Map,
      );
    }

    if (root['data'] is Map) {
      final Map<String, dynamic> nested =
      Map<String, dynamic>.from(
        root['data'] as Map,
      );

      if (nested['application'] is Map) {
        return Map<String, dynamic>.from(
          nested['application'] as Map,
        );
      }

      if (_looksLikeApplication(nested)) {
        return nested;
      }
    }

    if (_looksLikeApplication(root)) {
      return root;
    }

    return null;
  }

  bool _looksLikeApplication(
      Map<String, dynamic> json,
      ) {
    return json.containsKey('_id') ||
        json.containsKey('id') ||
        json.containsKey('job') ||
        json.containsKey('jobId') ||
        json.containsKey('status') ||
        json.containsKey('trackers');
  }

  List<ApplicationTimelineItem> get timelineItems {
    final ApplicationDetailsModel? details =
        application.value;

    if (details == null) {
      return <ApplicationTimelineItem>[];
    }

    final ApplicationInterviewModel? interview =
        effectiveInterview;

    final bool hasInterviewSchedule =
        interview?.scheduledAt != null;

    final int interviewStageIndex =
        scheduledInterviewStageIndex;

    final Map<int, DateTime?> timestamps =
    <int, DateTime?>{};

    int highestCompletedIndex = -1;

    for (final tracker in details.trackers) {
      final int stageIndex =
      _getStageIndex(
        tracker.status,
      );

      if (stageIndex == -1) {
        continue;
      }

      timestamps[stageIndex] =
          tracker.timestamp;

      if (stageIndex > highestCompletedIndex) {
        highestCompletedIndex = stageIndex;
      }
    }

    final int statusIndex =
    _getStageIndex(
      effectiveStatus,
    );

    if (statusIndex > highestCompletedIndex) {
      highestCompletedIndex = statusIndex;
    }

    if (hasInterviewSchedule &&
        interview != null) {
      timestamps[interviewStageIndex] =
          interview.scheduledAt;

      if (interviewStageIndex >
          highestCompletedIndex) {
        highestCompletedIndex =
            interviewStageIndex;
      }
    }

    final bool hasOfferLetter =
        sourceApplication?.hasOfferLetter == true;

    if (hasOfferLetter) {
      highestCompletedIndex = 7;
    }

    if (highestCompletedIndex < 0) {
      highestCompletedIndex = 0;
    }

    final String interviewMode =
        interview?.mode ?? '';

    final String interviewAddress =
        interview?.address ?? '';

    final String interviewLink =
        interview?.link ?? '';

    final List<ApplicationTimelineItem> items =
    <ApplicationTimelineItem>[];

    for (
    int index = _progressStages.length - 1;
    index >= 0;
    index--
    ) {
      final bool scheduledInterviewRow =
          hasInterviewSchedule &&
              index == interviewStageIndex;

      DateTime? timestamp = timestamps[index];

      if (index == 0 && timestamp == null) {
        timestamp = details.createdAt;
      }

      items.add(
        ApplicationTimelineItem(
          title: _progressStages[index],
          isCompleted:
          index <= highestCompletedIndex,
          isCurrent:
          index == highestCompletedIndex,
          isInterviewStage:
          _progressStages[index]
              .toLowerCase()
              .contains('interview'),
          hasInterviewSchedule:
          scheduledInterviewRow,
          timestamp: timestamp,
          interviewMode:
          scheduledInterviewRow
              ? interviewMode
              : '',
          interviewAddress:
          scheduledInterviewRow
              ? interviewAddress
              : '',
          interviewLink:
          scheduledInterviewRow
              ? interviewLink
              : '',
        ),
      );
    }

    return items;
  }

  int _getStageIndex(String rawStatus) {
    final String status =
    _normalizeStatus(rawStatus);

    if (status.contains('offer')) {
      return 7;
    }

    if (status.contains('hr') &&
        status.contains('interview')) {
      return 5;
    }

    if (status.contains('technical') &&
        status.contains('interview')) {
      return 4;
    }

    if ((status.contains('screening') ||
        status.contains('initial')) &&
        status.contains('interview')) {
      return 3;
    }

    /*
     * Generic Interview / Confirmed / Declined
     * is mapped to the scheduled interview stage.
     */
    if (status == 'interview' ||
        status == 'confirmed' ||
        status == 'declined' ||
        status.contains(
          'selected for interview',
        ) ||
        status.contains(
          'interview scheduled',
        )) {
      return scheduledInterviewStageIndex;
    }

    if (status.contains('selected') ||
        status.contains('accepted') ||
        status.contains('hired')) {
      return 6;
    }

    if (status.contains('shortlist')) {
      return 2;
    }

    if (status.contains('review')) {
      return 1;
    }

    if (status.contains('submitted') ||
        status.contains('pending') ||
        status.contains('applied')) {
      return 0;
    }

    return -1;
  }

  String _statusDisplayName(
      String rawStatus,
      ) {
    final int index =
    _getStageIndex(rawStatus);

    if (index >= 0 &&
        index < _progressStages.length) {
      return _progressStages[index];
    }

    final String value = rawStatus.trim();

    return value.isEmpty
        ? 'Application Submitted'
        : value;
  }

  String _normalizeStatus(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }

  Future<bool> respondToInterview({
    required String status,
    String note = '',
  }) async {
    if (isRespondingToInterview.value) {
      return false;
    }

    if (applicationId.trim().isEmpty) {
      Get.snackbar(
        'Interview',
        'Application ID is missing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
        const Color(0xFF252525),
        colorText: Colors.white,
      );

      return false;
    }

    final String normalizedStatus =
    status.trim();

    if (normalizedStatus != 'Confirmed' &&
        normalizedStatus != 'Declined') {
      Get.snackbar(
        'Interview',
        'Invalid interview response',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
        const Color(0xFF252525),
        colorText: Colors.white,
      );

      return false;
    }

    try {
      isRespondingToInterview.value = true;

      final String token =
      StorageService.getToken();

      if (token.isEmpty) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor:
          const Color(0xFF252525),
          colorText: Colors.white,
        );

        return false;
      }

      final dio.Response<dynamic> response =
      await service.respondToInterview(
        token: token,
        applicationId: applicationId,
        status: normalizedStatus,
        note: note.trim(),
      );

      _printCompleteJson(
        title:
        '🟢 COMPLETE INTERVIEW RESPONSE',
        data: response.data,
      );

      String message =
      normalizedStatus == 'Confirmed'
          ? 'Interview confirmed successfully. 5 coins added.'
          : 'Interview declined. A reschedule request has been sent.';

      if (response.data is Map) {
        final String apiMessage =
            response.data['message']
                ?.toString()
                .trim() ??
                '';

        if (apiMessage.isNotEmpty) {
          message = apiMessage;
        }
      }

      localInterviewResponseStatus.value =
          normalizedStatus;

      await getApplicationDetails();

      Get.snackbar(
        normalizedStatus == 'Confirmed'
            ? 'Interview Confirmed'
            : 'Reschedule Requested',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
        const Color(0xFF252525),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      return true;
    } on dio.DioException catch (
    exception,
    stackTrace
    ) {
    String message =
    'Unable to update interview response';

    final dynamic responseData =
    exception.response?.data;

    if (responseData is Map) {
    final String apiMessage =
    responseData['message']
        ?.toString()
        .trim() ??
    '';

    if (apiMessage.isNotEmpty) {
    message = apiMessage;
    }
    }

    _printCompleteJson(
    title:
    '🔴 COMPLETE INTERVIEW RESPONSE ERROR',
    data: responseData,
    );

    debugPrint('$stackTrace');

    Get.snackbar(
    'Interview',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor:
    const Color(0xFF252525),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    );

    return false;
    } catch (exception, stackTrace) {
    debugPrint(
    '🔴 INTERVIEW RESPONSE ERROR: '
    '$exception',
    );
    debugPrint('$stackTrace');

    Get.snackbar(
    'Interview',
    'Unable to update interview response',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor:
    const Color(0xFF252525),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    );

    return false;
    } finally {
    isRespondingToInterview.value = false;
    }
  }

  void _debugSourceApplication() {
    final ApplicationModel? source =
        sourceApplication;

    if (source == null) {
      debugPrint(
        '🟠 SOURCE APPLICATION: Not available',
      );
      return;
    }

    debugPrint('');
    debugPrint(
      '──────── SOURCE APPLICATION ────────',
    );
    debugPrint('ID: ${source.id}');
    debugPrint('STATUS: ${source.status}');
    debugPrint(
      'DISPLAY STATUS: ${source.displayStatus}',
    );
    debugPrint(
      'INTERVIEW TIME: '
          '${source.interview.scheduledAt}',
    );
    debugPrint(
      'INTERVIEW MODE: '
          '${source.interview.mode}',
    );
    debugPrint(
      'INTERVIEW ADDRESS: '
          '${source.interview.address}',
    );
    debugPrint(
      'INTERVIEW LINK: '
          '${source.interview.link}',
    );
    debugPrint(
      'HAS SCHEDULE: '
          '${source.interview.hasSchedule}',
    );
    debugPrint(
      'RESPONSE STATUS: '
          '${source.interview.responseStatus}',
    );
    debugPrint(
      'HAS OFFER LETTER: '
          '${source.hasOfferLetter}',
    );
    debugPrint(
      '────────────────────────────────────',
    );
    debugPrint('');
  }

  void _debugParsedApplication(
      ApplicationDetailsModel details,
      ) {
    debugPrint('');
    debugPrint(
      '──────── PARSED APPLICATION ────────',
    );
    debugPrint('ID: ${details.id}');
    debugPrint('STATUS: ${details.status}');
    debugPrint(
      'DISPLAY STATUS: $displayStatus',
    );
    debugPrint(
      'ROLE: ${details.job.role}',
    );
    debugPrint(
      'COMPANY: ${details.job.companyName}',
    );
    debugPrint(
      'TRACKERS: ${details.trackers.length}',
    );

    for (
    int index = 0;
    index < details.trackers.length;
    index++
    ) {
      final tracker =
      details.trackers[index];

      debugPrint(
        'TRACKER ${index + 1}: '
            '${tracker.status}, '
            '${tracker.timestamp}',
      );
    }

    debugPrint(
      'DETAIL INTERVIEW TIME: '
          '${details.interview.scheduledAt}',
    );
    debugPrint(
      'DETAIL INTERVIEW MODE: '
          '${details.interview.mode}',
    );
    debugPrint(
      'DETAIL INTERVIEW ADDRESS: '
          '${details.interview.address}',
    );
    debugPrint(
      'DETAIL INTERVIEW LINK: '
          '${details.interview.link}',
    );
    debugPrint(
      'DETAIL HAS SCHEDULE: '
          '${details.interview.hasSchedule}',
    );

    final ApplicationInterviewModel? effective =
        effectiveInterview;

    debugPrint(
      'EFFECTIVE INTERVIEW TIME: '
          '${effective?.scheduledAt}',
    );
    debugPrint(
      'EFFECTIVE INTERVIEW MODE: '
          '${effective?.mode}',
    );
    debugPrint(
      'EFFECTIVE INTERVIEW ADDRESS: '
          '${effective?.address}',
    );
    debugPrint(
      'EFFECTIVE HAS SCHEDULE: '
          '${effective?.hasSchedule}',
    );
    debugPrint(
      'INTERVIEW STAGE INDEX: '
          '$scheduledInterviewStageIndex',
    );
    debugPrint(
      '────────────────────────────────────',
    );
    debugPrint('');
  }

  void _debugTimeline() {
    debugPrint('');
    debugPrint(
      '──────── GENERATED TIMELINE ────────',
    );

    for (
    int index = 0;
    index < timelineItems.length;
    index++
    ) {
      final ApplicationTimelineItem item =
      timelineItems[index];

      debugPrint(
        '${index + 1}. '
            '${item.title} | '
            'completed=${item.isCompleted} | '
            'current=${item.isCurrent} | '
            'schedule=${item.hasInterviewSchedule} | '
            'time=${item.timestamp} | '
            'mode=${item.interviewMode} | '
            'address=${item.interviewAddress}',
      );
    }

    debugPrint(
      '────────────────────────────────────',
    );
    debugPrint('');
  }

  void _printCompleteJson({
    required String title,
    required dynamic data,
  }) {
    debugPrint('');
    debugPrint(
      '╔══════════════════════════════════════',
    );
    debugPrint('║ $title');
    debugPrint(
      '╠══════════════════════════════════════',
    );

    try {
      final String jsonText =
      const JsonEncoder.withIndent('  ')
          .convert(data);

      const int chunkSize = 700;

      for (
      int start = 0;
      start < jsonText.length;
      start += chunkSize
      ) {
        final int end =
        start + chunkSize < jsonText.length
            ? start + chunkSize
            : jsonText.length;

        debugPrint(
          jsonText.substring(start, end),
          wrapWidth: 1024,
        );
      }
    } catch (exception) {
      final String rawText = data.toString();

      const int chunkSize = 700;

      for (
      int start = 0;
      start < rawText.length;
      start += chunkSize
      ) {
        final int end =
        start + chunkSize < rawText.length
            ? start + chunkSize
            : rawText.length;

        debugPrint(
          rawText.substring(start, end),
          wrapWidth: 1024,
        );
      }

      debugPrint(
        '🔴 JSON PRINT ERROR: $exception',
      );
    }

    debugPrint(
      '╚══════════════════════════════════════',
    );
    debugPrint('');
  }

  String _getDioMessage(
      dio.DioException exception,
      ) {
    final dynamic responseData =
        exception.response?.data;

    if (responseData is Map) {
      final String message =
          responseData['message']
              ?.toString()
              .trim() ??
              '';

      if (message.isNotEmpty) {
        return message;
      }
    }

    if (exception.response?.statusCode == 404) {
      return 'Application details were not found';
    }

    if (exception.response?.statusCode == 401) {
      return 'Your session has expired';
    }

    return 'Unable to load application details';
  }
}