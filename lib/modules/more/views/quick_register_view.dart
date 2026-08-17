import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/services/storage_service.dart';
import '../../../data/providers/donor_provider.dart';
import '../../../data/repositories/donor_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controllers/more_controller.dart';

/// Shown when a user already has data from one role (donor/volunteer)
/// and wants to register for the other role without re-filling the form.
class QuickRegisterView extends StatelessWidget {
  const QuickRegisterView({super.key});

  static const Color _red = Color(0xFFE8285A);
  static const Color _purple = Color(0xFF673AB7);
  static const Color _lightBg = Color(0xFFF9F9FB);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final targetRole = args['targetRole'] as String? ?? 'donor';

    final isDonorTarget = targetRole == 'donor';
    final isVolunteerRequest = targetRole == 'volunteer';
    final primaryColor = isDonorTarget ? _red : _purple;
    final targetLabel = isDonorTarget ? 'Donor' : 'Volunteer';
    final existingLabel = isDonorTarget ? 'Volunteer' : 'Donor';
    final targetIcon = isDonorTarget ? Icons.water_drop_rounded : Icons.volunteer_activism_rounded;

    final storage = Get.find<StorageService>();

    return Scaffold(
      backgroundColor: _lightBg,
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 24,
              left: 12,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Become a $targetLabel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // ── Illustration ──
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(targetIcon, size: 48, color: primaryColor),
                  ),
                  const SizedBox(height: 28),

                  // ── Info card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Checkmark badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Already a $existingLabel',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Your profile data is already on file!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Since you\'re already registered as a $existingLabel, we have all the information we need. You can become a $targetLabel with just one tap — no form required!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Benefit chips ──
                        _buildBenefitRow(
                          icon: Icons.flash_on_rounded,
                          color: primaryColor,
                          text: 'Instant registration — no extra forms',
                        ),
                        const SizedBox(height: 10),
                        _buildBenefitRow(
                          icon: Icons.sync_rounded,
                          color: primaryColor,
                          text: 'Your existing data is reused automatically',
                        ),
                        const SizedBox(height: 10),
                        _buildBenefitRow(
                          icon: Icons.verified_rounded,
                          color: primaryColor,
                          text: 'Profile stays consistent across both roles',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Confirm/Next Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isVolunteerRequest) {
                          _showVolunteerPaymentSheet(context, storage, primaryColor);
                        } else {
                          _onConfirm(storage, targetRole, primaryColor);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(targetIcon, size: 20),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              isVolunteerRequest ? 'Next' : 'Confirm — Become a $targetLabel',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Maybe later',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  void _showVolunteerPaymentSheet(BuildContext context, StorageService storage, Color primaryColor) {
    final selectedMethod = 'bkash'.obs;
    final senderNumberController = TextEditingController(text: storage.userPhone ?? '+88 01');
    final transactionIdController = TextEditingController();
    final isSubmitting = false.obs;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Volunteer Payment',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Please send a fixed amount of ৳100 to any of the numbers below and enter the payment details.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Payment Numbers
              Obx(() => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedMethod.value == 'bkash'
                                ? 'Send Money (Personal) to: 01700-000000'
                                : selectedMethod.value == 'nagad'
                                    ? 'Send Money (Personal) to: 01800-000000'
                                    : 'Send Money (Personal) to: 01900-000000',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),

              // Method Selector
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildMethodCard('bkash', 'bKash', const Color(0xFFE2125D), selectedMethod),
                  const SizedBox(width: 8),
                  _buildMethodCard('nagad', 'Nagad', const Color(0xFFF7941D), selectedMethod),
                  const SizedBox(width: 8),
                  _buildMethodCard('rocket', 'Rocket', const Color(0xFF8C3494), selectedMethod),
                ],
              ),
              const SizedBox(height: 20),

              // Read-only Amount
              const Text(
                'Payment Amount',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: '৳ 100'),
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sender Number
              const Text(
                'Sender Mobile Number',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: senderNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. 017XXXXXXXX',
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Transaction ID
              const Text(
                'Transaction ID',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: transactionIdController,
                decoration: InputDecoration(
                  hintText: 'e.g. TRX12345678',
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(() => ElevatedButton(
                  onPressed: isSubmitting.value
                      ? null
                      : () => _submitVolunteerPayment(
                            context,
                            storage,
                            selectedMethod.value,
                            senderNumberController.text.trim(),
                            transactionIdController.text.trim(),
                            isSubmitting,
                            primaryColor,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Payment Request',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMethodCard(String value, String label, Color color, RxString selectedMethod) {
    return Expanded(
      child: Obx(() {
        final isSelected = selectedMethod.value == value;
        return GestureDetector(
          onTap: () => selectedMethod.value = value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _submitVolunteerPayment(
    BuildContext context,
    StorageService storage,
    String method,
    String senderNumber,
    String transactionId,
    RxBool isSubmitting,
    Color primaryColor,
  ) async {
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

    isSubmitting.value = true;
    try {
      final donorProvider = Get.put(DonorProvider());
      final donorRepository = Get.put(DonorRepository(donorProvider));

      final body = {
        "amount": 100.00,
        "method": method,
        "transaction_id": transactionId,
        "sender_number": senderNumber,
      };

      final response = await donorRepository.volunteerRequest(body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await storage.setIsVolunteer(true);

        try {
          if (Get.isRegistered<MoreController>()) {
            Get.find<MoreController>().fetchUserProfile();
          }
        } catch (_) {}

        Get.back(); // Dismiss bottom sheet
        Get.back(); // Dismiss QuickRegisterView

        Get.snackbar(
          '🎉 Success',
          'Volunteer request submitted successfully for approval!',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit request: ${response.body}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _onConfirm(StorageService storage, String targetRole, Color color) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final profileRepository = Get.find<ProfileRepository>();
      final donorProvider = Get.put(DonorProvider());
      final donorRepository = Get.put(DonorRepository(donorProvider));

      final profile = await profileRepository.getProfile();
      if (profile == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to retrieve profile data from server. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final body = {
        "name": profile.name,
        "gender": profile.gender ?? '',
        "phone": profile.phone ?? '',
        "blood_group": profile.bloodGroup ?? '',
        "division": profile.division ?? '',
        "district": profile.district ?? '',
        "upazila": profile.upazila ?? '',
        "address": profile.upazila != null && profile.district != null
            ? "${profile.upazila}, ${profile.district}"
            : (profile.division ?? ''),
        "email": profile.email ?? '',
        "date_of_birth": profile.dateOfBirth ?? '',
        "donations_count": 0,
        "is_donor": true,
        "is_volunteer": true,
      };

      final response = await donorRepository.registerDonor(body);

      Get.back();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (targetRole == 'donor') {
          await storage.setIsDonor(true);
        } else {
          await storage.setIsVolunteer(true);
        }

        Get.back();

        final label = targetRole == 'donor' ? 'Donor' : 'Volunteer';
        Get.snackbar(
          '🎉 Congratulations!',
          'You are now registered as a $label.',
          backgroundColor: color,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to register: ${response.body}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
