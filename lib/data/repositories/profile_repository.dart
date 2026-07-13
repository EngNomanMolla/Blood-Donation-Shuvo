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
          isDonor: data['is_donor'] == true,
          isVolunteer: data['is_volunteer'] == true,
          name: data['name'] ?? '',
          phone: data['phone'],
          bloodGroup: data['blood_group'],
          gender: data['gender'],
          division: data['division'],
          district: data['district'],
          upazila: data['upazila'],
        );
      }
    } catch (_) {}
    return null;
  }
}
