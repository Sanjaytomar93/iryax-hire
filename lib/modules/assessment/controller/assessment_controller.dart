import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../home/services/job_service.dart';
import '../model/assessment_model.dart';

class AssessmentController extends GetxController {
  final JobService service;

  AssessmentController(this.service);

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final hasStarted = false.obs;

  final assessment = Rxn<AssessmentModel>();
  final currentIndex = 0.obs;
  final selectedAnswers = <String, String>{}.obs;

  String jobId = '';
  String applicationId = '';
  String quizId = '';

  final correctAnswerQuestions =
  <String, AssessmentQuestion>{};

  @override
  void onInit() {
    super.onInit();

    final args =
    Get.arguments as Map<String, dynamic>?;

    jobId =
        args?['jobId']?.toString() ?? '';

    applicationId =
        args?['applicationId']?.toString() ?? '';

    quizId =
        args?['quizId']?.toString() ?? '';

    final rawQuestions =
    args?['assessmentQuestions'];

    if (rawQuestions is List) {
      for (final item in rawQuestions) {
        if (item is! Map) {
          continue;
        }

        final question =
        AssessmentQuestion.fromJson(
          Map<String, dynamic>.from(item),
        );

        if (question.id.isNotEmpty) {
          correctAnswerQuestions[question.id] =
              question;
        }
      }
    }

    debugPrint('══════════════════════════════════════');
    debugPrint(
      '🟢 RECEIVED QUESTIONS WITH ANSWERS: '
          '${correctAnswerQuestions.length}',
    );

    for (final question
    in correctAnswerQuestions.values) {
      debugPrint(
        '🟢 ${question.id} | '
            '${question.correctAnswer} | '
            '${question.marks} marks',
      );
    }

    debugPrint('══════════════════════════════════════');

    getAssessmentDetails();
  }

  void startAssessment() {
    hasStarted.value = true;
  }

  Future<void> getAssessmentDetails() async {
    try {
      isLoading.value = true;

      debugPrint('════════════════════════════════════════');
      debugPrint('🟡 CONTROLLER GET ASSESSMENT STARTED');
      debugPrint('🟡 ROUTE JOB ID: $jobId');
      debugPrint('🟡 ROUTE APPLICATION ID: $applicationId');
      debugPrint('🟡 ROUTE QUIZ ID: $quizId');
      debugPrint('════════════════════════════════════════');

      final response = await service.getAssessmentDetails(
        token: StorageService.getToken(),
        jobId: jobId,
        applicationId: applicationId,
        quizId: quizId,
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw Exception(
          'Invalid Get Assessment response format',
        );
      }

      if (responseData['success'] != true) {
        throw Exception(
          responseData['message']?.toString() ??
              'Unable to load assessment',
        );
      }

      final model = AssessmentModel.fromJson(
        Map<String, dynamic>.from(responseData),
      );

      assessment.value = model;

      if (applicationId.isEmpty) {
        applicationId = model.applicationId;
      }

      if (jobId.isEmpty) {
        jobId = model.jobId;
      }

      if (quizId.isEmpty) {
        quizId = model.quizId;
      }

      debugPrint('════════════════════════════════════════');
      debugPrint('🟢 PARSED ASSESSMENT DETAILS');
      debugPrint('🟢 APPLICATION ID: ${model.applicationId}');
      debugPrint('🟢 JOB ID: ${model.jobId}');
      debugPrint('🟢 QUIZ ID: ${model.quizId}');
      debugPrint('🟢 TITLE: ${model.title}');
      debugPrint('🟢 DESCRIPTION: ${model.description}');
      debugPrint('🟢 DURATION: ${model.duration}');
      debugPrint(
        '🟢 API TOTAL QUESTIONS: ${model.totalQuestions}',
      );
      debugPrint(
        '🟢 PARSED QUESTIONS: ${model.questions.length}',
      );
      debugPrint('🟢 INSTRUCTIONS: ${model.instructions}');
      debugPrint('════════════════════════════════════════');

      int totalAvailableMarks = 0;

      for (int index = 0;
      index < model.questions.length;
      index++) {
        final question = model.questions[index];

        totalAvailableMarks += question.marks;

        debugPrint('────────────────────────────────────────');
        debugPrint('🟡 QUESTION ${index + 1}');
        debugPrint('🟡 QUESTION ID: ${question.id}');
        debugPrint(
          '🟡 QUESTION TEXT: ${question.questionText}',
        );
        debugPrint(
          '🟡 QUESTION TYPE: ${question.questionType}',
        );
        debugPrint('🟡 MARKS: ${question.marks}');
        debugPrint('🟡 OPTIONS COUNT: ${question.options.length}');

        for (int optionIndex = 0;
        optionIndex < question.options.length;
        optionIndex++) {
          debugPrint(
            '   OPTION ${optionIndex + 1}: '
                '"${question.options[optionIndex]}"',
          );
        }

        debugPrint('────────────────────────────────────────');
      }

      debugPrint('════════════════════════════════════════');
      debugPrint(
        '🟢 TOTAL AVAILABLE ASSESSMENT MARKS: '
            '$totalAvailableMarks',
      );
      debugPrint(
        '🟢 TARGET SCORE TOTAL: 100',
      );
      debugPrint('════════════════════════════════════════');
    } on DioException catch (e) {
      debugPrint('════════════════════════════════════════');
      debugPrint('🔴 GET ASSESSMENT DIO ERROR');
      debugPrint('🔴 STATUS CODE: ${e.response?.statusCode}');
      debugPrint('🔴 RESPONSE: ${e.response?.data}');
      debugPrint('🔴 MESSAGE: ${e.message}');
      debugPrint('════════════════════════════════════════');

      Get.snackbar(
        'Error',
        _extractErrorMessage(
          e.response?.data,
          fallback: 'Unable to load assessment',
        ),
      );
    } catch (e) {
      debugPrint('════════════════════════════════════════');
      debugPrint('🔴 GET ASSESSMENT PARSING ERROR');
      debugPrint('🔴 ERROR: $e');
      debugPrint('════════════════════════════════════════');

      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }


  void selectAnswer(
      String questionId,
      String option,
      ) {
    selectedAnswers[questionId] = option;

    debugPrint('════════════════════════════════════════');
    debugPrint('🟡 ANSWER SELECTED');
    debugPrint('🟡 QUESTION ID: $questionId');
    debugPrint('🟡 SELECTED OPTION: "$option"');
    debugPrint(
      '🟡 ANSWERED QUESTIONS: '
          '${selectedAnswers.length}/'
          '${assessment.value?.questions.length ?? 0}',
    );
    debugPrint('════════════════════════════════════════');
  }


  void nextQuestion() {
    final data = assessment.value;

    if (data == null || data.questions.isEmpty) {
      return;
    }

    final question = data.questions[currentIndex.value];

    if (selectedAnswers[question.id] == null) {
      Get.snackbar(
        'Error',
        'Please select an answer',
      );
      return;
    }

    if (currentIndex.value < data.questions.length - 1) {
      currentIndex.value++;
    } else {
      submitAssessment();
    }
  }

  Future<void> submitAssessment() async {
    if (isSubmitting.value) {
      return;
    }

    try {
      isSubmitting.value = true;

      final data = assessment.value;

      if (data == null || data.questions.isEmpty) {
        Get.snackbar(
          'Error',
          'Assessment details are unavailable',
        );
        return;
      }

      final effectiveApplicationId =
      applicationId.isNotEmpty
          ? applicationId
          : data.applicationId;

      final effectiveQuizId =
      quizId.isNotEmpty ? quizId : data.quizId;

      if (effectiveApplicationId.isEmpty) {
        Get.snackbar(
          'Error',
          'Application ID is missing',
        );
        return;
      }

      if (effectiveQuizId.isEmpty) {
        Get.snackbar(
          'Error',
          'Quiz ID is missing',
        );
        return;
      }

      if (selectedAnswers.length <
          data.questions.length) {
        Get.snackbar(
          'Error',
          'Please answer all questions',
        );
        return;
      }

      if (correctAnswerQuestions.isEmpty) {
        Get.snackbar(
          'Error',
          'Correct answers are unavailable',
        );

        debugPrint(
          '🔴 No questions with correct answers '
              'were passed from Apply Job response.',
        );

        return;
      }

      int totalAvailableMarks = 0;
      int obtainedMarks = 0;
      int correctAnswersCount = 0;

      final answers = data.questions.map((question) {
        final selectedAnswer =
            selectedAnswers[question.id] ?? '';

        final sourceQuestion =
        correctAnswerQuestions[question.id];

        final correctAnswer =
            sourceQuestion?.correctAnswer ?? '';

        final questionMarks =
            sourceQuestion?.marks ?? question.marks;

        final isCorrect =
            correctAnswer.isNotEmpty &&
                _normalizeAnswer(selectedAnswer) ==
                    _normalizeAnswer(correctAnswer);

        final marksObtained =
        isCorrect ? questionMarks : 0;

        totalAvailableMarks += questionMarks;
        obtainedMarks += marksObtained;

        if (isCorrect) {
          correctAnswersCount++;
        }

        debugPrint(
          '────────────────────────────────────────',
        );
        debugPrint(
          '🟡 QUESTION: ${question.questionText}',
        );
        debugPrint(
          '🟡 SELECTED: "$selectedAnswer"',
        );
        debugPrint(
          '🟡 CORRECT: "$correctAnswer"',
        );
        debugPrint(
          '🟡 IS CORRECT: $isCorrect',
        );
        debugPrint(
          '🟡 MARKS: '
              '$marksObtained/$questionMarks',
        );
        debugPrint(
          '────────────────────────────────────────',
        );

        return {
          "questionId": question.id,
          "questionText": question.questionText,
          "options": question.options,
          "selectedOption": selectedAnswer,
          "correctAnswer": correctAnswer,
          "isCorrect": isCorrect,
          "marksObtained": marksObtained,
          "totalMarks": questionMarks,
        };
      }).toList();

      final technicalScore =
      totalAvailableMarks == 0
          ? 0
          : ((obtainedMarks /
          totalAvailableMarks) *
          100)
          .round()
          .clamp(0, 100);

      final overallRating = double.parse(
        ((technicalScore / 100) * 5)
            .clamp(0, 5)
            .toStringAsFixed(1),
      );

      debugPrint(
        '════════════════════════════════════════',
      );
      debugPrint(
        '🟢 CORRECT ANSWERS: '
            '$correctAnswersCount/'
            '${data.questions.length}',
      );
      debugPrint(
        '🟢 OBTAINED MARKS: $obtainedMarks',
      );
      debugPrint(
        '🟢 TOTAL AVAILABLE MARKS: '
            '$totalAvailableMarks',
      );
      debugPrint(
        '🟢 TECHNICAL SCORE: '
            '$technicalScore/100',
      );
      debugPrint(
        '🟢 OVERALL RATING: '
            '$overallRating/5',
      );
      debugPrint(
        '════════════════════════════════════════',
      );

      final submitPayload = {
        "applicationId": effectiveApplicationId,
        "quizId": effectiveQuizId,
        "score": technicalScore,
        "totalQuestions": data.questions.length,
        "targetTotal": 100,
        "answers": answers,
      };

      debugPrint(
        '🟡 SUBMIT ASSESSMENT PAYLOAD: '
            '$submitPayload',
      );

      final submitResponse =
      await service.submitAssessment(
        token: StorageService.getToken(),
        payload: submitPayload,
      );

      debugPrint(
        '🟢 SUBMIT ASSESSMENT RESPONSE: '
            '${submitResponse.data}',
      );

      final submitSuccess =
          submitResponse.data is Map &&
              submitResponse.data['success'] == true;

      if (!submitSuccess) {
        throw Exception(
          _extractErrorMessage(
            submitResponse.data,
            fallback:
            'Unable to submit assessment',
          ),
        );
      }

      final assessmentTitle =
      data.title.trim().isEmpty
          ? 'Assessment'
          : data.title.trim();

      final comment =
          'Candidate completed online assessment '
          '"$assessmentTitle". '
          'Score: $technicalScore/100';

      final scoreResponse =
      await service.updateAssessmentScore(
        token: StorageService.getToken(),
        applicationId: effectiveApplicationId,
        technicalScore: technicalScore,
        overallRating: overallRating,
        comment: comment,
      );

      debugPrint(
        '🟢 UPDATE SCORE RESPONSE: '
            '${scoreResponse.data}',
      );

      final updateSuccess =
          scoreResponse.data is Map &&
              scoreResponse.data['success'] == true;

      if (!updateSuccess) {
        throw Exception(
          _extractErrorMessage(
            scoreResponse.data,
            fallback:
            'Assessment submitted, but score update failed',
          ),
        );
      }

      Get.offNamed(
        AppRoutes.assessmentSuccess,
        arguments: {
          'message':
          submitResponse.data['message'] ??
              'Assessment submitted successfully',
          'technicalScore':
          technicalScore,
          'overallRating':
          overallRating,
          'correctAnswers':
          correctAnswersCount,
          'totalQuestions':
          data.questions.length,
          'obtainedMarks':
          obtainedMarks,
          'totalMarks':
          totalAvailableMarks,
        },
      );
    } on DioException catch (e) {
      debugPrint(
        '🔴 SUBMIT ASSESSMENT DIO ERROR: '
            '${e.response?.statusCode} '
            '${e.response?.data}',
      );

      Get.snackbar(
        'Error',
        _extractErrorMessage(
          e.response?.data,
          fallback: 'Unable to submit assessment',
        ),
      );
    } catch (e) {
      debugPrint(
        '🔴 SUBMIT ASSESSMENT ERROR: $e',
      );

      Get.snackbar(
        'Error',
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String _normalizeAnswer(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }


  int? _extractTechnicalScore(dynamic responseData) {
    if (responseData is! Map) {
      debugPrint(
        '🔴 INVALID SUBMIT RESPONSE TYPE: '
            '${responseData.runtimeType}',
      );

      return null;
    }

    final result = responseData['result'];
    final data = responseData['data'];
    final assessmentResult =
    responseData['assessmentResult'];

    debugPrint(
      '════════════════════════════════════════',
    );
    debugPrint('🟡 CHECKING SCORE RESPONSE KEYS');
    debugPrint(
      '🟡 ROOT technicalScore: '
          '${responseData['technicalScore']}',
    );
    debugPrint(
      '🟡 ROOT score: ${responseData['score']}',
    );
    debugPrint(
      '🟡 ROOT percentage: '
          '${responseData['percentage']}',
    );
    debugPrint(
      '🟡 ROOT obtainedMarks: '
          '${responseData['obtainedMarks']}',
    );

    if (result is Map) {
      debugPrint(
        '🟡 RESULT technicalScore: '
            '${result['technicalScore']}',
      );
      debugPrint(
        '🟡 RESULT score: ${result['score']}',
      );
      debugPrint(
        '🟡 RESULT percentage: '
            '${result['percentage']}',
      );
    }

    if (data is Map) {
      debugPrint(
        '🟡 DATA technicalScore: '
            '${data['technicalScore']}',
      );
      debugPrint(
        '🟡 DATA score: ${data['score']}',
      );
      debugPrint(
        '🟡 DATA percentage: '
            '${data['percentage']}',
      );
    }

    if (assessmentResult is Map) {
      debugPrint(
        '🟡 ASSESSMENT RESULT technicalScore: '
            '${assessmentResult['technicalScore']}',
      );
      debugPrint(
        '🟡 ASSESSMENT RESULT score: '
            '${assessmentResult['score']}',
      );
    }

    debugPrint(
      '════════════════════════════════════════',
    );

    final candidates = <dynamic>[
      responseData['technicalScore'],
      responseData['score'],
      responseData['percentage'],

      if (result is Map)
        result['technicalScore'],

      if (result is Map)
        result['score'],

      if (result is Map)
        result['percentage'],

      if (data is Map)
        data['technicalScore'],

      if (data is Map)
        data['score'],

      if (data is Map)
        data['percentage'],

      if (assessmentResult is Map)
        assessmentResult['technicalScore'],

      if (assessmentResult is Map)
        assessmentResult['score'],

      if (data is Map &&
          data['result'] is Map)
        data['result']['technicalScore'],

      if (data is Map &&
          data['result'] is Map)
        data['result']['score'],

      if (data is Map &&
          data['assessmentResult'] is Map)
        data['assessmentResult']['technicalScore'],

      if (data is Map &&
          data['assessmentResult'] is Map)
        data['assessmentResult']['score'],
    ];

    for (final value in candidates) {
      final parsedValue = _toDouble(value);

      if (parsedValue != null) {
        final technicalScore =
        parsedValue.round().clamp(0, 100);

        debugPrint(
          '🟢 SCORE FOUND IN SUBMIT RESPONSE: '
              '$technicalScore',
        );

        return technicalScore;
      }
    }

    debugPrint(
      '════════════════════════════════════════',
    );
    debugPrint(
      '🔴 SCORE NOT FOUND IN SUBMIT RESPONSE',
    );
    debugPrint(
      '🔴 RETURNING NULL INSTEAD OF ZERO',
    );
    debugPrint(
      '════════════════════════════════════════',
    );

    return null;
  }


  double _calculateOverallRating(int technicalScore) {
    /*
     Converts score out of 100 into rating out of 5.

     Example:
     25 / 100 × 5 = 1.25
     Rounded to one decimal = 1.3
    */

    final rating = (technicalScore / 100) * 5;

    return double.parse(
      rating.clamp(0, 5).toStringAsFixed(1),
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  String _extractErrorMessage(
      dynamic responseData, {
        required String fallback,
      }) {
    if (responseData is Map) {
      return responseData['message']?.toString() ??
          responseData['error']?.toString() ??
          fallback;
    }

    return fallback;
  }
}