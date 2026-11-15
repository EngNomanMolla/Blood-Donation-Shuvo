import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/callkit_service.dart';
import '../controllers/call_controller.dart';

/// Incoming Call View — shown when a call arrives while the app is in foreground
/// and the user needs to accept or decline.
///
/// This view also monitors the Agora channel to detect if the caller hangs up
/// before the receiver answers, so we can dismiss the ringing UI automatically.
class IncomingCallView extends StatefulWidget {
  const IncomingCallView({super.key});

  @override
  State<IncomingCallView> createState() => _IncomingCallViewState();
}

class _IncomingCallViewState extends State<IncomingCallView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late final Map<String, dynamic> args;
  late final String callerName;
  late final String callerAvatar;
  late final String bloodGroup;

  bool _hasResponded = false;
  Timer? _ringTimeoutTimer;

  /// Agora engine used to monitor if the caller leaves the channel (hangs up)
  RtcEngine? _monitorEngine;
  bool _isMonitoringCallerPresence = false;

  @override
  void initState() {
    super.initState();
    args = Get.arguments is Map
        ? Map<String, dynamic>.from(Get.arguments as Map)
        : <String, dynamic>{};

    callerName = args['caller_name'] ?? 'Donor / Requester';
    callerAvatar = args['caller_avatar'] ?? '';
    bloodGroup = args['blood_group'] ?? '';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-timeout after 45 seconds of ringing
    _ringTimeoutTimer = Timer(const Duration(seconds: 45), () {
      if (!_hasResponded && mounted) {
        _declineCall();
      }
    });

    // Start monitoring the Agora channel for caller presence
    // If the caller leaves before we answer, auto-dismiss the ringing screen
    _startCallerPresenceMonitor();
  }

  @override
  void dispose() {
    _ringTimeoutTimer?.cancel();
    _pulseController.dispose();
    _cleanupMonitorEngine();
    super.dispose();
  }

  /// Monitor the Agora channel (read-only) to detect if the caller leaves
  /// This allows us to dismiss the ringing screen if the caller hangs up
  Future<void> _startCallerPresenceMonitor() async {
    final String appId = args['agora_app_id'] ?? '';
    final String channelName = args['channel_name'] ?? '';
    final String rtcToken = args['rtc_token'] ?? '';
    int uid = int.tryParse(args['uid']?.toString() ?? '0') ?? 0;

    // Need valid params to monitor
    if (appId.isEmpty || channelName.isEmpty || rtcToken.isEmpty) {
      debugPrint("⚠️ [INCOMING] Cannot monitor caller presence - missing params");
      return;
    }

    try {
      _monitorEngine = createAgoraRtcEngine();
      await _monitorEngine!.initialize(RtcEngineContext(appId: appId.trim()));

      _monitorEngine!.registerEventHandler(
        RtcEngineEventHandler(
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("📞 [INCOMING MONITOR] Caller left channel (UID: $remoteUid, Reason: $reason)");
            // Caller hung up before we answered → dismiss the ringing screen
            if (!_hasResponded && mounted) {
              _handleCallerHungUp();
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("📞 [INCOMING MONITOR] Caller detected in channel (UID: $remoteUid)");
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("⚠️ [INCOMING MONITOR] Agora error: $err ($msg)");
          },
        ),
      );

      // Join as a silent observer (don't publish audio, just subscribe to detect user events)
      await _monitorEngine!.joinChannel(
        token: rtcToken.trim(),
        channelId: channelName.trim(),
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          autoSubscribeAudio: false,
          publishMicrophoneTrack: false,
        ),
      );
      _isMonitoringCallerPresence = true;
      debugPrint("✅ [INCOMING] Started monitoring caller presence on channel: $channelName");
    } catch (e) {
      debugPrint("⚠️ [INCOMING] Failed to start caller presence monitor: $e");
      _cleanupMonitorEngine();
    }
  }

  /// Clean up the monitoring engine
  Future<void> _cleanupMonitorEngine() async {
    if (_monitorEngine != null) {
      try {
        if (_isMonitoringCallerPresence) {
          await _monitorEngine!.leaveChannel();
        }
        await _monitorEngine!.release();
      } catch (e) {
        debugPrint("⚠️ [INCOMING] Error cleaning up monitor engine: $e");
      }
      _monitorEngine = null;
      _isMonitoringCallerPresence = false;
    }
  }

  /// Handle the case where the caller hung up before receiver answered
  void _handleCallerHungUp() {
    if (_hasResponded) return;
    _hasResponded = true;
    _ringTimeoutTimer?.cancel();
    CallKitService.endAllCalls();
    _cleanupMonitorEngine();

    if (mounted) {
      Get.snackbar(
        'Missed Call',
        '$callerName hung up before you could answer.',
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      Get.back();
    }
  }

  void _declineCall() async {
    if (_hasResponded) return;
    _hasResponded = true;
    _ringTimeoutTimer?.cancel();
    CallKitService.endAllCalls();
    
    // Clean up monitor engine before notifying decline
    await _cleanupMonitorEngine();
    
    // Notify caller that receiver declined via Agora join-leave
    CallKitService.notifyAgoraDeclined(args);
    
    if (mounted) {
      Get.back();
    }
  }

  void _acceptCall() async {
    if (_hasResponded) return;
    _hasResponded = true;
    _ringTimeoutTimer?.cancel();
    CallKitService.endAllCalls();
    
    // Clean up the monitor engine before accepting
    // The CallController will create its own Agora engine
    await _cleanupMonitorEngine();
    
    if (Get.isRegistered<CallController>()) {
      Get.delete<CallController>(force: true);
    }
    // Navigate to CallView with arguments directly
    Get.offNamed(AppRoutes.call, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _declineCall();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B1120)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                
                // Top App Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.water_drop_rounded, color: Color(0xFFE8194B), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Blood Donation Voice Call'.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Caller Info
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.ring_volume_rounded, color: Color(0xFF4CAF50), size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Incoming Voice Call...',
                      style: TextStyle(
                        color: Color(0xFF81C784),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (bloodGroup.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8194B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8194B).withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      'Blood Group: $bloodGroup',
                      style: const TextStyle(
                        color: Color(0xFFFF8DA1),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Pulsing Avatar
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                        ),
                      ),
                      Container(
                        width: 145,
                        height: 145,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
                        ),
                      ),
                      // Main Avatar
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4CAF50), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: callerAvatar.isNotEmpty
                              ? Image.network(
                                  callerAvatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Accept & Decline Action Dock
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Decline Button
                      _buildCallAction(
                        icon: Icons.call_end_rounded,
                        label: 'Decline',
                        color: const Color(0xFFE53935),
                        onTap: _declineCall,
                      ),

                      // Accept Button
                      _buildCallAction(
                        icon: Icons.call_rounded,
                        label: 'Accept',
                        color: const Color(0xFF2E7D32),
                        onTap: _acceptCall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF334155),
      child: const Icon(Icons.person_rounded, size: 60, color: Colors.white70),
    );
  }

  Widget _buildCallAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
