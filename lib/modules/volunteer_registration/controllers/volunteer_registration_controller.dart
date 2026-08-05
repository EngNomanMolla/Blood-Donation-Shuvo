import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/donor_repository.dart';
import '../../more/controllers/more_controller.dart';

class VolunteerRegistrationController extends GetxController {
  final DonorRepository donorRepository;

  VolunteerRegistrationController({required this.donorRepository});

  final fullNameController = TextEditingController();
  final mobileController = TextEditingController(text: '+88 01');
  final emailController = TextEditingController();
  final dobController = TextEditingController();

  final selectedGender = ''.obs;
  final selectedBloodGroup = ''.obs;
  final selectedDistrict = ''.obs;
  final selectedUpazila = ''.obs;
  final selectedThana = ''.obs;
  
  // Extra feature requested: Dual role support
  final isAlsoDonor = false.obs;
  final isLoading = false.obs;

  final genderOptions = ['Male', 'Female', 'Other'];
  final bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final districtOptions = ['Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet'];
  final upazilaOptions = ['Upazila 1', 'Upazila 2', 'Upazila 3'];
  final thanaOptions = ['Thana 1', 'Thana 2', 'Thana 3'];

  @override
  void onInit() {
    super.onInit();
    final storage = Get.find<StorageService>();
    if (storage.userPhone != null && storage.userPhone!.isNotEmpty) {
      mobileController.text = storage.userPhone!;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    dobController.dispose();
    super.onClose();
  }

  void onRegister() async {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your full name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedGender.value.isEmpty) {
      Get.snackbar('Error', 'Please select your gender',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (mobileController.text.trim().isEmpty || mobileController.text.trim() == '+88 01') {
      Get.snackbar('Error', 'Please enter your active mobile number',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedBloodGroup.value.isEmpty) {
      Get.snackbar('Error', 'Please select your blood group',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedDistrict.value.isEmpty) {
      Get.snackbar('Error', 'Please select your district',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedUpazila.value.isEmpty) {
      Get.snackbar('Error', 'Please select your upazila',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (dobController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please select your date of birth',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final storage = Get.find<StorageService>();
      final isDonorValue = isAlsoDonor.value || storage.isDonor;

      final body = {
        "name": fullNameController.text.trim(),
        "gender": selectedGender.value.toLowerCase(),
        "phone": mobileController.text.trim(),
        "blood_group": selectedBloodGroup.value,
        "district": selectedDistrict.value,
        "upazila": selectedUpazila.value,
        "address": "${selectedThana.value.isNotEmpty ? "${selectedThana.value}, " : ""}${selectedUpazila.value}, ${selectedDistrict.value}",
        "email": emailController.text.trim(),
        "date_of_birth": dobController.text.trim(),
        "donations_count": 0,
        "is_donor": isDonorValue,
        "is_volunteer": true
      };

      debugPrint("Volunteer Registration API Debug - Sending Payload: $body");
      final response = await donorRepository.registerDonor(body);
      debugPrint("Volunteer Registration API Debug - Response Code: ${response.statusCode}");
      debugPrint("Volunteer Registration API Debug - Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String successMsg = isAlsoDonor.value 
            ? 'Registered as Volunteer and Donor Successful!' 
            : 'Volunteer Registration Complete!';

        // Save to Storage
        await storage.setIsVolunteer(true);
        if (isAlsoDonor.value) {
          await storage.setIsDonor(true);
        }

        // Refresh MoreController profile details
        try {
          if (Get.isRegistered<MoreController>()) {
            Get.find<MoreController>().fetchUserProfile();
          }
        } catch (e) {
          debugPrint("Error refreshing profile: $e");
        }

        Get.snackbar('Success', successMsg,
            backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
        
        // Auto-navigate back after a brief delay
        Future.delayed(const Duration(seconds: 2), () => Get.back());
      } else {
        Get.snackbar('Error', 'Failed to register: ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Volunteer Registration API Debug - Error: $e");
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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

  void toggleAlsoDonor(bool? value) {
    if (value != null) {
      isAlsoDonor.value = value;
    }
  }
}
