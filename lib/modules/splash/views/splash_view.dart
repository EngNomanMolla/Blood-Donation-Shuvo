import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/text_styles.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

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