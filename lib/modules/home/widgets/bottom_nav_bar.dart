import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/app_colors.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                isSelected: widget.selectedIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.mail_rounded,
                label: 'Messages',
                index: 1,
                isSelected: widget.selectedIndex == 1,
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                index: 2,
                isSelected: widget.selectedIndex == 2,
              ),
              _buildNavItem(
                icon: Icons.widgets_rounded,
                label: 'More',
                index: 3,
                isSelected: widget.selectedIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        _controller.forward(from: 0.0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: isSelected ? 12 : 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.15),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    icon,
                    size: 26,
                    color: Colors.white,
                  ),
                );
              },
            ),
            if (isSelected) ...[
              const SizedBox(width: 10),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
