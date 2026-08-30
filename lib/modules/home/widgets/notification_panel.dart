import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
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
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0.2, 0.0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
        ),
      ),
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
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: AllStyles.headingTextStyle.copyWith(
                  fontSize: 24,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 4),
              Obx(() => Text(
                "${_homeController.unreadCount.value} new updates",
                style: AllStyles.notificationTimeStyle.copyWith(
                  color: AppColors.darkGray,
                ),
              )),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: AppColors.black),
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Obx(() {
      if (_homeController.isNotificationsLoading.value) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: 4,
          itemBuilder: (context, index) => const ShimmerLoadingCard(),
        );
      }

      final notificationsList = widget.notifications ?? _homeController.notifications;

      if (notificationsList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🔔",
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                "No notifications yet",
                style: AllStyles.headingTextStyle.copyWith(
                  fontSize: 16,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: notificationsList.length,
        itemBuilder: (context, index) {
          final notif = notificationsList[index];
          return _buildNotificationCard(notif, index);
        },
      );
    });
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 8 : 0),
          child: Material(
            color: Colors.transparent,
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getGradientStart(
                        notification.type,
                      ).withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getGradientStart(notification.type),
                          _getGradientEnd(notification.type),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(notification.type),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: AllStyles.notificationTitleStyle
                                          .copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!notification.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                notification.message,
                                style: AllStyles.notificationSubtitleStyle
                                    .copyWith(
                                      color: AppColors.white.withValues(alpha: 0.85),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Text(
                                notification.timeAgo,
                                style: AllStyles.notificationTimeStyle.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
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
        ),
      ),
    );
  }

  IconData _getCategoryIcon(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return Icons.payments_rounded;
      case NotificationType.cashback:
        return Icons.monetization_on_rounded;
      case NotificationType.offer:
        return Icons.local_offer_rounded;
      case NotificationType.urgent:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getGradientStart(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return AppColors.paymentGradientStart;
      case NotificationType.cashback:
        return AppColors.cashbackGradientStart;
      case NotificationType.offer:
        return AppColors.offerGradientStart;
      case NotificationType.urgent:
        return AppColors.urgentGradientStart;
    }
  }

  Color _getGradientEnd(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return AppColors.paymentGradientEnd;
      case NotificationType.cashback:
        return AppColors.cashbackGradientEnd;
      case NotificationType.offer:
        return AppColors.offerGradientEnd;
      case NotificationType.urgent:
        return AppColors.urgentGradientEnd;
    }
  }

  void Function() get onClose => widget.onClose;
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
      duration: const Duration(milliseconds: 1200),
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
        final opacityVal = Tween<double>(begin: 0.35, end: 0.75).evaluate(_shimmerController);
        return Opacity(
          opacity: opacityVal,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 180,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
