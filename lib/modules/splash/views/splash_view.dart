import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/services/storage_service.dart';
import 'package:blood_donation/data/providers/profile_provider.dart';
import 'package:blood_donation/data/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/text_styles.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        final storage = Get.find<StorageService>();
        if (!storage.hasShownOnboarding) {
          Get.offAllNamed(AppRoutes.onboarding);
          return;
        } 
        
        final token = storage.userToken;
        if (!storage.isLoggedIn || token == null || token.trim().isEmpty) {
          Get.offAllNamed(AppRoutes.login);
          return;
        }

        try {
          final profileProvider = Get.isRegistered<ProfileProvider>()
              ? Get.find<ProfileProvider>()
              : Get.put(ProfileProvider());
          final profileRepository = Get.isRegistered<ProfileRepository>()
              ? Get.find<ProfileRepository>()
              : Get.put(ProfileRepository(provider: profileProvider));
          
          final profile = await profileRepository.getProfile();
          if (profile != null) {
            await storage.setIsDonor(profile.isDonor);
            await storage.setIsVolunteer(profile.isVolunteer);
            await storage.setHasRecharged(profile.hasCompletedInitialRecharge);
            if (profile.phone != null) {
              await storage.setUserPhone(profile.phone!);
            }

            if (profile.initialRechargeStatus == 'approved' || profile.hasCompletedInitialRecharge) {
              Get.offAllNamed(AppRoutes.home);
            } else {
              Get.offAllNamed(AppRoutes.initialRecharge);
            }
            return;
          } else {
            // Profile is null (Token expired, 401 Unauthorized, or invalid session)
            debugPrint("Splash: Profile is null or token expired. Clearing auth and redirecting to login.");
            await storage.clearAuth();
            Get.offAllNamed(AppRoutes.login);
            return;
          }
        } catch (e) {
          debugPrint("Splash: Error verifying user session ($e). Clearing auth and redirecting to login.");
          await storage.clearAuth();
          Get.offAllNamed(AppRoutes.login);
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [

          /// Top Right Image
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/svg/splash/splash_top_right.svg',
              width: 140,
            ),
          ),

          /// Bottom Left Image
          Positioned(
            bottom: 0,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/svg/splash/splash_bottom_left.svg',
              width: 140,
            ),
          ),

          /// Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// Center Logo
                SvgPicture.asset(
                  'assets/images/svg/splash/splash_logo.svg',
                  width: 80,
                ),

                const SizedBox(height: 20),

                /// Title
                 Text(
                  'Blood Donation',
                  style: AllStyles.headingTextStyle.copyWith(color: AppColors.white)
                ),

                const SizedBox(height: 5),

                /// Subtitle
                 Text(
                  'Save Lives, Donate Blood',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'Poppins'
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}