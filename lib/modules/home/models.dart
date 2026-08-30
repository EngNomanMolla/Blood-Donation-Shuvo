import 'package:flutter/material.dart';

/// Quick action model for the quick actions grid
class QuickActionModel {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback? onTap;

  QuickActionModel({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.onTap,
  });
}

enum NotificationType { payment, cashback, offer, urgent }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String? details;
  final NotificationType type;
  final DateTime timestamp;
  final String icon;
  final bool isRead;
  final VoidCallback? onTap;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.details,
    required this.type,
    required this.timestamp,
    required this.icon,
    this.isRead = false,
    this.onTap,
  });

  factory NotificationItem.payment({
    String? id,
    String? title,
    String? message,
    VoidCallback? onTap,
  }) {
    return NotificationItem(
      id: id ?? 'payment_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Payment Received',
      message: message ?? 'You received ৳500',
      type: NotificationType.payment,
      timestamp: DateTime.now(),
      icon: '💳',
      onTap: onTap,
    );
  }

  factory NotificationItem.cashback({
    String? id,
    String? title,
    String? message,
    VoidCallback? onTap,
  }) {
    return NotificationItem(
      id: id ?? 'cashback_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Cashback Earned',
      message: message ?? 'You earned ৳20 cashback',
      type: NotificationType.cashback,
      timestamp: DateTime.now(),
      icon: '💰',
      onTap: onTap,
    );
  }

  factory NotificationItem.offer({
    String? id,
    String? title,
    String? message,
    VoidCallback? onTap,
  }) {
    return NotificationItem(
      id: id ?? 'offer_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Special Offer',
      message: message ?? 'Get discount on your next payment',
      type: NotificationType.offer,
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      icon: '🎁',
      onTap: onTap,
    );
  }

  factory NotificationItem.urgent({
    String? id,
    String? title,
    String? message,
    VoidCallback? onTap,
  }) {
    return NotificationItem(
      id: id ?? 'urgent_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Blood Needed',
      message: message ?? 'Emergency blood donation needed in your area',
      type: NotificationType.urgent,
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      icon: '🚨',
      onTap: onTap,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

class BannerModel {
  final int id;
  final String title;
  final String image;
  final String link;
  final bool isActive;
  final int order;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    required this.link,
    required this.isActive,
    required this.order,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      link: json['link'] ?? '',
      isActive: json['is_active'] ?? false,
      order: json['order'] ?? 0,
    );
  }
}
