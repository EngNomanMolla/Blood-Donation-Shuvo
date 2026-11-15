import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/data/bd_locations.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/donor_repository.dart';
import '../../more/controllers/more_controller.dart';
import '../views/volunteer_status_view.dart';

class VolunteerRegistrationController extends GetxController {
  final DonorRepository donorRepository;

  VolunteerRegistrationController({required this.donorRepository});

  final fullNameController = TextEditingController();
  final mobileController = TextEditingController(text: '+88 01');
  final emailController = TextEditingController();
  final dobController = TextEditingController();

  final selectedGender = ''.obs;
  final selectedBloodGroup = ''.obs;
  final selectedDivision = ''.obs;
  final selectedDistrict = ''.obs;
  final selectedUpazila = ''.obs;
  
  // Extra feature requested: Dual role support
  final isAlsoDonor = false.obs;
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

  void onRegister() {
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

    _showPaymentBottomSheet();
  }

  void _showPaymentBottomSheet() {
    final storage = Get.find<StorageService>();
    final selectedMethod = 'bkash'.obs;
    final senderNumberController = TextEditingController(text: storage.userPhone ?? '+88 01');
    final transactionIdController = TextEditingController();
    final amountController = TextEditingController();
    final isSubmitting = false.obs;
    const primaryColor = Color(0xFFE53935);

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.86,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Volunteer Payment',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fee Structure Notice Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, size: 14, color: primaryColor),
                        const SizedBox(width: 4),
                        const Text(
                          'Registration Fee Structure',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _buildFeeRoleBadge('District Head', '৳ 500'),
                        const SizedBox(width: 5),
                        _buildFeeRoleBadge('Upazila Head', '৳ 300'),
                        const SizedBox(width: 5),
                        _buildFeeRoleBadge('Volunteer', '৳ 300'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Please send the designated fee based on your role to the number below.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        color: Colors.grey[600],
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Payment Numbers Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Send Money to:',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '01717006474',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: primaryColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: '01717006474'));
                        Get.snackbar('Copied', 'Payment number copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16));
                      },
                      tooltip: 'Copy Number',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Method Selector
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildMethodCard('bkash', 'bKash', const Color(0xFFE2125D), selectedMethod),
                  const SizedBox(width: 6),
                  _buildMethodCard('nagad', 'Nagad', const Color(0xFFF7941D), selectedMethod),
                  const SizedBox(width: 6),
                  _buildMethodCard('rocket', 'Rocket', const Color(0xFF8C3494), selectedMethod),
                ],
              ),
              const SizedBox(height: 10),

              // Payment Amount
              const Text(
                'Payment Amount',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 6),
                    child: Text(
                      '৳',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 0),
                  hintText: '300',
                  hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Sender Number
              const Text(
                'Sender Mobile Number',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: senderNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. 017XXXXXXXX',
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Transaction ID
              const Text(
                'Transaction ID',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: transactionIdController,
                decoration: InputDecoration(
                  hintText: 'e.g. TRX12345678',
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Obx(() => ElevatedButton(
                  onPressed: isSubmitting.value
                      ? null
                      : () {
                          final rawAmount = amountController.text.trim();
                          if (rawAmount.isEmpty) {
                            Get.snackbar('Error', 'Payment amount is required',
                                backgroundColor: Colors.redAccent, colorText: Colors.white);
                            return;
                          }
                          final enteredAmount = double.tryParse(rawAmount.replaceAll('৳', '').trim()) ?? 0.0;
                          if (enteredAmount <= 0) {
                            Get.snackbar('Error', 'Please enter a valid payment amount',
                                backgroundColor: Colors.redAccent, colorText: Colors.white);
                            return;
                          }
                          _submitVolunteerRequest(
                            amount: enteredAmount,
                            method: selectedMethod.value,
                            senderNumber: senderNumberController.text.trim(),
                            transactionId: transactionIdController.text.trim(),
                            isSubmitting: isSubmitting,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Payment Request',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFeeRoleBadge(String title, String amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Column(
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              amount,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(String value, String label, Color color, RxString selectedMethod) {
    return Expanded(
      child: Obx(() {
        final isSelected = selectedMethod.value == value;
        return GestureDetector(
          onTap: () => selectedMethod.value = value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _submitVolunteerRequest({
    required double amount,
    required String method,
    required String senderNumber,
    required String transactionId,
    required RxBool isSubmitting,
  }) async {
    if (senderNumber.isEmpty || senderNumber == '+88 01') {
      Get.snackbar('Error', 'Please enter sender mobile number',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (transactionId.isEmpty) {
      Get.snackbar('Error', 'Please enter transaction ID',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid payment amount',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final storage = Get.find<StorageService>();
      final isDonorValue = isAlsoDonor.value || storage.isDonor;

      String dob = dobController.text.trim();
      if (dob.contains('/')) {
        final parts = dob.split('/');
        if (parts.length == 3) {
          dob = '${parts[2]}-${parts[1]}-${parts[0]}'; // YYYY-MM-DD
        }
      }

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
        "date_of_birth": dob,
        "donations_count": 0,
        "is_donor": isDonorValue,
        "is_volunteer": true,
        "amount": amount,
        "method": method,
        "transaction_id": transactionId,
        "sender_number": senderNumber,
      };

      debugPrint("Volunteer Registration API Debug - Sending Payload: $body");
      final response = await donorRepository.volunteerRequest(body);
      debugPrint("Volunteer Registration API Debug - Response Code: ${response.statusCode}");
      debugPrint("Volunteer Registration API Debug - Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String successMsg = isAlsoDonor.value 
            ? 'Registered as Volunteer and Donor Successful!' 
            : 'Volunteer Request Complete!';

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

        Get.back(); // Dismiss bottom sheet
        Get.off(() => const VolunteerStatusView(status: 'pending'));

        Get.snackbar('Success', successMsg,
            backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Failed to register: ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Volunteer Registration API Debug - Error: $e");
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
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

  Future<void> fetchDivisionsList() async {
    isDivisionsLoading.value = true;
    try {
      divisions.value = BDLocations.getDivisions();
    } catch (e) {
      Get.printError(info: "Error fetching divisions list: $e");
    } finally {
      isDivisionsLoading.value = false;
    }
  }

  Future<void> fetchDistrictsList(String division) async {
    isDistrictsLoading.value = true;
    try {
      districts.value = BDLocations.getDistricts(division);
    } catch (e) {
      Get.printError(info: "Error fetching districts list for $division: $e");
    } finally {
      isDistrictsLoading.value = false;
    }
  }

  Future<void> fetchUpazilasList(String district) async {
    isUpazilasLoading.value = true;
    try {
      upazilas.value = BDLocations.getUpazilasByDivisionAndDistrict(
          selectedDivision.value, district);
    } catch (e) {
      Get.printError(info: "Error fetching upazilas list for $district: $e");
    } finally {
      isUpazilasLoading.value = false;
    }
  }
}
