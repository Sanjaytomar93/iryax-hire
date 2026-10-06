class JobModel {
  final String id;
  final String role;
  final String companyName;
  final String salary;
  final String experience;
  final String location;
  final String description;
  final String skills;
  final String department;
  final String jobType;
  final String aboutCompany;
  final String status;
  final String createdAt;

  final bool isSaved;
  final bool isApplied;

  final String startTime;
  final String endTime;
  final String totalDuration;
  final int vacancies;

  final List<dynamic> assessmentIds;

  final int matchPercentage;
  final List<String> matchingRoles;
  final String matchLevel;

  const JobModel({
    required this.id,
    required this.role,
    required this.companyName,
    required this.salary,
    required this.experience,
    required this.location,
    required this.description,
    required this.skills,
    required this.department,
    required this.jobType,
    required this.aboutCompany,
    required this.status,
    required this.createdAt,
    this.isSaved = false,
    this.isApplied = false,
    this.startTime = '',
    this.endTime = '',
    this.totalDuration = '',
    this.vacancies = 0,
    this.assessmentIds = const [],
    this.matchPercentage = 0,
    this.matchingRoles = const [],
    this.matchLevel = '',
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      salary: json['salary']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      skills: json['skills']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? '',
      aboutCompany: json['aboutCompany']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',

      isSaved: json['isSaved'] == true,
      isApplied: json['isApplied'] == true,

      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      totalDuration:
      json['totalDuration']?.toString() ?? '',
      vacancies:
      int.tryParse(json['vacancies']?.toString() ?? '0') ??
          0,

      assessmentIds: json['assessmentIds'] is List
          ? List<dynamic>.from(json['assessmentIds'])
          : const [],

      matchPercentage: int.tryParse(
        json['matchPercentage']?.toString() ?? '0',
      ) ??
          0,

      matchingRoles: json['matchingRoles'] is List
          ? (json['matchingRoles'] as List)
          .map((item) => item.toString())
          .toList()
          : const [],

      matchLevel:
      json['matchLevel']?.toString() ?? '',
    );
  }

  List<String> get skillList {
    if (skills.trim().isEmpty) {
      return [];
    }

    return skills
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String get level {
    if (department.isNotEmpty) {
      return department;
    }

    if (experience.contains('0') ||
        experience.toLowerCase().contains('fresher')) {
      return 'Junior';
    }

    return 'Experienced';
  }

  String get postedAgo {
    final date = DateTime.tryParse(createdAt);

    if (date == null) {
      return 'Recently';
    }

    final diff = DateTime.now().difference(date);

    if (diff.isNegative) {
      return 'Recently';
    }

    if (diff.inDays > 0) {
      return '${diff.inDays} '
          'day${diff.inDays > 1 ? 's' : ''} ago';
    }

    if (diff.inHours > 0) {
      return '${diff.inHours} '
          'hour${diff.inHours > 1 ? 's' : ''} ago';
    }

    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min ago';
    }

    return 'Just now';
  }

  JobModel copyWith({
    bool? isSaved,
    bool? isApplied,
    String? startTime,
    String? endTime,
    String? totalDuration,
    int? vacancies,
    List<dynamic>? assessmentIds,
    int? matchPercentage,
    List<String>? matchingRoles,
    String? matchLevel,
  }) {
    return JobModel(
      id: id,
      role: role,
      companyName: companyName,
      salary: salary,
      experience: experience,
      location: location,
      description: description,
      skills: skills,
      department: department,
      jobType: jobType,
      aboutCompany: aboutCompany,
      status: status,
      createdAt: createdAt,
      isSaved: isSaved ?? this.isSaved,
      isApplied: isApplied ?? this.isApplied,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDuration:
      totalDuration ?? this.totalDuration,
      vacancies: vacancies ?? this.vacancies,
      assessmentIds:
      assessmentIds ?? this.assessmentIds,
      matchPercentage:
      matchPercentage ?? this.matchPercentage,
      matchingRoles:
      matchingRoles ?? this.matchingRoles,
      matchLevel: matchLevel ?? this.matchLevel,
    );
  }
}