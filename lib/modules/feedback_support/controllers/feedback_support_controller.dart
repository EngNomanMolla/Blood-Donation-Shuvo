import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackSupportController extends GetxController {
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

  void callSupport() {
    Get.snackbar(
      'Support',
      'Calling support team...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }

  void emailSupport() {
    Get.snackbar(
      'Support',
      'Opening email client...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
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
