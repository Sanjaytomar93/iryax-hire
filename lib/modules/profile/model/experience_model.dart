class ExperienceModel {
  final String id;
  final String companyName;
  final String role;
  final String location;
  final String salary;
  final String startDate;
  final String endDate;

  final String offerLetter;
  final String payslip;
  final String relievingLetter;
  final String otherDocument;

  ExperienceModel({
    required this.id,
    required this.companyName,
    required this.role,
    required this.location,
    required this.salary,
    required this.startDate,
    required this.endDate,
    required this.offerLetter,
    required this.payslip,
    required this.relievingLetter,
    required this.otherDocument,
  });

  factory ExperienceModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ExperienceModel(
      id: json['_id'] ?? '',
      companyName: json['companyName'] ?? '',
      role: json['role'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      offerLetter: json['offerLetter'] ?? '',
      payslip: json['payslip'] ?? '',
      relievingLetter: json['relievingLetter'] ?? '',
      otherDocument: json['otherDocument'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'companyName': companyName,
      'role': role,
      'location': location,
      'salary': salary,
      'startDate': startDate,
      'endDate': endDate,
      'offerLetter': offerLetter,
      'payslip': payslip,
      'relievingLetter': relievingLetter,
      'otherDocument': otherDocument,
    };
  }
}