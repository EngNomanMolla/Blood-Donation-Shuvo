import 'package:flutter/material.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../widgets/banner_slider.dart';
import '../widgets/blood_request_section.dart';
import '../widgets/home_header.dart';
import '../widgets/notification_panel.dart';
import '../widgets/become_donor_banner.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/bottom_nav_bar.dart';

/// Main home view - displays dashboard with blood request, banners, and quick actions
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _showNotification = false;
  String _selectedBloodType = 'A+';
  int _currentNavIndex = 0;

  final List<String> _bannerImages = [
    "https://picsum.photos/800/400?1",
    "https://picsum.photos/800/400?2",
    "https://picsum.photos/800/400?3",
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildMainContent(),
            _buildNotificationPanelOverlay(screenWidth),
          ],
        ),
      ),
      
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            onNotificationTap: () => setState(() => _showNotification = true),
            onBalanceTap: () {},
          ),
          const SizedBox(height: HomeConstants.sectionVerticalSpacing),
          BannerSlider(images: _bannerImages),
          const SizedBox(height: HomeConstants.sectionVerticalSpacing),
          BloodRequestSection(
            bloodTypes: HomeConstants.bloodTypes,
            selectedBloodType: _selectedBloodType,
            onBloodTypeChanged: _onBloodTypeSelected,
          ),
          const SizedBox(height: HomeConstants.sectionVerticalSpacing),
          BecomeDonorBanner(onTap: () {}),
          const SizedBox(height: HomeConstants.sectionVerticalSpacing),
          QuickActionsSection(actions: QuickActionsSection.getDefaultActions()),
          const SizedBox(height: HomeConstants.sectionVerticalSpacing),
        ],
      ),
    );
  }

  Widget _buildNotificationPanelOverlay(double screenWidth) {
    return AnimatedPositioned(
      duration: HomeConstants.notificationPanelDuration,
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      right: _showNotification ? 0 : -screenWidth,
      width: screenWidth,
      child: NotificationPanel(
        onClose: () => setState(() => _showNotification = false),
      ),
    );
  }

  void _onBloodTypeSelected(String bloodType) {
    setState(() => _selectedBloodType = bloodType);
    // Navigate to blood request list view with the selected blood type
    Get.toNamed(
      AppRoutes.bloodRequestList,
      arguments: {'bloodType': bloodType},
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Home - already on home view
        break;
      case 1:
        // Message
        debugPrint('Navigate to Messages');
        // TODO: Implement navigation to messages
        break;
      case 2:
        // Wallet
        debugPrint('Navigate to Wallet');
        // TODO: Implement navigation to wallet
        break;
      case 3:
        // More
        debugPrint('Navigate to More');
        // TODO: Implement navigation to more options
        break;
    }
  }
}
