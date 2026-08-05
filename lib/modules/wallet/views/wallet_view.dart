import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../controllers/wallet_controller.dart';
import 'widgets/balance_card.dart';
import 'widgets/wallet_transaction_section.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Resilient initialization fallback for hot-reload or direct navigation
    final WalletController controller;
    if (Get.isRegistered<WalletController>()) {
      controller = Get.find<WalletController>();
    } else {
      if (!Get.isRegistered<WalletProvider>()) {
        Get.put(WalletProvider());
      }
      if (!Get.isRegistered<WalletRepository>()) {
        Get.put(WalletRepository(Get.find<WalletProvider>()));
      }
      controller = Get.put(WalletController(walletRepository: Get.find<WalletRepository>()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCE8EE),
      body: Column(
        children: [
          _WalletAppBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final balance = controller.walletBalance.value;
              if (balance == null) {
                return const Center(
                  child: Text(
                    'No wallet information found.',
                    style: TextStyle(fontFamily: 'Poppins', color: AppColors.darkGray),
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BalanceCard(
                      balance: balance,
                      onAddMoney: controller.onAddMoney,
                      onWithdraw: controller.onWithdraw,
                    ),
                    const SizedBox(height: 25),
                    WalletTransactionSection(
                      transactions: controller.transactions,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── App Bar ────────────────────────────────────────────────────────────────

class _WalletAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              _AppBarIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Get.back(),
              ),
              Expanded(
                child: Text(
                  'Wallet',
                  textAlign: TextAlign.center,
                  style: AllStyles.titleTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              // Balances back button for symmetry
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
      ),
    );
  }
}
