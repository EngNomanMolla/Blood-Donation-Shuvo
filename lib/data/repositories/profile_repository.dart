import 'dart:convert';
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
  final String? avatar;
  final bool isAvailable;
  final int donationsCount;
  final int livesSavedCount;
  final String? status;
  final bool hasCompletedInitialRecharge;
  final double initialRechargeAmount;
  final String? initialRechargeStatus;
  final String? initialRechargeRejectReason;

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
    this.avatar,
    required this.isAvailable,
    required this.donationsCount,
    required this.livesSavedCount,
    this.status,
    required this.hasCompletedInitialRecharge,
    required this.initialRechargeAmount,
    this.initialRechargeStatus,
    this.initialRechargeRejectReason,
  });
}

class ProfileRepository {
  final ProfileProvider provider;

  ProfileRepository({required this.provider});

  Future<ProfileData?> getProfile() async {
    try {
      final response = await provider.getProfile();
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>;
        return ProfileData(
          isDonor: data['is_donor'] == true || data['is_donor'] == 1 || data['is_donor'] == '1' || data['is_donor'] == 'true',
          isVolunteer: data['is_volunteer'] == true || data['is_volunteer'] == 1 || data['is_volunteer'] == '1' || data['is_volunteer'] == 'true',
          name: data['name'] ?? '',
          phone: data['phone'],
          bloodGroup: data['blood_group'],
          gender: data['gender'],
          division: data['division'],
          district: data['district'],
          upazila: data['upazila'],
          email: data['email'],
          dateOfBirth: data['date_of_birth'] ?? data['dob'],
          avatar: data['avatar'],
          isAvailable: data['is_available'] == true || data['is_available'] == 1 || data['is_available'] == '1' || data['is_available'] == 'true',
          donationsCount: data['donations_count'] ?? 0,
          livesSavedCount: data['lives_saved_count'] ?? 0,
          status: data['status'],
          hasCompletedInitialRecharge: data['has_completed_initial_recharge'] == true || data['has_completed_initial_recharge'] == 1 || data['has_completed_initial_recharge'] == '1' || data['has_completed_initial_recharge'] == 'true',
          initialRechargeAmount: (data['initial_recharge_amount'] ?? 0).toDouble(),
          initialRechargeStatus: data['initial_recharge_status'],
          initialRechargeRejectReason: data['initial_recharge_reject_reason'],
        );
      }
    } catch (_) {}
    return null;
  }
}
