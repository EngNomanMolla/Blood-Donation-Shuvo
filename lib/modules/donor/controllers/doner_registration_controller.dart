import 'package:flutter/material.dart';
import 'package:get/get.dart';
 
// ─── GetX Controller ────────────────────────────────────────────────────────
 
class RegistrationController extends GetxController {
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController(text: '+88 01');
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
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    dobController.dispose();
    super.onClose();
  }
 
  void onRegister() {
    if (fullNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your full name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    Get.snackbar('Success', 'Registration Complete!',
        backgroundColor: const Color(0xFFE8285A), colorText: Colors.white);
  }
 
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFE8285A)),
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