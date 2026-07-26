
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

PageViewModel buildPage({
  required String image,
  required String title,
  required String body,
}) {
  return PageViewModel(
    title: '',
    bodyWidget: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          
          /// IMAGE
          Container(
            height: 300,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 50),

          /// TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 18),

          /// DESCRIPTION
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

List<PageViewModel> onboardingPages = [

  buildPage(
    image: 'assets/images/svg/onboarding/onboarding_one.svg',
    title: 'Discover Donor Based On Blood Type',
    body:
        'Find blood donors quickly and connect with people who are ready to save lives.',
  ),

  buildPage(
    image: 'assets/images/svg/onboarding/onboarding_two.svg',
    title: 'Search Donors Near You',
    body:
        'Locate available donors nearby and request blood instantly when needed.',
  ),

  buildPage(
    image: 'assets/images/svg/onboarding/onboarding_three.svg',
    title: 'Donate Blood Save Life',
    body:
        'Your one donation can save multiple lives. Become a hero today.',
  ),

  buildPage(
    image: 'assets/images/svg/onboarding/onboarding_four.svg',
    title: 'Join Blood Donation Community',
    body:
        'Connect with thousands of donors and help make the world a better place.',
  ),
];