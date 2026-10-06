class AssessmentModel {
  final String applicationId;
  final String jobId;
  final String quizId;
  final String title;
  final String description;
  final int duration;
  final int totalQuestions;
  final String instructions;
  final List<AssessmentQuestion> questions;

  AssessmentModel({
    required this.applicationId,
    required this.jobId,
    required this.quizId,
    required this.title,
    required this.description,
    required this.duration,
    required this.totalQuestions,
    required this.instructions,
    required this.questions,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final application = data['application'] ?? {};
    final job = data['job'] ?? {};
    final currentAssessment = data['currentAssessment'] ?? {};

    return AssessmentModel(
      applicationId: application['id']?.toString() ?? '',
      jobId: job['id']?.toString() ?? '',
      quizId: currentAssessment['id']?.toString() ?? '',
      title: currentAssessment['title']?.toString() ?? '',
      description: currentAssessment['description']?.toString() ?? '',
      duration: int.tryParse(currentAssessment['duration']?.toString() ?? '0') ?? 0,
      totalQuestions: int.tryParse(currentAssessment['totalQuestions']?.toString() ?? '0') ?? 0,
      instructions: currentAssessment['instructions']?.toString() ?? '',
      questions: (currentAssessment['questions'] as List? ?? [])
          .map((e) => AssessmentQuestion.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class AssessmentQuestion {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;
  final String correctAnswer;
  final int marks;

  AssessmentQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
    required this.marks,
  });

  factory AssessmentQuestion.fromJson(
      Map<String, dynamic> json,
      ) {
    return AssessmentQuestion(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          '',
      questionText:
      json['questionText']?.toString() ?? '',
      questionType:
      json['questionType']?.toString() ?? '',
      options: (json['options'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      correctAnswer:
      json['correctAnswer']?.toString() ?? '',
      marks: int.tryParse(
        json['marks']?.toString() ?? '0',
      ) ??
          0,
    );
  }
}