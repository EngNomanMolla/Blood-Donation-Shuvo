import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/services/storage_service.dart';
import 'package:blood_donation/data/repositories/auth_repository.dart';

class SignInController extends GetxController {
  final AuthRepository authRepository;

  SignInController({required this.authRepository});

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

  String _getFormattedPhone() {
    final rawPhone = mobileController.text.trim();
    String formattedPhone = rawPhone.replaceAll(RegExp(r'[\s\-]'), '');
    if (formattedPhone.startsWith('01') && formattedPhone.length == 11) {
      return '+88$formattedPhone';
    } else if (formattedPhone.startsWith('8801') && formattedPhone.length == 13) {
      return '+$formattedPhone';
    }
    return formattedPhone;
  }

  void sendOtp() async {
    final rawPhone = mobileController.text.trim();
    if (rawPhone.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid mobile number',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Format phone number to Bangladeshi prefix +88 if not already present
    final formattedPhone = _getFormattedPhone();
    if (!formattedPhone.startsWith('+8801') || formattedPhone.length != 14) {
      Get.snackbar('Error', 'Please enter a valid 11-digit mobile number starting with 01',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepository.sendCode(formattedPhone);
      isLoading.value = false;

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }
      } catch (_) {}

      if (isSuccess) {
        isOtpSent.value = true;
        
        // Auto-fill OTP code from API response
        final code = responseData['code'] ?? responseData['otp_code'];
        if (code != null) {
          otpController.text = code.toString();
        }

        final message = responseData['message'] ?? 'Verification code sent successful!';
        Get.snackbar('Success', message,
            backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
      } else {
        final errorMsg = responseData['message'] ?? 'Something went wrong (Status: ${response.statusCode})';
        Get.snackbar('Error', errorMsg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to connect to server: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void login() async {
    final verificationCode = otpController.text.trim();
    if (verificationCode.isEmpty || verificationCode.length < 4) {
      Get.snackbar('Error', 'Please enter valid verification code',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final formattedPhone = _getFormattedPhone();
    if (!formattedPhone.startsWith('+8801') || formattedPhone.length != 14) {
      Get.snackbar('Error', 'Please enter a valid 11-digit mobile number starting with 01',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepository.verifyCode(formattedPhone, verificationCode);
      isLoading.value = false;

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }
      } catch (_) {}

      if (isSuccess) {
        final storage = Get.find<StorageService>();
        await storage.setIsLoggedIn(true);
        final token = responseData['token'] ?? responseData['data']?['token'] ?? 'dummy_token';
        await storage.setUserToken(token);

        Get.offAllNamed(AppRoutes.initialRecharge);
        Get.snackbar('Success', 'Login successful!',
            backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
      } else {
        final errorMsg = responseData['message'] ?? 'Verification failed (Status: ${response.statusCode})';
        Get.snackbar('Error', errorMsg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to connect to server: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
