import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../../models/performance_model.dart';
import 'my_level_section.dart'; // re-uses BulletText

/// "Transaction History" section with donation info + transaction list
class TransactionHistorySection extends StatelessWidget {
  final DonationInfoModel donationInfo;
  final List<TransactionModel> transactions;

  const TransactionHistorySection({
    super.key,
    required this.donationInfo,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
          style: AllStyles.titleTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
        _DonationInfoCard(info: donationInfo),
        const SizedBox(height: 12),
        ...transactions.map(
          (tx) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TransactionCard(transaction: tx),
          ),
        ),
      ],
    );
  }
}

// ── Donation Info Card ─────────────────────────────────────────────────────

class _DonationInfoCard extends StatelessWidget {
  final DonationInfoModel info;

  const _DonationInfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BulletText(text: 'Last Donation: ${info.lastDonation}'),
          const SizedBox(height: 4),
          BulletText(text: 'Next Donation Date: ${info.nextDonationDate}'),
        ],
      ),
    );
  }
}

// ── Transaction Card ───────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: type / id / status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type,
                  style: AllStyles.subtitleTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tran ID : ${transaction.transactionId}',
                  style: AllStyles.subtitleTextStyle.copyWith(
                    fontSize: 12,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.statusLabel,
                  style: AllStyles.subtitleTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: transaction.statusColor,
                  ),
                ),
              ],
            ),
          ),
          // Right: amount / date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.formattedAmount,
                style: AllStyles.titleTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: transaction.amountColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                transaction.formattedDate,
                style: AllStyles.subtitleTextStyle.copyWith(
                  fontSize: 12,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
