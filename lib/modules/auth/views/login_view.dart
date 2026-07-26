import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/sign_in_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  // Premium Reds
  static const Color _primaryRed = Color(0xFFE53935);
  static const Color _darkRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Premium Background Layer
          _buildBackground(),

          // 2. Interactive Overlay Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/svg/splash/splash_logo.svg',
                      height: 80,
                      width: 80,
                      colorFilter: const ColorFilter.mode(_primaryRed, BlendMode.srcIn),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Heading
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your life-saving journey.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 3. Glassmorphism Login Card
                  _buildLoginCard(),

                  const SizedBox(height: 32),

                ],
              ),
            ),
          ),
          
          // Loading Overlay
          Obx(() => controller.isLoading.value 
              ? _buildLoadingOverlay() 
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          // Gradient Base
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFFFF5F5), Colors.white],
              ),
            ),
          ),
          // Decorative Blobs
          Positioned(
            top: -100,
            right: -80,
            child: _buildBlob(300, 300, _primaryRed.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBlob(250, 250, _darkRed.withValues(alpha: 0.06)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mobile Input
              _buildInputLabel('Mobile Number'),
              _buildTextField(
                controller: controller.mobileController,
                hint: '01XXXXXXXXX',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              // OTP Section
              Obx(() => controller.isOtpSent.value 
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('Verification Code'),
                      _buildTextField(
                        controller: controller.otpController,
                        hint: 'Enter Code',
                        icon: Icons.verified_user_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 32),
                      _buildActionButton(
                        title: 'Log In',
                        onTap: controller.login,
                      ),
                    ],
                  )
                : _buildActionButton(
                    title: 'Send Verification Code',
                    onTap: controller.sendOtp,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: _primaryRed, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primaryRed, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryRed, _darkRed],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _primaryRed.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: CircularProgressIndicator(color: _primaryRed),
      ),
    );
  }
}
