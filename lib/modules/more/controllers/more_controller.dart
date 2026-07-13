import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/services/storage_service.dart';

class MoreMenuItem {
  final IconData icon;
  final String title;
  final bool hasToggle;
  final String? route;

  const MoreMenuItem({
    required this.icon,
    required this.title,
    this.hasToggle = false,
    this.route,
  });
}

class MoreController extends GetxController {
  final RxBool isAvailable = true.obs;
  final RxBool isDonor = false.obs;
  final RxBool isVolunteer = false.obs;

  final List<MoreMenuItem> menuItems = [
    const MoreMenuItem(icon: Icons.person_outline, title: 'Available For Donate', hasToggle: true),
    const MoreMenuItem(icon: Icons.dashboard_customize_outlined, title: 'Volunteer Dashboard', route: AppRoutes.volunteerDashboard),
    const MoreMenuItem(icon: Icons.help_outline, title: 'FAQ'),
    const MoreMenuItem(icon: Icons.headset_mic_outlined, title: 'Help & Support', route: AppRoutes.support),
    const MoreMenuItem(icon: Icons.lock_outline, title: 'Privacy policy\'s'),
    const MoreMenuItem(icon: Icons.info_outline, title: 'About Us'),
    const MoreMenuItem(icon: Icons.logout_outlined, title: 'Logout'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadRoles();
  }

  void _loadRoles() {
    final storage = Get.find<StorageService>();
    isDonor.value = storage.isDonor;
    isVolunteer.value = storage.isVolunteer;
  }

  void toggleAvailability(bool value) {
    isAvailable.value = value;
  }

  /// Called when user taps "Become A Donor"
  void handleBecomeDonor() async {
    if (isDonor.value) {
      // Already a donor — do nothing (card is disabled)
      return;
    }
    if (isVolunteer.value) {
      // Has volunteer data — show quick confirm screen
      await Get.toNamed(
        AppRoutes.quickRegister,
        arguments: {
          'targetRole': 'donor',
          'existingRole': 'volunteer',
        },
      );
    } else {
      // Fresh user — go to full form
      await Get.toNamed(AppRoutes.donor);
    }
    _loadRoles();
  }

  /// Called when user taps "Become A Volunteer"
  void handleBecomeVolunteer() async {
    if (isVolunteer.value) {
      // Already a volunteer — do nothing (card is disabled)
      return;
    }
    if (isDonor.value) {
      // Has donor data — show quick confirm screen
      await Get.toNamed(
        AppRoutes.quickRegister,
        arguments: {
          'targetRole': 'volunteer',
          'existingRole': 'donor',
        },
      );
    } else {
      // Fresh user — go to full form
      await Get.toNamed(AppRoutes.volunteerRegistration);
    }
    _loadRoles();
  }

  void logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Logout', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final storage = Get.find<StorageService>();
              await storage.clearAuth();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void deleteAccount() {
    Get.back();
    Get.snackbar(
      'Account Deleted',
      'Your account has been successfully removed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
