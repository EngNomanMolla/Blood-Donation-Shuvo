import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/app/routes/app_routes.dart';

class SignInController extends GetxController {
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  
  final isLoading = false.obs;
  final isOtpSent = false.obs;
  
  @override
  void onClose() {
    mobileController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void sendOtp() async {
    if (mobileController.text.isEmpty || mobileController.text.length < 10) {
      Get.snackbar('Error', 'Please enter a valid mobile number',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    isOtpSent.value = true;
    
    Get.snackbar('Success', 'Verification code sent successful!',
        backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
  }

  void login() async {
    if (otpController.text.isEmpty || otpController.text.length < 4) {
      Get.snackbar('Error', 'Please enter valid verification code',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;

    Get.offAllNamed(AppRoutes.home);
  }
}
