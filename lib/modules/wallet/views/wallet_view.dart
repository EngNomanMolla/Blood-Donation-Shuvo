import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controllers/wallet_controller.dart';
import 'widgets/balance_card.dart';
import 'widgets/pending_recharge_card.dart';
import 'widgets/wallet_transaction_section.dart';

class WalletView extends StatelessWidget {
  final bool? showBackButton;

  const WalletView({super.key, this.showBackButton});

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
      if (!Get.isRegistered<ProfileProvider>()) {
        Get.put(ProfileProvider());
      }
      if (!Get.isRegistered<ProfileRepository>()) {
        Get.put(ProfileRepository(provider: Get.find<ProfileProvider>()));
      }
      if (!Get.isRegistered<WalletProvider>()) {
        Get.put(WalletProvider());
      }
      if (!Get.isRegistered<WalletRepository>()) {
        Get.put(WalletRepository(Get.find<WalletProvider>()));
      }
      controller = Get.put(WalletController(walletRepository: Get.find<WalletRepository>()));
    }

    final bool shouldShowBack = showBackButton ?? (Navigator.canPop(context) && Get.currentRoute == AppRoutes.wallet);

    return Scaffold(
      backgroundColor: const Color(0xFFFCE8EE),
      body: Column(
        children: [
          _WalletAppBar(showBackButton: shouldShowBack),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final balance = controller.walletBalance.value;
              if (balance == null) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                  onRefresh: () async => await controller.fetchWalletDetails(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const Center(
                        child: Text(
                          'No wallet information found.\nPull down to retry.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Poppins', color: AppColors.darkGray),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: Colors.white,
                onRefresh: () async => await controller.fetchWalletDetails(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    if (controller.pendingRecharge.value != null) ...[
                      PendingRechargeCard(
                        pending: controller.pendingRecharge.value!,
                        onRefresh: () => controller.fetchWalletDetails(),
                      ),
                      const SizedBox(height: 14),
                    ],
                    BalanceCard(
                      balance: balance,
                      onAddMoney: controller.onAddMoney,
                    ),
                    _buildActiveSubscriptionCard(controller),
                    const SizedBox(height: 16),
                    
                    // Subscription Plans card
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      shadowColor: AppColors.primary.withValues(alpha: 0.06),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => Get.toNamed(AppRoutes.subscriptionPlans),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFCE8EE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.card_membership_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Subscription Plans',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Unlock access to donor phone numbers and calls',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.primary.withValues(alpha: 0.7),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    WalletTransactionSection(
                      transactions: controller.transactions,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(WalletController controller) {
    return Obx(() {
      final hasSub = controller.hasActiveSubscription.value;
      final sub = controller.activeSubscription.value;
      final remainingMin = sub?.remainingMinutes ?? controller.remainingMinutes.value ?? 0;
      final usedMin = sub?.usedMinutes ?? 0;
      final totalMin = sub?.totalMinutes ?? remainingMin;
      final expiry = controller.subscriptionExpiryDate.value ?? (sub?.expireDate != null ? controller.formatDate(sub!.expireDate) : '');
      final planName = sub?.planName ?? 'Active Subscription';
      final daysLeft = sub?.daysLeft ?? 0;

      return Container(
        margin: const EdgeInsets.only(top: 14),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: hasSub 
                ? AppColors.primary.withValues(alpha: 0.15) 
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: 6,
                child: Container(
                  color: hasSub ? AppColors.primary : Colors.grey[400],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              hasSub ? Icons.verified_user_rounded : Icons.info_outline_rounded,
                              color: hasSub ? AppColors.primary : Colors.grey[500],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hasSub ? planName : 'No Active Subscription',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        if (hasSub && daysLeft > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200, width: 1),
                            ),
                            child: Text(
                              '$daysLeft days left',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (hasSub) ...[
                      const SizedBox(height: 14),
                      // Stats Row: Remaining, Used, Total
                      Row(
                        children: [
                          Expanded(
                            child: _buildMinuteStatItem(
                              icon: Icons.phone_in_talk_rounded,
                              iconColor: Colors.green,
                              bgColor: Colors.green.shade50,
                              label: 'Remaining',
                              value: '$remainingMin Min',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMinuteStatItem(
                              icon: Icons.phone_callback_rounded,
                              iconColor: Colors.blueGrey,
                              bgColor: Colors.blueGrey.shade50,
                              label: 'Used',
                              value: '$usedMin Min',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMinuteStatItem(
                              icon: Icons.timelapse_rounded,
                              iconColor: Colors.purple,
                              bgColor: Colors.purple.shade50,
                              label: 'Total',
                              value: '$totalMin Min',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Expiry Date Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.orange.shade800),
                            const SizedBox(width: 8),
                            Text(
                              'Expiry Date: ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              expiry.isNotEmpty ? expiry : 'N/A',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text(
                        'Buy a subscription plan below to get call minutes and see donor contact numbers.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMinuteStatItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Bar ────────────────────────────────────────────────────────────────

class _WalletAppBar extends StatelessWidget {
  final bool showBackButton;

  const _WalletAppBar({this.showBackButton = true});

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
              if (showBackButton)
                _AppBarIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Get.back(),
                )
              else
                const SizedBox(width: 40),
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
