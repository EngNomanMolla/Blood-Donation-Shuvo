import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/routes/app_routes.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

class BlockedUserDialog {
  static bool _isShowing = false;

  static void show({String? customMessage}) {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red glowing icon circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.block_flipped,
                      color: Color(0xFFDC2626),
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'অ্যাকাউন্ট স্থগিত করা হয়েছে',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle / Reason message
                Text(
                  customMessage ??
                      'আপনার অ্যাকাউন্টটি সাময়িকভাবে ব্লক বা স্থগিত করা হয়েছে। আপনি বর্তমানে এই অ্যাকাউন্টে প্রবেশ করতে পারবেন না। বিস্তারিত জানতে বা অ্যাকাউন্ট সক্রিয় করতে অনুগ্রহ করে আমাদের সাপোর্ট টিমের সাথে যোগাযোগ করুন।',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Call Support Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      const phone = '01319528282';
                      final Uri launchUri = Uri(scheme: 'tel', path: phone);
                      try {
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        }
                      } catch (e) {
                        debugPrint("Error launching support dialer: $e");
                      }
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                    label: const Text(
                      'সাপোর্টে কল করুন',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Back to Login / Exit Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      _isShowing = false;
                      if (Get.isRegistered<StorageService>()) {
                        await Get.find<StorageService>().clearAuth();
                      }
                      Get.offAllNamed(AppRoutes.login);
                    },
                    child: const Text(
                      'লগইন পেজে যান',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      _isShowing = false;
    });
  }
}

