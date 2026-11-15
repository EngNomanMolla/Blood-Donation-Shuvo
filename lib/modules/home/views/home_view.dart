import 'package:flutter/material.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../constants.dart';
import '../widgets/banner_slider.dart';
import '../widgets/blood_warning_notice.dart';
import '../widgets/blood_request_section.dart';
import '../widgets/home_header.dart';
import '../widgets/notification_panel.dart';
import '../widgets/become_donor_banner.dart';
import '../widgets/become_volunteer_banner.dart';
import '../widgets/become_member_banner.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/complaint_advice_card.dart';
import '../../../core/services/storage_service.dart';
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
            const BloodWarningNotice(),
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
            const SizedBox(height: 2),
            Obx(() => BecomeMemberBanner(
                  isMember: controller.isMember.value,
                  memberStatus: controller.memberStatus.value,
                  onTap: _onMemberTap,
                )),
            const SizedBox(height: HomeConstants.sectionVerticalSpacing),
            QuickActionsSection(actions: QuickActionsSection.getDefaultActions()),
            const SizedBox(height: 20),
            const ComplaintAdviceCard(),
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

      // 2. Proceed directly to Donor Registration (no membership required)
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

  void _onMemberTap() async {
    try {
      if (controller.isMember.value) {
        _showMemberBenefitsBottomSheet();
        return;
      }
      await Get.toNamed(AppRoutes.initialRecharge);
      controller.fetchProfile();
      controller.fetchWalletBalance();
    } catch (e) {
      debugPrint("Error on member tap: $e");
    }
  }

  void _showMemberBenefitsBottomSheet() {
    controller.fetchWalletBalance();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag pill
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Crown & Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Platform Member',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.blue.shade600,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'সক্রিয় মেম্বারশিপ • Active Status',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.grey.shade500,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Wallet Balance Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFFD97706),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ওয়ালেট ব্যালেন্স (Wallet Balance)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF78350F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                            controller.walletBalance.value,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          )),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.wallet);
                      },
                      child: const Text(
                        'রিচার্জ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Benefits list title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'আপনার আনলকড সুবিধাসমূহ (Unlocked Benefits):',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _buildBenefitTile(
                icon: Icons.phone_enabled_rounded,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                title: 'সরাসরি ফোন নম্বর',
                subtitle: 'যেকোনো রক্তদাতার সরাসরি মোবাইল নম্বর দেখার সুবিধা সক্রিয়।',
              ),
              const SizedBox(height: 8),
              _buildBenefitTile(
                icon: Icons.call_rounded,
                iconColor: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
                title: 'কল ও কথা বলার সুবিধা',
                subtitle: 'ওয়ালেট ব্যালেন্স ব্যবহার করে সরাসরি ডোনারের সাথে যোগাযোগ করুন।',
              ),
              const SizedBox(height: 8),
              _buildBenefitTile(
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF5F3FF),
                title: 'ভেরিফাইড মেম্বার সুবিধা',
                subtitle: 'প্ল্যাটফর্মে যেকোনো সময় রক্তদাতা পাওয়ার সর্বোচ্চ অগ্রাধিকার।',
              ),
              const SizedBox(height: 22),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.wallet);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF334155)),
                          SizedBox(width: 6),
                          Text(
                            'ওয়ালেটে যান',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_rounded, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'হোম পেজ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBenefitTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
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
}
