import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/donor_repository.dart';
import '../../more/controllers/more_controller.dart';
 
// ─── GetX Controller ────────────────────────────────────────────────────────
 
class RegistrationController extends GetxController {
  final DonorRepository donorRepository;

  RegistrationController({required this.donorRepository});

  final fullNameController = TextEditingController();
  final mobileController = TextEditingController(text: '+88 01');
  final emailController = TextEditingController();
  final dobController = TextEditingController();
 
  final selectedGender = ''.obs;
  final selectedBloodGroup = ''.obs;
  final selectedDivision = ''.obs;
  final selectedDistrict = ''.obs;
  final selectedUpazila = ''.obs;
  final isLoading = false.obs;

  // Geographical lists & loading flags
  final divisions = <String>[].obs;
  final districts = <String>[].obs;
  final upazilas = <String>[].obs;
  final isDivisionsLoading = false.obs;
  final isDistrictsLoading = false.obs;
  final isUpazilasLoading = false.obs;
 
  final genderOptions = ['Male', 'Female', 'Other'];
  final bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void onInit() {
    super.onInit();
    final storage = Get.find<StorageService>();
    if (storage.userPhone != null && storage.userPhone!.isNotEmpty) {
      mobileController.text = storage.userPhone!;
    }
    
    // Listen to changes in division
    ever(selectedDivision, (String division) {
      selectedDistrict.value = '';
      selectedUpazila.value = '';
      districts.clear();
      upazilas.clear();
      if (division.isNotEmpty) {
        fetchDistrictsList(division);
      }
    });

    // Listen to changes in district
    ever(selectedDistrict, (String district) {
      selectedUpazila.value = '';
      upazilas.clear();
      if (district.isNotEmpty) {
        fetchUpazilasList(district);
      }
    });

    fetchDivisionsList();
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
    if (selectedDivision.value.isEmpty) {
      Get.snackbar('Error', 'Please select your division',
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
      final token = storage.userToken;
      debugPrint("Donor Registration API Debug - Current Token: '$token'");

      final body = {
        "name": fullNameController.text.trim(),
        "gender": selectedGender.value.toLowerCase(),
        "phone": mobileController.text.trim(),
        "blood_group": selectedBloodGroup.value,
        "division": selectedDivision.value,
        "district": selectedDistrict.value,
        "upazila": selectedUpazila.value,
        "address": "${selectedUpazila.value}, ${selectedDistrict.value}, ${selectedDivision.value}",
        "email": emailController.text.trim(),
        "date_of_birth": dobController.text.trim(),
        "donations_count": 0,
        "is_donor": true,
        "is_volunteer": storage.isVolunteer
      };

      debugPrint("Donor Registration API Debug - Sending Payload: $body");
      final response = await donorRepository.registerDonor(body);
      debugPrint("Donor Registration API Debug - Response Code: ${response.statusCode}");
      debugPrint("Donor Registration API Debug - Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Save to Storage
        await storage.setIsDonor(true);

        // Refresh MoreController profile details
        try {
          if (Get.isRegistered<MoreController>()) {
            Get.find<MoreController>().fetchUserProfile();
          }
        } catch (e) {
          debugPrint("Error refreshing profile: $e");
        }

        Get.snackbar('Success', 'Registration Complete!',
            backgroundColor: const Color(0xFFE8285A), colorText: Colors.white);

        // Auto-navigate back after a brief delay
        Future.delayed(const Duration(seconds: 2), () => Get.back());
      } else {
        Get.snackbar('Error', 'Failed to register: ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Donor Registration API Debug - Error: $e");
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

  Future<void> fetchDivisionsList() async {
    isDivisionsLoading.value = true;
    try {
      final response = await http.get(Uri.parse(ApiConstants.bdApisDivisions));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        divisions.value = listData
            .map((e) => e['division'] as String)
            .toList()
          ..sort();
      }
    } catch (e) {
      Get.printError(info: "Error fetching divisions list from bdapis: $e");
    } finally {
      isDivisionsLoading.value = false;
    }
  }

  Future<void> fetchDistrictsList(String division) async {
    isDistrictsLoading.value = true;
    try {
      final response = await http.get(Uri.parse('${ApiConstants.bdApisDivisionDetail}/$division'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        districts.value = listData
            .map((e) => e['district'] as String)
            .toList()
          ..sort();
      }
    } catch (e) {
      Get.printError(info: "Error fetching districts list for $division from bdapis: $e");
    } finally {
      isDistrictsLoading.value = false;
    }
  }

  Future<void> fetchUpazilasList(String district) async {
    isUpazilasLoading.value = true;
    try {
      final response = await http.get(Uri.parse('${ApiConstants.bdApisDistrictDetail}/$district'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        if (listData.isNotEmpty) {
          final List<dynamic> ups = listData[0]['upazillas'] ?? [];
          upazilas.value = ups.map((e) => e.toString()).toList()..sort();
        }
      }
    } catch (e) {
      Get.printError(info: "Error fetching upazilas list for $district from bdapis: $e");
    } finally {
      isUpazilasLoading.value = false;
    }
  }
}