import 'package:blood_donation/data/repositories/donor_repository.dart';
import 'package:blood_donation/modules/doner_request/models/doner_list_model.dart';
import 'package:blood_donation/modules/doner_details/models/doner_details_model.dart';
import 'package:get/get.dart';

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

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final Donor? argDonor = Get.arguments?['donor'];
    if (argDonor != null) {
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
    }
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