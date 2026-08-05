import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/repositories/profile_repository.dart';

class InitialRechargeController extends GetxController {
  final WalletRepository walletRepository;

  InitialRechargeController({required this.walletRepository});

  final amountController = TextEditingController(text: '50');
  final transactionIdController = TextEditingController();
  final senderNumberController = TextEditingController(text: '+88 01');
  final noteController = TextEditingController(text: 'Initial recharge payment');

  final selectedMethod = 'bkash'.obs; // bkash, nagad, rocket
  final isLoading = false.obs;

  // Recharge status state machine: 'initial', 'pending', 'rejected'
  final rechargeStatus = 'initial'.obs;
  final rejectReason = ''.obs;
  final rechargeAmount = 50.0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Auto-fill phone number if available in storage
    final storage = Get.find<StorageService>();
    if (storage.userPhone != null && storage.userPhone!.isNotEmpty) {
      senderNumberController.text = storage.userPhone!;
    }
    
    fetchInitialRechargeStatus(showFeedback: false);
  }

  Future<void> fetchInitialRechargeStatus({bool showFeedback = false}) async {
    isLoading.value = true;
    try {
      final profileRepository = Get.find<ProfileRepository>();
      final profile = await profileRepository.getProfile();
      if (profile != null) {
        final storage = Get.find<StorageService>();
        await storage.setHasRecharged(profile.hasCompletedInitialRecharge);

        if (profile.initialRechargeStatus == 'approved' || profile.hasCompletedInitialRecharge) {
          if (showFeedback) {
            Get.snackbar('Success', 'Verification approved! Welcome to Blood Donation.',
                backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
          }
          Get.offAllNamed(AppRoutes.home);
          return;
        }

        rechargeAmount.value = profile.initialRechargeAmount > 0 ? profile.initialRechargeAmount : 50.0;
        rejectReason.value = profile.initialRechargeRejectReason ?? '';
        
        if (profile.initialRechargeStatus == 'pending') {
          rechargeStatus.value = 'pending';
          if (showFeedback) {
            Get.snackbar('Status Check', 'Your recharge verification is still pending review.',
                backgroundColor: Colors.amber, colorText: Colors.black);
          }
        } else if (profile.initialRechargeStatus == 'rejected') {
          rechargeStatus.value = 'rejected';
          if (showFeedback) {
            Get.snackbar('Status Check', 'Your recharge verification was rejected.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
          }
        } else {
          rechargeStatus.value = 'initial';
        }
      } else {
        if (showFeedback) {
          Get.snackbar('Error', 'Failed to fetch user status from server.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      }
    } catch (e) {
      debugPrint("Error fetching initial recharge status: $e");
      if (showFeedback) {
        Get.snackbar('Error', 'An error occurred while connecting to server.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    transactionIdController.dispose();
    senderNumberController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void selectMethod(String method) {
    selectedMethod.value = method;
  }

  Future<void> onRecharge() async {
    final amountText = amountController.text.trim();
    final transactionId = transactionIdController.text.trim();
    final senderNumber = senderNumberController.text.trim();
    final note = noteController.text.trim();

    if (amountText.isEmpty) {
      Get.snackbar('Error', 'Please enter recharge amount',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount < 1.0) {
      Get.snackbar('Error', 'Amount must be at least ৳ 1',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (transactionId.isEmpty) {
      Get.snackbar('Error', 'Please enter transaction ID',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (senderNumber.isEmpty || senderNumber == '+88 01') {
      Get.snackbar('Error', 'Please enter sender mobile number',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await walletRepository.recharge(
        method: selectedMethod.value,
        amount: amount,
        transactionId: transactionId,
        senderNumber: senderNumber,
        note: note.isNotEmpty ? note : null,
      );

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) {
        rechargeStatus.value = 'pending';
        Get.snackbar('Success', 'Initial recharge submitted successfully!',
            backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Recharge failed: ${response.body}',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
