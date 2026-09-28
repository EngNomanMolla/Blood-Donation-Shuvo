import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackSupportController extends GetxController {
  static const String supportPhone = '01319528282';
  static const String supportEmail = 'bloodlonkbd74@gmail.com';

  // Mock data for reviews
  final reviews = [
    {
      'name': 'Sarah Johnson',
      'rating': 5.0,
      'comment': 'The app is so easy to use! I found a donor for my sister in just 10 minutes. Truly a life-saving platform.',
      'date': '2 days ago',
      'avatar': 'https://i.pravatar.cc/150?u=sarah',
    },
    {
      'name': 'Michael Chen',
      'rating': 4.5,
      'comment': 'Very smooth experience. The notification system is excellent. Would love to see more dark mode options.',
      'date': '1 week ago',
      'avatar': 'https://i.pravatar.cc/150?u=michael',
    },
    {
      'name': 'Amara Okafor',
      'rating': 5.0,
      'comment': 'I\'ve donated 3 times through this app. The community is amazing and the process is very transparent.',
      'date': '2 weeks ago',
      'avatar': 'https://i.pravatar.cc/150?u=amara',
    },
    {
      'name': 'David Wilson',
      'rating': 4.0,
      'comment': 'Great initiative. The emergency contact feature is a game-changer. Keep up the good work!',
      'date': '1 month ago',
      'avatar': 'https://i.pravatar.cc/150?u=david',
    },
  ].obs;

  final averageRating = 4.8.obs;
  final totalReviews = 1250.obs;

  Future<void> callSupport() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: supportPhone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching dialer for $supportPhone: $e");
      Get.snackbar(
        'Call Support',
        'Helpline: $supportPhone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> emailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'Blood Donation App Support',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching email client for $supportEmail: $e");
      Get.snackbar(
        'Email Support',
        'Support Email: $supportEmail',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void startLiveChat() {
    Get.snackbar(
      'Support',
      'Connecting to live chat agent...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE70349).withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }
}
