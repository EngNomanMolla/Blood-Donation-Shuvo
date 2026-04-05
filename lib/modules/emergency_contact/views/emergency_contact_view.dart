import 'dart:ffi';

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
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 6, color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(contact.icon, color: primaryRed, size: 28),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                ...contact.numbers.map(
                  (num) =>
                      Text(num, style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),

          /// CALL BUTTON (CALL FIRST NUMBER)
          Material(
            color: primaryRed.withValues(alpha: 0.1),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => makeCall(contact.numbers.first),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.call, color: primaryRed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
