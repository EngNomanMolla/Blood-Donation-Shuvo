import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../models.dart';

class HomeController extends GetxController {
  final HomeRepository homeRepository;
  final ProfileRepository profileRepository;

  HomeController({
    required this.homeRepository,
    required this.profileRepository,
  });

  final banners = <BannerModel>[].obs;
  final isLoading = false.obs;

  final unreadCount = 0.obs;
  final notifications = <NotificationItem>[].obs;
  final isNotificationsLoading = false.obs;

  // Profile Avatar and Wallet Balance
  final avatarUrl = ''.obs;
  final walletBalance = '৳ 0'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchProfile();
    fetchWalletBalance();
    fetchNotifications();
  }

  Future<void> fetchWalletBalance() async {
    try {
      final WalletProvider walletProvider;
      if (Get.isRegistered<WalletProvider>()) {
        walletProvider = Get.find<WalletProvider>();
      } else {
        walletProvider = Get.put(WalletProvider());
      }

      final WalletRepository walletRepository;
      if (Get.isRegistered<WalletRepository>()) {
        walletRepository = Get.find<WalletRepository>();
      } else {
        walletRepository = Get.put(WalletRepository(walletProvider));
      }

      final response = await walletRepository.getWallet();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final double balanceVal = (decoded['balance'] ?? 0).toDouble();
        walletBalance.value = '৳ ${balanceVal.toStringAsFixed(0)}';
      }
    } catch (e) {
      debugPrint("Error fetching wallet balance in HomeController: $e");
    }
  }

  Future<void> fetchNotifications() async {
    isNotificationsLoading.value = true;
    try {
      final response = await homeRepository.getNotifications();
      debugPrint("Notifications API debug - Code: ${response.statusCode}");
      debugPrint("Notifications API debug - Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Parse unread count from summary
        if (decoded['summary'] is Map) {
          unreadCount.value = decoded['summary']['unread_count'] ?? 0;
        } else {
          unreadCount.value = 0;
        }

        // Parse list of notifications
        final List<dynamic> dataList = decoded['data'] ?? [];
        final parsed = dataList.map((json) {
          final String id = json['id']?.toString() ?? '';
          final String title = json['title']?.toString() ?? '';
          final String message = json['message']?.toString() ?? '';
          final String? details = json['details']?.toString();
          final String typeStr = json['type']?.toString() ?? '';
          final bool isRead = json['is_read'] ?? false;
          
          DateTime timestamp;
          if (json['sent_at'] != null) {
            timestamp = DateTime.tryParse(json['sent_at'].toString()) ?? DateTime.now();
          } else if (json['created_at'] != null) {
            timestamp = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
          } else {
            timestamp = DateTime.now();
          }

          NotificationType notifType;
          String iconStr;
          if (typeStr.contains('payment')) {
            notifType = NotificationType.payment;
            iconStr = '💳';
          } else if (typeStr.contains('cashback')) {
            notifType = NotificationType.cashback;
            iconStr = '💰';
          } else if (typeStr.contains('offer') || typeStr.contains('promo')) {
            notifType = NotificationType.offer;
            iconStr = '🎁';
          } else {
            notifType = NotificationType.urgent;
            iconStr = '🚨';
          }

          return NotificationItem(
            id: id,
            title: title,
            message: message,
            details: details,
            type: notifType,
            timestamp: timestamp,
            icon: iconStr,
            isRead: isRead,
          );
        }).toList();

        notifications.assignAll(parsed);
      }
    } catch (e) {
      Get.printError(info: 'Error fetching notifications: $e');
    } finally {
      isNotificationsLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((notif) => notif.id == id);
    if (index != -1) {
      final notif = notifications[index];
      if (!notif.isRead) {
        final updated = NotificationItem(
          id: notif.id,
          title: notif.title,
          message: notif.message,
          type: notif.type,
          timestamp: notif.timestamp,
          icon: notif.icon,
          isRead: true,
          onTap: notif.onTap,
        );
        notifications[index] = updated;

        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
      }
    }

    try {
      final response = await homeRepository.markNotificationAsRead(id);
      debugPrint("Mark Notification Read API debug - Code: ${response.statusCode}");
      debugPrint("Mark Notification Read API debug - Body: ${response.body}");
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> fetchProfile() async {
    try {
      final profile = await profileRepository.getProfile();
      if (profile != null) {
        avatarUrl.value = profile.avatar ?? '';
        final storage = Get.find<StorageService>();
        await storage.setIsDonor(profile.isDonor);
        await storage.setIsVolunteer(profile.isVolunteer);
        if (profile.phone != null) {
          await storage.setUserPhone(profile.phone!);
        }
      }
    } catch (e) {
      Get.printError(info: 'Error fetching profile: $e');
    }
  }

  Future<void> fetchBanners() async {
    isLoading.value = true;
    try {
      final bannerList = await homeRepository.getBanners();
      banners.value = bannerList
          .where((banner) => banner.isActive)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      Get.printError(info: "Error fetching banners from API: $e. Using local fallbacks.");
      banners.value = [
        BannerModel(
          id: 1,
          title: "Emergency Blood Needed",
          image: "https://images.unsplash.com/photo-1615461066841-6116e61058f4?auto=format&fit=crop&w=1200&q=80",
          link: "https://example.com/campaigns/emergency-blood-needed",
          isActive: true,
          order: 1,
        ),
        BannerModel(
          id: 2,
          title: "Become a Volunteer",
          image: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1200&q=80",
          link: "https://example.com/campaigns/become-a-volunteer",
          isActive: true,
          order: 2,
        ),
        BannerModel(
          id: 3,
          title: "Donate Near You",
          image: "https://images.unsplash.com/photo-1584515933487-779824d29309?auto=format&fit=crop&w=1200&q=80",
          link: "https://example.com/campaigns/donate-near-you",
          isActive: true,
          order: 3,
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHomeData() async {
    await Future.wait([
      fetchBanners(),
      fetchProfile(),
      fetchWalletBalance(),
      fetchNotifications(),
    ]);
  }
}
