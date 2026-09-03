import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/modules/performance/models/performance_model.dart';
import '../../../data/repositories/wallet_repository.dart';

class VolunteerWalletController extends GetxController {
  final WalletRepository walletRepository;

  VolunteerWalletController({required this.walletRepository});

  // ── Wallet Balance ───────────────────────────────────────────────────────
  final RxString walletBalance = '0'.obs;
  final RxString totalEarning = '0'.obs;
  final RxString totalWithdraw = '0'.obs;
  
  final RxString activeTab = 'transactions'.obs;
  final RxBool isLoading = false.obs;

  // ── Transactions ────────────────────────────────────────────────────────
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  // ── Withdrawals ─────────────────────────────────────────────────────────
  final RxList<WithdrawalModel> withdrawals = <WithdrawalModel>[].obs;
  final RxBool isWithdrawalsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletDetails();
    fetchWithdrawals();
  }

  Future<void> fetchWalletDetails() async {
    isLoading.value = true;
    try {
      final response = await walletRepository.getVolunteerWallet();
      debugPrint("Volunteer Wallet API Response Code: ${response.statusCode}");
      debugPrint("Volunteer Wallet API Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        final double balanceVal = (decoded['balance'] ?? 0).toDouble();
        final double totalEarningVal = (decoded['earnings'] ?? decoded['total_earning'] ?? decoded['total_earnings'] ?? 0).toDouble();
        final double totalWithdrawVal = (decoded['withdrawals'] ?? decoded['total_withdraw'] ?? decoded['total_withdraws'] ?? decoded['total_withdrawal'] ?? decoded['withdraws'] ?? 0).toDouble();

        walletBalance.value = balanceVal.toStringAsFixed(0);
        totalEarning.value = totalEarningVal.toStringAsFixed(0);
        totalWithdraw.value = totalWithdrawVal.toStringAsFixed(0);

        final dynamic txData = decoded['transactions'];
        final List<dynamic> txList = (txData is Map) ? (txData['data'] ?? []) : (txData is List ? txData : []);
        final mappedTx = txList.map((tx) {
          final double amountVal = (tx['amount'] ?? 0).toDouble();
          final String typeVal = tx['type'] ?? 'Withdraw';
          final String statusVal = tx['status'] ?? 'pending';
          final String txId = (tx['transaction_id'] ?? tx['id'] ?? '').toString();
          
          DateTime dateVal;
          if (tx['created_at'] != null) {
            try {
              dateVal = DateTime.parse(tx['created_at']);
            } catch (_) {
              dateVal = DateTime.now();
            }
          } else {
            dateVal = DateTime.now();
          }

          TransactionStatus statusEnum;
          if (statusVal == 'accepted') {
            statusEnum = TransactionStatus.accepted;
          } else if (statusVal == 'successful' || statusVal == 'completed' || statusVal == 'approved' || statusVal == 'success') {
            statusEnum = TransactionStatus.successful;
          } else {
            statusEnum = TransactionStatus.pending;
          }

          final t = typeVal.toLowerCase();
          final isCredit = t.contains('recharge') ||
              t.contains('deposit') ||
              t.contains('earning') ||
              t.contains('commission') ||
              t.contains('referral') ||
              t.contains('bonus') ||
              t.contains('reward') ||
              t.contains('cashback') ||
              t == 'credit' ||
              t == 'income';

          return TransactionModel(
            type: typeVal.capitalizeFirst ?? 'Transaction',
            transactionId: txId,
            status: statusEnum,
            amount: amountVal.toStringAsFixed(0),
            isCredit: isCredit,
            date: dateVal,
          );
        }).toList();

        transactions.assignAll(mappedTx);
      } else {
        Get.snackbar('Error', 'Failed to fetch wallet details',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error fetching volunteer wallet: $e");
      Get.snackbar('Error', 'An error occurred while loading wallet details',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  final RxBool isWithdrawing = false.obs;

  Future<bool> submitWithdraw({
    required double amount,
    required String method,
    required String accountNumber,
    required String note,
  }) async {
    isWithdrawing.value = true;
    try {
      final body = {
        "amount": amount,
        "method": method.toLowerCase(),
        "account_number": accountNumber,
        "note": note,
      };

      final response = await walletRepository.volunteerWithdraw(body);
      debugPrint("Volunteer Withdraw API Response Code: ${response.statusCode}");
      debugPrint("Volunteer Withdraw API Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Withdrawal request submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
        fetchWalletDetails(); // Refresh balance & transactions
        fetchWithdrawals(); // Refresh withdrawals history
        return true;
      } else {
        String errorMsg = 'Failed to submit withdrawal request';
        try {
          final Map<String, dynamic> decoded = jsonDecode(response.body);
          errorMsg = decoded['message'] ?? decoded['error'] ?? errorMsg;
        } catch (_) {}
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint("Error submitting volunteer withdraw: $e");
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isWithdrawing.value = false;
    }
  }

  Future<void> fetchWithdrawals() async {
    isWithdrawalsLoading.value = true;
    try {
      final response = await walletRepository.getWithdrawals();
      debugPrint("Volunteer Withdrawals API Response Code: ${response.statusCode}");
      debugPrint("Volunteer Withdrawals API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dynamic outerData = decoded['data'];
        final List<dynamic> dataList = (outerData is Map) ? (outerData['data'] ?? []) : [];

        final mappedWithdrawals = dataList.map((item) {
          final int idVal = item['id'] ?? 0;
          final double amountVal = (item['amount'] ?? 0).toDouble();
          final String methodVal = item['method'] ?? '';
          final String accountVal = item['account_number'] ?? '';
          final String? noteVal = item['note'];
          final String statusVal = item['status'] ?? 'pending';
          final String? adminNoteVal = item['admin_note'];
          
          DateTime dateVal;
          if (item['created_at'] != null) {
            try {
              dateVal = DateTime.parse(item['created_at']);
            } catch (_) {
              dateVal = DateTime.now();
            }
          } else {
            dateVal = DateTime.now();
          }

          return WithdrawalModel(
            id: idVal,
            amount: amountVal,
            method: methodVal,
            accountNumber: accountVal,
            note: noteVal,
            status: statusVal,
            adminNote: adminNoteVal,
            createdAt: dateVal,
          );
        }).toList();

        withdrawals.assignAll(mappedWithdrawals);
      } else {
        Get.snackbar('Error', 'Failed to fetch withdrawals history',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error fetching withdrawals history: $e");
      Get.snackbar('Error', 'An error occurred while loading withdrawals history',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isWithdrawalsLoading.value = false;
    }
  }
}
