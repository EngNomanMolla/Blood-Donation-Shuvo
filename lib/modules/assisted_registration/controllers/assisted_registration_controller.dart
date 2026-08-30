import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/donor_repository.dart';

class AssistedRegistrationController extends GetxController {
  final AuthRepository authRepository;
  final DonorRepository donorRepository;

  AssistedRegistrationController({
    required this.authRepository,
    required this.donorRepository,
  });

  // Mobile Verification Fields (First as requested)
  final mobileController = TextEditingController(text: '+88 01');
  final verificationCodeController = TextEditingController();

  // Donor Details Fields
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();

  final selectedGender = ''.obs;
  final selectedBloodGroup = ''.obs;
  final selectedDivision = ''.obs;
  final selectedDistrict = ''.obs;
  final selectedUpazila = ''.obs;

  // Geographical lists & loading flags
  final divisions = <String>[].obs;
  final districts = <String>[].obs;
  final upazilas = <String>[].obs;
  final isDivisionsLoading = false.obs;
  final isDistrictsLoading = false.obs;
  final isUpazilasLoading = false.obs;

  final genderOptions = ['Male', 'Female', 'Other'];
  final bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  final isSendingCode = false.obs;
  final isRegistering = false.obs;

  @override
  void onInit() {
    super.onInit();
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
    mobileController.dispose();
    verificationCodeController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    super.onClose();
  }

  void onSendCode() async {
    String phone = mobileController.text.trim();
    // Strip spaces if any
    phone = phone.replaceAll(' ', '');
    // Standard validation
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Please enter a mobile number',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSendingCode.value = true;
    try {
      final response = await authRepository.volunteerSendCode(phone);
      debugPrint("Volunteer Send Code API Response Code: ${response.statusCode}");
      debugPrint("Volunteer Send Code API Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar('Code Sent', 'Verification code has been sent successfully',
            backgroundColor: const Color(0xFFE53935), colorText: Colors.white);

        // Auto-fill OTP from response
        try {
          final decoded = jsonDecode(response.body);
          String? otpCode;
          if (decoded != null) {
            if (decoded['code'] != null) {
              otpCode = decoded['code'].toString();
            } else if (decoded['otp'] != null) {
              otpCode = decoded['otp'].toString();
            } else if (decoded['data'] is Map && decoded['data']['code'] != null) {
              otpCode = decoded['data']['code'].toString();
            } else if (decoded['data'] is Map && decoded['data']['otp'] != null) {
              otpCode = decoded['data']['otp'].toString();
            }
          }

          if (otpCode != null && otpCode.isNotEmpty) {
            verificationCodeController.text = otpCode;
            debugPrint("Auto-filled OTP Code: $otpCode");
          } else {
            // Regexp fallback to find any 4-6 digit number in response body
            final reg = RegExp(r'\b\d{4,6}\b');
            final match = reg.firstMatch(response.body);
            if (match != null) {
              final val = match.group(0);
              if (val != null) {
                verificationCodeController.text = val;
                debugPrint("Auto-filled OTP Code via Regex: $val");
              }
            }
          }
        } catch (e) {
          debugPrint("Failed to parse OTP from response: $e");
        }
      } else {
        Get.snackbar('Error', 'Failed to send verification code: ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSendingCode.value = false;
    }
  }

  void onRegister() async {
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
    if (selectedGender.value.isEmpty) {
      Get.snackbar('Error', 'Please select gender', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedBloodGroup.value.isEmpty) {
      Get.snackbar('Error', 'Please select blood group', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedDivision.value.isEmpty) {
      Get.snackbar('Error', 'Please select division', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedDistrict.value.isEmpty) {
      Get.snackbar('Error', 'Please select district', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedUpazila.value.isEmpty) {
      Get.snackbar('Error', 'Please select upazila', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (dobController.text.isEmpty) {
      Get.snackbar('Error', 'Date of birth is required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isRegistering.value = true;
    
    // Convert date of birth format to YYYY-MM-DD if it contains '/'
    String dob = dobController.text.trim();
    if (dob.contains('/')) {
      final parts = dob.split('/');
      if (parts.length == 3) {
        dob = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    final body = {
      "phone": mobileController.text.replaceAll(' ', ''),
      "code": verificationCodeController.text.trim(),
      "name": fullNameController.text.trim(),
      "gender": selectedGender.value.toLowerCase(),
      "blood_group": selectedBloodGroup.value,
      "district": selectedDistrict.value,
      "upazila": selectedUpazila.value,
      "address": "${selectedUpazila.value}, ${selectedDistrict.value}, ${selectedDivision.value}",
      "email": emailController.text.trim(),
      "date_of_birth": dob,
    };

    debugPrint("Volunteer Register Donor API debug - Payload: $body");

    try {
      final response = await donorRepository.volunteerRegisterDonor(body);
      debugPrint("Volunteer Register Donor API debug - Code: ${response.statusCode}");
      debugPrint("Volunteer Register Donor API debug - Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar('Success', 'Donor Registration Successfully Completed!',
            backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
        Future.delayed(const Duration(seconds: 2), () => Get.back());
      } else {
        final decoded = jsonDecode(response.body);
        final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Registration failed';
        Get.snackbar('Error', errorMsg.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isRegistering.value = false;
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
