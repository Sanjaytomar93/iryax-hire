import '../../home/model/job_model.dart';
import 'application_model.dart';

class ApplicationTrackerModel {
  final String id;
  final String status;
  final DateTime? timestamp;

  const ApplicationTrackerModel({
    required this.id,
    required this.status,
    required this.timestamp,
  });

  factory ApplicationTrackerModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ApplicationTrackerModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      timestamp: DateTime.tryParse(
        json['timestamp']?.toString() ?? '',
      ),
    );
  }
}

class ApplicationDetailsModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String status;
  final List<ApplicationTrackerModel> trackers;
  final ApplicationInterviewModel interview;

  final double appearanceScore;
  final double workKnowledge;
  final double technicalScore;
  final double inchargeScore;
  final double overallRating;

  final String comment;
  final JobModel job;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ApplicationDetailsModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.status,
    required this.trackers,
    required this.interview,
    required this.appearanceScore,
    required this.workKnowledge,
    required this.technicalScore,
    required this.inchargeScore,
    required this.overallRating,
    required this.comment,
    required this.job,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicationDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final trackerData = json['trackers'];
    final dynamic jobData =
        json['job'] ?? json['jobId'] ?? <String, dynamic>{};

    return ApplicationDetailsModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Submitted',
      trackers: trackerData is List
          ? trackerData
          .whereType<Map>()
          .map(
            (item) => ApplicationTrackerModel.fromJson(
          Map<String, dynamic>.from(item),
        ),

      )
          .toList()
          : <ApplicationTrackerModel>[],
      interview: ApplicationInterviewModel.fromJson(json),
      appearanceScore: _toDouble(
        json['appearanceScore'],
      ),
      workKnowledge: _toDouble(
        json['workKnowledge'],
      ),
      technicalScore: _toDouble(
        json['technicalScore'],
      ),
      inchargeScore: _toDouble(
        json['inchargeScore'],
      ),
      overallRating: _toDouble(
        json['overallRating'],
      ),
      comment: json['comment']?.toString() ?? '',
      job: jobData is Map
          ? JobModel.fromJson(
        Map<String, dynamic>.from(jobData),
      )
          : JobModel.fromJson(<String, dynamic>{}),
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
      updatedAt: DateTime.tryParse(
        json['updatedAt']?.toString() ?? '',
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  String get candidateName {
    return '$firstName $lastName'.trim();
  }
}