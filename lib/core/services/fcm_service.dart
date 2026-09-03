import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import 'storage_service.dart';

import 'callkit_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("\n=======================================================");
  debugPrint("📩 [BACKGROUND FCM MESSAGE RECEIVED]");
  debugPrint("Message ID: ${message.messageId}");
  debugPrint("Notification Title: ${message.notification?.title}");
  debugPrint("Notification Body: ${message.notification?.body}");
  try {
    const encoder = JsonEncoder.withIndent('  ');
    debugPrint("Raw Data Payload JSON:\n${encoder.convert(message.data)}");
  } catch (_) {
    debugPrint("Raw Data Payload: ${message.data}");
  }
  debugPrint("=======================================================\n");

  final data = message.data;
  final String? type = data['type'] ?? data['notification_type'];

  if (type == 'incoming_call') {
    final String channelName = data['channel_name'] ?? data['channel'] ?? '';
    final String callerId = data['caller_id']?.toString() ?? data['sender_id']?.toString() ?? '0';
    final String callerName = data['caller_name'] ?? data['title'] ?? 'Incoming Call';
    final String callerAvatar = data['caller_avatar'] ?? data['user_avatar'] ?? data['avatar'] ?? '';
    final String agoraAppId = data['agora_app_id'] ?? data['app_id'] ?? data['agora_appid'] ?? '';
    final String rtcToken = data['rtc_token'] ?? data['token'] ?? '';
    final String bloodGroup = data['blood_group'] ?? '';

    String uid = data['uid']?.toString() ?? data['recipient_id']?.toString() ?? data['user_id']?.toString() ?? '';
    if (uid.isEmpty || uid == '0') {
      final parts = channelName.split('_');
      if (parts.length >= 3 && parts[0] == 'call') {
        uid = parts[2];
      }
    }
    if (uid.isEmpty) uid = '0';

    await CallKitService.showIncomingCall(
      uuid: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      callerName: callerName,
      callerAvatar: callerAvatar,
      callerNumber: bloodGroup.isNotEmpty ? 'Blood Group: $bloodGroup' : 'Incoming Call',
      channelName: channelName,
      callerId: callerId,
      agoraAppId: agoraAppId,
      rtcToken: rtcToken,
      bloodGroup: bloodGroup,
      uid: uid,
    );
  }
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
      debugPrint("\n=======================================================");
      debugPrint("🔔 [FOREGROUND FCM MESSAGE RECEIVED]");
      _handleIncomingMessage(message, isForeground: true);
    });

    // 5. Background Notification Tap Listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("\n=======================================================");
      debugPrint("📱 [BACKGROUND FCM NOTIFICATION TAPPED]");
      _handleIncomingMessage(message, isForeground: false);
    });

    // 6. Terminated State Initial Message Check
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("\n=======================================================");
      debugPrint("🚀 [TERMINATED APP OPENED VIA FCM NOTIFICATION]");
      _handleIncomingMessage(initialMessage, isForeground: false);
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    return this;
  }

  void _handleIncomingMessage(RemoteMessage message, {required bool isForeground}) {
    final data = message.data;
    debugPrint("Message ID: ${message.messageId}");
    debugPrint("Notification Title: ${message.notification?.title}");
    debugPrint("Notification Body: ${message.notification?.body}");
    try {
      const encoder = JsonEncoder.withIndent('  ');
      debugPrint("Full Data Payload (JSON):\n${encoder.convert(data)}");
    } catch (_) {
      debugPrint("Full Data Payload: $data");
    }
    debugPrint("=======================================================\n");

    final String? type = data['type'] ?? data['notification_type'];

    if (type == 'incoming_call') {
      final String channelName = data['channel_name'] ?? data['channel'] ?? '';
      final String callerId = data['caller_id']?.toString() ?? data['sender_id']?.toString() ?? '0';
      final String callerName = data['caller_name'] ?? data['title'] ?? 'Incoming Call';
      final String callerAvatar = data['caller_avatar'] ?? data['user_avatar'] ?? data['avatar'] ?? '';
      final String agoraAppId = data['agora_app_id'] ?? data['app_id'] ?? data['agora_appid'] ?? '';
      final String rtcToken = data['rtc_token'] ?? data['token'] ?? '';
      final String bloodGroup = data['blood_group'] ?? '';
      
      String uid = data['uid']?.toString() ?? data['recipient_id']?.toString() ?? data['user_id']?.toString() ?? '';
      if (uid.isEmpty || uid == '0') {
        final parts = channelName.split('_');
        if (parts.length >= 3 && parts[0] == 'call') {
          uid = parts[2]; // Extract receiver UID from call_<callerId>_<receiverId>_...
        }
      }
      if (uid.isEmpty) uid = '0';

      debugPrint("👉 Parsed Incoming Call Details:");
      debugPrint("   • Caller Name : $callerName");
      debugPrint("   • Channel Name: $channelName");
      debugPrint("   • Agora App ID: $agoraAppId");
      debugPrint("   • Target UID  : $uid");
      debugPrint("   • RTC Token   : ${rtcToken.isNotEmpty ? (rtcToken.length > 30 ? '${rtcToken.substring(0, 30)}...' : rtcToken) : 'EMPTY'} (Length: ${rtcToken.length})");
      debugPrint("-------------------------------------------------------\n");

      final callArgs = {
        'is_incoming': true,
        'channel_name': channelName,
        'caller_id': callerId,
        'caller_name': callerName,
        'caller_avatar': callerAvatar,
        'agora_app_id': agoraAppId,
        'rtc_token': rtcToken,
        'blood_group': bloodGroup,
        'uid': uid,
      };

      // Navigate to Incoming Call Screen
      if (Get.currentRoute != AppRoutes.incomingCall && Get.currentRoute != AppRoutes.call) {
        Get.toNamed(AppRoutes.incomingCall, arguments: callArgs);
      }
    }
  }
}
