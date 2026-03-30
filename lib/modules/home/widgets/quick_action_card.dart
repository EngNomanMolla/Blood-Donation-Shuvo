import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../models.dart';

/// Quick action card for action items with smooth animations and responsive design
class QuickActionCard extends StatefulWidget {
  final QuickActionModel action;

  const QuickActionCard({
    super.key,
    required this.action,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.action.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: widget.action.iconBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12 + _elevationAnimation.value,
                    offset: Offset(0, 3 + _elevationAnimation.value * 0.5),
                    spreadRadius: _elevationAnimation.value * 0.5,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 16,
              vertical: isMobile ? 12 : 14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildIconContainer(isMobile),
                SizedBox(width: isMobile ? 12 : 14),
                Expanded(
                  child: _buildTextContent(isMobile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(bool isMobile) {
    final iconSize = isMobile ? 48.0 : 54.0;
    final innerIconSize = isMobile ? 24.0 : 26.0;

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.action.iconBg,
            widget.action.iconBg.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.action.iconColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.action.icon,
        color: widget.action.iconColor,
        size: innerIconSize,
      ),
    );
  }

  Widget _buildTextContent(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.action.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AllStyles.subtitleTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: isMobile ? 13 : 14,
            height: 1.3,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
