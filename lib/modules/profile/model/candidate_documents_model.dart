class CandidateDocumentsModel {
  final String id;
  final String candidateId;
  final String email;
  final int completionPercentage;
  final CandidateDocuments documents;

  CandidateDocumentsModel({
    required this.id,
    required this.candidateId,
    required this.email,
    required this.completionPercentage,
    required this.documents,
  });

  factory CandidateDocumentsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : json;

    return CandidateDocumentsModel(
      id: data['_id']?.toString() ?? '',
      candidateId: data['candidateId']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      completionPercentage:
      int.tryParse(data['completionPercentage']?.toString() ?? '0') ?? 0,
      documents: CandidateDocuments.fromJson(
        data['documents'] is Map
            ? Map<String, dynamic>.from(data['documents'])
            : {},
      ),
    );
  }
}

class CandidateDocuments {
  final CandidateDocument aadharCard;
  final CandidateDocument panCard;
  final CandidateDocument tenthCertificate;
  final CandidateDocument twelfthCertificate;
  final CandidateDocument graduationCertificate;
  final CandidateDocument experienceLetters;
  final CandidateDocument passportPhoto;
  final BankDetails bankDetails;
  final EmergencyContact emergencyContact1;
  final EmergencyContact emergencyContact2;

  CandidateDocuments({
    required this.aadharCard,
    required this.panCard,
    required this.tenthCertificate,
    required this.twelfthCertificate,
    required this.graduationCertificate,
    required this.experienceLetters,
    required this.passportPhoto,
    required this.bankDetails,
    required this.emergencyContact1,
    required this.emergencyContact2,
  });

  factory CandidateDocuments.fromJson(
      Map<String, dynamic> json,
      ) {
    Map<String, dynamic> mapValue(String key) {
      final value = json[key];

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }

      return {};
    }

    return CandidateDocuments(
      aadharCard: CandidateDocument.fromJson(
        mapValue('aadharCard'),
      ),
      panCard: CandidateDocument.fromJson(
        mapValue('panCard'),
      ),
      tenthCertificate: CandidateDocument.fromJson(
        mapValue('tenthCertificate'),
      ),
      twelfthCertificate: CandidateDocument.fromJson(
        mapValue('twelfthCertificate'),
      ),
      graduationCertificate: CandidateDocument.fromJson(
        mapValue('graduationCertificate'),
      ),
      experienceLetters: CandidateDocument.fromJson(
        mapValue('experienceLetters'),
      ),
      passportPhoto: CandidateDocument.fromJson(
        mapValue('passportPhoto'),
      ),
      bankDetails: BankDetails.fromJson(
        mapValue('bankDetails'),
      ),
      emergencyContact1: EmergencyContact.fromJson(
        mapValue('emergencyContact1'),
      ),
      emergencyContact2: EmergencyContact.fromJson(
        mapValue('emergencyContact2'),
      ),
    );
  }
}

class CandidateDocument {
  final bool verified;
  final String url;
  final String status;
  final String uploadedAt;

  CandidateDocument({
    required this.verified,
    required this.url,
    required this.status,
    required this.uploadedAt,
  });

  factory CandidateDocument.fromJson(
      Map<String, dynamic> json,
      ) {
    return CandidateDocument(
      verified: json['verified'] == true,
      url: json['url']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
    );
  }

  bool get isUploaded => url.trim().isNotEmpty;
}

class BankDetails {
  final bool verified;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String uploadedAt;

  BankDetails({
    required this.verified,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.uploadedAt,
  });

  factory BankDetails.fromJson(
      Map<String, dynamic> json,
      ) {
    return BankDetails(
      verified: json['verified'] == true,
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode']?.toString() ?? '',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
    );
  }
}

class EmergencyContact {
  final bool verified;
  final String name;
  final String phone;
  final String relationship;
  final String uploadedAt;

  EmergencyContact({
    required this.verified,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.uploadedAt,
  });

  factory EmergencyContact.fromJson(
      Map<String, dynamic> json,
      ) {
    return EmergencyContact(
      verified: json['verified'] == true,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
    );
  }
}