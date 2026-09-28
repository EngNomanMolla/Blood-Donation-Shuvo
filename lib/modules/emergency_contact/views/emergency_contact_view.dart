

import 'package:blood_donation/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/emergency_contact_controller.dart';
import '../models/emergency_contact_model.dart';

class EmergencyContactView extends StatelessWidget {
  EmergencyContactView({super.key});

  final EmergencyContactController controller = Get.put(
    EmergencyContactController(),
  );

  static const Color primaryRed = Color(0xFFE8194B);
  static const Color lightPink = Color(0xFFFFF0F3);
  static const Color softPink = Color(0xFFFFDDE5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink,
      // ── AppBar ──
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8194B), Color(0xFFFF6B8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Material(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(8),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'Emergency Contacts',
          style: AllStyles.titleTextStyle.copyWith(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          /// BODY
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 16, bottom: 20),
                itemCount: controller.contacts.length,
                itemBuilder: (context, index) {
                  return EmergencyContactCard(
                    contact: controller.contacts[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CARD WIDGET
class EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;

  const EmergencyContactCard({super.key, required this.contact});

  static const Color primaryRed = Color(0xFFE8194B);

  /// CALL FUNCTION
  Future<void> makeCall(String number) async {
    final Uri url = Uri.parse("tel:$number");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error making call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstNumber = contact.numbers.isNotEmpty ? contact.numbers.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => makeCall(firstNumber),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                /// ICON
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(contact.icon, color: primaryRed, size: 26),
                ),

                const SizedBox(width: 14),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (contact.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          contact.description,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Hotline: $firstNumber',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// CALL BUTTON
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
