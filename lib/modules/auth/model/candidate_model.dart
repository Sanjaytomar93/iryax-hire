class CandidateModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? qualification;
  final List<String> roles;

  CandidateModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.qualification,
    required this.roles,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      qualification: json['qualification'],
      roles: List<String>.from(json['role'] ?? []),
    );
  }
}