import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import 'package:blood_donation/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Heading
            Text(
              "Sign In Your Account",
              style: AllStyles.headingTextStyle.copyWith(
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 10),

            /// Subtitle
            Text(
              "Lorem Ipsum text may appear in any size and font to simulate everything you create.",
              style: AllStyles.subtitleTextStyle.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            /// Mobile number label
            Text(
              "Mobile Number",
              style: AllStyles.subtitleTextStyle.copyWith(
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 8),

            /// Mobile number input
            TextField(
              decoration: InputDecoration(
                hintText: "Type Number",
                hintStyle: AllStyles.subtitleTextStyle,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Verification code + button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "verification Code",
                      labelStyle: AllStyles.subtitleTextStyle,

                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),

                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Send Code",
                    style: AllStyles.subtitleTextStyle.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// Login Button
            PrimaryButton(
              title: "Login",
              onPressed: () {
                /// Navigate to dashboard (Home)
                Get.offAllNamed(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}
