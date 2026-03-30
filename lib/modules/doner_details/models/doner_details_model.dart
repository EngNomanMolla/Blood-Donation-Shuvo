class UserProfile {
  final String name;
  final String email;
  final String bloodType;
  final int donated;
  final int liveSave;
  final String imageUrl;
 
  const UserProfile({
    required this.name,
    required this.email,
    required this.bloodType,
    required this.donated,
    required this.liveSave,
    required this.imageUrl,
  });
}
 
class DonorProfile {
  final String name;
  final int age;
  final String gender;
  final String hospital;
  final String location;
  final String date;
  final String imageUrl;
 
  const DonorProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.hospital,
    required this.location,
    required this.date,
    required this.imageUrl,
  });
}