import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/modules/home/models.dart';

class NotificationDetailView extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailView({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final colors = _getCategoryVisuals(notification.type);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notification Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Top Summary Card with Gradient Icon & Category
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Gradient Icon Box
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors.gradient,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        colors.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(colors.icon, size: 13, color: colors.primary),
                        const SizedBox(width: 5),
                        Text(
                          colors.label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    notification.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Timestamp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 5),
                      Text(
                        notification.timeAgo,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Message Body Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Message",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF334155),
                      height: 1.6,
                    ),
                  ),
                  if (notification.details != null && notification.details!.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF64748B),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Additional Information",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notification.details!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                        height: 1.6,
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
