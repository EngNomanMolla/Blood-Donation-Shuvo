import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../more/controllers/more_controller.dart';

class VolunteerStatusView extends GetView<MoreController> {
  final String status;
  const VolunteerStatusView({super.key, required this.status});

  static const _primaryRed = Color(0xFFE53935);
  static const _darkRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: Text(
          isPending ? 'Verification Pending' : 'Request Rejected',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Stack(
        children: [
          // Background circles
          _buildBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.amber.shade50 : Colors.red.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPending ? Colors.amber.shade200 : Colors.red.shade200,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isPending ? Icons.hourglass_empty_rounded : Icons.cancel_rounded,
                      color: isPending ? Colors.amber.shade700 : Colors.red,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    isPending ? 'Verification Pending' : 'Volunteer Request Rejected',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    isPending
                        ? 'Your volunteer activation request has been submitted and is currently pending review by the administrator. Verification usually takes a few minutes.'
                        : 'Your volunteer registration request was rejected by the administrator. Please make sure payment details were correct and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 48),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              await controller.fetchUserProfile();
                              if (controller.volunteerPaymentStatus.value == 'approved' || controller.isVolunteer.value) {
                                Get.back();
                                Get.snackbar('Success', 'Volunteer verification approved!',
                                    backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
                              } else if (controller.volunteerPaymentStatus.value != status) {
                                Get.back();
                                controller.handleBecomeVolunteer();
                              } else {
                                Get.snackbar(
                                  'Status Check',
                                  isPending 
                                      ? 'Your status is still pending review.' 
                                      : 'Your status is still rejected.',
                                  backgroundColor: isPending ? Colors.amber : Colors.redAccent,
                                  colorText: isPending ? Colors.black : Colors.white,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Icon(isPending ? Icons.refresh_rounded : Icons.edit_note_rounded, size: 20),
                      label: Text(
                        isPending ? 'Check Verification Status' : 'Try Again / Submit New Request',
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryRed.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _darkRed.withValues(alpha: 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
