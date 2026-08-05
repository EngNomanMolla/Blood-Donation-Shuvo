// ── Wallet Balance Model ───────────────────────────────────────────────────

class WalletBalanceModel {
  final String balance;
  final int totalPoints;

  const WalletBalanceModel({
    required this.balance,
    required this.totalPoints,
  });
}

// ── Wallet Transaction Model ───────────────────────────────────────────────

class WalletTransactionModel {
  final String title;
  final String subtitle;
  final String date;
  final String amount;
  final bool isCredit;
  final String status;

  const WalletTransactionModel({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.status = 'completed',
  });
}
