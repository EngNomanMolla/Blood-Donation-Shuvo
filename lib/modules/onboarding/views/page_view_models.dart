import 'package:blood_donation/core/utils/text_styles.dart';
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// IMAGE
          SvgPicture.asset(
            image,
            height: 280,
          ),

          const SizedBox(height: 40),

          /// TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: AllStyles.headingTextStyle
          ),

          const SizedBox(height: 16),

          /// DESCRIPTION
          Text(
            body,
            textAlign: TextAlign.center,
            style: AllStyles.subtitleTextStyle.copyWith(color: Colors.grey,height: 1.4),
        
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