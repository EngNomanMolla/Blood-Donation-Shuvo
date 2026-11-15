import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';

class CallKitService extends GetxService {
  static CallKitService get to => Get.find<CallKitService>();

  /// Flag to prevent processing multiple call accepts simultaneously
  static bool _isProcessingAccept = false;

  /// Flag indicating whether a call is currently active (prevents duplicate incoming calls)
  static bool isCallActive = false;

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
    int availableMinutes = 0,
  }) async {
    // Don't show a new incoming call if already in a call
    if (isCallActive) {
      debugPrint("⚠️ [CALLKIT] Already in a call, ignoring new incoming call");
      return;
    }

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
        'available_minutes': availableMinutes,
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
          _handleCallDeclined(callKitParams.extra, callKitParams.id);
          break;
        case CallEventActionCallEnded(:final callKitParams):
          debugPrint("🛑 [CALLKIT] Call ended");
          _handleCallDeclined(callKitParams.extra, callKitParams.id);
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

  /// Handle decline/end from CallKit - notify caller via Agora then clean up
  void _handleCallDeclined(Map<String, dynamic>? extra, String? callId) {
    // Notify the caller that this call was declined
    notifyAgoraDeclined(extra);
    _endCurrentCall(callId);
  }

  /// Check if app was started directly by accepting an incoming call (terminated state)
  Future<void> _checkInitialCall() async {
    try {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      if (activeCalls.isNotEmpty) {
        debugPrint("📱 [CALLKIT] Found active calls on start: ${activeCalls.length}");
        for (final call in activeCalls) {
          if (call.isAccepted && call.extra != null) {
            // Wait for the app to be fully initialized before navigating
            // This handles the terminated → accepted race condition
            await Future.delayed(const Duration(milliseconds: 800));
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
    
    // Prevent processing multiple accepts simultaneously
    if (_isProcessingAccept) {
      debugPrint("⚠️ [CALLKIT] Already processing a call accept, ignoring duplicate");
      return;
    }
    _isProcessingAccept = true;
    isCallActive = true;
    
    try {
      debugPrint("🎉 [CALLKIT ACCEPTED] Extra Payload: $extra");

      final String channelName = extra['channel_name']?.toString() ?? '';
      final String agoraAppId = extra['agora_app_id']?.toString() ?? '';
      final String rtcToken = extra['rtc_token']?.toString() ?? '';

      // Validate required call parameters before navigating
      if (channelName.isEmpty || agoraAppId.isEmpty || rtcToken.isEmpty) {
        debugPrint("❌ [CALLKIT] Invalid call parameters - cannot accept call");
        debugPrint("   Channel: ${channelName.isNotEmpty ? 'OK' : 'EMPTY'}, AppId: ${agoraAppId.isNotEmpty ? 'OK' : 'EMPTY'}, Token: ${rtcToken.isNotEmpty ? 'OK' : 'EMPTY'}");
        _isProcessingAccept = false;
        isCallActive = false;
        return;
      }

      if (Get.currentRoute != AppRoutes.call) {
        // End the native CallKit UI before navigating to in-app call screen
        endAllCalls();
        Get.offAllNamed(AppRoutes.call, arguments: extra);
      }
    } catch (e) {
      debugPrint("❌ [CALLKIT ERROR] Processing accepted call: $e");
      isCallActive = false;
    } finally {
      _isProcessingAccept = false;
    }
  }

  /// Notify caller on Agora channel that receiver declined
  /// This works by briefly joining and immediately leaving the channel,
  /// which triggers `onUserOffline` on the caller's side → causing their call to end too
  static Future<void> notifyAgoraDeclined(Map<String, dynamic>? extra) async {
    if (extra == null) return;
    final String appId = extra['agora_app_id'] ?? '';
    final String channelName = extra['channel_name'] ?? '';
    final String rtcToken = extra['rtc_token'] ?? '';
    int uid = int.tryParse(extra['uid']?.toString() ?? '0') ?? 0;
    if (uid == 0 && channelName.isNotEmpty) {
      final parts = channelName.split('_');
      if (parts.length >= 3 && parts[0] == 'call') {
        uid = int.tryParse(parts[2]) ?? 0;
      }
    }

    if (appId.isNotEmpty && channelName.isNotEmpty && rtcToken.isNotEmpty) {
      RtcEngine? engine;
      try {
        debugPrint("📡 [CALLKIT] Notifying caller via Agora join-leave (decline signal)");
        engine = createAgoraRtcEngine();
        await engine.initialize(RtcEngineContext(appId: appId.trim()));
        await engine.joinChannel(
          token: rtcToken.trim(),
          channelId: channelName.trim(),
          uid: uid,
          options: const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            autoSubscribeAudio: false,
            publishMicrophoneTrack: false,
          ),
        );
        // Wait briefly so the caller's Agora engine detects the join
        await Future.delayed(const Duration(milliseconds: 500));
        await engine.leaveChannel();
        await engine.release();
        debugPrint("✅ [CALLKIT] Caller notified of decline via Agora");
      } catch (e) {
        debugPrint("⚠️ [CALLKIT] Agora decline notification error: $e");
        // Clean up engine even on error
        try {
          await engine?.leaveChannel();
          await engine?.release();
        } catch (_) {}
      }
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

  /// Mark call as inactive (called from CallController when call ends)
  static void markCallInactive() {
    isCallActive = false;
    _isProcessingAccept = false;
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
