// ── Wallet Balance Model ───────────────────────────────────────────────────

class WalletBalanceModel {
  final String balance;
  final int totalPoints;

  const WalletBalanceModel({
    required this.balance,
    required this.totalPoints,
  });
}

// ── Pending Recharge Model ──────────────────────────────────────────────────

class PendingRechargeModel {
  final String amount;
  final String date;
  final String trxId;
  final String paymentMethod;
  final String note;

  const PendingRechargeModel({
    required this.amount,
    required this.date,
    this.trxId = '',
    this.paymentMethod = '',
    this.note = '',
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

class ActiveSubscriptionModel {
  final int id;
  final String planName;
  final double pricePaid;
  final String currency;
  final int durationDays;
  final int totalMinutes;
  final int remainingMinutes;
  final int usedMinutes;
  final String startsAt;
  final String endsAt;
  final String expireDate;
  final String status;
  final bool isActive;
  final int daysLeft;

  const ActiveSubscriptionModel({
    required this.id,
    required this.planName,
    required this.pricePaid,
    required this.currency,
    required this.durationDays,
    required this.totalMinutes,
    required this.remainingMinutes,
    required this.usedMinutes,
    required this.startsAt,
    required this.endsAt,
    required this.expireDate,
    required this.status,
    required this.isActive,
    required this.daysLeft,
  });

  factory ActiveSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionModel(
      id: json['id'] ?? 0,
      planName: json['plan_name'] ?? 'Active Plan',
      pricePaid: (json['price_paid'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'BDT',
      durationDays: json['duration_days'] ?? 0,
      totalMinutes: json['total_call_minutes'] ?? json['total_minutes'] ?? 0,
      remainingMinutes: json['remaining_call_minutes'] ?? json['current_minutes'] ?? 0,
      usedMinutes: json['used_call_minutes'] ?? json['used_minutes'] ?? 0,
      startsAt: json['starts_at'] ?? '',
      endsAt: json['ends_at'] ?? '',
      expireDate: json['expire_date'] ?? json['ends_at'] ?? '',
      status: json['status'] ?? 'active',
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1' || json['is_active'] == 'true',
      daysLeft: json['days_left'] ?? 0,
    );
  }
}
