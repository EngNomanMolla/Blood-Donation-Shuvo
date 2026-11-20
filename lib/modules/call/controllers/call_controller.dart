import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:blood_donation/data/repositories/call_repository.dart';
import 'package:blood_donation/modules/call/models/call_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/callkit_service.dart';
import '../../../data/repositories/profile_repository.dart';

/// Call state transitions:
/// Outgoing: connecting → ringing → connected → ended
/// Incoming: connecting → connected → ended
enum CallState { connecting, ringing, connected, ended, error }

class CallController extends GetxController {
  final CallRepository callRepository;

  CallController({required this.callRepository});

  final recipientId = 0.obs;
  final donorName = ''.obs;
  final donorAvatar = ''.obs;
  final bloodGroup = ''.obs;
  final availableMinutes = 0.obs;
  final isIncoming = false.obs;

  final debugChannel = ''.obs;
  final debugAppId = ''.obs;
  final debugUid = ''.obs;
  final debugToken = ''.obs;
  final debugStep = 'Starting...'.obs;
  final debugError = ''.obs;

  final callState = CallState.connecting.obs;
  final callStatusText = 'Calling...'.obs;
  final isMuted = false.obs;
  final isSpeakerOn = false.obs;
  final isJoined = false.obs;
  final remoteUserJoined = false.obs;
  final errorMessage = ''.obs;

  final callDurationSeconds = 0.obs;
  Timer? _callTimer;
  Timer? _ringingTimeoutTimer;

  late RtcEngine _engine;
  bool _isEngineInitialized = false;
  bool _isRingbackPlaying = false;

  Future<String> _getRingbackTonePath() async {
    final tempFile = File('${Directory.systemTemp.path}/bloodlink_ringback_tone.wav');
    if (!await tempFile.exists()) {
      final byteData = await rootBundle.load('assets/audio/ringback_tone.wav');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    }
    return tempFile.path;
  }

  Future<void> _playRingbackTone() async {
    if (!_isEngineInitialized || isIncoming.value || _isRingbackPlaying || _isEndingCall) return;
    try {
      final filePath = await _getRingbackTonePath();
      debugPrint("🎵 [AGORA] Starting Ringback Tone: $filePath");
      await _engine.startAudioMixing(
        filePath: filePath,
        loopback: true, // Only local user hears the dialing tone
        cycle: -1,      // Infinite loop until answered
      );
      _isRingbackPlaying = true;
    } catch (e) {
      debugPrint("⚠️ [AGORA] Error playing ringback tone: $e");
    }
  }

  Future<void> _stopRingbackTone() async {
    if (!_isRingbackPlaying) return;
    _isRingbackPlaying = false;
    try {
      if (_isEngineInitialized) {
        debugPrint("🛑 [AGORA] Stopping Ringback Tone");
        await _engine.stopAudioMixing();
      }
    } catch (e) {
      debugPrint("⚠️ [AGORA] Error stopping ringback tone: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Mark that a call is now active
    CallKitService.isCallActive = true;

    final Map<String, dynamic> args = Get.arguments is Map
        ? Map<String, dynamic>.from(Get.arguments as Map)
        : <String, dynamic>{};
    isIncoming.value = args['is_incoming'] == true;
    
    if (isIncoming.value) {
      donorName.value = args['caller_name'] ?? 'Caller';
      donorAvatar.value = ProfileData.sanitizeAvatarUrl(args['caller_avatar']) ?? '';
      bloodGroup.value = args['blood_group'] ?? '';
      if (args['available_minutes'] != null) {
        availableMinutes.value = int.tryParse(args['available_minutes'].toString()) ?? 0;
      }
    } else {
      recipientId.value = args['recipient_id'] ?? 0;
      donorName.value = args['donor_name'] ?? 'Donor';
      donorAvatar.value = ProfileData.sanitizeAvatarUrl(args['donor_avatar']) ?? '';
      bloodGroup.value = args['blood_group'] ?? '';
      availableMinutes.value = int.tryParse(args['available_minutes']?.toString() ?? '0') ?? 0;
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
        Future.delayed(const Duration(seconds: 2), () {
          endCall();
        });
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
                _stopRingbackTone();
                _startCallTimer();
              } else if (isIncoming.value) {
                callState.value = CallState.connecting;
                callStatusText.value = 'Connecting...';
              } else {
                callState.value = CallState.ringing;
                callStatusText.value = 'Ringing...';
                _playRingbackTone();
              }
            } else if (state == ConnectionStateType.connectionStateFailed) {
              _stopRingbackTone();
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
              _stopRingbackTone();
              _ringingTimeoutTimer?.cancel();
              _startCallTimer();
            } else if (isIncoming.value) {
              callState.value = CallState.connecting;
              callStatusText.value = 'Connecting...';
              // If caller already left before receiver joined, timeout and end call
              _ringingTimeoutTimer?.cancel();
              _ringingTimeoutTimer = Timer(const Duration(seconds: 8), () {
                if (!remoteUserJoined.value && !_isEndingCall) {
                  callState.value = CallState.ended;
                  callStatusText.value = 'Call Ended';
                  Get.snackbar(
                    'Call Ended',
                    'The caller has hung up.',
                    backgroundColor: Colors.orangeAccent.withValues(alpha: 0.8),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                  endCall();
                }
              });
            } else {
              callState.value = CallState.ringing;
              callStatusText.value = 'Ringing...';
              _playRingbackTone();
              
              // 45-second Ringing Timeout for Outgoing Calls
              _ringingTimeoutTimer?.cancel();
              _ringingTimeoutTimer = Timer(const Duration(seconds: 45), () {
                if (callState.value != CallState.connected && !_isEndingCall) {
                  _stopRingbackTone();
                  callState.value = CallState.ended;
                  callStatusText.value = 'No Answer';
                  Get.snackbar(
                    'No Answer',
                    'The donor did not answer the call.',
                    backgroundColor: Colors.orangeAccent.withValues(alpha: 0.8),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                  endCall();
                }
              });
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("Agora Remote User Joined -> RemoteUid: $remoteUid");
            remoteUserJoined.value = true;
            _ringingTimeoutTimer?.cancel();
            _stopRingbackTone();
            debugStep.value = 'Remote User Joined (UID: $remoteUid)';
            callState.value = CallState.connected;
            callStatusText.value = 'Connected';
            _startCallTimer();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("Agora Remote User Offline -> RemoteUid: $remoteUid, Reason: $reason");
            if (_isEndingCall) return; // Already ending, ignore
            
            _stopRingbackTone();
            
            // Capture previous state BEFORE changing it
            final previousState = callState.value;
            final bool wasConnected = previousState == CallState.connected;
            final bool wasRinging = previousState == CallState.ringing;
            final bool wasRealConversation = wasConnected && callDurationSeconds.value > 1;
            remoteUserJoined.value = false;
            _ringingTimeoutTimer?.cancel();
            debugStep.value = 'Remote User Left ($reason)';
            callState.value = CallState.ended;
            
            // Different messages based on call state when remote user left
            String title;
            String message;
            if (wasRealConversation) {
              title = 'Call Ended';
              message = 'The call has ended.';
              callStatusText.value = 'Call Ended';
            } else if (wasConnected) {
              // Connected but very short (< 2 seconds)
              title = 'Call Ended';
              message = 'The call was ended by the other person.';
              callStatusText.value = 'Call Ended';
            } else if (wasRinging || !isIncoming.value) {
              // Outgoing call: the receiver declined or didn't answer
              title = 'Call Declined';
              message = 'The call was declined by the donor.';
              callStatusText.value = 'Call Declined';
            } else {
              // Incoming call: the caller hung up before we answered
              title = 'Call Ended';
              message = 'The caller has hung up.';
              callStatusText.value = 'Caller Hung Up';
            }
            
            Get.snackbar(
              title,
              message,
              backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );

            // End call on this side → both sides are now disconnected
            endCall();
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
      try {
        await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await _engine.enableAudio();
        await _engine.setDefaultAudioRouteToSpeakerphone(isSpeakerOn.value);
      } catch (audioErr) {
        debugPrint("Agora audio setup warning (non-fatal): $audioErr");
      }

      if (_isEndingCall) return;
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

  int get remainingSeconds {
    if (availableMinutes.value <= 0) return 0;
    final int totalSec = availableMinutes.value * 60;
    final int rem = totalSec - callDurationSeconds.value;
    return rem > 0 ? rem : 0;
  }

  String get formattedRemainingTime {
    final int rem = remainingSeconds;
    final int minutes = rem ~/ 60;
    final int seconds = rem % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    callDurationSeconds.value = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isEndingCall) {
        timer.cancel();
        return;
      }
      callDurationSeconds.value++;

      // Automatic disconnect when available call minutes run out
      if (availableMinutes.value > 0) {
        final int maxSeconds = availableMinutes.value * 60;
        final int remSeconds = maxSeconds - callDurationSeconds.value;

        // Warning when 30 seconds remaining
        if (remSeconds == 30) {
          Get.snackbar(
            'Call Time Alert',
            'Only 30 seconds remaining for this call.',
            backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }

        // Available minutes finished -> End call for both caller and receiver
        if (callDurationSeconds.value >= maxSeconds) {
          timer.cancel();
          callState.value = CallState.ended;
          callStatusText.value = 'Call Time Expired';
          Get.snackbar(
            'Call Ended',
            'Your available call minutes have expired.',
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
          Future.delayed(const Duration(milliseconds: 500), () => endCall());
        }
      }
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

    debugPrint("📞 [CALL] endCall() called - cleaning up...");

    _callTimer?.cancel();
    _ringingTimeoutTimer?.cancel();
    _stopRingbackTone();
    callState.value = CallState.ended;
    callStatusText.value = 'Call Ended';

    // End any active native CallKit UI
    CallKitService.endAllCalls();
    // Mark call as no longer active so new calls can come through
    CallKitService.markCallInactive();

    // 1. Non-blocking Agora Engine cleanup FIRST (so remote side gets notified via onUserOffline)
    if (_isEngineInitialized) {
      _isEngineInitialized = false;
      try {
        // leaveChannel triggers onUserOffline on the other side → their call ends too
        await _engine.leaveChannel().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint("⚠️ [CALL] leaveChannel timed out");
          },
        );
        await _engine.release().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint("⚠️ [CALL] release timed out");
          },
        );
      } catch (e) {
        debugPrint("Background Agora release error: $e");
      }
    }

    // 2. Navigate away from call screen
    // Small delay to ensure the Agora leave is processed before UI changes
    await Future.delayed(const Duration(milliseconds: 100));
    _navigateAway();
  }

  /// Safely navigate away from the call screen, handling all edge cases
  void _navigateAway() {
    try {
      // Close any open dialogs first
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Check if we're still on the call screen
      final currentRoute = Get.currentRoute;
      if (currentRoute == AppRoutes.call || currentRoute == AppRoutes.incomingCall) {
        // Try to go back to previous screen
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        } else {
          // If can't pop (e.g., call was opened from terminated state), go to home
          Get.offAllNamed(AppRoutes.home);
        }
      }
    } catch (e) {
      debugPrint("Error navigating away from call: $e");
      // Last resort: try to go home
      try {
        Get.offAllNamed(AppRoutes.home);
      } catch (_) {}
    }
  }

  @override
  void onClose() {
    _callTimer?.cancel();
    _ringingTimeoutTimer?.cancel();
    _stopRingbackTone();
    _isEndingCall = true;
    CallKitService.markCallInactive();
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
