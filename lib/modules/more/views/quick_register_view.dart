import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/services/storage_service.dart';

/// Shown when a user already has data from one role (donor/volunteer)
/// and wants to register for the other role without re-filling the form.
class QuickRegisterView extends StatelessWidget {
  const QuickRegisterView({super.key});

  static const Color _red = Color(0xFFE8285A);
  static const Color _purple = Color(0xFF673AB7);
  static const Color _lightBg = Color(0xFFF9F9FB);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final targetRole = args['targetRole'] as String? ?? 'donor';


    final isDonorTarget = targetRole == 'donor';
    final primaryColor = isDonorTarget ? _red : _purple;
    final targetLabel = isDonorTarget ? 'Donor' : 'Volunteer';
    final existingLabel = isDonorTarget ? 'Volunteer' : 'Donor';
    final targetIcon = isDonorTarget ? Icons.water_drop_rounded : Icons.volunteer_activism_rounded;

    final storage = Get.find<StorageService>();

    return Scaffold(
      backgroundColor: _lightBg,
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 24,
              left: 12,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Become a $targetLabel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // ── Illustration ──
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(targetIcon, size: 48, color: primaryColor),
                  ),
                  const SizedBox(height: 28),

                  // ── Info card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Checkmark badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Already a $existingLabel',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your profile data is already on file!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Since you\'re already registered as a $existingLabel, we have all the information we need. You can become a $targetLabel with just one tap — no form required!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Benefit chips ──
                        _buildBenefitRow(
                          icon: Icons.flash_on_rounded,
                          color: primaryColor,
                          text: 'Instant registration — no extra forms',
                        ),
                        const SizedBox(height: 10),
                        _buildBenefitRow(
                          icon: Icons.sync_rounded,
                          color: primaryColor,
                          text: 'Your existing data is reused automatically',
                        ),
                        const SizedBox(height: 10),
                        _buildBenefitRow(
                          icon: Icons.verified_rounded,
                          color: primaryColor,
                          text: 'Profile stays consistent across both roles',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Confirm Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _onConfirm(storage, targetRole, primaryColor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(targetIcon, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Confirm — Become a $targetLabel',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Maybe later',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  void _onConfirm(StorageService storage, String targetRole, Color color) async {
    // Optimistically update local storage
    if (targetRole == 'donor') {
      await storage.setIsDonor(true);
    } else {
      await storage.setIsVolunteer(true);
    }

    Get.back();

    // Show success snackbar
    final label = targetRole == 'donor' ? 'Donor' : 'Volunteer';
    Get.snackbar(
      '🎉 Congratulations!',
      'You are now registered as a $label.',
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
