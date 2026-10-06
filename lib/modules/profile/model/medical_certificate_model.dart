class MedicalCertificateModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String candidateId;
  final String candidateName;
  final String registrationDate;
  final String expiryDate;
  final String document;
  final String uploadedAt;

  MedicalCertificateModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.candidateId,
    required this.candidateName,
    required this.registrationDate,
    required this.expiryDate,
    required this.document,
    required this.uploadedAt,
  });

  factory MedicalCertificateModel.fromJson(Map<String, dynamic> json) {
    return MedicalCertificateModel(
      id: json['_id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      candidateId: json['candidateId']?.toString() ?? '',
      candidateName: json['candidateName']?.toString() ?? '',
      registrationDate: json['registrationDate']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString() ?? '',
      document: json['documentUrl']?.toString() ??
          json['document']?.toString() ??
          '',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'candidateId': candidateId,
      'candidateName': candidateName,
      'registrationDate': registrationDate,
      'expiryDate': expiryDate,
      'documentUrl': document,
      'uploadedAt': uploadedAt,
    };
  }
}