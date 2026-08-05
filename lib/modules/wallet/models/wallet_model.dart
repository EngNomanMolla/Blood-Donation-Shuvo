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

class SubscriptionPlanModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationDays;
  final int callMinutes;
  final bool isActive;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.callMinutes,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'BDT',
      durationDays: json['duration_days'] ?? 0,
      callMinutes: json['call_minutes'] ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1' || json['is_active'] == 'true',
    );
  }
}
