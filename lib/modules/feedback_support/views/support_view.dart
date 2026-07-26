import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../controllers/feedback_support_controller.dart';

class SupportView extends GetView<FeedbackSupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            _buildSupportOptions(),
            _buildFaqSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Customer Support', style: AllStyles.headingTextStyle.copyWith(fontSize: 18, color: AppColors.white)),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white, size: 20),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded, color: AppColors.white, size: 60),
          ),
          const SizedBox(height: 20),
          Text(
            'How can we help you?',
            style: AllStyles.headingTextStyle.copyWith(color: AppColors.white, fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'We are available 24/7 to assist you',
            style: AllStyles.subtitleTextStyle.copyWith(color: AppColors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSupportCard(
            title: 'Call Us',
            subtitle: 'Speak directly with an agent',
            icon: Icons.phone_rounded,
            color: Colors.green,
            onTap: () => controller.callSupport(),
          ),
          const SizedBox(height: 12),
          _buildSupportCard(
            title: 'Email Support',
            subtitle: 'Get response within 24 hours',
            icon: Icons.email_rounded,
            color: Colors.orange,
            onTap: () => controller.emailSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AllStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AllStyles.subtitleTextStyle.copyWith(color: AppColors.darkGray, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.borderGray, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Frequently Asked Questions',
            style: AllStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        _buildFaqItem('How to find a blood donor?', 'Go to home and select blood type or search nearby donors.'),
        _buildFaqItem('How can I become a donor?', 'Click the "Become a Blood Donor" banner on the home page and register.'),
        _buildFaqItem('Is my data secure?', 'Yes, we take privacy very seriously and your data is encrypted.'),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question, style: AllStyles.subtitleTextStyle.copyWith(fontWeight: FontWeight.w600)),
          tilePadding: EdgeInsets.zero,
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(answer, style: AllStyles.subtitleTextStyle.copyWith(color: AppColors.darkGray)),
            ),
          ],
        ),
      ),
    );
  }
}
