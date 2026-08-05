import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../../models/wallet_model.dart';

/// Grouped transaction list inside a single card with dividers
class WalletTransactionSection extends StatelessWidget {
  final List<WalletTransactionModel> transactions;

  const WalletTransactionSection({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction History',
              style: AllStyles.titleTextStyle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
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
          // No extra padding on ListView — items carry their own padding
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 64,    // aligns with text start (icon 36 + gap 12 + left 16)
              endIndent: 16,
              color: AppColors.borderGray.withValues(alpha: 0.7),
            ),
            itemBuilder: (_, index) =>
                _TransactionItem(transaction: transactions[index]),
          ),
        ),
      ],
    );
  }
}

// ── Transaction Item ───────────────────────────────────────────────────────

class _TransactionItem extends StatelessWidget {
  final WalletTransactionModel transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final iconColor = isCredit ? const Color(0xFF16A34A) : AppColors.primary;
    final iconBg =
        isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFFEBEE);
    final amountColor = isCredit ? const Color(0xFF16A34A) : AppColors.primary;
    final amountPrefix = isCredit ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // ── Icon ────────────────────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: iconColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          // ── Title / Subtitle / Date ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: AllStyles.subtitleTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: AllStyles.subtitleTextStyle.copyWith(
                    fontSize: 12,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
          // ── Amount + Date ─────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${transaction.amount}',
                style: AllStyles.subtitleTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                transaction.date,
                style: AllStyles.subtitleTextStyle.copyWith(
                  fontSize: 11,
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
