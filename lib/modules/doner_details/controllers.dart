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
  ).obs;
}