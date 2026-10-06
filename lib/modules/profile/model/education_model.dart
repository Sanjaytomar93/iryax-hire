class EducationModel {
  final String id;
  final String qualification;
  final String institution;
  final String startDate;
  final String endDate;
  final String passingYear;
  final String location;
  final String percentage;

  EducationModel({
    required this.id,
    required this.qualification,
    required this.institution,
    required this.startDate,
    required this.endDate,
    required this.passingYear,
    required this.location,
    required this.percentage,
  });

  factory EducationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return EducationModel(
      id: json['_id'] ?? '',
      qualification: json['qualification'] ?? '',
      institution: json['institution'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      passingYear: json['passingYear'] ?? '',
      location: json['location'] ?? '',
      percentage: json['percentage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'qualification': qualification,
      'institution': institution,
      'startDate': startDate,
      'endDate': endDate,
      'passingYear': passingYear,
      'location': location,
      'percentage': percentage,
    };
  }
}