import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/utils/app_colors.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: '1. Information We Collect',
              content: 'We collect personal information that you provide to us, including but not limited to your name, phone number, email address, blood group, date of birth, and location details during registration.',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: '2. How We Use Information',
              content: 'Your blood group and contact number are used specifically to match with recipients in need of emergency blood donations. Location details are utilized to filter local donors and improve response times.',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: '3. Data Security & Storage',
              content: 'We take data safety very seriously. Your authentication tokens are stored securely in local secure preferences. We implement industry-standard encryption protocols to protect your personal details from unauthorized access.',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: '4. Third Party Sharing',
              content: 'We do not sell, trade, or share your personally identifiable information with third parties. Your phone number is only visible to active subscribers who explicitly request to contact you for emergency donations.',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: '5. Changes to This Policy',
              content: 'We reserves the right to modify this privacy policy at any time. Any changes will be updated on this page with an updated effective date. Continued usage of our platform constitutes agreement to the terms.',
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Last Updated: August 20, 2026',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
