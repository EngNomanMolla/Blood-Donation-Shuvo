import 'package:blood_donation/data/repositories/profile_repository.dart';

class Donor {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String location;
  final String imageUrl;
  final String phone;
  final String bloodGroup;
  final String? lastDonationDate;

  const Donor({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.location,
    required this.imageUrl,
    required this.phone,
    required this.bloodGroup,
    this.lastDonationDate,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    // Determine location string
    final locationMap = json['location'];
    String locStr = json['address'] ?? '';
    if (locationMap is Map) {
      locStr = locationMap['full'] ?? locationMap['display'] ?? json['address'] ?? '';
    }
    
    // Determine gender value
    final String genderVal = json['gender_label'] ?? json['gender'] ?? 'Male';

    // Parse real profile image from API, otherwise empty string (fallback to default icon)
    final rawAvatar = json['avatar'] ??
        json['avatar_url'] ??
        json['image'] ??
        json['profile_image'] ??
        json['photo'] ??
        (json['user'] is Map ? (json['user']['avatar'] ?? json['user']['image'] ?? json['user']['avatar_url']) : null);

    final String sanitizedImg = ProfileData.sanitizeAvatarUrl(rawAvatar) ?? '';

    // Extract last donation date if provided in list item
    final donorObj = json['donor'] is Map ? json['donor'] : null;
    final rawLastDonation = json['last_donation_date'] ??
        json['last_donation'] ??
        json['last_donation_at'] ??
        donorObj?['last_donation_date'] ??
        donorObj?['last_donation'];

    return Donor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: genderVal,
      location: locStr,
      imageUrl: sanitizedImg,
      phone: json['phone'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      lastDonationDate: rawLastDonation?.toString(),
    );
  }
}