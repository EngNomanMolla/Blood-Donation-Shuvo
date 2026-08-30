import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../constants.dart';
import '../controllers/home_controller.dart';

/// Header section with avatar, balance, and notification button
class HomeHeader extends StatefulWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onBalanceTap;

  const HomeHeader({
    super.key,
    required this.onNotificationTap,
    required this.onBalanceTap,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool _showBalance = false;
  Timer? _balanceTimer;

  @override
  void dispose() {
    _balanceTimer?.cancel();
    super.dispose();
  }

  void _handleBalanceTap() {
    setState(() => _showBalance = true);
    _balanceTimer?.cancel();
    _balanceTimer = Timer(
      const Duration(seconds: HomeConstants.balanceDisplayDuration),
      () {
        if (mounted) setState(() => _showBalance = false);
      },
    );
    widget.onBalanceTap();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeConstants.headerPadding,
        vertical: HomeConstants.headerVerticalPadding,
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 10),
          _buildBalanceButton(),
          const SizedBox(width: 10),
          _buildNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final HomeController homeController = Get.find<HomeController>();
    return SizedBox(
      width: 60,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: .25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Obx(() {
          final avatar = homeController.avatarUrl.value;
          if (avatar.isNotEmpty) {
            return CircleAvatar(
              radius: HomeConstants.avatarRadius,
              backgroundImage: NetworkImage(avatar),
            );
          } else {
            return const CircleAvatar(
              radius: HomeConstants.avatarRadius,
              backgroundColor: Color(0xFFFDECF4),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildBalanceButton() {
    final HomeController homeController = Get.find<HomeController>();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _handleBalanceTap();
          homeController.fetchWalletBalance();
        },
        child: AnimatedContainer(
          duration: HomeConstants.containerAnimationDuration,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                HomeConstants.balanceCurrency,
                style: AllStyles.subtitleTextStyle.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Obx(() {
                final balance = homeController.walletBalance.value;
                final displayBalance = balance.replaceAll('৳', '').trim();
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _showBalance
                        ? displayBalance
                        : HomeConstants.balancePlaceholder,
                    key: ValueKey(_showBalance),
                    style: AllStyles.subtitleTextStyle.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    final HomeController homeController = Get.find<HomeController>();
    return SizedBox(
      width: 50,
      child: GestureDetector(
        onTap: widget.onNotificationTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF7D7E1),
              child: Icon(Icons.notifications_none),
            ),
            Obx(() {
              if (homeController.unreadCount.value > 0) {
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
