import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/services/storage_service.dart';
import 'package:blood_donation/modules/onboarding/views/page_view_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  static const Color _primaryRed = Color(0xFFE53935);
  static const Color _darkRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Premium Background Blobs
          _buildBackground(),

          // 2. Introduction Screen Content
          IntroductionScreen(
            pages: onboardingPages,
            
            // Custom Buttons
            showSkipButton: true,
            skip: _buildSkipButton(),
            next: _buildNextButton(),
            done: _buildDoneButton(),
            
            onDone: () {
              Get.find<StorageService>().setHasShownOnboarding(true);
              Get.offAllNamed(AppRoutes.login);
            },
            onSkip: () {
              Get.find<StorageService>().setHasShownOnboarding(true);
              Get.offAllNamed(AppRoutes.login);
            },
            
            // Layout Configurations
            curve: Curves.fastOutSlowIn,
            animationDuration: 600,
            
            dotsDecorator: DotsDecorator(
              size: const Size(10.0, 10.0),
              color: _primaryRed.withOpacity(0.25),
              activeSize: const Size(28.0, 10.0),
              activeColor: _primaryRed,
              spacing: const EdgeInsets.symmetric(horizontal: 4.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            
            dotsContainerDecorator: const ShapeDecoration(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -80,
            child: _buildBlob(320, 320, _primaryRed.withOpacity(0.04)),
          ),
          Positioned(
            bottom: 200,
            right: -60,
            child: _buildBlob(200, 200, _darkRed.withOpacity(0.03)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _primaryRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "Skip",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: _primaryRed,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryRed, _darkRed],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primaryRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildDoneButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryRed, _darkRed],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _primaryRed.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Text(
        "Start",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}