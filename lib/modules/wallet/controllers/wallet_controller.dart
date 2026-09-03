import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../models/wallet_model.dart';

class WalletController extends GetxController {
  final WalletRepository walletRepository;

  WalletController({required this.walletRepository});

  final isLoading = false.obs;
  final walletBalance = Rxn<WalletBalanceModel>();
  final transactions = <WalletTransactionModel>[].obs;

  // Active Subscription Details
  final activeSubscription = Rxn<ActiveSubscriptionModel>();
  final remainingMinutes = Rxn<int>();
  final subscriptionExpiryDate = RxnString();
  final hasActiveSubscription = false.obs;

  // Pending Recharge Details
  final pendingRecharge = Rxn<PendingRechargeModel>();

  @override
  void onInit() {
    super.onInit();
    fetchWalletDetails();
  }

  Future<void> fetchWalletDetails() async {
    isLoading.value = true;
    try {
      // 1. Fetch Active Subscription
      try {
        final subResponse = await walletRepository.getActiveSubscription();
        if (subResponse.statusCode == 200) {
          final subDecoded = jsonDecode(subResponse.body);
          debugPrint("Active Subscription API Response: $subDecoded");
          if (subDecoded['has_active_subscription'] == true && subDecoded['active_subscription'] != null) {
            hasActiveSubscription.value = true;
            final sub = ActiveSubscriptionModel.fromJson(subDecoded['active_subscription']);
            activeSubscription.value = sub;
            remainingMinutes.value = sub.remainingMinutes;
            subscriptionExpiryDate.value = formatDate(sub.expireDate.isNotEmpty ? sub.expireDate : sub.endsAt);
          } else {
            hasActiveSubscription.value = false;
            activeSubscription.value = null;
            remainingMinutes.value = 0;
            subscriptionExpiryDate.value = null;
          }
        }
      } catch (e) {
        debugPrint("Error fetching active subscription: $e");
      }

      // 2. Fetch Wallet Balance & Transactions
      final response = await walletRepository.getWallet();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        debugPrint("Wallet API Response decoded: $decoded");
        
        final double balanceVal = (decoded['balance'] ?? 0).toDouble();
        walletBalance.value = WalletBalanceModel(
          balance: '৳ ${balanceVal.toStringAsFixed(0)}',
          totalPoints: 0,
        );

        // Fallback for subscription if not already loaded from dedicated endpoint
        if (!hasActiveSubscription.value) {
          final dynamic subData = decoded['subscription'];
          if (subData != null && subData is Map) {
            hasActiveSubscription.value = true;
            remainingMinutes.value = subData['call_minutes'] ?? subData['minutes'] ?? 0;
            final String? endsAt = subData['ends_at'] ?? subData['expiry_date'] ?? subData['expires_at'];
            if (endsAt != null) {
              subscriptionExpiryDate.value = formatDate(endsAt);
            }
          }
        }

        final List<dynamic> txList = decoded['transactions'] ?? [];
        final mappedTx = txList.map((tx) {
          final double amountVal = (tx['amount'] ?? 0).toDouble();
          final String typeVal = (tx['type'] ?? 'recharge').toString();
          final String descVal = (tx['description'] ?? '').toString();
          final String dateVal = formatDate(tx['created_at']);
          final String statusVal = (tx['status'] ?? 'completed').toString();
          
          final isCredit = _checkIsCredit(tx, typeVal, descVal);

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

        // 3. Detect any Pending Recharge
        PendingRechargeModel? foundPending;

        if (decoded['pending_recharge'] != null && decoded['pending_recharge'] is Map) {
          final p = decoded['pending_recharge'] as Map;
          final double pAmount = (p['amount'] ?? 0).toDouble();
          foundPending = PendingRechargeModel(
            amount: '৳ ${pAmount.toStringAsFixed(0)}',
            date: formatDate(p['created_at']),
            trxId: p['transaction_id']?.toString() ?? p['trx_id']?.toString() ?? '',
            paymentMethod: (p['method'] ?? p['payment_method'] ?? '').toString().toUpperCase(),
            note: p['note']?.toString() ?? '',
          );
        } else {
          // Check transaction list for any pending recharge/deposit/transaction
          for (var tx in txList) {
            final String typeVal = (tx['type'] ?? '').toString().toLowerCase();
            final String statusVal = (tx['status'] ?? '').toString().toLowerCase();
            final bool isPendingStatus = statusVal == 'pending' || statusVal == '0' || statusVal == 'under_review' || statusVal == 'review';
            final bool isRechargeType = typeVal == 'recharge' || typeVal == 'deposit' || typeVal.isEmpty;

            if (isRechargeType && isPendingStatus) {
              final double pAmount = (tx['amount'] ?? 0).toDouble();
              foundPending = PendingRechargeModel(
                amount: '৳ ${pAmount.toStringAsFixed(0)}',
                date: formatDate(tx['created_at']),
                trxId: tx['transaction_id']?.toString() ?? tx['trx_id']?.toString() ?? '',
                paymentMethod: (tx['method'] ?? tx['payment_method'] ?? '').toString().toUpperCase(),
                note: tx['note']?.toString() ?? '',
              );
              break;
            }
          }
        }

        // Fallback: Check user profile for initial activation recharge pending status
        if (foundPending == null) {
          try {
            if (Get.isRegistered<ProfileRepository>()) {
              final profile = await Get.find<ProfileRepository>().getProfile();
              if (profile != null && profile.initialRechargeStatus == 'pending') {
                final double pAmount = profile.initialRechargeAmount > 0 ? profile.initialRechargeAmount : 50.0;
                foundPending = PendingRechargeModel(
                  amount: '৳ ${pAmount.toStringAsFixed(0)}',
                  date: 'Activation Request',
                  paymentMethod: 'WALLET ACTIVATION',
                  note: 'Initial wallet recharge pending verification',
                );
              }
            }
          } catch (e) {
            debugPrint("Profile pending check error: $e");
          }
        }

        pendingRecharge.value = foundPending;
        debugPrint("👉 [WALLET PENDING RECHARGE]: ${foundPending != null ? 'Found (${foundPending.amount})' : 'None'}");
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

  bool _checkIsCredit(dynamic tx, String typeVal, String descVal) {
    if (tx is Map) {
      if (tx['is_credit'] == true || tx['is_credit'] == 1 || tx['is_credit'] == '1') return true;
      if (tx['is_credit'] == false || tx['is_credit'] == 0 || tx['is_credit'] == '0') return false;
      final action = (tx['action'] ?? tx['transaction_type'] ?? tx['entry_type'] ?? '').toString().toLowerCase();
      if (action == 'credit' || action == 'in' || action == 'add') return true;
      if (action == 'debit' || action == 'out' || action == 'deduct') return false;
    }

    final t = typeVal.toLowerCase();
    final d = descVal.toLowerCase();

    // Explicit debit types
    if (t.contains('subscript') ||
        t.contains('purchase') ||
        t.contains('withdraw') ||
        t.contains('deduct') ||
        t.contains('fee') ||
        t == 'debit' ||
        t == 'spent' ||
        t == 'payment') {
      return false;
    }

    // Credit types: commission, referral, earning, recharge, deposit, bonus, reward, cashback, refund
    if (t.contains('commission') ||
        t.contains('earning') ||
        t.contains('referral') ||
        t.contains('recharge') ||
        t.contains('deposit') ||
        t.contains('bonus') ||
        t.contains('reward') ||
        t.contains('refund') ||
        t.contains('cashback') ||
        t == 'credit' ||
        t == 'income' ||
        d.contains('commission') ||
        d.contains('earning') ||
        d.contains('referral') ||
        d.contains('bonus')) {
      return true;
    }

    return t == 'recharge' || t == 'deposit';
  }

  final isLoadingPlans = false.obs;
  final subscriptionPlans = <SubscriptionPlanModel>[].obs;

  Future<void> fetchSubscriptionPlans() async {
    isLoadingPlans.value = true;
    try {
      final response = await walletRepository.getSubscriptionPlans();
      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        final mappedPlans = decoded.map((plan) => SubscriptionPlanModel.fromJson(plan)).toList();
        subscriptionPlans.assignAll(mappedPlans);
      } else {
        Get.snackbar('Error', 'Failed to fetch subscription plans',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error fetching subscription plans: $e");
      Get.snackbar('Error', 'An error occurred while fetching plans: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoadingPlans.value = false;
    }
  }

  void onAddMoney() {
    Get.toNamed(AppRoutes.initialRecharge, arguments: {'is_general_recharge': true});
  }

  void onWithdraw() {
    // TODO: navigate to Withdraw screen
  }

  final isPurchasing = false.obs;

  Future<bool> purchaseSubscriptionPlan(int planId, String planName) async {
    isPurchasing.value = true;
    try {
      final response = await walletRepository.purchaseSubscription(planId);
      debugPrint("Purchase Subscription API Response Code: ${response.statusCode}");
      debugPrint("Purchase Subscription API Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 1. Close confirm dialog if open
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        // 2. Refresh active subscription & balance immediately
        await fetchWalletDetails();

        // 3. Return to Wallet screen
        if (Get.currentRoute == AppRoutes.subscriptionPlans) {
          Get.back();
        } else if (Get.currentRoute != AppRoutes.wallet) {
          Get.until((route) => route.settings.name == AppRoutes.wallet || route.isFirst);
        }

        Get.snackbar(
          'Success',
          'Successfully subscribed to $planName!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return true;
      } else {
        String errorMsg = 'Failed to purchase subscription';
        try {
          final Map<String, dynamic> decoded = jsonDecode(response.body);
          errorMsg = decoded['message'] ?? decoded['error'] ?? errorMsg;
        } catch (_) {}

        // Close dialog on failure too so user isn't stuck
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        Get.snackbar(
          'Subscription Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      debugPrint("Error purchasing subscription: $e");
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isPurchasing.value = false;
    }
  }
}
