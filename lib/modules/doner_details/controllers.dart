import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/data/providers/wallet_provider.dart';
import 'package:blood_donation/data/repositories/donor_repository.dart';
import 'package:blood_donation/data/repositories/wallet_repository.dart';
import 'package:blood_donation/modules/doner_request/models/doner_list_model.dart';
import 'package:blood_donation/modules/doner_details/models/doner_details_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileController extends GetxController {
  final user = const UserProfile(
    name: 'Miraj Ahmed',
    email: 'Mirajahmed3540@Gmail.Com',
    bloodType: 'A+',
    donated: 0,
    liveSave: 0,
    imageUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
  ).obs;
 
  final donor = const DonorProfile(
    name: 'Emili Dash',
    age: 24,
    gender: 'Female',
    hospital: 'Dhaka Medical',
    location: 'Dhaka, Bangladesh',
    date: '24 Apr 2024',
    imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    phone: '',
  ).obs;

  final donorId = 0.obs;
  final isLoading = false.obs;
  final remainingMinutes = Rxn<int>();
  final isCheckingMinutes = false.obs;
  final hasActiveSubscription = false.obs;

  @override
  void onInit() {
    super.onInit();
    final Donor? argDonor = Get.arguments?['donor'];
    final int? passedId = Get.arguments?['id'] ?? Get.arguments?['donor_id'];
    if (passedId != null) {
      donorId.value = passedId;
    }
    if (argDonor != null) {
      donorId.value = argDonor.id;
      user.value = UserProfile(
        name: argDonor.name,
        email: '',
        bloodType: argDonor.bloodGroup,
        donated: 0,
        liveSave: 0,
        imageUrl: argDonor.imageUrl,
      );
      donor.value = DonorProfile(
        name: argDonor.name,
        age: argDonor.age,
        gender: argDonor.gender,
        hospital: '',
        location: argDonor.location,
        date: '',
        imageUrl: argDonor.imageUrl,
        phone: argDonor.phone,
      );
      fetchDonorDetails(argDonor.id);
    } else if (passedId != null) {
      fetchDonorDetails(passedId);
    }
    fetchCallerMinutes();
  }

  Future<void> fetchCallerMinutes() async {
    try {
      final WalletProvider walletProvider = Get.isRegistered<WalletProvider>()
          ? Get.find<WalletProvider>()
          : Get.put(WalletProvider());

      final WalletRepository walletRepository = Get.isRegistered<WalletRepository>()
          ? Get.find<WalletRepository>()
          : Get.put(WalletRepository(walletProvider));

      // 1. Try dedicated active subscription endpoint
      final subResponse = await walletRepository.getActiveSubscription();
      if (subResponse.statusCode == 200) {
        final subDecoded = jsonDecode(subResponse.body);
        if (subDecoded['has_active_subscription'] == true && subDecoded['active_subscription'] != null) {
          hasActiveSubscription.value = true;
          final activeSub = subDecoded['active_subscription'];
          remainingMinutes.value = activeSub['remaining_call_minutes'] ?? activeSub['current_minutes'] ?? activeSub['total_call_minutes'] ?? 0;
          return;
        }
      }

      // 2. Fallback to general wallet endpoint
      final response = await walletRepository.getWallet();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dynamic subData = decoded['subscription'];
        if (subData != null && subData is Map) {
          hasActiveSubscription.value = true;
          remainingMinutes.value = subData['call_minutes'] ?? subData['minutes'] ?? 0;
        } else if (decoded['call_minutes'] != null || decoded['subscription_ends_at'] != null) {
          hasActiveSubscription.value = true;
          remainingMinutes.value = decoded['call_minutes'] ?? 0;
        } else {
          hasActiveSubscription.value = false;
          remainingMinutes.value = 0;
        }
      }
    } catch (e) {
      debugPrint("Error fetching caller minutes: $e");
    }
  }

  Future<void> initiateDonorCall() async {
    isCheckingMinutes.value = true;
    try {
      // Re-fetch latest minutes from wallet
      await fetchCallerMinutes();

      final int minutes = remainingMinutes.value ?? 0;
      if (minutes <= 0) {
        _showInsufficientMinutesDialog();
      } else {
        _proceedWithAppCall(minutes);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to initiate call. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCheckingMinutes.value = false;
    }
  }

  Future<void> directPhoneCall() async {
    final phone = donor.value.phone.trim();
    if (phone.isEmpty) {
      Get.snackbar(
        'Phone Unavailable',
        'No direct phone number available for this donor.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open dialer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _showInsufficientMinutesDialog() {
    final donorPhone = donor.value.phone.trim();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEEF1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_disabled_rounded,
                  color: Color(0xFFE8194B),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Insufficient App Call Minutes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You have 0 App Call minutes remaining. You can recharge minutes or call directly using your mobile SIM card.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Option 1: Direct SIM Call Button
              if (donorPhone.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      directPhoneCall();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_forwarded_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Call via Phone SIM ($donorPhone)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Option 2: Recharge Minutes
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8194B),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.subscriptionPlans);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Recharge App Minutes',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedWithAppCall(int availableMinutes) {
    Get.toNamed(
      AppRoutes.call,
      arguments: {
        'recipient_id': donorId.value,
        'donor_name': donor.value.name,
        'donor_avatar': donor.value.imageUrl,
        'blood_group': user.value.bloodType,
        'available_minutes': availableMinutes,
      },
    );
  }

  Future<void> fetchDonorDetails(int id) async {
    isLoading.value = true;
    try {
      final donorRepository = Get.find<DonorRepository>();
      final details = await donorRepository.getDonorDetails(id);
      
      final String genderVal = details['gender_label'] ?? details['gender'] ?? 'Male';
      final String defaultImgUrl = genderVal.toLowerCase() == 'female'
          ? 'https://randomuser.me/api/portraits/women/${id % 100}.jpg'
          : 'https://randomuser.me/api/portraits/men/${id % 100}.jpg';

      final locationMap = details['location'];
      String locStr = details['address'] ?? '';
      if (locationMap is Map) {
        locStr = locationMap['full'] ?? locationMap['display'] ?? details['address'] ?? '';
      }

      String formattedDate = '';
      final createdAtStr = details['created_at'];
      if (createdAtStr != null) {
        try {
          final parsedDate = DateTime.parse(createdAtStr);
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          formattedDate = '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
        } catch (_) {
          formattedDate = createdAtStr.toString().split('T').first;
        }
      }

      user.value = UserProfile(
        name: details['name'] ?? '',
        email: details['email'] ?? '',
        bloodType: details['blood_group'] ?? '',
        donated: details['donations_count'] ?? 0,
        liveSave: details['lives_saved_count'] ?? 0,
        imageUrl: defaultImgUrl,
      );

      donor.value = DonorProfile(
        name: details['name'] ?? '',
        age: details['age'] ?? 0,
        gender: genderVal,
        hospital: details['address'] ?? '',
        location: locStr,
        date: formattedDate.isNotEmpty ? 'Registered: $formattedDate' : '',
        imageUrl: defaultImgUrl,
        phone: details['phone'] ?? '',
      );
    } catch (e) {
      Get.printError(info: "Error fetching donor details: $e");
    } finally {
      isLoading.value = false;
    }
  }
}