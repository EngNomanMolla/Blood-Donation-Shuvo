import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/modules/performance/models/performance_model.dart';

class VolunteerWalletController extends GetxController {
  // ── Wallet Balance ───────────────────────────────────────────────────────
  final RxString walletBalance = '500'.obs;
  final RxString totalEarning = '1500'.obs;
  final RxString totalWithdraw = '1000'.obs;

  // ── Donation Info (Migrated from Performance) ────────────────────────────
  final DonationInfoModel donationInfo = const DonationInfoModel(
    lastDonation: '60 Days Ago',
    nextDonationDate: '24 Jun 2026',
  );

  // ── Transactions (Migrated from Performance) ─────────────────────────────
  final List<TransactionModel> transactions = [
    TransactionModel(
      type: 'Withdraw',
      transactionId: '1623831436',
      status: TransactionStatus.pending,
      amount: '1000',
      isCredit: true,
      date: DateTime(2025, 7, 21, 8, 56),
    ),
    TransactionModel(
      type: 'Recharge',
      transactionId: '1623831436',
      status: TransactionStatus.accepted,
      amount: '100',
      isCredit: false,
      date: DateTime(2025, 7, 25, 8, 56),
    ),
    TransactionModel(
      type: 'Withdraw',
      transactionId: '1623831436',
      status: TransactionStatus.successful,
      amount: '1000',
      isCredit: true,
      date: DateTime(2025, 7, 21, 8, 56),
    ),
  ];

  void onWithdraw() {
    // Implement withdraw logic
    Get.snackbar(
      'Withdraw',
      'Withdrawal process initiated for ৳${walletBalance.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.1),
      colorText: Colors.green[800],
    );
  }
}
