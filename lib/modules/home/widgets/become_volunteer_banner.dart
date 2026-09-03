import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../constants.dart';

/// Beautiful and modern become a volunteer promotional banner
class BecomeVolunteerBanner extends StatefulWidget {
  final VoidCallback? onTap;

  const BecomeVolunteerBanner({super.key, this.onTap});

  @override
  State<BecomeVolunteerBanner> createState() => _BecomeVolunteerBannerState();
}

class _BecomeVolunteerBannerState extends State<BecomeVolunteerBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _elevationAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _elevationAnim = Tween<double>(begin: 4, end: 12).animate(
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
    widget.onTap?.call();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeConstants.headerPadding,
            vertical: 2,
          ),
          child: AnimatedBuilder(
            animation: _elevationAnim,
            builder: (context, child) => Card(
              elevation: _elevationAnim.value,
              shadowColor: const Color(0xFF0D9488).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  HomeConstants.componentBorderRadius,
                ),
              ),
              child: child,
            ),
            child: Container(
              height: HomeConstants.donorBannerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  HomeConstants.componentBorderRadius,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF14B8A6),
                  ],
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  _buildBackgroundEffect(),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundEffect() {
    return Stack(
      children: [
        // Top-right decorative circles
        Positioned(
          right: -20,
          top: -15,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -40,
          top: 10,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom-left decorative circles
        Positioned(
          left: -30,
          bottom: -20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Left side accent line
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Volunteer icon with background
          _buildIconSection(),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: _buildTextSection(),
          ),
          const SizedBox(width: 8),
          // CTA Arrow
          _buildArrowIcon(),
        ],
      ),
    );
  }

  Widget _buildIconSection() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle glow effect
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          // Icon
          const Icon(
            Icons.volunteer_activism_rounded,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Make A Difference',
          style: AllStyles.subtitleTextStyle.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Become a Volunteer',
          style: AllStyles.titleTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
