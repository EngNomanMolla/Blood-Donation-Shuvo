import 'package:blood_donation/modules/doner_request/models/doner_list_model.dart';
import 'package:get/get.dart';

class DonateController extends GetxController {
  final searchQuery = ''.obs;
  final selectedDistrict = 'District'.obs;
  final selectedUpazila = 'Upazila'.obs;
  final selectedThana = 'Thana'.obs;
 
  final donors = <Donor>[
    Donor(
      name: 'Emili Dash',
      age: 24,
      gender: 'Female',
      location: 'Dhaka, Bangladesh',
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Donor(
      name: 'Emili Dash',
      age: 24,
      gender: 'Female',
      location: 'Dhaka, Bangladesh',
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    Donor(
      name: 'Emili Dash',
      age: 24,
      gender: 'Female',
      location: 'Dhaka, Bangladesh',
      imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
    ),
    Donor(
      name: 'Emili Dash',
      age: 24,
      gender: 'Female',
      location: 'Dhaka, Bangladesh',
      imageUrl: 'https://randomuser.me/api/portraits/women/21.jpg',
    ),
    Donor(
      name: 'Emili Dash',
      age: 24,
      gender: 'Female',
      location: 'Dhaka, Bangladesh',
      imageUrl: 'https://randomuser.me/api/portraits/women/55.jpg',
    ),
    Donor(
      name: 'Emili Dash',
      age: 24,
      gender: 'Female',
      location: 'Dhaka, Bangladesh',
      imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    ),
  ].obs;
 
  List<Donor> get filteredDonors {
    if (searchQuery.isEmpty) return donors;
    return donors
        .where((d) =>
            d.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            d.location.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }
}