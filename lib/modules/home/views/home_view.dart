import 'package:flutter/material.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../constants.dart';
import '../widgets/banner_slider.dart';
import '../widgets/blood_request_section.dart';
import '../widgets/home_header.dart';
import '../widgets/notification_panel.dart';
import '../widgets/become_donor_banner.dart';
import '../widgets/become_volunteer_banner.dart';
import '../widgets/quick_actions_section.dart';
import '../../../core/services/storage_service.dart';

/// Main home view - displays dashboard with blood request, banners, and quick actions
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = Get.find<HomeController>();
  bool _showNotification = false;
  String _selectedBloodType = 'A+';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
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
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      displacement: 30,
      strokeWidth: 2.5,
      onRefresh: () async => await controller.refreshHomeData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              onNotificationTap: () => setState(() => _showNotification = true),
              onBalanceTap: () {},
            ),
            const SizedBox(height: HomeConstants.sectionVerticalSpacing),
            Obx(() {
              if (controller.isLoading.value) {
                return const SizedBox(
                  height: HomeConstants.bannerHeight,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                );
              }
              if (controller.banners.isEmpty) {
                return const SizedBox.shrink();
              }
              final images = controller.banners.map((b) => b.image).toList();
              return BannerSlider(images: images);
            }),
            const SizedBox(height: HomeConstants.sectionVerticalSpacing),
            BloodRequestSection(
              bloodTypes: HomeConstants.bloodTypes,
              selectedBloodType: _selectedBloodType,
              onBloodTypeChanged: _onBloodTypeSelected,
            ),
            const SizedBox(height: 8),
            BecomeDonorBanner(onTap: _onDonorTap),
            const SizedBox(height: 8),
            BecomeVolunteerBanner(onTap: _onVolunteerTap),
            const SizedBox(height: HomeConstants.sectionVerticalSpacing),
            QuickActionsSection(actions: QuickActionsSection.getDefaultActions()),
            const SizedBox(height: 100), // Space for floating bottom nav
          ],
        ),
      ),
    );
  }

  void _onDonorTap() {
    try {
      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        if (storage.isVolunteer && !storage.isDonor) {
          Get.toNamed(AppRoutes.quickRegister, arguments: {
            'targetRole': 'donor',
            'existingRole': 'volunteer',
          });
          return;
        }
      }
    } catch (_) {}
    Get.toNamed(AppRoutes.donor);
  }

  void _onVolunteerTap() {
    try {
      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        if (storage.isVolunteer) {
          Get.toNamed(AppRoutes.volunteerDashboard);
          return;
        } else if (storage.isDonor) {
          Get.toNamed(AppRoutes.quickRegister, arguments: {
            'targetRole': 'volunteer',
            'existingRole': 'donor',
          });
          return;
        }
      }
    } catch (_) {}
    Get.toNamed(AppRoutes.volunteerRegistration);
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
}
