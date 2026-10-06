class ApiConstants {
  static const String baseUrl =
      'https://ingrainhirebackend.ingrainsystems.com';

  static const String sendRegisterOtp = '/api/candidate/send-register-otp';
  static const String verifyRegisterOtp = '/api/candidate/verify-register-otp';
  static const String register = '/api/candidate/register';

  static const String login = '/api/candidate/login';
  static const String verifyLoginOtp = '/api/candidate/verify-otp';
  static const String resendOtp = '/api/candidate/resend-otp';

  static const String forgotPassword = '/api/candidate/forgot-password';
  static const String resetPassword = '/api/candidate/reset-password';


  // Roles
  static const String allRoles =
      '/api/roles/all';

  // Candidate Profile
  static const String candidateProfile =
      '/api/candidate/profile';

  // Education
  static const String candidateEducation =
      '/api/candidate/education';

  static String candidateEducationById(String id) =>
      '/api/candidate/education/$id';

  // Experience / Professional Details
  static const String candidateExperience =
      '/api/candidate/experience';

  static String candidateExperienceById(String id) =>
      '/api/candidate/experience/$id';

  // Medical Certificate
  static const String uploadMedicalCertificate =
      '/api/medical-certificates/upload';

  static String medicalCertificatesByCandidateId(String candidateId) =>
      '/api/medical-certificates/candidate/$candidateId';

  // static String medicalCertificatesByEmployeeId(String employeeId) =>
  //     '/api/medical-certificates/employee/$employeeId';

  static String medicalCertificatesByEmployeeId(String candidateId) =>
      "/api/medical-certificates/employee/$candidateId";


  static String candidateWallet(String candidateId) =>
      "/api/candidate/mywallet/$candidateId";

  // Jobs
  static const String jobs = "/api/jobs/all";

  // Jobs matched with candidate roles, used only on Home
  static String matchedJobs(String candidateId) =>
      "/api/jobs/matchedjobs/$candidateId";

  static const String submitApplication =
      "/api/applications/submit";

  static String jobDetails(String jobId) =>
      "/api/jobs/view/$jobId";

  static String candidateDashboardCount(String candidateId) =>
      "/api/candidate/mydashboardcount/$candidateId";

  static const String toggleSavedJob =
      "/api/candidate/saved-jobs/toggle";

  static const String savedJobs =
      "/api/candidate/saved-jobs";

  // Ask backend exact endpoint if different
  // NEW
  static const String candidateApplications =
      "/api/candidate/applications";

  static String singleApplication(String applicationId) =>
      '/api/applications/singleapplication/$applicationId';

  static const String confirmInterview =
      '/api/candidate/confirm-interview';

  static const String uploadSignedOfferLetter =
      '/api/applications/upload-signed-docs';

  static const String shortJobs = "/api/jobs/short-jobs";

  static String assessmentDetails(
      String jobId,
      String applicationId,
      String quizId,
      ) =>
      "/api/admin/assementdetails/$jobId/$applicationId/$quizId";

  static const String submitAssessment =
      "/api/applications/submit-assessment";

  static const String updateAssessmentScore =
      "/api/applications/update-score";


  static const String candidateDocuments =
      '/api/candidate/documents';

  static const String uploadCandidateDocument =
      '/api/candidate/documents/upload';


  static const String updateBankDetails =
      '/api/candidate/save-bank-details';


  // static const String updateBankDetails =
  //     '/api/candidate/update-bank-details';

  static const String saveEmergencyContact =
      '/api/candidate/save-emergency-contact';




}