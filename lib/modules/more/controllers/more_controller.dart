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

  final List<MoreMenuItem> menuItems = [
    const MoreMenuItem(icon: Icons.person_outline, title: 'Available For Donate', hasToggle: true),
    const MoreMenuItem(icon: Icons.dashboard_customize_outlined, title: 'Volunteer Dashboard', route: AppRoutes.volunteerDashboard),
    const MoreMenuItem(icon: Icons.help_outline, title: 'FAQ'),
    const MoreMenuItem(icon: Icons.headset_mic_outlined, title: 'Help & Support', route: AppRoutes.support),
    const MoreMenuItem(icon: Icons.lock_outline, title: 'Privacy policy\'s'),
    const MoreMenuItem(icon: Icons.info_outline, title: 'About Us'),
    const MoreMenuItem(icon: Icons.logout_outlined, title: 'Logout'),
  ];

  void toggleAvailability(bool value) {
    isAvailable.value = value;
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
    // Logic to delete account would go here
    Get.back(); // Close dialog
    Get.snackbar(
      'Account Deleted',
      'Your volunteer account has been successfully removed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}

