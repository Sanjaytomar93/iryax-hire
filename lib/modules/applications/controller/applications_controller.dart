import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../home/model/job_model.dart';
import '../../home/services/job_service.dart';
import '../model/application_model.dart';

class ApplicationsController extends GetxController {
  final JobService service;

  ApplicationsController(this.service);

  final isLoading = false.obs;
  final isSavingJob = false.obs;

  final isUploadingSignedOffer = false.obs;
  final isDownloadingOffer = false.obs;

  final selectedTab = 0.obs;
  final selectedFilter = 'All'.obs;

  final applications = <ApplicationModel>[].obs;
  final savedJobs = <JobModel>[].obs;

  final offerSearchController = TextEditingController();

  final offerSearchQuery = ''.obs;
  final selectedOfferDate = Rxn<DateTime>();

  final selectedSignedFilePath = ''.obs;
  final selectedSignedFileName = ''.obs;

  List<ApplicationModel> get filteredApplications {
    if (selectedFilter.value == 'All') {
      return applications;
    }

    return applications.where((application) {
      final String status =
      application.status.toLowerCase();

      if (selectedFilter.value == 'Submitted') {
        return status.contains('pending') ||
            status.contains('submitted') ||
            status.contains('applied');
      }

      if (selectedFilter.value == 'Interview') {
        return application.isInterviewSelected;
      }

      if (selectedFilter.value == 'Accepted') {
        return status.contains('selected') ||
            status.contains('accepted') ||
            status.contains('offer') ||
            status.contains('hired');
      }

      if (selectedFilter.value == 'Rejected') {
        return status.contains('rejected');
      }

      return true;
    }).toList();
  }

  List<ApplicationModel> get filteredOfferLetters {
    final String query =
    offerSearchQuery.value.trim().toLowerCase();

    final DateTime? selectedDate =
        selectedOfferDate.value;

    final List<ApplicationModel> result =
    applications.where((application) {
      if (!application.hasOfferLetter) {
        return false;
      }

      final bool matchesSearch =
          query.isEmpty ||
              application.displayRole
                  .toLowerCase()
                  .contains(query) ||
              application.displayDocumentType
                  .toLowerCase()
                  .contains(query) ||
              application.docReviewStatus
                  .toLowerCase()
                  .contains(query);

      if (!matchesSearch) {
        return false;
      }

      if (selectedDate == null) {
        return true;
      }

      final DateTime? issueDate =
          application.offerIssueDate;

      if (issueDate == null) {
        return false;
      }

      return issueDate.year == selectedDate.year &&
          issueDate.month == selectedDate.month &&
          issueDate.day == selectedDate.day;
    }).toList();

    result.sort((first, second) {
      final DateTime firstDate =
          first.offerIssueDate ??
              DateTime.fromMillisecondsSinceEpoch(0);

      final DateTime secondDate =
          second.offerIssueDate ??
              DateTime.fromMillisecondsSinceEpoch(0);

      return secondDate.compareTo(firstDate);
    });

    return result;
  }

  @override
  void onInit() {
    super.onInit();

    _handleNavigationArguments();
    loadApplications();
  }

  void _printCompleteJson({
    required String title,
    required dynamic data,
  }) {
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════');
    debugPrint('║ $title');
    debugPrint('╠══════════════════════════════════════════════');

    try {
      final String formattedJson =
      const JsonEncoder.withIndent('  ').convert(data);

      const int chunkSize = 800;

      for (
      int start = 0;
      start < formattedJson.length;
      start += chunkSize
      ) {
        final int end =
        (start + chunkSize < formattedJson.length)
            ? start + chunkSize
            : formattedJson.length;

        debugPrint(
          formattedJson.substring(start, end),
          wrapWidth: 1024,
        );
      }
    } catch (error) {
      final String rawData = data.toString();

      const int chunkSize = 800;

      for (
      int start = 0;
      start < rawData.length;
      start += chunkSize
      ) {
        final int end =
        (start + chunkSize < rawData.length)
            ? start + chunkSize
            : rawData.length;

        debugPrint(
          rawData.substring(start, end),
          wrapWidth: 1024,
        );
      }

      debugPrint('🔴 JSON FORMAT ERROR: $error');
    }

    debugPrint('╚══════════════════════════════════════════════');
    debugPrint('');
  }

  void _handleNavigationArguments() {
    final dynamic arguments = Get.arguments;

    if (arguments is! Map) {
      return;
    }

    final dynamic tab = arguments['tab'];
    final dynamic filter = arguments['filter'];

    if (tab is int) {
      selectedTab.value = tab;
    }

    if (filter is String && filter.isNotEmpty) {
      selectedFilter.value = filter;
    }
  }

  Future<void> loadApplications() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;

      await Future.wait([
        getAppliedJobs(),
        getSavedJobs(),
      ]);
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 APPLICATION LOAD ERROR: $e',
      );
      debugPrint('$stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAppliedJobs() async {
    try {
      final String token = StorageService.getToken();

      debugPrint('');
      debugPrint('════════════════════════════════════════');
      debugPrint('🟡 GET APPLIED JOBS REQUEST');
      debugPrint('🟡 TOKEN AVAILABLE: ${token.isNotEmpty}');
      debugPrint('════════════════════════════════════════');

      if (token.isEmpty) {
        debugPrint(
          '🔴 APPLIED JOBS ERROR: Token missing',
        );
        return;
      }

      final dio.Response response =
      await service.getCandidateApplications(
        token: token,
      );

      debugPrint('');
      debugPrint('════════════════════════════════════════');
      debugPrint('🟢 APPLIED JOBS API SUCCESS');
      debugPrint(
        '🟢 STATUS CODE: ${response.statusCode}',
      );
      debugPrint(
        '🟢 STATUS MESSAGE: ${response.statusMessage}',
      );
      debugPrint(
        '🟢 REQUEST URL: ${response.requestOptions.uri}',
      );
      debugPrint(
        '🟢 REQUEST METHOD: '
            '${response.requestOptions.method}',
      );
      debugPrint(
        '🟢 RESPONSE TYPE: ${response.data.runtimeType}',
      );
      debugPrint('════════════════════════════════════════');

      _printCompleteJson(
        title: '🟢 COMPLETE APPLIED JOBS RESPONSE',
        data: response.data,
      );

      final dynamic data = response.data;

      List<dynamic> list = <dynamic>[];

      if (data is List) {
        debugPrint(
          '🟢 RESPONSE FORMAT: Direct List',
        );

        list = data;
      } else if (data is Map) {
        debugPrint(
          '🟢 RESPONSE ROOT KEYS: ${data.keys.toList()}',
        );

        if (data['applications'] is List) {
          debugPrint(
            '🟢 APPLICATION LIST PATH: applications',
          );

          list = data['applications'] as List;
        } else if (data['data'] is List) {
          debugPrint(
            '🟢 APPLICATION LIST PATH: data',
          );

          list = data['data'] as List;
        } else if (data['data'] is Map &&
            data['data']['applications'] is List) {
          debugPrint(
            '🟢 APPLICATION LIST PATH: '
                'data.applications',
          );

          list =
          data['data']['applications'] as List;
        } else {
          debugPrint(
            '🔴 APPLICATION LIST NOT FOUND '
                'IN RESPONSE',
          );
        }
      } else {
        debugPrint(
          '🔴 UNKNOWN RESPONSE FORMAT: '
              '${data.runtimeType}',
        );
      }

      debugPrint(
        '🟢 RAW APPLICATION LIST LENGTH: '
            '${list.length}',
      );

      for (int index = 0; index < list.length; index++) {
        _printCompleteJson(
          title: 'APPLICATION ITEM ${index + 1}',
          data: list[index],
        );
      }
      final List<ApplicationModel> parsedApplications =
      <ApplicationModel>[];

      for (int index = 0; index < list.length; index++) {
        final dynamic rawItem = list[index];

        if (rawItem is! Map) {
          debugPrint(
            '🔴 APPLICATION ITEM ${index + 1} IS NOT A MAP',
          );
          continue;
        }

        final Map<String, dynamic> rawJson =
        Map<String, dynamic>.from(rawItem);

        try {
          final ApplicationModel application =
          ApplicationModel.fromJson(rawJson);

          parsedApplications.add(application);

          final bool containsOfferData =
              (rawJson['offerLetter']
                  ?.toString()
                  .trim()
                  .isNotEmpty ??
                  false) ||
                  (rawJson['adminAttachment']
                      ?.toString()
                      .trim()
                      .isNotEmpty ??
                      false) ||
                  (rawJson['candidateAgreementsUpload']
                      ?.toString()
                      .trim()
                      .isNotEmpty ??
                      false) ||
                  application.hasOfferLetter;

          if (containsOfferData) {
            _debugOfferLetterApplication(
              index: index,
              rawJson: rawJson,
              application: application,
            );
          }
        } catch (error, stackTrace) {
          debugPrint(
            '🔴 APPLICATION PARSE ERROR AT INDEX $index: $error',
          );

          debugPrint('$stackTrace');

          _printCompleteJson(
            title: '🔴 FAILED APPLICATION JSON',
            data: rawJson,
          );
        }
      }

      applications.assignAll(parsedApplications);

      final List<ApplicationModel> offerApplications =
      applications.where((application) {
        return application.hasOfferLetter;
      }).toList();

      debugPrint('');
      debugPrint(
        '╔════════ OFFER LETTER SUMMARY ════════',
      );

      debugPrint(
        '║ TOTAL APPLICATIONS: ${applications.length}',
      );

      debugPrint(
        '║ TOTAL OFFER LETTERS: ${offerApplications.length}',
      );

      for (int index = 0;
      index < offerApplications.length;
      index++) {
        final ApplicationModel application =
        offerApplications[index];

        debugPrint(
          '║ ${index + 1}. '
              'ID=${application.id} | '
              'ROLE=${application.displayRole} | '
              'TYPE=${application.displayDocumentType} | '
              'ATTACHMENT=${application.offerAttachmentPath} | '
              'SIGNED=${application.signedOfferPath}',
        );
      }

      debugPrint(
        '╚═══════════════════════════════════════',
      );
      debugPrint('');

      debugPrint('');
      debugPrint('════════════════════════════════════════');
      debugPrint(
        '🟢 TOTAL PARSED APPLICATIONS: '
            '${applications.length}',
      );
      debugPrint(
        '🟢 TOTAL INTERVIEW APPLICATIONS: '
            '${applications
            .where((item) => item.isInterviewSelected)
            .length}',
      );
      debugPrint(
        '🟢 TOTAL APPLICATIONS WITH SCHEDULE: '
            '${applications
            .where((item) => item.interview.hasSchedule)
            .length}',
      );
      debugPrint(
        '🟢 TOTAL OFFER LETTERS: '
            '${applications
            .where((item) => item.hasOfferLetter)
            .length}',
      );
      debugPrint('════════════════════════════════════════');

      for (
      int index = 0;
      index < applications.length;
      index++
      ) {
        final ApplicationModel application =
        applications[index];

        debugPrint('');
        debugPrint(
          '──────── APPLICATION ${index + 1} ────────',
        );
        debugPrint(
          'ID: ${application.id}',
        );
        debugPrint(
          'STATUS FROM API: ${application.status}',
        );
        debugPrint(
          'DISPLAY STATUS: ${application.displayStatus}',
        );
        debugPrint(
          'JOB ROLE: ${application.job.role}',
        );
        debugPrint(
          'COMPANY: ${application.job.companyName}',
        );
        debugPrint(
          'INTERVIEW SELECTED: '
              '${application.isInterviewSelected}',
        );
        debugPrint(
          'HAS INTERVIEW SCHEDULE: '
              '${application.interview.hasSchedule}',
        );
        debugPrint(
          'INTERVIEW ROUND: '
              '${application.interview.round}',
        );
        debugPrint(
          'INTERVIEW MODE: '
              '${application.interview.mode}',
        );
        debugPrint(
          'INTERVIEW DATE/TIME: '
              '${application.interview.scheduledAt}',
        );
        debugPrint(
          'INTERVIEW ADDRESS: '
              '${application.interview.address}',
        );
        debugPrint(
          'INTERVIEW LINK: '
              '${application.interview.link}',
        );
        debugPrint(
          'INTERVIEW RESPONSE STATUS: '
              '${application.interview.responseStatus}',
        );
        debugPrint(
          '────────────────────────────────────────',
        );
      }
    } catch (error, stackTrace) {
      _printDioError(
        title: 'APPLIED JOBS',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> getSavedJobs() async {
    try {
      final String token = StorageService.getToken();

      if (token.isEmpty) {
        debugPrint(
          '🔴 SAVED JOBS ERROR: Token missing',
        );
        return;
      }

      final dio.Response response =
      await service.getSavedJobs(
        token: token,
      );

      debugPrint(
        '🟢 SAVED JOBS RESPONSE: ${response.data}',
      );

      final dynamic data = response.data;

      List<dynamic> list = [];

      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data['savedJobs'] is List) {
          list = data['savedJobs'];
        } else if (data['data'] is List) {
          list = data['data'];
        } else if (data['data'] is Map &&
            data['data']['savedJobs'] is List) {
          list = data['data']['savedJobs'];
        }
      }

      savedJobs.assignAll(
        list
            .whereType<Map>()
            .map(
              (item) =>
              JobModel.fromJson(
                Map<String, dynamic>.from(item),
              ).copyWith(
                isSaved: true,
              ),
        )
            .toList(),
      );

      debugPrint(
        '🟢 TOTAL SAVED JOBS: ${savedJobs.length}',
      );
    } catch (e, stackTrace) {
      _printDioError(
        title: 'SAVED JOBS',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void updateOfferSearch(String value) {
    offerSearchQuery.value = value.trim();
  }

  Future<void> selectOfferLetterDate(BuildContext context,) async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate =
    await showDatePicker(
      context: context,
      initialDate: selectedOfferDate.value ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select Issue Date',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF174F84),
              onPrimary: Colors.white,
              surface: Color(0xFF1D2232),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) {
      return;
    }

    selectedOfferDate.value = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
  }

  void clearOfferDate() {
    selectedOfferDate.value = null;
  }

  String get selectedOfferDateText {
    final DateTime? date = selectedOfferDate.value;

    if (date == null) {
      return 'Select Date';
    }

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final String day =
    date.day.toString().padLeft(2, '0');

    return '${months[date.month - 1]} $day';
  }

  Future<void> showOfferPreview(ApplicationModel application,) async {
    if (isDownloadingOffer.value) {
      return;
    }

    final String filePath =
    application.offerAttachmentPath.trim();

    debugPrint('');
    debugPrint('════════ OFFER PREVIEW ════════');
    debugPrint('APPLICATION ID: ${application.id}');
    debugPrint('OFFER FILE PATH: $filePath');
    debugPrint(
      'OFFER TEXT LENGTH: ${application.offerContent.length}',
    );
    debugPrint('═══════════════════════════════');

    if (filePath.isNotEmpty) {
      await previewOfferDocument(
        application: application,
        remotePath: filePath,
      );

      return;
    }

    if (application.offerContent.isNotEmpty) {
      showOfferTextPreview(application);
      return;
    }

    _showError(
      'Offer letter file is not available',
    );
  }


  void _showPreparingPreviewDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFF1C2232),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 26,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    'Preparing offer letter preview...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showOfferTextPreview(ApplicationModel application,) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1C2232),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 30,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.84,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  8,
                  12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Offer Letter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                color: Color(0xFF3A4253),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    application.offerContent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> previewOfferDocument({
    required ApplicationModel application,
    required String remotePath,
  }) async {
    if (isDownloadingOffer.value) {
      return;
    }

    String localPath = '';

    try {
      isDownloadingOffer.value = true;

      final String downloadUrl =
      _buildDocumentUrl(remotePath);

      final Directory directory =
      await getTemporaryDirectory();

      final String extension =
      _getFileExtension(remotePath);

      final String fileName = _extractFileName(
        remotePath,
        'offer_letter_${application.id}'
            '${extension.isEmpty ? '.pdf' : '.$extension'}',
      );

      localPath = '${directory.path}/$fileName';

      debugPrint('');
      debugPrint(
        '════════ OFFER PREVIEW DOWNLOAD ════════',
      );
      debugPrint('URL: $downloadUrl');
      debugPrint('LOCAL PATH: $localPath');
      debugPrint('EXTENSION: $extension');
      debugPrint(
        '═══════════════════════════════════════',
      );

      _showPreparingPreviewDialog();

      await service.downloadApplicationDocument(
        url: downloadUrl,
        savePath: localPath,
        onReceiveProgress: (received, total) {
          if (total <= 0) {
            return;
          }

          final int progress =
          ((received / total) * 100).round();

          debugPrint(
            '🟡 OFFER PREVIEW DOWNLOAD: $progress%',
          );
        },
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      final File downloadedFile = File(localPath);

      if (!await downloadedFile.exists()) {
        throw Exception(
          'Downloaded offer letter does not exist',
        );
      }

      if (await downloadedFile.length() == 0) {
        throw Exception(
          'Downloaded offer letter is empty',
        );
      }

      if (extension == 'pdf') {
        await _showPdfPreviewDialog(
          application: application,
          localPath: localPath,
        );

        return;
      }

      final OpenResult result =
      await OpenFilex.open(localPath);

      if (result.type != ResultType.done) {
        _showError(
          'No application is available to open this document',
        );
      }
    } catch (error, stackTrace) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      debugPrint(
        '🔴 OFFER PDF PREVIEW ERROR: $error',
      );
      debugPrint('$stackTrace');

      if (localPath.isNotEmpty) {
        final File localFile = File(localPath);

        if (await localFile.exists() &&
            await localFile.length() > 0) {
          final OpenResult result =
          await OpenFilex.open(localPath);

          if (result.type != ResultType.done) {
            _showError(
              'Unable to preview or open the PDF',
            );
          }

          return;
        }
      }

      _showError(
        'Unable to preview the offer letter',
      );
    } finally {
      isDownloadingOffer.value = false;
    }
  }


  // Future<String> _downloadOfferToTemporaryDirectory({
  //   required ApplicationModel application,
  //   required String remotePath,
  // }) async {
  //   final String downloadUrl =
  //   _buildDocumentUrl(remotePath);
  //
  //   final Directory directory =
  //   await getTemporaryDirectory();
  //
  //   final String extension =
  //   _getFileExtension(remotePath);
  //
  //   final String fileName = _extractFileName(
  //     remotePath,
  //     'offer_letter_${application.id}'
  //         '${extension.isEmpty ? '.pdf' : '.$extension'}',
  //   );
  //
  //   final String localPath =
  //       '${directory.path}/$fileName';
  //
  //   final File localFile = File(localPath);
  //
  //   if (await localFile.exists() &&
  //       await localFile.length() > 0) {
  //     return localPath;
  //   }
  //
  //   debugPrint('');
  //   debugPrint(
  //     '════════ OFFER PREVIEW DOWNLOAD ════════',
  //   );
  //   debugPrint('URL: $downloadUrl');
  //   debugPrint('LOCAL PATH: $localPath');
  //   debugPrint('EXTENSION: $extension');
  //   debugPrint(
  //     '════════════════════════════════════════',
  //   );
  //
  //   await service.downloadApplicationDocument(
  //     url: downloadUrl,
  //     savePath: localPath,
  //     onReceiveProgress: (received, total) {
  //       if (total <= 0) {
  //         return;
  //       }
  //
  //       final int progress =
  //       ((received / total) * 100).round();
  //
  //       debugPrint(
  //         '🟡 OFFER PREVIEW DOWNLOAD: $progress%',
  //       );
  //     },
  //   );
  //
  //   if (!await localFile.exists() ||
  //       await localFile.length() == 0) {
  //     throw Exception(
  //       'Downloaded offer letter is empty',
  //     );
  //   }
  //
  //   return localPath;
  // }


  Future<void> _showPdfPreviewDialog({
    required ApplicationModel application,
    required String localPath,
  }) async {
    await Get.dialog<void>(
      Dialog(
        backgroundColor: const Color(0xFF151923),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: Get.width,
          height: Get.height * 0.88,
          child: Column(
            children: [
              Container(
                height: 56,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 4,
                ),
                color: const Color(0xFF1D2232),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${application.displayRole} Offer Letter',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Download',
                      onPressed: () {
                        downloadOfferLetter(application);
                      },
                      icon: const Icon(
                        Icons.download_outlined,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: Get.back,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                color: Color(0xFF353D50),
              ),

              Expanded(
                child: Container(
                  color: const Color(0xFF303030),
                  child: SfPdfViewer.file(
                    File(localPath),
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                    canShowPaginationDialog: true,
                    enableDoubleTapZooming: true,
                    enableTextSelection: true,
                    onDocumentLoadFailed: (
                        PdfDocumentLoadFailedDetails details,
                        ) {
                      debugPrint(
                        '🔴 PDF LOAD ERROR: ${details.error}',
                      );
                      debugPrint(
                        '🔴 PDF LOAD DESCRIPTION: '
                            '${details.description}',
                      );

                      _showError(
                        'Unable to display the PDF',
                      );
                    },
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  14,
                ),
                color: const Color(0xFF1D2232),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();

                    showSignedOfferUploadDialog(
                      application,
                    );
                  },
                  icon: const Icon(
                    Icons.upload_file_outlined,
                    size: 20,
                  ),
                  label: Text(
                    application.hasSignedOffer
                        ? 'Resubmit Signed Offer Letter'
                        : 'Upload Signed Offer Letter',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF164F84),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  String _getFileExtension(String path) {
    final String cleanPath =
    path
        .split('?')
        .first
        .trim()
        .toLowerCase();

    final int dotIndex = cleanPath.lastIndexOf('.');

    if (dotIndex == -1 ||
        dotIndex == cleanPath.length - 1) {
      return '';
    }

    return cleanPath.substring(dotIndex + 1);
  }

  void showSignedOfferUploadDialog(ApplicationModel application,) {
    clearSelectedSignedFile();

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1C2232),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 22,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
                () =>
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            application.hasSignedOffer
                                ? 'Resubmit Offer Letter'
                                : 'Upload Signed Offer Letter',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                          isUploadingSignedOffer.value
                              ? null
                              : Get.back,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the signed offer letter in PDF, DOC, '
                          'or DOCX format.',
                      style: TextStyle(
                        color: Color(0xFFAEB5C3),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap:
                      isUploadingSignedOffer.value
                          ? null
                          : pickSignedOfferFile,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF272E3F),
                          borderRadius:
                          BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF4A5264),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 36,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              selectedSignedFileName
                                  .value
                                  .isEmpty
                                  ? 'Choose signed document'
                                  : selectedSignedFileName.value,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                selectedSignedFileName
                                    .value
                                    .isEmpty
                                    ? const Color(
                                  0xFFADB4C2,
                                )
                                    : Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'PDF, DOC or DOCX • Maximum 10 MB',
                              style: TextStyle(
                                color: Color(0xFF7F8798),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                        isUploadingSignedOffer.value ||
                            selectedSignedFilePath
                                .value
                                .isEmpty
                            ? null
                            : () {
                          submitSignedOfferLetter(
                            application,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF174F84),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          const Color(0xFF333A49),
                          disabledForegroundColor:
                          const Color(0xFF7B8290),
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        child:
                        isUploadingSignedOffer.value
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          application.hasSignedOffer
                              ? 'Resubmit Signed Offer Letter'
                              : 'Submit Signed Offer Letter',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> pickSignedOfferFile() async {
    try {
      final FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
        ],
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile selectedFile =
          result.files.single;

      final String? path = selectedFile.path;

      if (path == null || path.isEmpty) {
        _showError(
          'The selected file path is unavailable',
        );
        return;
      }

      final File file = File(path);

      if (!await file.exists()) {
        _showError('The selected file does not exist');
        return;
      }

      const int maximumSize = 10 * 1024 * 1024;

      if (selectedFile.size > maximumSize) {
        _showError(
          'The selected file must be below 10 MB',
        );
        return;
      }

      selectedSignedFilePath.value = path;
      selectedSignedFileName.value =
          selectedFile.name;
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 SIGNED OFFER FILE PICK ERROR: $e',
      );
      debugPrint('$stackTrace');

      _showError(
        'Unable to select the signed document',
      );
    }
  }

  void clearSelectedSignedFile() {
    selectedSignedFilePath.value = '';
    selectedSignedFileName.value = '';
  }

  Future<void> submitSignedOfferLetter(ApplicationModel application,) async {
    if (isUploadingSignedOffer.value) {
      return;
    }

    if (application.id
        .trim()
        .isEmpty) {
      _showError('Application ID is missing');
      return;
    }

    if (selectedSignedFilePath.value.isEmpty) {
      _showError(
        'Please select the signed offer letter',
      );
      return;
    }

    final String token = StorageService.getToken();

    if (token.isEmpty) {
      _showError(
        'Session expired. Please login again.',
      );
      return;
    }

    try {
      isUploadingSignedOffer.value = true;

      final dio.Response response =
      await service.uploadSignedOfferLetter(
        token: token,
        applicationId: application.id,
        filePath: selectedSignedFilePath.value,
        fileName: selectedSignedFileName.value,
      );

      final dynamic responseData = response.data;

      final bool success =
          response.statusCode == 200 ||
              response.statusCode == 201 ||
              (responseData is Map &&
                  responseData['success'] == true);

      if (!success) {
        throw Exception(
          responseData is Map
              ? responseData['message']?.toString() ??
              'Unable to submit signed offer letter'
              : 'Unable to submit signed offer letter',
        );
      }

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      clearSelectedSignedFile();

      await getAppliedJobs();

      final String message =
      responseData is Map
          ? responseData['message']?.toString() ??
          'Signed offer letter submitted successfully'
          : 'Signed offer letter submitted successfully';

      _showSuccess(message);
    } catch (e, stackTrace) {
      _printDioError(
        title: 'SIGNED OFFER UPLOAD',
        error: e,
        stackTrace: stackTrace,
      );

      String message =
          'Unable to submit signed offer letter';

      if (e is dio.DioException) {
        final dynamic responseData = e.response?.data;

        if (responseData is Map) {
          message =
              responseData['message']?.toString() ??
                  responseData['error']?.toString() ??
                  message;
        }
      }

      _showError(message);
    } finally {
      isUploadingSignedOffer.value = false;
    }
  }

  Future<void> downloadOfferLetter(ApplicationModel application,) async {
    final String attachmentPath =
        application.offerAttachmentPath;

    if (attachmentPath.isNotEmpty) {
      await downloadRemoteDocument(
        remotePath: attachmentPath,
        fallbackName:
        'offer_letter_${application.id}.pdf',
      );

      return;
    }

    if (application.offerContent.isNotEmpty) {
      await saveOfferTextDocument(application);
      return;
    }

    _showError(
      'Offer-letter attachment is not available',
    );
  }

  Future<void> saveOfferTextDocument(ApplicationModel application,) async {
    try {
      isDownloadingOffer.value = true;

      final Directory directory =
      await getApplicationDocumentsDirectory();

      final String filePath =
          '${directory.path}/'
          'offer_letter_${application.id}.txt';

      final File file = File(filePath);

      await file.writeAsString(
        application.offerContent,
        flush: true,
      );

      _showSuccess(
        'Offer letter downloaded successfully',
      );

      await OpenFilex.open(filePath);
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 OFFER TEXT SAVE ERROR: $e',
      );
      debugPrint('$stackTrace');

      _showError(
        'Unable to save the offer letter',
      );
    } finally {
      isDownloadingOffer.value = false;
    }
  }

  Future<void> downloadRemoteDocument({
    required String remotePath,
    required String fallbackName,
  }) async {
    if (isDownloadingOffer.value) {
      return;
    }

    try {
      isDownloadingOffer.value = true;

      final String downloadUrl =
      _buildDocumentUrl(remotePath);

      final Directory directory =
      await getApplicationDocumentsDirectory();

      final String fileName =
      _extractFileName(
        remotePath,
        fallbackName,
      );

      final String savePath =
          '${directory.path}/$fileName';

      await service.downloadApplicationDocument(
        url: downloadUrl,
        savePath: savePath,
        onReceiveProgress: (received, total) {
          if (total <= 0) {
            return;
          }

          final int progress =
          ((received / total) * 100).round();

          debugPrint(
            '🟡 OFFER DOWNLOAD PROGRESS: $progress%',
          );
        },
      );

      _showSuccess(
        'Document downloaded successfully',
      );

      await OpenFilex.open(savePath);
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 OFFER DOCUMENT DOWNLOAD ERROR: $e',
      );
      debugPrint('$stackTrace');

      _showError(
        'Unable to download the document',
      );
    } finally {
      isDownloadingOffer.value = false;
    }
  }

  String _buildDocumentUrl(String path) {
    final String cleanPath = path.trim();

    if (cleanPath.startsWith('http://') ||
        cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    if (cleanPath.startsWith('/')) {
      return '${ApiConstants.baseUrl}$cleanPath';
    }

    return '${ApiConstants.baseUrl}/$cleanPath';
  }

  String _extractFileName(String path,
      String fallbackName,) {
    final String cleanPath =
    path
        .split('?')
        .first
        .trim();

    final String fileName =
    cleanPath
        .split('/')
        .last
        .trim();

    if (fileName.isEmpty || !fileName.contains('.')) {
      return fallbackName;
    }

    return fileName;
  }

  Future<void> toggleSavedJob(JobModel job,) async {
    if (isSavingJob.value) {
      return;
    }

    if (job.id.isEmpty) {
      debugPrint(
        '🔴 APP TOGGLE SAVE ERROR: Job ID missing',
      );
      return;
    }

    final String token = StorageService.getToken();

    if (token.isEmpty) {
      debugPrint(
        '🔴 APP TOGGLE SAVE ERROR: Token missing',
      );
      return;
    }

    final int existingIndex =
    savedJobs.indexWhere(
          (element) => element.id == job.id,
    );

    final bool wasSaved =
        existingIndex != -1 || job.isSaved;

    try {
      isSavingJob.value = true;

      final dio.Response response =
      await service.toggleSavedJob(
        token: token,
        jobId: job.id,
      );

      debugPrint(
        '🟢 APP TOGGLE SAVE RESPONSE: ${response.data}',
      );

      final dynamic responseData = response.data;

      final bool isSaved =
      responseData is Map &&
          responseData['isSaved'] is bool
          ? responseData['isSaved'] == true
          : !wasSaved;

      if (isSaved) {
        final JobModel updatedJob =
        job.copyWith(isSaved: true);

        if (existingIndex == -1) {
          savedJobs.insert(0, updatedJob);
        } else {
          savedJobs[existingIndex] = updatedJob;
        }
      } else {
        savedJobs.removeWhere(
              (element) => element.id == job.id,
        );
      }

      savedJobs.refresh();

      debugPrint(
        isSaved
            ? '🟢 JOB SAVED SUCCESSFULLY'
            : '🟢 JOB REMOVED SUCCESSFULLY',
      );
    } catch (e, stackTrace) {
      _printDioError(
        title: 'APP TOGGLE SAVE',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      isSavingJob.value = false;
    }
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2E7046),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF8F2D32),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }


  void _debugOfferLetterApplication({
    required int index,
    required Map<String, dynamic> rawJson,
    required ApplicationModel application,
  }) {
    final dynamic rawHistory = rawJson['documentHistory'];

    debugPrint('');
    debugPrint(
      '╔════════ OFFER LETTER DEBUG ${index + 1} ════════',
    );

    debugPrint(
      '║ APPLICATION ID: ${application.id}',
    );

    debugPrint(
      '║ JOB ROLE: ${application.job.role}',
    );

    debugPrint(
      '║ APPLICATION STATUS: ${application.status}',
    );

    debugPrint(
      '║ HAS OFFER LETTER: ${application.hasOfferLetter}',
    );

    debugPrint(
      '║ RAW offerLetter EXISTS: '
          '${(rawJson['offerLetter']?.toString().trim() ?? '').isNotEmpty}',
    );

    debugPrint(
      '║ RAW offerLetter LENGTH: '
          '${rawJson['offerLetter']
          ?.toString()
          .length ?? 0}',
    );

    debugPrint(
      '║ RAW documentType: ${rawJson['documentType']}',
    );

    debugPrint(
      '║ RAW offerSentAt: ${rawJson['offerSentAt']}',
    );

    debugPrint(
      '║ RAW adminAttachment: ${rawJson['adminAttachment']}',
    );

    debugPrint(
      '║ RAW candidateAgreementsUpload: '
          '${rawJson['candidateAgreementsUpload']}',
    );

    debugPrint(
      '║ RAW docReviewStatus: ${rawJson['docReviewStatus']}',
    );

    debugPrint(
      '║ PARSED OFFER ATTACHMENT PATH: '
          '${application.offerAttachmentPath}',
    );

    debugPrint(
      '║ PARSED SIGNED OFFER PATH: '
          '${application.signedOfferPath}',
    );

    debugPrint(
      '║ PARSED DOCUMENT TYPE: '
          '${application.displayDocumentType}',
    );

    debugPrint(
      '║ PARSED ISSUE DATE: '
          '${application.offerIssueDate}',
    );

    debugPrint(
      '║ DOCUMENT HISTORY TYPE: '
          '${rawHistory.runtimeType}',
    );

    if (rawHistory is List) {
      debugPrint(
        '║ DOCUMENT HISTORY COUNT: ${rawHistory.length}',
      );

      for (
      int historyIndex = 0;
      historyIndex < rawHistory.length;
      historyIndex++
      ) {
        final dynamic item = rawHistory[historyIndex];

        if (item is! Map) {
          debugPrint(
            '║ HISTORY ${historyIndex + 1}: Invalid format',
          );
          continue;
        }

        debugPrint(
          '║ ───── HISTORY ${historyIndex + 1} ─────',
        );

        debugPrint(
          '║ documentType: ${item['documentType']}',
        );

        debugPrint(
          '║ sentAt: ${item['sentAt']}',
        );

        debugPrint(
          '║ attachmentPath: ${item['attachmentPath']}',
        );

        debugPrint(
          '║ signedPath: ${item['signedPath']}',
        );

        debugPrint(
          '║ signedAt: ${item['signedAt']}',
        );

        debugPrint(
          '║ content exists: '
              '${(item['content']?.toString().trim() ?? '').isNotEmpty}',
        );

        debugPrint(
          '║ content length: '
              '${item['content']
              ?.toString()
              .length ?? 0}',
        );
      }
    }

    debugPrint(
      '╚════════════════════════════════════════',
    );
    debugPrint('');
  }


  void _printDioError({
    required String title,
    required Object error,
    required StackTrace stackTrace,
  }) {
    debugPrint(
      '🔴 $title ERROR: $error',
    );
    debugPrint('$stackTrace');

    if (error is dio.DioException) {
      debugPrint(
        '🔴 $title STATUS: ${error.response?.statusCode}',
      );
      _printCompleteJson(
        title: '🔴 COMPLETE $title ERROR RESPONSE',
        data: error.response?.data,
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
        '🔴 $title QUERY: '
            '${error.requestOptions.queryParameters}',
      );
      debugPrint(
        '🔴 $title RESPONSE HEADERS: '
            '${error.response?.headers.map}',
      );

      debugPrint(
        '🔴 $title REQUEST HEADERS: '
            '${error.requestOptions.headers}',
      );

      debugPrint(
        '🔴 $title ERROR TYPE: ${error.type}',
      );

      debugPrint(
        '🔴 $title ERROR MESSAGE: ${error.message}',
      );
    }
  }


  void debugOfferLetterFileUrl(ApplicationModel application,) {
    final String attachmentPath =
    application.offerAttachmentPath.trim();

    debugPrint('');
    debugPrint(
      '════════ OFFER FILE URL DEBUG ════════',
    );

    debugPrint(
      'APPLICATION ID: ${application.id}',
    );

    debugPrint(
      'RAW ATTACHMENT PATH: $attachmentPath',
    );

    if (attachmentPath.isEmpty) {
      debugPrint(
        '🔴 ORIGINAL OFFER FILE PATH IS EMPTY',
      );

      debugPrint(
        '🟡 API PROVIDED ONLY TEXT: '
            '${application.offerContent.isNotEmpty}',
      );

      debugPrint(
        '══════════════════════════════════════',
      );

      return;
    }

    final String completeUrl =
    _buildDocumentUrl(attachmentPath);

    debugPrint(
      '🟢 COMPLETE OFFER FILE URL: $completeUrl',
    );

    debugPrint(
      '🟢 FILE EXTENSION: '
          '${_getFileExtensionForDebug(attachmentPath)}',
    );

    debugPrint(
      '══════════════════════════════════════',
    );
  }


  String _getFileExtensionForDebug(String path) {
    final String cleanPath =
    path
        .split('?')
        .first
        .trim()
        .toLowerCase();

    final int dotIndex = cleanPath.lastIndexOf('.');

    if (dotIndex == -1 ||
        dotIndex == cleanPath.length - 1) {
      return 'UNKNOWN';
    }

    return cleanPath.substring(dotIndex + 1);
  }

  @override
  void onClose() {
    offerSearchController.dispose();
    super.onClose();
  }

}