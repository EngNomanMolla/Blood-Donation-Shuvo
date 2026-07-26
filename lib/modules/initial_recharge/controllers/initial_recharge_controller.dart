import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/wallet_repository.dart';

class InitialRechargeController extends GetxController {
  final WalletRepository walletRepository;

  InitialRechargeController({required this.walletRepository});

  final amountController = TextEditingController(text: '50');
  final transactionIdController = TextEditingController();
  final senderNumberController = TextEditingController(text: '+88 01');
  final noteController = TextEditingController(text: 'Initial recharge payment');

  final selectedMethod = 'bkash'.obs; // bkash, nagad, rocket
  final isLoading = false.obs;

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
        final storage = Get.find<StorageService>();
        await storage.setHasRecharged(true);

        Get.offAllNamed(AppRoutes.home);
        Get.snackbar('Success', 'Initial recharge completed successfully!',
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
