import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';

class CallKitService extends GetxService {
  static CallKitService get to => Get.find<CallKitService>();

  Future<CallKitService> init() async {
    _listenToCallEvents();
    _checkInitialCall();
    return this;
  }

  /// Display native incoming call UI (works in Foreground, Background, and Terminated)
  static Future<void> showIncomingCall({
    required String uuid,
    required String callerName,
    required String callerAvatar,
    required String callerNumber,
    required String channelName,
    required String callerId,
    required String agoraAppId,
    required String rtcToken,
    required String bloodGroup,
    required String uid,
  }) async {
    final CallKitParams callKitParams = CallKitParams(
      id: uuid.isNotEmpty ? uuid : DateTime.now().millisecondsSinceEpoch.toString(),
      nameCaller: callerName.isNotEmpty ? callerName : 'Blood Donor / Requester',
      appName: 'Blood Donation',
      avatar: callerAvatar.isNotEmpty ? callerAvatar : 'https://cdn-icons-png.flaticon.com/512/822/822143.png',
      handle: bloodGroup.isNotEmpty ? 'Blood Group: $bloodGroup' : (callerNumber.isNotEmpty ? callerNumber : 'Incoming Voice Call'),
      type: 0, // 0 for Audio Call, 1 for Video Call
      duration: 30000,
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed Call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{
        'is_incoming': true,
        'channel_name': channelName,
        'caller_id': callerId,
        'caller_name': callerName,
        'caller_avatar': callerAvatar,
        'agora_app_id': agoraAppId,
        'rtc_token': rtcToken,
        'blood_group': bloodGroup,
        'uid': uid,
      },
      headers: <String, dynamic>{'apiKey': 'blood_donation'},
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0F172A',
        backgroundUrl: '',
        actionColor: '#E70349',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: 'Incoming Blood Donation Calls',
        missedCallNotificationChannelName: 'Missed Blood Donation Calls',
        isShowCallID: false,
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'voiceChat',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    try {
      debugPrint("📱 [CALLKIT] Showing Native Incoming Call: $callerName");
      await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    } catch (e) {
      debugPrint("❌ [CALLKIT ERROR] Failed to show call notification: $e");
    }
  }

  /// Listen to CallKit button clicks (Accept / Decline / End / Missed)
  void _listenToCallEvents() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;
      debugPrint("📞 [CALLKIT EVENT]: ${event.eventName}");

      switch (event) {
        case CallEventActionCallAccept(:final callKitParams):
          _handleCallAccepted(callKitParams.extra);
          break;
        case CallEventActionCallDecline(:final callKitParams):
          debugPrint("🚫 [CALLKIT] Call declined by user");
          _endCurrentCall(callKitParams.id);
          break;
        case CallEventActionCallEnded(:final callKitParams):
          debugPrint("🛑 [CALLKIT] Call ended");
          _endCurrentCall(callKitParams.id);
          break;
        case CallEventActionCallTimeout(:final id):
          debugPrint("⏳ [CALLKIT] Call timed out");
          _endCurrentCall(id);
          break;
        default:
          break;
      }
    });
  }

  /// Check if app was started directly by accepting an incoming call
  Future<void> _checkInitialCall() async {
    try {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      if (activeCalls.isNotEmpty) {
        debugPrint("📱 [CALLKIT] Found active calls on start: ${activeCalls.length}");
        for (final call in activeCalls) {
          if (call.isAccepted && call.extra != null) {
            _handleCallAccepted(call.extra);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ [CALLKIT] Error checking initial calls: $e");
    }
  }

  /// Handle Call Accepted from CallKit UI -> Direct jump to CallView
  void _handleCallAccepted(Map<String, dynamic>? extra) {
    if (extra == null || extra.isEmpty) return;
    try {
      debugPrint("🎉 [CALLKIT ACCEPTED] Extra Payload: $extra");

      if (extra['channel_name'] != null && extra['channel_name'].toString().isNotEmpty) {
        if (Get.currentRoute != AppRoutes.call) {
          Get.offAllNamed(AppRoutes.call, arguments: extra);
        }
      }
    } catch (e) {
      debugPrint("❌ [CALLKIT ERROR] Processing accepted call: $e");
    }
  }

  /// End a specific or all active calls
  static Future<void> endAllCalls() async {
    try {
      await FlutterCallkitIncoming.endAllCalls();
      debugPrint("✅ [CALLKIT] All calls ended.");
    } catch (e) {
      debugPrint("⚠️ [CALLKIT] Error ending calls: $e");
    }
  }

  static Future<void> _endCurrentCall(String? id) async {
    if (id != null && id.isNotEmpty) {
      try {
        await FlutterCallkitIncoming.endCall(id);
      } catch (_) {
        await FlutterCallkitIncoming.endAllCalls();
      }
    } else {
      await FlutterCallkitIncoming.endAllCalls();
    }
  }
}
