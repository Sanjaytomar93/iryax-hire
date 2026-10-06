import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/api_constants.dart';

class ProfileService {
  final Dio dio;

  ProfileService(this.dio);

  Options _options(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  ////////////////////////////////////////////////////////////
  /// Candidate Profile
  ////////////////////////////////////////////////////////////

  Future<Response> getCandidateProfile(String token) async {
    return await dio.get(
      ApiConstants.candidateProfile,
      options: _options(token),
    );
  }

  Future<Response> updateCandidateProfile({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    return await dio.put(
      ApiConstants.candidateProfile,
      data: body,
      options: _options(token),
    );
  }

  ////////////////////////////////////////////////////////////
  /// Education APIs
  ////////////////////////////////////////////////////////////

  Future<Response> getEducationDetails(
      String token,
      ) async {
    return await dio.get(
      ApiConstants.candidateEducation,
      options: _options(token),
    );
  }

  Future<Response> addEducation({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    return await dio.post(
      ApiConstants.candidateEducation,
      data: body,
      options: _options(token),
    );
  }

  Future<Response> updateEducation({
    required String token,
    required String educationId,
    required Map<String, dynamic> body,
  }) async {
    return await dio.put(
      ApiConstants.candidateEducationById(
        educationId,
      ),
      data: body,
      options: _options(token),
    );
  }

  Future<Response> deleteEducation({
    required String token,
    required String educationId,
  }) async {
    return await dio.delete(
      ApiConstants.candidateEducationById(
        educationId,
      ),
      options: _options(token),
    );
  }

  ////////////////////////////////////////////////////////////
  /// Experience APIs
  ////////////////////////////////////////////////////////////

  Future<Response> getExperienceDetails(
      String token,
      ) async {
    return await dio.get(
      ApiConstants.candidateExperience,
      options: _options(token),
    );
  }

  Future<Response> addExperience({
    required String token,
    required FormData formData,
  }) async {
    return await dio.post(
      ApiConstants.candidateExperience,
      data: formData,
      options: _options(token),
    );
  }

  Future<Response> updateExperience({
    required String token,
    required String experienceId,
    required FormData formData,
  }) async {
    return await dio.put(
      ApiConstants.candidateExperienceById(
        experienceId,
      ),
      data: formData,
      options: _options(token),
    );
  }

  Future<Response> deleteExperience({
    required String token,
    required String experienceId,
  }) async {
    return await dio.delete(
      ApiConstants.candidateExperienceById(
        experienceId,
      ),
      options: _options(token),
    );
  }

  ////////////////////////////////////////////////////////////
  /// Medical Certificate APIs
  ////////////////////////////////////////////////////////////

  Future<Response> uploadMedicalCertificate({
    required String token,
    required FormData formData,
  }) async {
    return await dio.post(
      ApiConstants.uploadMedicalCertificate,
      data: formData,
      options: _options(token),
    );
  }


  Future<Response> getMedicalCertificates({
    required String token,
    required String candidateId,
  }) async {
    final path = ApiConstants.medicalCertificatesByEmployeeId(candidateId);

    debugPrint('🟡 GET MEDICAL CERTIFICATES URL: $path');

    final response = await dio.get(
      path,
      options: _options(token),
    );

    debugPrint('🟢 GET MEDICAL STATUS: ${response.statusCode}');
    debugPrint('🟢 GET MEDICAL RESPONSE: ${response.data}');

    return response;
  }

  // Future<Response> getMedicalCertificates({
  //   required String token,
  //   required String employeeId,
  // }) async {
  //   return await dio.get(
  //     ApiConstants.medicalCertificatesByEmployeeId(employeeId),
  //     options: _options(token),
  //   );
  // }

  ////////////////////////////////////////////////////////////
  /// Wallet History (from profile response)
  ////////////////////////////////////////////////////////////

  Future<List<dynamic>> getWalletHistory(
      String token,
      ) async {
    final response =
    await getCandidateProfile(token);

    return response.data['walletHistory'] ??
        [];
  }


  Future<Response> getCandidateWallet({
    required String token,
    required String candidateId,
  }) async {
    return await dio.get(
      ApiConstants.candidateWallet(candidateId),
      options: _options(token),
    );
  }

  // Future<int> getWalletCoins(
  //     String token,
  //     ) async {
  //   final response =
  //   await getCandidateProfile(token);
  //
  //   return response.data['wallet']?['coins'] ??
  //       0;
  // }


////////////////////////////////////////////////////////////
  /// Candidate Documents APIs
////////////////////////////////////////////////////////////

  Future<Response> getCandidateDocuments({
    required String token,
  }) async {
    debugPrint(
      '🟡 GET CANDIDATE DOCUMENTS URL: ${ApiConstants.candidateDocuments}',
    );

    final response = await dio.get(
      ApiConstants.candidateDocuments,
      options: _options(token),
    );

    debugPrint(
      '🟢 GET DOCUMENTS STATUS: ${response.statusCode}',
    );

    debugPrint(
      '🟢 GET DOCUMENTS RESPONSE: ${response.data}',
    );

    return response;
  }

  Future<Response> uploadCandidateDocument({
    required String token,
    required FormData formData,
  }) async {
    debugPrint(
      '🟡 UPLOAD DOCUMENT URL: ${ApiConstants.uploadCandidateDocument}',
    );

    final response = await dio.post(
      ApiConstants.uploadCandidateDocument,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    debugPrint(
      '🟢 UPLOAD DOCUMENT STATUS: ${response.statusCode}',
    );

    debugPrint(
      '🟢 UPLOAD DOCUMENT RESPONSE: ${response.data}',
    );

    return response;
  }


  Future<Response> updateBankDetails({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    debugPrint('🟡 UPDATE BANK URL: ${ApiConstants.updateBankDetails}');
    debugPrint('🟡 UPDATE BANK BODY: $body');

    return await dio.post(
      ApiConstants.updateBankDetails,
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> saveEmergencyContact({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    debugPrint('🟡 SAVE EMERGENCY URL: ${ApiConstants.saveEmergencyContact}');
    debugPrint('🟡 SAVE EMERGENCY BODY: $body');

    return await dio.post(
      ApiConstants.saveEmergencyContact,
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}