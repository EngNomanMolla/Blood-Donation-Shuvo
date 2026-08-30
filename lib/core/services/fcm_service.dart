import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background FCM message: ${message.messageId} | Data: ${message.data}");
}

class FCMService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<FCMService> init() async {
    // 1. Request Notification Permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('User notification permission status: ${settings.authorizationStatus}');

    // 2. Fetch & Save Device FCM Token
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('Device FCM Token: $token');
        final storage = Get.find<StorageService>();
        await storage.setFcmToken(token);
      }
    } catch (e) {
      debugPrint('Error getting initial FCM token: $e');
    }

    // 3. Listen to token refreshes
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed: $newToken');
      try {
        final storage = Get.find<StorageService>();
        await storage.setFcmToken(newToken);
      } catch (_) {}
    });

    // 4. Foreground Message Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground FCM Message received: ${message.data}');
      _handleIncomingMessage(message, isForeground: true);
    });

    // 5. Background Notification Tap Listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM Message opened from background: ${message.data}');
      _handleIncomingMessage(message, isForeground: false);
    });

    // 6. Terminated State Initial Message Check
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM Initial Message (Terminated): ${initialMessage.data}');
      _handleIncomingMessage(initialMessage, isForeground: false);
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    return this;
  }

  void _handleIncomingMessage(RemoteMessage message, {required bool isForeground}) {
    final data = message.data;
    final String? type = data['type'] ?? data['notification_type'];

    if (type == 'incoming_call') {
      final String channelName = data['channel_name'] ?? '';
      final String callerId = data['caller_id']?.toString() ?? '0';
      final String callerName = data['caller_name'] ?? data['title'] ?? 'Incoming Call';
      final String callerAvatar = data['caller_avatar'] ?? data['user_avatar'] ?? '';
      final String agoraAppId = data['agora_app_id'] ?? data['app_id'] ?? '';
      final String rtcToken = data['rtc_token'] ?? '';
      final String bloodGroup = data['blood_group'] ?? '';

      debugPrint("Incoming Call Received from: $callerName | Channel: $channelName | AppID: $agoraAppId");

      final callArgs = {
        'is_incoming': true,
        'channel_name': channelName,
        'caller_id': callerId,
        'caller_name': callerName,
        'caller_avatar': callerAvatar,
        'agora_app_id': agoraAppId,
        'rtc_token': rtcToken,
        'blood_group': bloodGroup,
      };

      // Navigate to Incoming Call Screen
      if (Get.currentRoute != AppRoutes.incomingCall && Get.currentRoute != AppRoutes.call) {
        Get.toNamed(AppRoutes.incomingCall, arguments: callArgs);
      }
    }
  }
}
