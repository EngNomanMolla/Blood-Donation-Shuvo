import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/emergency_contact_model.dart';

class EmergencyContactController extends GetxController {
  /// SAMPLE DATA
  List<EmergencyContact> get contacts => [
        EmergencyContact(
          title: "Hospital Emergency Number",
          icon: Icons.local_hospital,
          numbers: ["01924653778", "01924653665"],
        ),
        EmergencyContact(
          title: "Ambulance Number",
          icon: Icons.local_shipping,
          numbers: ["01924653778", "01924653665"],
        ),
        EmergencyContact(
          title: "Police Number",
          icon: Icons.local_police,
          numbers: ["01924653778", "01924653665"],
        ),
        EmergencyContact(
          title: "Fire Service Number",
          icon: Icons.fire_truck,
          numbers: ["01924653778", "01924653665"],
        ),
      ];
}