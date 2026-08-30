import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:blood_donation/data/repositories/call_repository.dart';
import 'package:blood_donation/modules/call/models/call_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum CallState { connecting, ringing, connected, ended, error }

class CallController extends GetxController {
  final CallRepository callRepository;

  CallController({required this.callRepository});

  // Call arguments
  final recipientId = 0.obs;
  final donorName = ''.obs;
  final donorAvatar = ''.obs;
  final bloodGroup = ''.obs;
  final availableMinutes = 0.obs;
  final isIncoming = false.obs;

  // Call State
  final callState = CallState.connecting.obs;
  final callStatusText = 'Calling...'.obs;
  final isMuted = false.obs;
  final isSpeakerOn = false.obs;
  final isJoined = false.obs;
  final remoteUserJoined = false.obs;
  final errorMessage = ''.obs;

  // Duration Timer
  final callDurationSeconds = 0.obs;
  Timer? _callTimer;

  late RtcEngine _engine;
  bool _isEngineInitialized = false;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments is Map
        ? Map<String, dynamic>.from(Get.arguments as Map)
        : <String, dynamic>{};
    isIncoming.value = args['is_incoming'] == true;
    
    if (isIncoming.value) {
      donorName.value = args['caller_name'] ?? 'Caller';
      donorAvatar.value = args['caller_avatar'] ?? '';
      bloodGroup.value = args['blood_group'] ?? '';
    } else {
      recipientId.value = args['recipient_id'] ?? 0;
      donorName.value = args['donor_name'] ?? 'Donor';
      donorAvatar.value = args['donor_avatar'] ?? '';
      bloodGroup.value = args['blood_group'] ?? '';
      availableMinutes.value = args['available_minutes'] ?? 0;
    }

    initiateCallSession(args);
  }

  Future<void> initiateCallSession([Map<String, dynamic>? rawArgs]) async {
    final Map<String, dynamic> args = rawArgs ??
        (Get.arguments is Map
            ? Map<String, dynamic>.from(Get.arguments as Map)
            : <String, dynamic>{});
    try {
      callState.value = CallState.connecting;
      callStatusText.value = isIncoming.value ? 'Connecting...' : 'Calling...';

      // 1. Request Microphone Permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        callState.value = CallState.error;
        callStatusText.value = 'Microphone permission denied';
        Get.snackbar(
          'Permission Required',
          'Please allow microphone permission to make voice calls.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 2. Resolve Agora Token Data
      late final AgoraTokenData tokenData;
      if (isIncoming.value) {
        // Pre-provided token data from push notification payload
        final String appId = args['agora_app_id'] ?? '';
        final String channelName = args['channel_name'] ?? '';
        final String rtcToken = args['rtc_token'] ?? '';
        final int uid = int.tryParse(args['uid']?.toString() ?? '0') ?? 0;

        tokenData = AgoraTokenData(
          appId: appId,
          channelName: channelName,
          rtcToken: rtcToken,
          uid: uid,
          remainingCallMinutes: 0,
          tokenTtlSeconds: 0,
          expiresAt: '',
        );
        debugPrint("Incoming Call Token Data -> AppID: ${tokenData.appId}, Channel: ${tokenData.channelName}");
      } else {
        // Fetch Agora Token from Backend API for outgoing call
        tokenData = await callRepository.getAgoraToken(recipientId.value);
        debugPrint("Fetched Agora Token Data -> AppID: ${tokenData.appId}, Channel: ${tokenData.channelName}, UID: ${tokenData.uid}, TokenLength: ${tokenData.rtcToken.length}");
        if (tokenData.remainingCallMinutes > 0) {
          availableMinutes.value = tokenData.remainingCallMinutes;
        }
      }

      // 3. Initialize Agora Engine safely
      if (_isEngineInitialized) {
        try {
          await _engine.leaveChannel();
          await _engine.release();
        } catch (_) {}
        _isEngineInitialized = false;
      }

      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(
        appId: tokenData.appId.trim(),
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      _isEngineInitialized = true;
      debugPrint("Agora Engine Initialized Successfully with AppID: ${tokenData.appId.trim()}");

      // 4. Register Event Handlers
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("Agora onJoinChannelSuccess -> Channel: ${connection.channelId}, LocalUid: ${connection.localUid}");
            isJoined.value = true;
            if (isIncoming.value) {
              callState.value = CallState.connected;
              callStatusText.value = 'Connected';
              _startCallTimer();
            } else {
              callState.value = CallState.ringing;
              callStatusText.value = 'Ringing...';
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("Agora Remote User Joined -> RemoteUid: $remoteUid");
            remoteUserJoined.value = true;
            callState.value = CallState.connected;
            callStatusText.value = 'Connected';
            _startCallTimer();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("Agora Remote User Offline -> RemoteUid: $remoteUid, Reason: $reason");
            remoteUserJoined.value = false;
            callState.value = CallState.ended;
            callStatusText.value = 'Call Ended';
            Future.delayed(const Duration(seconds: 1), () => endCall());
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            debugPrint("Agora onLeaveChannel");
            isJoined.value = false;
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("Agora Error Callback -> Code: $err, Message: $msg");
            errorMessage.value = msg;
          },
        ),
      );

      // 5. Setup Audio & Join Channel
      try {
        await _engine.enableAudio();
        await _engine.setDefaultAudioRouteToSpeakerphone(isSpeakerOn.value);
      } catch (audioErr) {
        debugPrint("Agora audio setup warning (non-fatal): $audioErr");
      }

      debugPrint("Joining Agora Channel: ${tokenData.channelName} | UID: ${tokenData.uid} | Token: ${tokenData.rtcToken}");

      await _engine.joinChannel(
        token: tokenData.rtcToken.trim(),
        channelId: tokenData.channelName.trim(),
        uid: tokenData.uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
        ),
      );
      debugPrint("Agora joinChannel call executed successfully");
    } catch (e, stack) {
      debugPrint("Error initiating call session: $e\n$stack");
      callState.value = CallState.error;
      callStatusText.value = 'Connection failed';
      Get.snackbar(
        'Call Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    callDurationSeconds.value = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDurationSeconds.value++;
    });
  }

  String get formattedDuration {
    final int minutes = callDurationSeconds.value ~/ 60;
    final int seconds = callDurationSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> toggleMute() async {
    if (!_isEngineInitialized) return;
    try {
      isMuted.value = !isMuted.value;
      await _engine.muteLocalAudioStream(isMuted.value);
    } catch (e) {
      debugPrint("Error toggling mute: $e");
    }
  }

  Future<void> toggleSpeaker() async {
    if (!_isEngineInitialized) return;
    try {
      isSpeakerOn.value = !isSpeakerOn.value;
      await _engine.setEnableSpeakerphone(isSpeakerOn.value);
    } catch (e) {
      debugPrint("Error toggling speaker: $e");
    }
  }

  bool _isEndingCall = false;

  Future<void> endCall() async {
    if (_isEndingCall) return;
    _isEndingCall = true;

    _callTimer?.cancel();
    callState.value = CallState.ended;
    callStatusText.value = 'Call Ended';

    if (_isEngineInitialized) {
      try {
        await _engine.leaveChannel();
        await _engine.release();
      } catch (e) {
        debugPrint("Error releasing Agora engine: $e");
      }
      _isEngineInitialized = false;
    }

    // Safely pop screen
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      if (Get.currentRoute == '/call' || (Get.key.currentState?.canPop() ?? false)) {
        Get.back();
      }
    } catch (e) {
      debugPrint("Error popping call view: $e");
    }
  }

  @override
  void onClose() {
    _callTimer?.cancel();
    if (_isEngineInitialized) {
      try {
        _engine.leaveChannel();
        _engine.release();
      } catch (_) {}
    }
    super.onClose();
  }
}
