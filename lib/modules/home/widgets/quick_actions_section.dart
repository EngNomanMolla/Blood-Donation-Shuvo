import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import '../constants.dart';
import '../models.dart';
import 'quick_action_card.dart';

/// Quick actions grid section with responsive design
class QuickActionsSection extends StatelessWidget {
  final List<QuickActionModel> actions;

  const QuickActionsSection({
    super.key,
    required this.actions,
  });

  static List<QuickActionModel> getDefaultActions() {
    return [
      QuickActionModel(
        label: "Emergency Contacts",
        icon: Icons.phone_callback_rounded,
        iconColor: AppColors.primary,
        iconBg: const Color(0xFFFCECEE),
        onTap: () => Get.toNamed(AppRoutes.emergencyContacts),
      ),
      QuickActionModel(
        label: "Referral Bonus",
        icon: Icons.favorite_rounded,
        iconColor: AppColors.primary,
        iconBg: const Color(0xFFFCECEE),
      ),
      QuickActionModel(
        label: "People Review's",
        icon: Icons.chat_bubble_rounded,
        iconColor: Colors.orange,
        iconBg: const Color(0xFFFFF3E0),
      ),
      QuickActionModel(
        label: "Support",
        icon: Icons.support_agent_rounded,
        iconColor: Colors.blueGrey,
        iconBg: const Color(0xFFECEFF1),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Responsive grid columns
    final crossAxisCount = isMobile ? 2 : 3;
    final aspectRatio = isMobile ? 2.6 : 2.8;
    final spacing = isMobile ? 14.0 : 16.0;
    final horizontalPadding = isMobile ? 14.0 : HomeConstants.headerPadding.toDouble();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
            children: actions
                .map((action) => _buildAnimatedCard(action))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(QuickActionModel action) {
    return QuickActionCard(action: action);
  }
}
