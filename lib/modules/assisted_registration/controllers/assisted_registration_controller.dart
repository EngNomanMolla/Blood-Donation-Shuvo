import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssistedRegistrationController extends GetxController {
  // Mobile Verification Fields (First as requested)
  final mobileController = TextEditingController(text: '+88 01');
  final verificationCodeController = TextEditingController();

  // Donor Details Fields
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();

  final selectedGender = ''.obs;
  final selectedBloodGroup = ''.obs;
  final selectedDistrict = ''.obs;
  final selectedUpazila = ''.obs;
  final selectedThana = ''.obs;

  final genderOptions = ['Male', 'Female', 'Other'];
  final bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final districtOptions = ['Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet'];
  final upazilaOptions = ['Upazila 1', 'Upazila 2', 'Upazila 3'];
  final thanaOptions = ['Thana 1', 'Thana 2', 'Thana 3'];

  @override
  void onClose() {
    mobileController.dispose();
    verificationCodeController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    super.onClose();
  }

  void onSendCode() {
    if (mobileController.text.length < 11) {
      Get.snackbar('Error', 'Please enter a valid mobile number',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    Get.snackbar('Code Sent', 'Verification code has been sent to ${mobileController.text}',
        backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
  }

  void onRegister() {
    if (mobileController.text.length < 11) {
      Get.snackbar('Error', 'Valid mobile number required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (verificationCodeController.text.isEmpty) {
      Get.snackbar('Error', 'Verification code is required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (fullNameController.text.isEmpty) {
      Get.snackbar('Error', 'Full name is required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.snackbar('Success', 'Donor Registration Successfully Completed!',
        backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
    
    Future.delayed(const Duration(seconds: 2), () => Get.back());
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFE53935)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }
}
