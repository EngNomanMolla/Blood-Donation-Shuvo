class Donor {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String location;
  final String imageUrl;
  final String phone;
  final String bloodGroup;

  const Donor({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.location,
    required this.imageUrl,
    required this.phone,
    required this.bloodGroup,
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

    // Generate/get profile image (API has no avatar key in provided JSON, use randomuser.me mock avatar)
    final int id = json['id'] ?? 0;
    final String defaultImgUrl = genderVal.toLowerCase() == 'female'
        ? 'https://randomuser.me/api/portraits/women/${id % 100}.jpg'
        : 'https://randomuser.me/api/portraits/men/${id % 100}.jpg';

    return Donor(
      id: id,
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: genderVal,
      location: locStr,
      imageUrl: defaultImgUrl,
      phone: json['phone'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
    );
  }
}