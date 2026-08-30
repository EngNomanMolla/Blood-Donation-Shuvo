import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/services/storage_service.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../volunteer_registration/views/volunteer_status_view.dart';
import '../../../data/providers/donor_provider.dart';
import '../../../data/repositories/donor_repository.dart';

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
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxString bloodGroup = ''.obs;
  final RxInt donationsCount = 0.obs;
  final RxInt livesSavedCount = 0.obs;
  final RxBool isAvailable = true.obs;
  final RxBool isDonor = false.obs;
  final RxBool isVolunteer = false.obs;
  final RxString volunteerPaymentStatus = ''.obs;
  final RxBool isLoading = false.obs;

  List<MoreMenuItem> get filteredMenuItems {
    final list = <MoreMenuItem>[
      const MoreMenuItem(icon: Icons.person_outline, title: 'Available For Donate', hasToggle: true),
    ];

    if (isDonor.value) {
      list.add(const MoreMenuItem(
        icon: Icons.dashboard_customize_outlined,
        title: 'Donor Dashboard',
        route: AppRoutes.donorDashboard,
      ));
    }

    if (isVolunteer.value) {
      list.add(const MoreMenuItem(
        icon: Icons.volunteer_activism_rounded,
        title: 'Volunteer Dashboard',
        route: AppRoutes.volunteerDashboard,
      ));
    }

    list.addAll([
      const MoreMenuItem(icon: Icons.headset_mic_outlined, title: 'Help & Support', route: AppRoutes.support),
      const MoreMenuItem(icon: Icons.lock_outline, title: 'Privacy Policy', route: AppRoutes.privacyPolicy),
      const MoreMenuItem(icon: Icons.info_outline, title: 'About Us', route: AppRoutes.aboutUs),
      const MoreMenuItem(icon: Icons.logout_outlined, title: 'Logout'),
    ]);

    return list;
  }

  List<MoreMenuItem> get menuItems => filteredMenuItems;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final profileRepository = Get.find<ProfileRepository>();
      final profile = await profileRepository.getProfile();
      if (profile != null) {
        name.value = profile.name;
        email.value = profile.email ?? '';
        phone.value = profile.phone ?? '';
        avatarUrl.value = profile.avatar ?? '';
        bloodGroup.value = profile.bloodGroup ?? '';
        donationsCount.value = profile.donationsCount;
        livesSavedCount.value = profile.livesSavedCount;
        isAvailable.value = profile.isAvailable;
        isDonor.value = profile.isDonor;
        isVolunteer.value = profile.isVolunteer;
        volunteerPaymentStatus.value = profile.volunteerPaymentStatus ?? '';

        // Sync with StorageService
        final storage = Get.find<StorageService>();
        await storage.setIsDonor(profile.isDonor);
        await storage.setIsVolunteer(profile.isVolunteer);
        if (profile.phone != null) {
          await storage.setUserPhone(profile.phone!);
        }
      }
    } catch (e) {
      debugPrint("Error fetching user profile in MoreController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleAvailability(bool value) async {
    isAvailable.value = value;
    try {
      final donorProvider = Get.put(DonorProvider());
      final donorRepository = Get.put(DonorRepository(donorProvider));

      debugPrint("MoreController: Updating availability status on server to $value");
      final response = await donorRepository.updateAvailability(value);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar('Success', 'Availability updated successfully!',
            backgroundColor: const Color(0xFFE8285A), colorText: Colors.white);
      } else {
        isAvailable.value = !value;
        Get.snackbar('Error', 'Failed to update availability status: ${response.body}',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      isAvailable.value = !value;
      debugPrint("Error updating availability status on server: $e");
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
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
    fetchUserProfile();
  }

  void handleBecomeVolunteer() async {
    if (isVolunteer.value) {
      return;
    }

    if (volunteerPaymentStatus.value == 'pending') {
      await Get.to(() => const VolunteerStatusView(status: 'pending'));
      fetchUserProfile();
      return;
    } else if (volunteerPaymentStatus.value == 'rejected') {
      await Get.to(() => const VolunteerStatusView(status: 'rejected'));
      fetchUserProfile();
      return;
    }

    if (isDonor.value) {
      await Get.toNamed(
        AppRoutes.quickRegister,
        arguments: {
          'targetRole': 'volunteer',
          'existingRole': 'donor',
        },
      );
    } else {
      await Get.toNamed(AppRoutes.volunteerRegistration);
    }
    fetchUserProfile();
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

  void deleteAccount() async {
    Get.back();
    isLoading.value = true;
    try {
      final profileRepo = Get.find<ProfileRepository>();
      final response = await profileRepo.deleteVolunteerAccount();
      debugPrint("Delete Volunteer Account API debug - Code: ${response.statusCode}");
      debugPrint("Delete Volunteer Account API debug - Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        final storage = Get.find<StorageService>();
        await storage.clearAuth();
        Get.offAllNamed(AppRoutes.login);

        Get.snackbar(
          'Account Deleted',
          'Your volunteer account has been successfully removed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete volunteer account: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error during delete volunteer account: $e");
      Get.snackbar(
        'Error',
        'An error occurred while deleting your account: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    isLoading.value = true;
    try {
      final profileRepository = Get.find<ProfileRepository>();
      final response = await profileRepository.updateProfileImage(image.path);

      if (response.statusCode == 200) {
        await fetchUserProfile();
        Get.snackbar(
          'Success',
          'Profile picture updated successfully!',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile picture. Server responded with status: ${response.statusCode}',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
