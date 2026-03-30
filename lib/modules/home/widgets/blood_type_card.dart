import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';

/// Blood type selection card with animation
class BloodTypeCard extends StatefulWidget {
  final String bloodType;
  final bool isSelected;
  final VoidCallback onTap;

  const BloodTypeCard({
    super.key,
    required this.bloodType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<BloodTypeCard> createState() => _BloodTypeCardState();
}

class _BloodTypeCardState extends State<BloodTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _animController.forward();
  void _onTapUp(_) {
    _animController.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _animController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary : const Color(0xFFFCECEE),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop_rounded,
                size: 34,
                color: widget.isSelected ? AppColors.white : AppColors.primary,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: AllStyles.subtitleTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      widget.isSelected ? AppColors.white : AppColors.primary,
                ),
                child: Text(widget.bloodType),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
