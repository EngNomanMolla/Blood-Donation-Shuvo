import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../models/wallet_model.dart';

class WalletController extends GetxController {
  final WalletRepository walletRepository;

  WalletController({required this.walletRepository});

  final isLoading = false.obs;
  final walletBalance = Rxn<WalletBalanceModel>();
  final transactions = <WalletTransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletDetails();
  }

  Future<void> fetchWalletDetails() async {
    isLoading.value = true;
    try {
      final response = await walletRepository.getWallet();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        final double balanceVal = (decoded['balance'] ?? 0).toDouble();
        walletBalance.value = WalletBalanceModel(
          balance: '৳ ${balanceVal.toStringAsFixed(0)}',
          totalPoints: 0,
        );

        final List<dynamic> txList = decoded['transactions'] ?? [];
        final mappedTx = txList.map((tx) {
          final double amountVal = (tx['amount'] ?? 0).toDouble();
          final String typeVal = tx['type'] ?? 'recharge';
          final String descVal = tx['description'] ?? '';
          final String dateVal = formatDate(tx['created_at']);
          final String statusVal = tx['status'] ?? 'completed';
          
          final isCredit = typeVal == 'recharge' || typeVal == 'deposit';

          return WalletTransactionModel(
            title: typeVal.capitalizeFirst ?? 'Transaction',
            subtitle: descVal.isNotEmpty ? descVal : (typeVal.capitalizeFirst ?? 'Transaction'),
            date: dateVal,
            amount: '৳ ${amountVal.toStringAsFixed(0)}',
            isCredit: isCredit,
            status: statusVal,
          );
        }).toList();

        transactions.assignAll(mappedTx);
      } else {
        Get.snackbar('Error', 'Failed to fetch wallet details',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error fetching wallet details: $e");
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  void onAddMoney() {
    // TODO: navigate to Add Money screen
  }

  void onWithdraw() {
    // TODO: navigate to Withdraw screen
  }
}
