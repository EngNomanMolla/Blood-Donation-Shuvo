import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/services/callkit_service.dart';
import 'package:blood_donation/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _handleInitialNavigation();
  }

  void _handleInitialNavigation() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      // If a call is already active or in progress, do NOT navigate away!
      if (CallKitService.isCallActive || Get.currentRoute == AppRoutes.call) {
        debugPrint("📞 [SPLASH] Active call detected, skipping splash navigation");
        return;
      }

      final storage = Get.find<StorageService>();
      if (storage.isLoggedIn && storage.userToken != null && storage.userToken!.isNotEmpty) {
        Get.offAllNamed(AppRoutes.home);
      } else if (storage.hasShownOnboarding) {
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    });
  }
}