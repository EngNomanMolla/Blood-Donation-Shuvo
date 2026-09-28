import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/modules/home/models.dart';
import '../controllers/home_controller.dart';
import '../views/notification_detail_view.dart';

/// Modern, beautiful notification panel that slides from the right
class NotificationPanel extends StatefulWidget {
  final VoidCallback onClose;
  final List<NotificationItem>? notifications;

  const NotificationPanel({
    super.key,
    required this.onClose,
    this.notifications,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final HomeController _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.2, 0.0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
        );

    _animationController.forward();

    // Refresh notifications when panel opens
    _homeController.fetchNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF416C).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final count = _homeController.unreadCount.value;
                      return Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: count > 0 ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            count > 0 ? "$count unread updates" : "All caught up",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: count > 0 ? const Color(0xFF059669) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Color(0xFF334155), size: 20),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Obx(() {
      if (_homeController.isNotificationsLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          itemCount: 4,
          itemBuilder: (context, index) => const ShimmerLoadingCard(),
        );
      }

      final notificationsList = widget.notifications ?? _homeController.notifications;

      if (notificationsList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 38,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No notifications yet",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "We'll notify you when blood requests, offers, or payments arrive.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        itemCount: notificationsList.length,
        itemBuilder: (context, index) {
          final notif = notificationsList[index];
          return _buildNotificationCard(notif, index);
        },
      );
    });
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    final colors = _getCategoryVisuals(notification.type);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? const Color(0xFFF1F5F9)
                  : colors.primary.withValues(alpha: 0.25),
              width: notification.isRead ? 1.0 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: notification.isRead
                    ? const Color(0xFF0F172A).withValues(alpha: 0.03)
                    : colors.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                _homeController.markAsRead(notification.id);
                Get.to(() => NotificationDetailView(
                  notification: NotificationItem(
                    id: notification.id,
                    title: notification.title,
                    message: notification.message,
                    details: notification.details,
                    type: notification.type,
                    timestamp: notification.timestamp,
                    icon: notification.icon,
                    isRead: true,
                    onTap: notification.onTap,
                  ),
                ));
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Category Badge & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: colors.bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(colors.icon, size: 12, color: colors.primary),
                              const SizedBox(width: 4),
                              Text(
                                colors.label,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.timeAgo,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.primary.withValues(alpha: 0.6),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Middle Row: Gradient Icon & Content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors.gradient,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              colors.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.5,
                                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  height: 1.25,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // Bottom strip with "View Details" hint
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF8FAFC), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tap to see details",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "View",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: colors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _CategoryVisuals _getCategoryVisuals(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return _CategoryVisuals(
          label: "Payment",
          icon: Icons.account_balance_wallet_rounded,
          primary: const Color(0xFF6366F1),
          bg: const Color(0xFFEEF2FF),
          gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        );
      case NotificationType.cashback:
        return _CategoryVisuals(
          label: "Cashback",
          icon: Icons.stars_rounded,
          primary: const Color(0xFF10B981),
          bg: const Color(0xFFECFDF5),
          gradient: const [Color(0xFF10B981), Color(0xFF059669)],
        );
      case NotificationType.offer:
        return _CategoryVisuals(
          label: "Special Offer",
          icon: Icons.local_offer_rounded,
          primary: const Color(0xFFF59E0B),
          bg: const Color(0xFFFFFBEB),
          gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case NotificationType.call:
        return _CategoryVisuals(
          label: "Call Alert",
          icon: Icons.phone_in_talk_rounded,
          primary: const Color(0xFF0284C7),
          bg: const Color(0xFFF0F9FF),
          gradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
        );
      case NotificationType.urgent:
        return _CategoryVisuals(
          label: "Announcement",
          icon: Icons.campaign_rounded,
          primary: const Color(0xFFE11D48),
          bg: const Color(0xFFFFF1F2),
          gradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
        );
    }
  }

  void Function() get onClose => widget.onClose;
}

class _CategoryVisuals {
  final String label;
  final IconData icon;
  final Color primary;
  final Color bg;
  final List<Color> gradient;

  _CategoryVisuals({
    required this.label,
    required this.icon,
    required this.primary,
    required this.bg,
    required this.gradient,
  });
}

/// A custom animatable shimmer card to load notifications.
class ShimmerLoadingCard extends StatefulWidget {
  const ShimmerLoadingCard({super.key});

  @override
  State<ShimmerLoadingCard> createState() => _ShimmerLoadingCardState();
}

class _ShimmerLoadingCardState extends State<ShimmerLoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final opacityVal = Tween<double>(begin: 0.35, end: 0.8).evaluate(_shimmerController);
        return Opacity(
          opacity: opacityVal,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 70,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 180,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
