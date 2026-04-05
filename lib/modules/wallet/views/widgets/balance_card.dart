import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../../models/wallet_model.dart';

/// Redesigned wallet balance card — no fixed height, overflow-safe
class BalanceCard extends StatelessWidget {
  final WalletBalanceModel balance;
  final VoidCallback onAddMoney;
  final VoidCallback onWithdraw;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.onAddMoney,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE70349), Color(0xFFFF4D6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Decorative background circles ──────────────────────────────
          Positioned(
            right: -30,
            bottom: -40,
            child: _circle(180, 0.10),
          ),
          Positioned(
            right: 40,
            top: -50,
            child: _circle(140, 0.07),
          ),
          Positioned(
            left: -20,
            top: -20,
            child: _circle(100, 0.05),
          ),
          // ── Main content ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: AllStyles.subtitleTextStyle.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Balance amount
                Text(
                  balance.balance,
                  style: AllStyles.headingTextStyle.copyWith(
                    color: AppColors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Divider
                Divider(
                  color: AppColors.white.withValues(alpha: 0.2),
                  height: 1,
                ),
                const SizedBox(height: 12),
                // Bottom row: points + actions evenly spaced
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PointsBadge(points: balance.totalPoints),
                    _QuickActionBtn(
                      icon: Icons.add_rounded,
                      label: 'Add',
                      onTap: onAddMoney,
                    ),
                    _QuickActionBtn(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Withdraw',
                      onTap: onWithdraw,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      );
}

// ── Points Badge ───────────────────────────────────────────────────────────

class _PointsBadge extends StatelessWidget {
  final int points;

  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            '$points Points',
            style: AllStyles.subtitleTextStyle.copyWith(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Button ────────────────────────────────────────────────────

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: AllStyles.subtitleTextStyle.copyWith(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
