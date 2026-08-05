import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/modules/auth/bindings/sign_in_binding.dart';
import 'package:blood_donation/modules/auth/views/login_view.dart';
import 'package:blood_donation/modules/donor/views/donor_registration_view.dart';
import 'package:blood_donation/modules/donor/bindings/donor_registration_binding.dart';
import 'package:blood_donation/modules/doner_details/views/doner_details_view.dart';
import 'package:blood_donation/modules/doner_request/views/doner_request_list_view.dart';
import 'package:blood_donation/modules/doner_request/bindings/doner_request_binding.dart';
import 'package:blood_donation/modules/home/views/main_view.dart';
import 'package:blood_donation/modules/onboarding/views/onboarding_view.dart';
import 'package:blood_donation/modules/more/views/profile_view.dart';
import 'package:blood_donation/modules/home/bindings/home_binding.dart';
import 'package:blood_donation/modules/more/bindings/more_binding.dart';
import 'package:blood_donation/modules/splash/views/splash_view.dart';
import 'package:blood_donation/modules/emergency_contact/views/emergency_contact_view.dart';
import 'package:blood_donation/modules/performance/views/performance_view.dart';
import 'package:blood_donation/modules/wallet/views/wallet_view.dart';
import 'package:blood_donation/modules/wallet/views/subscription_plans_view.dart';
import 'package:blood_donation/modules/wallet/bindings/wallet_binding.dart';
import 'package:blood_donation/modules/feedback_support/bindings/feedback_support_binding.dart';
import 'package:blood_donation/modules/feedback_support/views/people_reviews_view.dart';
import 'package:blood_donation/modules/feedback_support/views/support_view.dart';
import 'package:blood_donation/modules/more/views/volunteer_dashboard_view.dart';
import 'package:blood_donation/modules/more/views/donor_dashboard_view.dart';
import 'package:blood_donation/modules/volunteer_wallet/bindings/volunteer_wallet_binding.dart';
import 'package:blood_donation/modules/volunteer_wallet/views/volunteer_wallet_view.dart';
import 'package:blood_donation/modules/volunteer_registration/bindings/volunteer_registration_binding.dart';
import 'package:blood_donation/modules/volunteer_registration/views/volunteer_registration_view.dart';
import 'package:blood_donation/modules/assisted_registration/bindings/assisted_registration_binding.dart';
import 'package:blood_donation/modules/assisted_registration/views/assisted_registration_view.dart';
import 'package:blood_donation/modules/more/views/quick_register_view.dart';
import 'package:blood_donation/modules/initial_recharge/bindings/initial_recharge_binding.dart';
import 'package:blood_donation/modules/initial_recharge/views/initial_recharge_view.dart';
import 'package:get/get.dart';

/// App page routes and bindings configuration
class AppPages {
  static final pages = [
    // Splash Screen - Entry point
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // Onboarding Screen
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // Login Screen
    GetPage(
      name: AppRoutes.login,
      page: () => const SignInScreen(),
      binding: SignInBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Home Screen - Main dashboard
    GetPage(
      name: AppRoutes.home,
      page: () => const MainView(),
      binding: HomeBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Donor Registration Screen
    GetPage(
      name: AppRoutes.donor,
      page: () => const DonerRegistrationView(),
      binding: DonorRegistrationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Donor Details Screen
    GetPage(
      name: AppRoutes.donorDetails,
      page: () => DonerDetailsView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Blood Request List Screen
    GetPage(
      name: AppRoutes.bloodRequestList,
      page: () => const DonateScreen(),
      binding: DonerRequestBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Profile Screen
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Emergency Contacts Screen
    GetPage(
      name: AppRoutes.emergencyContacts,
      page: () => EmergencyContactView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Performance Screen
    GetPage(
      name: AppRoutes.performance,
      page: () => PerformanceView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Wallet Screen
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Subscription Plans Screen
    GetPage(
      name: AppRoutes.subscriptionPlans,
      page: () => const SubscriptionPlansView(),
      binding: WalletBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // People Reviews Screen
    GetPage(
      name: AppRoutes.peopleReviews,
      page: () => const PeopleReviewsView(),
      binding: FeedbackSupportBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Support Screen
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
      binding: FeedbackSupportBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Volunteer Dashboard Screen
    GetPage(
      name: AppRoutes.volunteerDashboard,
      page: () => const VolunteerDashboardView(),
      binding: MoreBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Donor Dashboard Screen
    GetPage(
      name: AppRoutes.donorDashboard,
      page: () => const DonorDashboardView(),
      binding: MoreBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Volunteer Wallet Screen
    GetPage(
      name: AppRoutes.volunteerWallet,
      page: () => const VolunteerWalletView(),
      binding: VolunteerWalletBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Volunteer Registration Screen
    GetPage(
      name: AppRoutes.volunteerRegistration,
      page: () => const VolunteerRegistrationView(),
      binding: VolunteerRegistrationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Assisted Donor Registration Screen
    GetPage(
      name: AppRoutes.assistedRegistration,
      page: () => const AssistedRegistrationView(),
      binding: AssistedRegistrationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Quick Register Screen (for users who already have data from the other role)
    GetPage(
      name: AppRoutes.quickRegister,
      page: () => const QuickRegisterView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Initial Recharge Screen
    GetPage(
      name: AppRoutes.initialRecharge,
      page: () => const InitialRechargeView(),
      binding: InitialRechargeBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];

  /// Get initial route based on app state
  /// Returns splash as the entry point
  static String getInitialRoute() => AppRoutes.splash;
}
