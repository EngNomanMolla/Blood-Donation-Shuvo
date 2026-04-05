import 'package:get/get.dart';
import '../models/wallet_model.dart';

class WalletController extends GetxController {
  // ── Balance ───────────────────────────────────────────────────────────────

  final WalletBalanceModel walletBalance = const WalletBalanceModel(
    balance: '৳ 1,300.00',
    totalPoints: 300,
  );

  // ── Transactions ──────────────────────────────────────────────────────────

  final List<WalletTransactionModel> transactions = const [
    WalletTransactionModel(
      title: 'Donation Reward',
      subtitle: 'Received For Blood Donation',
      date: '24 Apr 2024',
      amount: '৳ 300',
      isCredit: true,
    ),
    WalletTransactionModel(
      title: 'Money Withdraw',
      subtitle: 'Transferred To Bank Account',
      date: '24 Apr 2024',
      amount: '৳ 300',
      isCredit: false,
    ),
    WalletTransactionModel(
      title: 'Referral Bonus',
      subtitle: 'Received For Blood Donation',
      date: '24 Apr 2024',
      amount: '৳ 300',
      isCredit: true,
    ),
    WalletTransactionModel(
      title: 'Add Money',
      subtitle: 'Received For Blood Donation',
      date: '24 Apr 2024',
      amount: '৳ 300',
      isCredit: true,
    ),
    WalletTransactionModel(
      title: 'Donation Reward',
      subtitle: 'Received For Blood Donation',
      date: '24 Apr 2024',
      amount: '৳ 300',
      isCredit: true,
    ),
    WalletTransactionModel(
      title: 'Referral Bonus',
      subtitle: 'Received For Blood Donation',
      date: '24 Apr 2024',
      amount: '৳ 300',
      isCredit: true,
    ),
  ];

  // ── Actions ───────────────────────────────────────────────────────────────

  void onAddMoney() {
    // TODO: navigate to Add Money screen
  }

  void onWithdraw() {
    // TODO: navigate to Withdraw screen
  }
}
