import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';

class JobService {
  final Dio dio;

  JobService(this.dio);

  Options _authOptions(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Options _jsonAuthOptions(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<Response> getDashboardCount({
    required String token,
    required String candidateId,
  }) async {
    final path = ApiConstants.candidateDashboardCount(candidateId);
    debugPrint('🟡 DASHBOARD URL: $path');

    return await dio.get(path, options: _authOptions(token));
  }

  Future<Response> getJobs() async {
    debugPrint('🟡 JOBS URL: ${ApiConstants.jobs}');
    return await dio.get(ApiConstants.jobs);
  }

  Future<Response> getMatchedJobs({
    required String token,
    required String candidateId,
  }) async {
    final path = ApiConstants.matchedJobs(candidateId);

    debugPrint('🟡 MATCHED JOBS URL: $path');
    debugPrint(
      '🟡 MATCHED JOBS CANDIDATE ID: $candidateId',
    );

    return await dio.get(
      path,
      options: _authOptions(token),
    );
  }

  Future<Response> getShortJobs() async {
    debugPrint('🟡 SHORT JOBS URL: ${ApiConstants.shortJobs}');
    return await dio.get(ApiConstants.shortJobs);
  }

  Future<Response> getJobDetails({
    required String token,
    required String jobId,
  }) async {
    final path = ApiConstants.jobDetails(jobId);

    debugPrint('🟡 JOB DETAILS URL: $path');

    return await dio.get(
      path,
      options: token.isNotEmpty
          ? _authOptions(token)
          : null,
    );
  }


  Future<Response> getSavedJobs({
    required String token,
  }) async {
    return await dio.get(
      ApiConstants.savedJobs,
      options: _authOptions(token),
    );
  }

  Future<Response> toggleSavedJob({
    required String token,
    required String jobId,
  }) async {
    debugPrint('🟡 TOGGLE SAVE URL: ${ApiConstants.toggleSavedJob}');
    debugPrint('🟡 TOGGLE SAVE jobId: $jobId');

    return dio.post(
      ApiConstants.toggleSavedJob,
      data: {"jobId": jobId},
      options: _jsonAuthOptions(token),
    );
  }


  Future<Response> applyJob({
    required String token,
    required FormData formData,
  }) async {
    debugPrint(
      '🟡 APPLY JOB URL: ${ApiConstants.submitApplication}',
    );

    return await dio.post(
      ApiConstants.submitApplication,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        contentType: Headers.multipartFormDataContentType,
      ),
    );
  }

  // Future<Response> applyJob({
  //   required String token,
  //   required FormData formData,
  // }) async {
  //   return await dio.post(
  //     ApiConstants.submitApplication,
  //     data: formData,
  //     options: Options(
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'multipart/form-data',
  //       },
  //     ),
  //   );
  // }

  Future<Response> getCandidateApplications({
    required String token,
  }) async {
    debugPrint('🟡 APPLIED JOBS URL: ${ApiConstants.candidateApplications}');

    return await dio.get(
      ApiConstants.candidateApplications,
      options: _authOptions(token),
    );
  }


  void _printFullJson(
      String title,
      dynamic data,
      ) {
    try {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(data);

      debugPrint('════════════════════════════════════════');
      debugPrint(title);
      debugPrint('════════════════════════════════════════');

      const chunkSize = 800;

      for (int i = 0; i < prettyJson.length; i += chunkSize) {
        final end = (i + chunkSize < prettyJson.length)
            ? i + chunkSize
            : prettyJson.length;

        debugPrint(prettyJson.substring(i, end));
      }

      debugPrint('════════════════════════════════════════');
    } catch (e) {
      debugPrint('$title: $data');
      debugPrint('JSON PRINT ERROR: $e');
    }
  }

  Future<Response> getAssessmentDetails({
    required String token,
    required String jobId,
    required String applicationId,
    required String quizId,
  }) async {
    final path = ApiConstants.assessmentDetails(
      jobId,
      applicationId,
      quizId,
    );

    debugPrint('════════════════════════════════════════');
    debugPrint('🟡 GET ASSESSMENT REQUEST');
    debugPrint('🟡 URL: ${ApiConstants.baseUrl}$path');
    debugPrint('🟡 JOB ID: $jobId');
    debugPrint('🟡 APPLICATION ID: $applicationId');
    debugPrint('🟡 QUIZ ID: $quizId');
    debugPrint(
      '🟡 TOKEN: ${token.isNotEmpty ? "Available" : "Missing"}',
    );
    debugPrint('════════════════════════════════════════');

    try {
      final response = await dio.get(
        path,
        options: _authOptions(token),
      );

      debugPrint(
        '🟢 GET ASSESSMENT STATUS CODE: ${response.statusCode}',
      );

      _printFullJson(
        '🟢 FULL GET ASSESSMENT RESPONSE',
        response.data,
      );

      return response;
    } on DioException catch (e) {
      debugPrint('════════════════════════════════════════');
      debugPrint('🔴 GET ASSESSMENT API ERROR');
      debugPrint('🔴 STATUS CODE: ${e.response?.statusCode}');
      debugPrint('🔴 MESSAGE: ${e.message}');
      debugPrint('🔴 ERROR TYPE: ${e.type}');
      debugPrint('🔴 URL: ${e.requestOptions.uri}');
      debugPrint('════════════════════════════════════════');

      _printFullJson(
        '🔴 GET ASSESSMENT ERROR RESPONSE',
        e.response?.data,
      );

      rethrow;
    }
  }


  Future<Response> submitAssessment({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🟡 SUBMIT ASSESSMENT REQUEST');
    debugPrint(
      '🟡 URL: '
          '${ApiConstants.baseUrl}${ApiConstants.submitAssessment}',
    );
    debugPrint(
      '🟡 TOKEN: ${token.isNotEmpty ? "Available" : "Missing"}',
    );
    debugPrint('════════════════════════════════════════');

    _printFullJson(
      '🟡 FULL SUBMIT ASSESSMENT PAYLOAD',
      payload,
    );

    try {
      final response = await dio.post(
        ApiConstants.submitAssessment,
        data: payload,
        options: _jsonAuthOptions(token),
      );

      debugPrint(
        '🟢 SUBMIT ASSESSMENT STATUS CODE: '
            '${response.statusCode}',
      );

      _printFullJson(
        '🟢 FULL SUBMIT ASSESSMENT RESPONSE',
        response.data,
      );

      return response;
    } on DioException catch (e) {
      debugPrint('════════════════════════════════════════');
      debugPrint('🔴 SUBMIT ASSESSMENT API ERROR');
      debugPrint('🔴 STATUS CODE: ${e.response?.statusCode}');
      debugPrint('🔴 MESSAGE: ${e.message}');
      debugPrint('🔴 ERROR TYPE: ${e.type}');
      debugPrint('🔴 URL: ${e.requestOptions.uri}');
      debugPrint('════════════════════════════════════════');

      _printFullJson(
        '🔴 SUBMIT ASSESSMENT ERROR RESPONSE',
        e.response?.data,
      );

      rethrow;
    }
  }


  Future<Response> updateAssessmentScore({
    required String token,
    required String applicationId,
    required int technicalScore,
    required double overallRating,
    required String comment,
  }) async {
    final payload = {
      "applicationId": applicationId,
      "technicalScore": technicalScore,
      "overallRating": overallRating,
      "comment": comment,
    };

    debugPrint('════════════════════════════════════════');
    debugPrint('🟡 UPDATE SCORE REQUEST');
    debugPrint(
      '🟡 URL: '
          '${ApiConstants.baseUrl}'
          '${ApiConstants.updateAssessmentScore}',
    );
    debugPrint(
      '🟡 TOKEN: ${token.isNotEmpty ? "Available" : "Missing"}',
    );
    debugPrint('════════════════════════════════════════');

    _printFullJson(
      '🟡 FULL UPDATE SCORE PAYLOAD',
      payload,
    );

    try {
      final response = await dio.post(
        ApiConstants.updateAssessmentScore,
        data: payload,
        options: _jsonAuthOptions(token),
      );

      debugPrint(
        '🟢 UPDATE SCORE STATUS CODE: ${response.statusCode}',
      );

      _printFullJson(
        '🟢 FULL UPDATE SCORE RESPONSE',
        response.data,
      );

      return response;
    } on DioException catch (e) {
      debugPrint('════════════════════════════════════════');
      debugPrint('🔴 UPDATE SCORE API ERROR');
      debugPrint('🔴 STATUS CODE: ${e.response?.statusCode}');
      debugPrint('🔴 MESSAGE: ${e.message}');
      debugPrint('🔴 ERROR TYPE: ${e.type}');
      debugPrint('🔴 URL: ${e.requestOptions.uri}');
      debugPrint('════════════════════════════════════════');

      _printFullJson(
        '🔴 UPDATE SCORE ERROR RESPONSE',
        e.response?.data,
      );

      rethrow;
    }
  }


  Future<Response> getSingleApplication({
    required String token,
    required String applicationId,
  }) async {
    final path = ApiConstants.singleApplication(
      applicationId,
    );

    debugPrint('════════════════════════════════════════');
    debugPrint('🟡 SINGLE APPLICATION REQUEST');
    debugPrint('🟡 URL: ${ApiConstants.baseUrl}$path');
    debugPrint('🟡 APPLICATION ID: $applicationId');
    debugPrint(
      '🟡 TOKEN: ${token.isNotEmpty ? "Available" : "Missing"}',
    );
    debugPrint('════════════════════════════════════════');

    try {
      final response = await dio.get(
        path,
        options: _authOptions(token),
      );

      debugPrint(
        '🟢 SINGLE APPLICATION STATUS: '
            '${response.statusCode}',
      );

      _printFullJson(
        '🟢 SINGLE APPLICATION RESPONSE',
        response.data,
      );

      return response;
    } on DioException catch (e) {
      debugPrint('════════════════════════════════════════');
      debugPrint('🔴 SINGLE APPLICATION ERROR');
      debugPrint('🔴 STATUS CODE: ${e.response?.statusCode}');
      debugPrint('🔴 MESSAGE: ${e.message}');
      debugPrint('🔴 URL: ${e.requestOptions.uri}');
      debugPrint('════════════════════════════════════════');

      _printFullJson(
        '🔴 SINGLE APPLICATION ERROR RESPONSE',
        e.response?.data,
      );

      rethrow;
    }
  }

  Future<Response> respondToInterview({
    required String token,
    required String applicationId,
    required String status,
    String note = '',
  }) async {
    final payload = <String, dynamic>{
      'applicationId': applicationId,
      'status': status,
    };

    if (note.trim().isNotEmpty) {
      payload['note'] = note.trim();
    }

    debugPrint('════════════════════════════════════════');
    debugPrint('🟡 INTERVIEW RESPONSE REQUEST');
    debugPrint(
      '🟡 URL: '
          '${ApiConstants.baseUrl}${ApiConstants.confirmInterview}',
    );
    debugPrint('🟡 APPLICATION ID: $applicationId');
    debugPrint('🟡 STATUS: $status');
    debugPrint('🟡 NOTE: ${note.trim()}');
    debugPrint('════════════════════════════════════════');

    try {
      final response = await dio.put(
        ApiConstants.confirmInterview,
        data: payload,
        options: _jsonAuthOptions(token),
      );

      debugPrint(
        '🟢 INTERVIEW RESPONSE STATUS CODE: '
            '${response.statusCode}',
      );

      _printFullJson(
        '🟢 INTERVIEW RESPONSE DATA',
        response.data,
      );

      return response;
    } on DioException catch (e) {
      debugPrint('════════════════════════════════════════');
      debugPrint('🔴 INTERVIEW RESPONSE API ERROR');
      debugPrint('🔴 STATUS CODE: ${e.response?.statusCode}');
      debugPrint('🔴 MESSAGE: ${e.message}');
      debugPrint('🔴 URL: ${e.requestOptions.uri}');
      debugPrint('════════════════════════════════════════');

      _printFullJson(
        '🔴 INTERVIEW RESPONSE ERROR DATA',
        e.response?.data,
      );

      rethrow;
    }
  }


  Future<Response> uploadSignedOfferLetter({
    required String token,
    required String applicationId,
    required String filePath,
    required String fileName,
  }) async {
    final FormData formData = FormData.fromMap({
      'applicationId': applicationId,
      'documentType': 'Offer',
      'signedDoc': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    debugPrint('════════════════════════════════════════');
    debugPrint('🟡 SIGNED OFFER LETTER UPLOAD');
    debugPrint(
      '🟡 URL: '
          '${ApiConstants.baseUrl}'
          '${ApiConstants.uploadSignedOfferLetter}',
    );
    debugPrint('🟡 APPLICATION ID: $applicationId');
    debugPrint('🟡 DOCUMENT TYPE: Offer');
    debugPrint('🟡 FILE NAME: $fileName');
    debugPrint('════════════════════════════════════════');

    try {
      final Response response = await dio.post(
        ApiConstants.uploadSignedOfferLetter,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: Headers.multipartFormDataContentType,
        ),
        onSendProgress: (sent, total) {
          if (total <= 0) {
            return;
          }

          final int progress =
          ((sent / total) * 100).round();

          debugPrint(
            '🟡 SIGNED OFFER UPLOAD PROGRESS: $progress%',
          );
        },
      );

      debugPrint(
        '🟢 SIGNED OFFER STATUS: ${response.statusCode}',
      );

      _printFullJson(
        '🟢 SIGNED OFFER RESPONSE',
        response.data,
      );

      return response;
    } on DioException catch (e) {
      debugPrint('════════════════════════════════════════');
      debugPrint('🔴 SIGNED OFFER UPLOAD ERROR');
      debugPrint('🔴 STATUS: ${e.response?.statusCode}');
      debugPrint('🔴 MESSAGE: ${e.message}');
      debugPrint('🔴 URL: ${e.requestOptions.uri}');
      debugPrint('════════════════════════════════════════');

      _printFullJson(
        '🔴 SIGNED OFFER ERROR RESPONSE',
        e.response?.data,
      );

      rethrow;
    }
  }

  Future<Response> downloadApplicationDocument({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    debugPrint('🟡 DOCUMENT DOWNLOAD URL: $url');
    debugPrint('🟡 DOCUMENT SAVE PATH: $savePath');

    return dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}