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
                gradient: widget.action.gradientColors != null
                    ? LinearGradient(
                        colors: widget.action.gradientColors!,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.action.gradientColors == null ? widget.action.iconBg : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.action.borderColor ?? widget.action.iconColor.withValues(alpha: 0.15),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.action.iconColor.withValues(alpha: 0.08),
                    blurRadius: 10 + _elevationAnimation.value,
                    offset: Offset(0, 3 + _elevationAnimation.value * 0.5),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildIconContainer(isMobile),
                const SizedBox(width: 10),
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
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.action.iconColor,
            widget.action.iconColor.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.action.iconColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          widget.action.icon,
          color: Colors.white,
          size: 20,
        ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            fontSize: 13,
          ),
        ),
        if (widget.action.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.action.subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
              fontSize: 10.5,
            ),
          ),
        ],
      ],
    );
  }
}
