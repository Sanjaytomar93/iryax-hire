import 'wallet_model.dart';
import 'wallet_history_model.dart';

class CandidateProfileModel {
  final String id;
  final String name;
  final String dob;
  final String email;
  final String phone;
  final String skills;
  final String experience;
  final String address;
  final String percentage;
  final String passingYear;
  final String institution;
  final List<String> department;
  final String currentLocation;
  final String noticePeriod;
  final String dateOfJoining;
  final List<String> role;
  final String currentCompany;
  final String currentCTC;
  final String expectedCTC;
  final String qualification;
  final String city;
  final String gender;
  final String pincode;
  final String state;

  final List<String> savedJobs;

  final WalletModel wallet;
  final List<WalletHistoryModel> walletHistory;

  CandidateProfileModel({
    required this.id,
    required this.name,
    required this.dob,
    required this.email,
    required this.phone,
    required this.skills,
    required this.experience,
    required this.address,
    required this.percentage,
    required this.passingYear,
    required this.institution,
    required this.department,
    required this.currentLocation,
    required this.noticePeriod,
    required this.dateOfJoining,
    required this.role,
    required this.currentCompany,
    required this.currentCTC,
    required this.expectedCTC,
    required this.qualification,
    required this.city,
    required this.gender,
    required this.pincode,
    required this.state,
    required this.savedJobs,
    required this.wallet,
    required this.walletHistory,
  });

  factory CandidateProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CandidateProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      skills: json['skills'] ?? '',
      experience: json['experience'] ?? '',
      address: json['address'] ?? '',
      percentage: json['percentage'] ?? '',
      passingYear: json['passingYear'] ?? '',
      institution: json['institution'] ?? '',
      department:
      List<String>.from(
        json['department'] ?? [],
      ),
      currentLocation:
      json['currentLocation'] ?? '',
      noticePeriod:
      json['noticePeriod'] ?? '',
      dateOfJoining:
      json['dateOfJoining'] ?? '',
      role:
      List<String>.from(
        json['role'] ?? [],
      ),
      currentCompany:
      json['currentCompany'] ?? '',
      currentCTC:
      json['currentCTC'] ?? '',
      expectedCTC:
      json['expectedCTC'] ?? '',
      qualification:
      json['qualification'] ?? '',
      city: json['city'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      pincode: json['pincode'] ?? '',
      state: json['state'] ?? '',
      savedJobs:
      List<String>.from(
        json['savedJobs'] ?? [],
      ),
      wallet: WalletModel.fromJson(
        json['wallet'] ?? {},
      ),
      walletHistory:
      (json['walletHistory'] as List?)
          ?.map(
            (e) =>
            WalletHistoryModel
                .fromJson(e),
      )
          .toList() ??
          [],
    );
  }
}