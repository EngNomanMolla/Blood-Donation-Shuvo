import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../providers/profile_provider.dart';

class ProfileData {
  final bool isDonor;
  final bool isVolunteer;
  final String name;
  final String? phone;
  final String? bloodGroup;
  final String? gender;
  final String? division;
  final String? district;
  final String? upazila;
  final String? email;
  final String? dateOfBirth;
  final String? lastDonationDate;
  final String? avatar;
  final bool isAvailable;
  final int donationsCount;
  final int livesSavedCount;
  final String? status;
  final bool hasCompletedInitialRecharge;
  final double initialRechargeAmount;
  final String? initialRechargeStatus;
  final String? initialRechargeRejectReason;
  final String? volunteerPaymentStatus;

  ProfileData({
    required this.isDonor,
    required this.isVolunteer,
    required this.name,
    this.phone,
    this.bloodGroup,
    this.gender,
    this.division,
    this.district,
    this.upazila,
    this.email,
    this.dateOfBirth,
    this.lastDonationDate,
    this.avatar,
    required this.isAvailable,
    required this.donationsCount,
    required this.livesSavedCount,
    this.status,
    required this.hasCompletedInitialRecharge,
    required this.initialRechargeAmount,
    this.initialRechargeStatus,
    this.initialRechargeRejectReason,
    this.volunteerPaymentStatus,
  });

  static String? sanitizeAvatarUrl(dynamic raw) {
    if (raw == null) return null;
    String url = raw.toString().trim();
    if (url.isEmpty || url == 'null') return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    const base = 'http://www.bloodlinkonline.xyz';
    if (url.startsWith('/')) {
      return '$base$url';
    }
    if (url.startsWith('storage/')) {
      return '$base/$url';
    }
    return '$base/storage/$url';
  }
}

class ProfileRepository {
  final ProfileProvider provider;

  ProfileRepository({required this.provider});

  Future<ProfileData?> getProfile() async {
    try {
      final response = await provider.getProfile();
      debugPrint("getProfile response [${response.statusCode}]: ${response.body}");
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = (body['data'] is Map<String, dynamic>)
            ? body['data'] as Map<String, dynamic>
            : (body is Map<String, dynamic> ? body : <String, dynamic>{});

        final donorObj = (data['donor'] is Map<String, dynamic>) ? data['donor'] as Map<String, dynamic> : null;
        final donorInfoObj = (data['donor_info'] is Map<String, dynamic>) ? data['donor_info'] as Map<String, dynamic> : null;
        final donorProfileObj = (data['donor_profile'] is Map<String, dynamic>) ? data['donor_profile'] as Map<String, dynamic> : null;
        final userObj = (data['user'] is Map<String, dynamic>) ? data['user'] as Map<String, dynamic> : null;

        final rawAvatar = data['avatar'] ?? data['avatar_url'] ?? data['image'] ?? data['profile_image'] ?? data['photo'] ?? userObj?['avatar'];
        final sanitizedAvatar = ProfileData.sanitizeAvatarUrl(rawAvatar);

        final lastDonation = data['last_donation_date'] ??
            data['last_date_donated'] ??
            data['last_donated_at'] ??
            data['last_donation'] ??
            data['last_donated_date'] ??
            data['last_donate_date'] ??
            data['last_donate'] ??
            data['last_donation_at'] ??
            donorObj?['last_donation_date'] ??
            donorObj?['last_date_donated'] ??
            donorObj?['last_donated_at'] ??
            donorObj?['last_donation'] ??
            donorObj?['last_donated_date'] ??
            donorObj?['last_donate_date'] ??
            donorObj?['last_donation_at'] ??
            donorInfoObj?['last_donation_date'] ??
            donorInfoObj?['last_date_donated'] ??
            donorInfoObj?['last_donated_at'] ??
            donorInfoObj?['last_donation'] ??
            donorProfileObj?['last_donation_date'] ??
            donorProfileObj?['last_date_donated'] ??
            donorProfileObj?['last_donated_at'] ??
            userObj?['last_donation_date'] ??
            userObj?['last_date_donated'] ??
            userObj?['last_donated_at'];

        final bloodGroup = data['blood_group'] ?? donorObj?['blood_group'] ?? donorInfoObj?['blood_group'] ?? donorProfileObj?['blood_group'] ?? userObj?['blood_group'];
        final gender = data['gender'] ?? userObj?['gender'] ?? donorObj?['gender'] ?? donorInfoObj?['gender'] ?? donorProfileObj?['gender'];
        final rawDonations = data['donations_count'] ??
            data['total_times_donated'] ??
            data['total_time_donated'] ??
            data['total_donations'] ??
            donorObj?['donations_count'] ??
            donorObj?['total_times_donated'] ??
            donorInfoObj?['donations_count'] ??
            donorProfileObj?['donations_count'] ??
            userObj?['donations_count'] ??
            0;
        final donationsCount = int.tryParse(rawDonations.toString()) ?? 0;

        return ProfileData(
          isDonor: data['is_donor'] == true || data['is_donor'] == 1 || data['is_donor'] == '1' || data['is_donor'] == 'true' || donorObj != null,
          isVolunteer: data['is_volunteer'] == true || data['is_volunteer'] == 1 || data['is_volunteer'] == '1' || data['is_volunteer'] == 'true',
          name: data['name'] ?? '',
          phone: data['phone'],
          bloodGroup: bloodGroup?.toString(),
          gender: gender?.toString(),
          division: data['division']?.toString(),
          district: data['district']?.toString(),
          upazila: data['upazila']?.toString(),
          email: data['email']?.toString(),
          dateOfBirth: (data['date_of_birth'] ?? data['dob'])?.toString(),
          lastDonationDate: lastDonation?.toString(),
          avatar: sanitizedAvatar,
          isAvailable: data['is_available'] == true || data['is_available'] == 1 || data['is_available'] == '1' || data['is_available'] == 'true' || donorObj?['is_available'] == true || donorObj?['is_available'] == 1,
          donationsCount: donationsCount,
          livesSavedCount: int.tryParse((data['lives_saved_count'] ?? 0).toString()) ?? 0,
          status: data['status']?.toString(),
          hasCompletedInitialRecharge: data['has_completed_initial_recharge'] == true || data['has_completed_initial_recharge'] == 1 || data['has_completed_initial_recharge'] == '1' || data['has_completed_initial_recharge'] == 'true',
          initialRechargeAmount: double.tryParse((data['initial_recharge_amount'] ?? 0).toString()) ?? 0.0,
          initialRechargeStatus: data['initial_recharge_status']?.toString(),
          initialRechargeRejectReason: data['initial_recharge_reject_reason']?.toString(),
          volunteerPaymentStatus: data['volunteer_payment_status']?.toString(),
        );
      }
    } catch (e) {
      debugPrint("Error parsing profile in getProfile: $e");
    }
    return null;
  }

  Future<http.Response> updateProfile(Map<String, dynamic> body) async {
    return await provider.updateProfile(body);
  }

  Future<http.Response> updateProfileImage(String imagePath) async {
    return await provider.updateProfileImage(imagePath);
  }

  Future<http.Response> deleteVolunteerAccount() async {
    return await provider.deleteVolunteerAccount();
  }
}
