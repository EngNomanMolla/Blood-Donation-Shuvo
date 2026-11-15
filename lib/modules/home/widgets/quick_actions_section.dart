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
        label: "Emergency",
        subtitle: "Quick Contacts",
        icon: Icons.phone_in_talk_rounded,
        iconColor: const Color(0xFFE53935),
        iconBg: const Color(0xFFFFF1F3),
        gradientColors: const [Color(0xFFFFF6F7), Color(0xFFFFF0F2)],
        borderColor: const Color(0xFFFFD4DC),
        onTap: () => Get.toNamed(AppRoutes.emergencyContacts),
      ),
      QuickActionModel(
        label: "Support",
        subtitle: "24/7 Helpline",
        icon: Icons.headset_mic_rounded,
        iconColor: const Color(0xFF0284C7),
        iconBg: const Color(0xFFF0F9FF),
        gradientColors: const [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
        borderColor: const Color(0xFFBAE6FD),
        onTap: () => Get.toNamed(AppRoutes.support),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Responsive grid columns
    final crossAxisCount = 2;
    final aspectRatio = isMobile ? 2.0 : 2.2;
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
            padding: EdgeInsets.zero,
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
