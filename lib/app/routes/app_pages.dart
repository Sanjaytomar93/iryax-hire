import 'package:get/get.dart';

import '../../modules/applications/binding/application_details_binding.dart';
import '../../modules/applications/binding/applications_binding.dart';
import '../../modules/applications/binding/offer_letters_binding.dart';
import '../../modules/applications/view/application_details_view.dart';
import '../../modules/applications/view/applications_view.dart';
import '../../modules/applications/view/offer_letters_view.dart';
import '../../modules/assessment/binding/assessment_binding.dart';
import '../../modules/assessment/view/assessment_success_view.dart';
import '../../modules/assessment/view/assessment_view.dart';
import '../../modules/auth/view/forgot_password_view.dart';
import '../../modules/auth/view/login_view.dart';
import '../../modules/auth/view/register_email_view.dart';
import '../../modules/auth/view/register_otp_view.dart';
import '../../modules/auth/view/register_step_one_view.dart';
import '../../modules/auth/view/register_step_two_view.dart';
import '../../modules/auth/view/reset_password_view.dart';
import '../../modules/home/bindings/jobs_binding.dart';
import '../../modules/home/view/explore_view.dart';
import '../../modules/home/view/home_view.dart';
import '../../modules/jobs/view/about_company_view.dart';
import '../../modules/jobs/view/apply_job_view.dart';
import '../../modules/jobs/view/job_details_view.dart';
import '../../modules/onboarding/onboarding_binding.dart';
import '../../modules/onboarding/view/onboarding_view.dart';
import '../../modules/profile/binding/profile_binding.dart';
import '../../modules/profile/view/add_education_view.dart';
import '../../modules/profile/view/add_medical_certificate_view.dart';
import '../../modules/profile/view/add_professional_view.dart';
import '../../modules/profile/view/education_details_view.dart';
import '../../modules/profile/view/medical_certificate_view.dart';
import '../../modules/profile/view/personal_details_view.dart';
// import '../../modules/profile/view/personal_documents_view.dart';
import '../../modules/profile/view/personal_documents_view.dart';
import '../../modules/profile/view/professional_details_view.dart';
import '../../modules/profile/view/profile_view.dart';
import '../../modules/profile/view/wallet_view.dart';
import '../../modules/shortJobs/binding/short_job_binding.dart';
import '../../modules/shortJobs/view/short_jobs_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/view/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),

    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.registerEmail, page: () => const RegisterEmailView()),
    GetPage(name: AppRoutes.registerOtp, page: () => const RegisterOtpView()),
    GetPage(name: AppRoutes.registerStepOne, page: () => const RegisterStepOneView()),
    GetPage(name: AppRoutes.registerStepTwo, page: () => const RegisterStepTwoView()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
    GetPage(name: AppRoutes.resetPassword, page: () => const ResetPasswordView()),

    // GetPage(name: AppRoutes.home, page: () => const HomeView()),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.personalDetails,
      page: () => const PersonalDetailsView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.educationDetails,
      page: () => const EducationDetailsView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.addEducation,
      page: () => const AddEducationView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.personalDocuments,
      page: () => const PersonalDocumentsView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.professionalDetails,
      page: () => const ProfessionalDetailsView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.addProfessional,
      page: () => const AddProfessionalView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.medicalCertificate,
      page: () => const MedicalCertificateView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.addMedicalCertificate,
      page: () => const AddMedicalCertificateView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletView(),
      binding: ProfileBinding(),
    ),



    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: JobsBinding(),
    ),

    GetPage(
      name: AppRoutes.explore,
      page: () => const ExploreView(),
      binding: JobsBinding(),
    ),

    GetPage(
      name: AppRoutes.jobDetails,
      page: () => const JobDetailsView(),
      binding: JobsBinding(),
    ),

    GetPage(
      name: AppRoutes.applyJob,
      page: () => const ApplyJobView(),
      binding: JobsBinding(),
    ),

    GetPage(
      name: AppRoutes.aboutCompany,
      page: () => const AboutCompanyView(),
    ),

    GetPage(
      name: AppRoutes.applications,
      page: () => const ApplicationsView(),
      binding: ApplicationsBinding(),
    ),

    GetPage(
      name: AppRoutes.applicationDetails,
      page: () => const ApplicationDetailsView(),
      binding: ApplicationDetailsBinding(),
    ),

    GetPage(
      name: AppRoutes.shortJobs,
      page: () => const ShortJobsView(),
      binding: ShortJobsBinding(),
    ),

    GetPage(
      name: AppRoutes.assessment,
      page: () => const AssessmentView(),
      binding: AssessmentBinding(),
    ),

    GetPage(
      name: AppRoutes.assessmentSuccess,
      page: () => const AssessmentSuccessView(),
    ),


    GetPage(
      name: AppRoutes.offerLetters,
      page: () => const OfferLettersView(),
      binding: OfferLettersBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}