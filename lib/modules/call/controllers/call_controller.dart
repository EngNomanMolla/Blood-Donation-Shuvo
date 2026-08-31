import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:blood_donation/data/repositories/call_repository.dart';
import 'package:blood_donation/modules/call/models/call_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app/routes/app_routes.dart';

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

  // On-screen Debug Info
  final debugChannel = ''.obs;
  final debugAppId = ''.obs;
  final debugUid = ''.obs;
  final debugToken = ''.obs;
  final debugStep = 'Starting...'.obs;
  final debugError = ''.obs;

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

      isIncoming.value = args['is_incoming'] == true;

      // 2. Resolve Agora Token Data
      late final AgoraTokenData tokenData;
      if (isIncoming.value) {
        // Pre-provided token data from push notification payload
        final String appId = args['agora_app_id'] ?? '';
        final String channelName = args['channel_name'] ?? '';
        final String rtcToken = args['rtc_token'] ?? '';
        
        int uid = int.tryParse(args['uid']?.toString() ?? '0') ?? 0;
        if (uid == 0 && channelName.isNotEmpty) {
          final parts = channelName.split('_');
          if (parts.length >= 3 && parts[0] == 'call') {
            uid = int.tryParse(parts[2]) ?? 0;
          }
        }

        if (appId.isEmpty || channelName.isEmpty || rtcToken.isEmpty) {
          throw Exception("Invalid call parameters: AppId '${appId.isNotEmpty ? 'OK' : 'EMPTY'}', Channel '${channelName.isNotEmpty ? 'OK' : 'EMPTY'}', Token '${rtcToken.isNotEmpty ? 'OK' : 'EMPTY'}'");
        }

        tokenData = AgoraTokenData(
          appId: appId,
          channelName: channelName,
          rtcToken: rtcToken,
          uid: uid,
          remainingCallMinutes: 0,
          tokenTtlSeconds: 0,
          expiresAt: '',
        );
        debugPrint("Incoming Call Token Data -> AppID: ${tokenData.appId}, Channel: ${tokenData.channelName}, UID: ${tokenData.uid}");
      } else {
        debugStep.value = 'Fetching Token from Backend...';
        // Fetch Agora Token from Backend API for outgoing call
        tokenData = await callRepository.getAgoraToken(recipientId.value);
        debugPrint("Fetched Agora Token Data -> AppID: ${tokenData.appId}, Channel: ${tokenData.channelName}, UID: ${tokenData.uid}, TokenLength: ${tokenData.rtcToken.length}");
        if (tokenData.remainingCallMinutes > 0) {
          availableMinutes.value = tokenData.remainingCallMinutes;
        }
      }

      // Assign to debug observables
      debugChannel.value = tokenData.channelName.trim();
      debugAppId.value = tokenData.appId.trim();
      debugUid.value = tokenData.uid.toString();
      debugToken.value = tokenData.rtcToken.trim().isNotEmpty
          ? '${tokenData.rtcToken.trim().substring(0, tokenData.rtcToken.trim().length > 25 ? 25 : tokenData.rtcToken.trim().length)}... (${tokenData.rtcToken.trim().length} chars)'
          : 'EMPTY';

      // 3. Initialize Agora Engine safely
      debugStep.value = 'Initializing Agora Engine...';
      if (_isEngineInitialized) {
        try {
          await _engine.leaveChannel();
          await _engine.release();
        } catch (_) {}
        _isEngineInitialized = false;
        // Brief pause to allow native audio thread release
        await Future.delayed(const Duration(milliseconds: 150));
      }

      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(
        appId: tokenData.appId.trim(),
        channelProfile: ChannelProfileType.channelProfileCommunication,
        audioScenario: AudioScenarioType.audioScenarioDefault,
      ));
      _isEngineInitialized = true;
      debugStep.value = 'Agora Engine Initialized';
      debugPrint("Agora Engine Initialized Successfully with AppID: ${tokenData.appId.trim()}");

      // 4. Register Event Handlers
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint("Agora onConnectionStateChanged -> State: $state, Reason: $reason");
            debugStep.value = 'Connection State: $state';
            if (state == ConnectionStateType.connectionStateConnected) {
              isJoined.value = true;
              if (remoteUserJoined.value) {
                callState.value = CallState.connected;
                callStatusText.value = 'Connected';
                _startCallTimer();
              } else if (isIncoming.value) {
                callState.value = CallState.connecting;
                callStatusText.value = 'Connecting...';
              } else {
                callState.value = CallState.ringing;
                callStatusText.value = 'Ringing...';
              }
            } else if (state == ConnectionStateType.connectionStateFailed) {
              callState.value = CallState.error;
              callStatusText.value = 'Connection failed';
              debugError.value = 'Connection failed: $reason';
              Get.snackbar(
                'Connection Failed',
                'Agora connection failed: $reason',
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("Agora onJoinChannelSuccess -> Channel: ${connection.channelId}, LocalUid: ${connection.localUid}");
            isJoined.value = true;
            debugStep.value = 'Joined: ${connection.channelId} (UID: ${connection.localUid})';
            if (remoteUserJoined.value) {
              callState.value = CallState.connected;
              callStatusText.value = 'Connected';
              _startCallTimer();
            } else if (isIncoming.value) {
              callState.value = CallState.connecting;
              callStatusText.value = 'Connecting...';
            } else {
              callState.value = CallState.ringing;
              callStatusText.value = 'Ringing...';
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("Agora Remote User Joined -> RemoteUid: $remoteUid");
            remoteUserJoined.value = true;
            debugStep.value = 'Remote User Joined (UID: $remoteUid)';
            callState.value = CallState.connected;
            callStatusText.value = 'Connected';
            _startCallTimer();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("Agora Remote User Offline -> RemoteUid: $remoteUid, Reason: $reason");
            remoteUserJoined.value = false;
            debugStep.value = 'Remote User Left ($reason)';
            callState.value = CallState.ended;
            callStatusText.value = 'Call Ended';
            Future.delayed(const Duration(seconds: 1), () => endCall());
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            debugPrint("Agora onLeaveChannel");
            debugStep.value = 'Left Channel';
            isJoined.value = false;
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("Agora Error Callback -> Code: $err, Message: $msg");
            errorMessage.value = msg;
            debugError.value = 'Error: $err ($msg)';
            if (callState.value == CallState.connecting) {
              callState.value = CallState.error;
              callStatusText.value = 'Connection error ($err)';
              Get.snackbar(
                'Call Error',
                'Agora error: $err ($msg)',
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        ),
      );

      if (_isEndingCall) return;

      // 5. Setup Audio & Join Channel
      try {
        await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await _engine.enableAudio();
        await _engine.setDefaultAudioRouteToSpeakerphone(isSpeakerOn.value);
      } catch (audioErr) {
        debugPrint("Agora audio setup warning (non-fatal): $audioErr");
      }

      if (_isEndingCall) return;

      debugPrint("\n-------------------------------------------------------");
      debugPrint("🚀 [AGORA JOIN CHANNEL INITIATED]");
      debugPrint("   • Channel ID : ${tokenData.channelName.trim()}");
      debugPrint("   • Joining UID: ${tokenData.uid}");
      debugPrint("   • App ID     : ${tokenData.appId.trim()}");
      debugPrint("   • Token Len  : ${tokenData.rtcToken.trim().length}");
      debugPrint("   • Full Token : ${tokenData.rtcToken.trim()}");
      debugPrint("-------------------------------------------------------\n");

      debugStep.value = 'Joining Channel (UID: ${tokenData.uid})...';
      await _engine.joinChannel(
        token: tokenData.rtcToken.trim(),
        channelId: tokenData.channelName.trim(),
        uid: tokenData.uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          publishScreenTrack: false,
          publishCustomAudioTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
        ),
      );
      debugPrint("✅ Agora joinChannel() executed without exception");
    } catch (e, stack) {
      if (_isEndingCall) return;
      debugPrint("Error initiating call session: $e\n$stack");
      callState.value = CallState.error;
      callStatusText.value = 'Connection failed';
      debugError.value = 'Exception: $e';
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
    if (!_isEngineInitialized || _isEndingCall) return;
    try {
      isMuted.value = !isMuted.value;
      await _engine.muteLocalAudioStream(isMuted.value);
    } catch (e) {
      debugPrint("Error toggling mute: $e");
    }
  }

  Future<void> toggleSpeaker() async {
    if (!_isEngineInitialized || _isEndingCall) return;
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

    // 1. Instant Navigation - Pop screen immediately so user experiences zero lag
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      debugPrint("Error popping call view: $e");
    }

    // 2. Non-blocking Agora Engine cleanup in background
    if (_isEngineInitialized) {
      _isEngineInitialized = false;
      try {
        _engine.leaveChannel().catchError((e) => debugPrint("leaveChannel err: $e"));
        _engine.release().catchError((e) => debugPrint("release err: $e"));
      } catch (e) {
        debugPrint("Background Agora release error: $e");
      }
    }
  }

  @override
  void onClose() {
    _callTimer?.cancel();
    _isEndingCall = true;
    if (_isEngineInitialized) {
      _isEngineInitialized = false;
      try {
        _engine.leaveChannel().catchError((e) => null);
        _engine.release().catchError((e) => null);
      } catch (_) {}
    }
    super.onClose();
  }
}
