import 'package:blood_donation/modules/call/controllers/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallView extends GetView<CallController> {
  const CallView({super.key});

  static const Color primaryRed = Color(0xFFE8194B);
  static const Color darkBgTop = Color(0xFF13091B);
  static const Color darkBgBottom = Color(0xFF090D16);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.endCall();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [darkBgTop, darkBgBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(flex: 1),
                _buildCallerInfoSection(),
                const Spacer(flex: 2),
                _buildActionButtons(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => controller.endCall(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ),
          ),
          Obx(() {
            final minutes = controller.availableMinutes.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFF4ADE80),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    minutes > 0 ? '$minutes Min Left' : 'Calling',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCallerInfoSection() {
    return Column(
      children: [
        // Pulsing Avatar with Glowing Ring
        _buildPulsingAvatar(),
        const SizedBox(height: 28),

        // Donor Name
        Obx(() => Text(
              controller.donorName.value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            )),
        const SizedBox(height: 8),

        // Blood Group Badge
        Obx(() {
          final blood = controller.bloodGroup.value;
          if (blood.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryRed.withValues(alpha: 0.5)),
            ),
            child: Text(
              '$blood Blood Donor',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B8A),
              ),
            ),
          );
        }),

        // Call Status / Duration
        Obx(() {
          final state = controller.callState.value;
          if (state == CallState.connected) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.formattedDuration,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4ADE80),
                  ),
                ),
              ],
            );
          }

          return Text(
            controller.callStatusText.value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: state == CallState.error ? Colors.redAccent : Colors.white60,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPulsingAvatar() {
    return Obx(() {
      final avatarUrl = controller.donorAvatar.value;
      final isRinging = controller.callState.value == CallState.ringing ||
          controller.callState.value == CallState.connecting;

      return Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow Ring
          if (isRinging)
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryRed.withValues(alpha: 0.08),
              ),
            ),
          // Middle Ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryRed.withValues(alpha: 0.15),
              border: Border.all(
                color: primaryRed.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          // Avatar Image
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: primaryRed.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF2A1520),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFFF6B8A),
                    size: 54,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Button
          Obx(() {
            final isMuted = controller.isMuted.value;
            return _buildControlButton(
              icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              isActive: isMuted,
              label: isMuted ? 'Unmute' : 'Mute',
              onTap: () => controller.toggleMute(),
            );
          }),

          // End Call Button (Big Red)
          GestureDetector(
            onTap: () => controller.endCall(),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          // Speaker Button
          Obx(() {
            final isSpeaker = controller.isSpeakerOn.value;
            return _buildControlButton(
              icon: isSpeaker ? Icons.volume_up_rounded : Icons.volume_down_rounded,
              isActive: isSpeaker,
              label: isSpeaker ? 'Speaker' : 'Earpiece',
              onTap: () => controller.toggleSpeaker(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF1E1B4B) : Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
