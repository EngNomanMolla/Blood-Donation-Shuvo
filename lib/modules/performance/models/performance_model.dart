import 'package:flutter/material.dart';

// ── Stat Card Model ────────────────────────────────────────────────────────

class StatCardModel {
  final String label;
  final String value;
  final IconData icon;

  const StatCardModel({
    required this.label,
    required this.value,
    required this.icon,
  });
}

// ── Level Model ────────────────────────────────────────────────────────────

class LevelModel {
  final String prefix;
  final String letter;
  final String subtitle;

  const LevelModel({
    required this.prefix,
    required this.letter,
    required this.subtitle,
  });
}

// ── Transaction Model ──────────────────────────────────────────────────────

enum TransactionStatus { pending, accepted, successful }

class TransactionModel {
  final String type;
  final String transactionId;
  final TransactionStatus status;
  final String amount;
  final bool isCredit;
  final DateTime date;

  const TransactionModel({
    required this.type,
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.isCredit,
    required this.date,
  });

  String get statusLabel => status.name;

  Color get statusColor {
    switch (status) {
      case TransactionStatus.pending:
        return const Color(0xFFF59E0B);
      case TransactionStatus.accepted:
        return const Color(0xFF2563EB);
      case TransactionStatus.successful:
        return const Color(0xFF16A34A);
    }
  }

  Color get amountColor {
    return isCredit ? const Color(0xFF16A34A) : const Color(0xFFE70349);
  }

  String get formattedAmount => isCredit ? '+$amount' : '— $amount';

  String get formattedDate {
    return '${_monthName(date.month)} ${date.day} , ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// ── Current Level Model ────────────────────────────────────────────────────

class CurrentLevelModel {
  final String levelName;
  final double progressFraction;
  final String progressLabel;
  final List<String> requirements;

  const CurrentLevelModel({
    required this.levelName,
    required this.progressFraction,
    required this.progressLabel,
    required this.requirements,
  });
}

// ── Donation Info Model ────────────────────────────────────────────────────

class DonationInfoModel {
  final String lastDonation;
  final String nextDonationDate;

  const DonationInfoModel({
    required this.lastDonation,
    required this.nextDonationDate,
  });
}

class WithdrawalModel {
  final int id;
  final double amount;
  final String method;
  final String accountNumber;
  final String? note;
  final String status;
  final String? adminNote;
  final DateTime createdAt;

  const WithdrawalModel({
    required this.id,
    required this.amount,
    required this.method,
    required this.accountNumber,
    this.note,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });

  String get formattedDate {
    return '${_monthName(createdAt.month)} ${createdAt.day} , ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
      case 'successful':
      case 'success':
        return const Color(0xFF16A34A);
      case 'rejected':
      case 'failed':
        return const Color(0xFFEF4444);
      case 'pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }
}
