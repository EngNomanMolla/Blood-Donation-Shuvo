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
import '../../../data/providers/profile_provider.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../volunteer_registration/views/volunteer_status_view.dart';
import '../../more/controllers/more_controller.dart';

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
            const SizedBox(height: 2),
            Obx(() => BecomeDonorBanner(
                  isDonor: controller.isDonor.value,
                  onTap: _onDonorTap,
                )),
            const SizedBox(height: 2),
            Obx(() => BecomeVolunteerBanner(
                  isVolunteer: controller.isVolunteer.value,
                  volunteerPaymentStatus: controller.volunteerPaymentStatus.value,
                  onTap: _onVolunteerTap,
                )),
            const SizedBox(height: HomeConstants.sectionVerticalSpacing),
            QuickActionsSection(actions: QuickActionsSection.getDefaultActions()),
            const SizedBox(height: 100), // Space for floating bottom nav
          ],
        ),
      ),
    );
  }

  void _onDonorTap() async {
    try {
      final storage = Get.find<StorageService>();

      // 1. If user is already a donor -> go to Donor Dashboard
      if (storage.isDonor || controller.isDonor.value) {
        Get.toNamed(AppRoutes.donorDashboard);
        return;
      }

      // 2. Check if user is an approved member (recharge completed)
      bool isApproved = storage.hasRecharged || storage.initialRechargeStatus == 'approved';

      if (!isApproved) {
        // Fresh backend check to ensure accurate status
        try {
          final profileProvider = Get.isRegistered<ProfileProvider>()
              ? Get.find<ProfileProvider>()
              : Get.put(ProfileProvider());
          final profileRepo = Get.isRegistered<ProfileRepository>()
              ? Get.find<ProfileRepository>()
              : Get.put(ProfileRepository(provider: profileProvider));

          final profile = await profileRepo.getProfile();
          if (profile != null) {
            await storage.setHasRecharged(profile.hasCompletedInitialRecharge);
            if (profile.initialRechargeStatus != null) {
              await storage.setInitialRechargeStatus(profile.initialRechargeStatus!);
            }

            if (profile.initialRechargeStatus == 'approved' || profile.hasCompletedInitialRecharge) {
              isApproved = true;
            } else {
              _showDonorMembershipRequiredDialog(
                status: profile.initialRechargeStatus ?? 'initial',
                rejectReason: profile.initialRechargeRejectReason,
                amount: profile.initialRechargeAmount > 0 ? profile.initialRechargeAmount : 50.0,
              );
              return;
            }
          } else {
            _showDonorMembershipRequiredDialog(
              status: storage.initialRechargeStatus ?? 'initial',
              amount: 50.0,
            );
            return;
          }
        } catch (e) {
          _showDonorMembershipRequiredDialog(
            status: storage.initialRechargeStatus ?? 'initial',
            amount: 50.0,
          );
          return;
        }
      }

      // 3. User is an approved member -> proceed to Donor Registration
      if (storage.isVolunteer || controller.isVolunteer.value) {
        Get.toNamed(AppRoutes.quickRegister, arguments: {
          'targetRole': 'donor',
          'existingRole': 'volunteer',
        });
        return;
      }

      Get.toNamed(AppRoutes.donor);
    } catch (e) {
      debugPrint("Error on donor tap: $e");
      Get.toNamed(AppRoutes.donor);
    }
  }

  void _showDonorMembershipRequiredDialog({
    required String status,
    String? rejectReason,
    double amount = 50.0,
  }) {
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    Color themeColor;
    IconData icon;
    String statusTitle;
    String statusBadge;
    String message;
    String actionButtonText;

    if (isPending) {
      themeColor = const Color(0xFFF59E0B);
      icon = Icons.hourglass_top_rounded;
      statusTitle = 'ভেরিফিকেশন প্রক্রিয়াধীন';
      statusBadge = 'Pending Review';
      message = 'রক্তদাতা হিসেবে যুক্ত হতে মেম্বারশিপ প্রয়োজন। আপনার ৳${amount.toStringAsFixed(0)} রিচার্জ ভেরিফিকেশন পর্যালোচনায় রয়েছে। অ্যাডমিন অনুমোদন সম্পন্ন করলে আপনি ডোনার রেজিস্ট্রেশন করতে পারবেন।';
      actionButtonText = 'ভেরিফিকেশন স্ট্যাটাস দেখুন';
    } else if (isRejected) {
      themeColor = const Color(0xFFEF4444);
      icon = Icons.cancel_outlined;
      statusTitle = 'রিচার্জ বাতিল হয়েছে';
      statusBadge = 'Rejected';
      message = 'আপনার মেম্বারশিপ রিচার্জ রিকোয়েস্টটি গৃহীত হয়নি${(rejectReason != null && rejectReason.isNotEmpty) ? ' (কারণ: $rejectReason)' : ''}। ডোনার হতে হলে অনুগ্রহ করে পুনরায় রিচার্জ করুন।';
      actionButtonText = 'পুনরায় রিচার্জ করুন';
    } else {
      themeColor = AppColors.primary;
      icon = Icons.workspace_premium_rounded;
      statusTitle = 'আগে মেম্বার হতে হবে';
      statusBadge = '৳${amount.toStringAsFixed(0)} এককালীন রিচার্জ';
      message = 'রক্তদাতা হিসেবে যুক্ত হতে হলে আপনাকে আগে আমাদের প্ল্যাটফর্মের সদস্য বা মেম্বার হতে হবে। মাত্র ৳${amount.toStringAsFixed(0)} রিচার্জ সম্পন্ন করে মেম্বারশিপ সক্রিয় করুন।';
      actionButtonText = 'মেম্বার হতে রিচার্জ করুন (৳${amount.toStringAsFixed(0)})';
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Icon(icon, color: themeColor, size: 34),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                statusTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusBadge,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Message Body
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.toNamed(AppRoutes.initialRecharge);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          actionButtonText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Dismiss / Cancel Button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'বন্ধ করুন / পরে দেখবো',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onVolunteerTap() async {
    try {
      final paymentStatus = controller.volunteerPaymentStatus.value.toLowerCase().trim();
      if (paymentStatus == 'pending') {
        if (!Get.isRegistered<MoreController>()) {
          Get.lazyPut<MoreController>(() => MoreController());
        }
        await Get.to(() => const VolunteerStatusView(status: 'pending'));
        controller.fetchProfile();
        return;
      } else if (paymentStatus == 'rejected') {
        if (!Get.isRegistered<MoreController>()) {
          Get.lazyPut<MoreController>(() => MoreController());
        }
        await Get.to(() => const VolunteerStatusView(status: 'rejected'));
        controller.fetchProfile();
        return;
      }

      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        if (storage.isVolunteer || controller.isVolunteer.value) {
          Get.toNamed(AppRoutes.volunteerDashboard);
          return;
        } else if (storage.isDonor || controller.isDonor.value) {
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
