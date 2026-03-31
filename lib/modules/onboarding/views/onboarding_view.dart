import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/modules/onboarding/views/page_view_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';


class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: IntroductionScreen(
        
          pages: onboardingPages,
        
          showSkipButton: true,
          skip: const Text("Skip"),
        
          next:  CircleAvatar(
            radius: 18.0,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.arrow_forward,size: 18.0, color: AppColors.white,)),
        
          done: const Text(
            "Start",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        
          onDone: () {
            /// navigate to home
            Get.offAllNamed(AppRoutes.home);
          },

          onSkip: () {
            /// skip to home
            Get.offAllNamed(AppRoutes.home);
          },
        
          dotsDecorator: const DotsDecorator(
            activeColor: Colors.red,
            size: Size(8, 8),
            activeSize: Size(22, 8),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
          ),
        ),
      ),
    );
  }
}